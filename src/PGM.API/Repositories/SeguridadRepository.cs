using Dapper;
using PGM.API.Models;

namespace PGM.API.Repositories;

public class SeguridadRepository(DbConnectionFactory db) : ISeguridadRepository
{
    public async Task<List<UsuarioAdmin>> ListarUsuarios(string? busqueda)
    {
        using var conn = db.Create();
        var where = string.IsNullOrWhiteSpace(busqueda) ? "" :
            "WHERE RTRIM(u.CODIGO_USUARIO_BD) LIKE @B OR RTRIM(u.DESCRIPCION_USUARIO_BD) LIKE @B OR RTRIM(u.CODIGO_GRUPO_BD) LIKE @B";
        var usuarios = (await conn.QueryAsync<UsuarioAdmin>($"""
            SELECT
                RTRIM(u.CODIGO_USUARIO_BD)               AS CodigoUsuario,
                ISNULL(RTRIM(u.CODIGO_GRUPO_BD),'')      AS CodigoGrupo,
                ISNULL(u.DESCRIPCION_USUARIO_BD,'')      AS Descripcion,
                ISNULL(RTRIM(u.IDENTIFICADOR),'')        AS Identificador,
                u.FECHA_CADUCACION_USUARIO_BD            AS FechaCaducacion,
                u.IdArea
            FROM SG_USUARIOS_BD u
            {where}
            ORDER BY u.CODIGO_USUARIO_BD
            """, new { B = $"%{busqueda}%" })).ToList();

        // Cargar permisos de cada usuario en una sola query
        var codigos = usuarios.Select(u => u.CodigoUsuario).ToList();
        if (codigos.Count > 0)
        {
            var permisos = await conn.QueryAsync<(string Usuario, string Proceso)>("""
                SELECT RTRIM(CODIGO_USUARIO_BD) AS Usuario, RTRIM(CODIGO) AS Proceso
                FROM SG_USUARIOS_PROCESOS_BD
                WHERE RTRIM(CODIGO_USUARIO_BD) IN @Codigos
                """, new { Codigos = codigos });
            var dict = permisos.GroupBy(p => p.Usuario)
                               .ToDictionary(g => g.Key, g => g.Select(p => p.Proceso).ToList());
            foreach (var u in usuarios)
                u.Permisos = dict.TryGetValue(u.CodigoUsuario, out var p) ? p : [];
        }
        return usuarios;
    }

    public async Task<UsuarioAdmin?> ObtenerUsuario(string codigo)
    {
        using var conn = db.Create();
        var u = await conn.QueryFirstOrDefaultAsync<UsuarioAdmin>("""
            SELECT
                RTRIM(CODIGO_USUARIO_BD)              AS CodigoUsuario,
                ISNULL(RTRIM(CODIGO_GRUPO_BD),'')     AS CodigoGrupo,
                ISNULL(DESCRIPCION_USUARIO_BD,'')     AS Descripcion,
                ISNULL(RTRIM(IDENTIFICADOR),'')       AS Identificador,
                FECHA_CADUCACION_USUARIO_BD           AS FechaCaducacion,
                IdArea
            FROM SG_USUARIOS_BD
            WHERE RTRIM(CODIGO_USUARIO_BD) = @Codigo
            """, new { Codigo = codigo.ToUpper() });
        if (u is null) return null;

        var permisos = await conn.QueryAsync<string>("""
            SELECT DISTINCT RTRIM(CODIGO)
            FROM SG_USUARIOS_PROCESOS_BD
            WHERE RTRIM(CODIGO_USUARIO_BD) = @Codigo
            ORDER BY 1
            """, new { Codigo = codigo.ToUpper() });
        u.Permisos = permisos.ToList();
        return u;
    }

    public async Task CrearUsuario(CrearUsuarioRequest req, string passwordHash)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            INSERT INTO SG_USUARIOS_BD
                (CODIGO_USUARIO_BD, CLAVE, CODIGO_GRUPO_BD, DESCRIPCION_USUARIO_BD,
                 IDENTIFICADOR, FECHA_CADUCACION_USUARIO_BD)
            VALUES
                (@Codigo, @Clave, @Grupo, @Desc, @Ident, @Caducacion)
            """, new {
                Codigo    = req.CodigoUsuario.ToUpper().PadRight(15),
                Clave     = passwordHash.ToLower(),
                Grupo     = (req.CodigoGrupo ?? "").PadRight(20),
                Desc      = req.Descripcion,
                Ident     = string.IsNullOrWhiteSpace(req.Identificador) ? null : req.Identificador,
                Caducacion = req.FechaCaducacion,
            });

        await GuardarPermisos(conn, req.CodigoUsuario.ToUpper(), req.Permisos);
    }

    public async Task ActualizarUsuario(string codigo, ActualizarUsuarioRequest req)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE SG_USUARIOS_BD SET
                CODIGO_GRUPO_BD            = @Grupo,
                DESCRIPCION_USUARIO_BD     = @Desc,
                IDENTIFICADOR              = @Ident,
                FECHA_CADUCACION_USUARIO_BD = @Caducacion
            WHERE RTRIM(CODIGO_USUARIO_BD) = @Codigo
            """, new {
                Codigo    = codigo.ToUpper(),
                Grupo     = (req.CodigoGrupo ?? "").PadRight(20),
                Desc      = req.Descripcion,
                Ident     = string.IsNullOrWhiteSpace(req.Identificador) ? null : req.Identificador,
                Caducacion = req.FechaCaducacion,
            });

        await GuardarPermisos(conn, codigo.ToUpper(), req.Permisos);
    }

    public async Task CambiarPassword(string codigo, string passwordHash)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE SG_USUARIOS_BD SET CLAVE = @Clave
            WHERE RTRIM(CODIGO_USUARIO_BD) = @Codigo
            """, new { Codigo = codigo.ToUpper(), Clave = passwordHash.ToLower() });
    }

    public async Task EliminarUsuario(string codigo)
    {
        using var conn = db.Create();
        // Eliminar permisos primero, luego el usuario
        await conn.ExecuteAsync("""
            DELETE FROM SG_USUARIOS_PROCESOS_BD WHERE RTRIM(CODIGO_USUARIO_BD) = @Codigo;
            DELETE FROM SG_USUARIOS_BD           WHERE RTRIM(CODIGO_USUARIO_BD) = @Codigo;
            """, new { Codigo = codigo.ToUpper() });
    }

    public async Task<List<GrupoItem>> ListarGrupos()
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<GrupoItem>("""
            SELECT
                RTRIM(CODIGO_GRUPO_BD)  AS Codigo,
                COUNT(*)               AS TotalUsuarios
            FROM SG_USUARIOS_BD
            WHERE CODIGO_GRUPO_BD IS NOT NULL AND RTRIM(CODIGO_GRUPO_BD) <> ''
            GROUP BY RTRIM(CODIGO_GRUPO_BD)
            ORDER BY 1
            """);
        return result.ToList();
    }

    public async Task<List<string>> ListarProcesos()
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<string>("""
            SELECT DISTINCT RTRIM(CODIGO) FROM SG_USUARIOS_PROCESOS_BD
            ORDER BY 1
            """);
        return result.ToList();
    }

    // ── helpers ────────────────────────────────────────────────────────────────

    private static async Task GuardarPermisos(
        System.Data.IDbConnection conn, string codigoUsuario, List<string> permisos)
    {
        await conn.ExecuteAsync("""
            DELETE FROM SG_USUARIOS_PROCESOS_BD
            WHERE RTRIM(CODIGO_USUARIO_BD) = @Usuario
            """, new { Usuario = codigoUsuario });

        if (permisos.Count == 0) return;

        foreach (var p in permisos.Distinct())
            await conn.ExecuteAsync("""
                INSERT INTO SG_USUARIOS_PROCESOS_BD (CODIGO_USUARIO_BD, CODIGO)
                VALUES (@Usuario, @Codigo)
                """, new { Usuario = codigoUsuario.PadRight(15), Codigo = p.PadRight(50) });
    }
}
