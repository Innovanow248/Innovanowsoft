using Microsoft.Data.SqlClient;

namespace PGM.API.Repositories;

public class DbConnectionFactory(string connectionString)
{
    public SqlConnection Create() => new(connectionString);
}
