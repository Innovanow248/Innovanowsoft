using Oracle.ManagedDataAccess.Client;

namespace PGM.API;

public class OracleConnectionFactory(IConfiguration cfg)
{
    public OracleConnection Create()
    {
        var cs = cfg.GetConnectionString("OracleConnection")
            ?? throw new InvalidOperationException("OracleConnection not configured.");
        return new OracleConnection(cs);
    }
}
