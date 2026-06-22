using Dapper;
using SAF.API.Models;

namespace SAF.API.Repositories;

public class ProveedoresRepository(DbConnectionFactory db) : IProveedoresRepository
{
    public async Task<List<Proveedor>> Buscar(string termino)
    {
        using var conn = db.Create();
        const string sql = """
            SELECT TOP 50
                RTRIM(p.IDENTIFICADOR)    AS Identificador,
                RTRIM(p.NOMBRE)           AS Nombre,
                RTRIM(p.APELLIDO)         AS Apellido,
                RTRIM(p.CUIT_CUIL)        AS CuitCuil,
                RTRIM(cp.E_MAIL)          AS Email,
                RTRIM(cp.TELEFONO)        AS Telefono,
                RTRIM(cp.TIPO_SOCIEDAD)   AS TipoSociedad,
                cp.FECHA_ALTA             AS FechaAlta,
                cp.FECHA_BAJA             AS FechaBaja,
                RTRIM(cp.NRO_REGISTRO_MUNI) AS NroRegistro
            FROM PERSONAS p
            INNER JOIN CO_PROVEEDORES cp ON RTRIM(cp.IDENTIFICADOR) = RTRIM(p.IDENTIFICADOR)
            WHERE cp.FECHA_BAJA IS NULL
              AND (RTRIM(p.CUIT_CUIL)  LIKE @Termino
                OR RTRIM(p.APELLIDO)   LIKE @Termino
                OR RTRIM(p.NOMBRE)     LIKE @Termino
                OR RTRIM(p.DOCUMENTO) LIKE @Termino)
            ORDER BY p.APELLIDO, p.NOMBRE
            """;

        var result = await conn.QueryAsync<Proveedor>(sql, new { Termino = $"%{termino}%" });
        return result.ToList();
    }

    public async Task<Proveedor?> ObtenerPorId(string identificador)
    {
        using var conn = db.Create();
        const string sql = """
            SELECT
                RTRIM(p.IDENTIFICADOR)    AS Identificador,
                RTRIM(p.NOMBRE)           AS Nombre,
                RTRIM(p.APELLIDO)         AS Apellido,
                RTRIM(p.CUIT_CUIL)        AS CuitCuil,
                RTRIM(cp.E_MAIL)          AS Email,
                RTRIM(cp.TELEFONO)        AS Telefono,
                RTRIM(cp.TIPO_SOCIEDAD)   AS TipoSociedad,
                cp.FECHA_ALTA             AS FechaAlta,
                cp.FECHA_BAJA             AS FechaBaja,
                RTRIM(cp.NRO_REGISTRO_MUNI) AS NroRegistro
            FROM PERSONAS p
            INNER JOIN CO_PROVEEDORES cp ON RTRIM(cp.IDENTIFICADOR) = RTRIM(p.IDENTIFICADOR)
            WHERE RTRIM(p.IDENTIFICADOR) = @Id
            """;

        return await conn.QueryFirstOrDefaultAsync<Proveedor>(sql, new { Id = identificador });
    }
}
