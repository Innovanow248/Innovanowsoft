using SAF.API.Models;

namespace SAF.API.Repositories;

public interface IAreasRepository
{
    Task<List<Area>> Listar();
}
