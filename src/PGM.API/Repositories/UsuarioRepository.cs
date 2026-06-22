using Dapper;
using PGM.API.Models;

namespace PGM.API.Repositories;

public class UsuarioRepository(DbConnectionFactory db) : IUsuarioRepository
{
    // SG_USUARIOS_BD.CLAVE = SHA-1 hex del password (40 chars, sin trailing spaces)
    public async Task<Usuario?> ValidarCredenciales(string codigoUsuario, string passwordHash)
    {
        using var conn = db.Create();
        const string sql = """
            SELECT
                RTRIM(u.CODIGO_USUARIO_BD)  AS CodigoUsuario,
                RTRIM(u.CODIGO_GRUPO_BD)    AS CodigoGrupo,
                ISNULL(u.DESCRIPCION_USUARIO_BD, '') AS Descripcion,
                ISNULL(RTRIM(u.IDENTIFICADOR), '')   AS Identificador,
                u.DIRECCION_IP                       AS DireccionIp,
                u.FECHA_CADUCACION_USUARIO_BD        AS FechaCaducacion,
                u.IdArea
            FROM SG_USUARIOS_BD u
            WHERE RTRIM(u.CODIGO_USUARIO_BD) = @Usuario
              AND RTRIM(u.CLAVE)             = @PasswordHash
              AND (u.FECHA_CADUCACION_USUARIO_BD IS NULL
                   OR u.FECHA_CADUCACION_USUARIO_BD > GETDATE())
            """;

        return await conn.QueryFirstOrDefaultAsync<Usuario>(sql, new
        {
            Usuario     = codigoUsuario.ToUpper(),
            PasswordHash = passwordHash.ToLower()
        });
    }

    public async Task<List<string>> ObtenerPermisosProcesos(string codigoUsuario)
    {
        using var conn = db.Create();
        const string sql = """
            SELECT DISTINCT RTRIM(CODIGO)
            FROM SG_USUARIOS_PROCESOS_BD
            WHERE RTRIM(CODIGO_USUARIO_BD) = @Usuario
            """;

        var result = await conn.QueryAsync<string>(sql, new { Usuario = codigoUsuario });
        return result.ToList();
    }
}
