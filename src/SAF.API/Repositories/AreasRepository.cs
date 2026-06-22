using Dapper;
using SAF.API.Models;

namespace SAF.API.Repositories;

public class AreasRepository(DbConnectionFactory db) : IAreasRepository
{
    public async Task<List<Area>> Listar()
    {
        using var conn = db.Create();
        var result = await conn.QueryAsync<Area>("""
            SELECT IdArea, RTRIM(Codigo) AS Codigo,
                   RTRIM(Descripcion)   AS Descripcion,
                   IdAreaSuperior
            FROM AREAS
            WHERE IdArea >= 117
            ORDER BY Codigo
            """);
        return result.ToList();
    }
}
