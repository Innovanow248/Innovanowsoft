using Microsoft.Data.SqlClient;

namespace SAF.API.Repositories;

public class DbConnectionFactory(string connectionString)
{
    public SqlConnection Create() => new(connectionString);
}
