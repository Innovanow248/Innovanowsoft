using Dapper;
using SAF.API.Models;

namespace SAF.API.Repositories;

public class UsuarioRepository(DbConnectionFactory db) : IUsuarioRepository
{
    public async Task<UsuarioSAF?> ValidarCredenciales(string codigoUsuario, string passwordHash)
    {
        using var conn = db.Create();
        const string sql = """
            SELECT
                RTRIM(u.CODIGO_USUARIO_BD)        AS CodigoUsuario,
                RTRIM(u.CODIGO_GRUPO_BD)           AS CodigoGrupo,
                ISNULL(RTRIM(u.IDENTIFICADOR), '') AS Identificador
            FROM SG_USUARIOS_BD u
            WHERE RTRIM(u.CODIGO_USUARIO_BD) = @Usuario
              AND RTRIM(u.CLAVE)             = @PasswordHash
              AND (u.FECHA_CADUCACION_USUARIO_BD IS NULL
                   OR u.FECHA_CADUCACION_USUARIO_BD > GETDATE())
            """;

        return await conn.QueryFirstOrDefaultAsync<UsuarioSAF>(sql, new
        {
            Usuario      = codigoUsuario.ToUpper(),
            PasswordHash = passwordHash
        });
    }

    public async Task<List<string>> ObtenerPermisos(string codigoUsuario)
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
