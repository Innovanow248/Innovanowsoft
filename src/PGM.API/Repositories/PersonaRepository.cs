using Dapper;
using PGM.API.Models;

namespace PGM.API.Repositories;

public class PersonaRepository(DbConnectionFactory db) : IPersonaRepository
{
    private const string SelectBase = """
        SELECT
            RTRIM(IDENTIFICADOR)         AS Identificador,
            RTRIM(TIPO_DOCUMENTO)        AS TipoDocumento,
            RTRIM(DOCUMENTO)             AS Documento,
            RTRIM(ISNULL(APELLIDO,''))   AS Apellido,
            RTRIM(ISNULL(NOMBRE,''))     AS Nombre,
            RTRIM(ISNULL(CUIT_CUIL,''))  AS CuitCuil,
            RTRIM(ISNULL(SEXO,''))       AS Sexo,
            FECHA_NACIMIENTO             AS FechaNacimiento,
            RTRIM(ISNULL(CALLE_NOCOD,''))       AS CalleNocod,
            RTRIM(ISNULL(NUMERACION_CALLE,''))  AS NumeracionCalle,
            RTRIM(ISNULL(PISO,''))              AS Piso,
            RTRIM(ISNULL(DEPARTAMENTO,''))      AS Departamento,
            RTRIM(ISNULL(BARRIO,''))            AS Barrio,
            RTRIM(ISNULL(CODIGO_POSTAL_AUXILIAR,'')) AS CodigoPostalAuxiliar,
            RTRIM(ISNULL(CODIGO_PROVINCIA,''))  AS CodigoProvincia,
            RTRIM(ISNULL(PAIS,''))              AS Pais,
            RTRIM(ISNULL(TELEFONO,''))          AS Telefono,
            RTRIM(ISNULL(TELEFONO_MOVIL,''))    AS TelefonoMovil,
            RTRIM(ISNULL(E_MAIL,''))            AS Email,
            RTRIM(ISNULL(CALLE_NOCOD,'')) +
              CASE WHEN RTRIM(ISNULL(NUMERACION_CALLE,'')) != ''
                   THEN ' ' + RTRIM(NUMERACION_CALLE) ELSE '' END AS Domicilio,
            RTRIM(ISNULL(BARRIO,''))            AS Localidad
        FROM PERSONAS
        """;

    public async Task<Persona?> BuscarPorCuit(string cuitCuil)
    {
        using var conn = db.Create();
        return await conn.QueryFirstOrDefaultAsync<Persona>(
            SelectBase + " WHERE RTRIM(CUIT_CUIL) = @CuitCuil",
            new { CuitCuil = cuitCuil.Replace("-", "") });
    }

    public async Task<Persona?> BuscarPorDocumento(string documento)
    {
        using var conn = db.Create();
        return await conn.QueryFirstOrDefaultAsync<Persona>(
            SelectBase + " WHERE RTRIM(DOCUMENTO) = @Documento",
            new { Documento = documento });
    }

    public async Task<List<Persona>> BuscarPorApellido(string apellido, string? tipoBien = null)
    {
        using var conn = db.Create();
        var whereExtra = string.IsNullOrWhiteSpace(tipoBien)
            ? ""
            : " AND RTRIM(IDENTIFICADOR) IN (SELECT RTRIM(IDENTIFICADOR) FROM RT_PADRON_BASE WHERE RTRIM(TIPO_BIEN) = @TipoBien)";
        var result = await conn.QueryAsync<Persona>(
            SelectBase + $" WHERE APELLIDO LIKE @Apellido{whereExtra} ORDER BY APELLIDO, NOMBRE",
            new { Apellido = apellido.ToUpper() + "%", TipoBien = tipoBien?.ToUpper() });
        return result.ToList();
    }

    public async Task<Persona?> ObtenerPorId(string identificador)
    {
        using var conn = db.Create();
        return await conn.QueryFirstOrDefaultAsync<Persona>(
            SelectBase + " WHERE RTRIM(IDENTIFICADOR) = @Id",
            new { Id = identificador });
    }

    public async Task<string> CrearPersona(Persona p)
    {
        using var conn = db.Create();

        // Obtener próximo IDENTIFICADOR incrementando el contador
        var nuevoId = await conn.QuerySingleAsync<string>("""
            DECLARE @contador INT, @nuevo CHAR(5)
            UPDATE GEN_CONTADOR
            SET @contador = CONTADOR = CONTADOR + 1
            WHERE TIPO_CONTADOR = 'ID_PERSONA'
            SET @nuevo = dbo.fn_IntToBase36(@contador)
            SELECT @nuevo
            """);

        await conn.ExecuteAsync("""
            INSERT INTO PERSONAS (
                IDENTIFICADOR, TIPO_DOCUMENTO, DOCUMENTO,
                APELLIDO, NOMBRE, APELLIDO_NOMBRE, CUIT_CUIL, SEXO,
                FECHA_NACIMIENTO, CALLE_NOCOD, NUMERACION_CALLE,
                PISO, DEPARTAMENTO, BARRIO,
                CODIGO_POSTAL_AUXILIAR, CODIGO_PROVINCIA, PAIS,
                TELEFONO, TELEFONO_MOVIL, E_MAIL,
                CODIGO_POSTAL_SUFIJO, FECHA_AC
            ) VALUES (
                @Identificador, @TipoDocumento, @Documento,
                @Apellido, @Nombre, @ApellidoNombre, @CuitCuil, @Sexo,
                @FechaNacimiento, @CalleNocod, @NumeracionCalle,
                @Piso, @Departamento, @Barrio,
                @CodigoPostalAuxiliar, @CodigoProvincia, @Pais,
                @Telefono, @TelefonoMovil, @Email,
                '', GETDATE()
            )
            """, new
        {
            Identificador        = nuevoId,
            TipoDocumento        = (p.TipoDocumento + "               ")[..15],
            Documento            = (p.Documento + "           ")[..11],
            Apellido             = p.Apellido?.ToUpper(),
            Nombre               = p.Nombre?.ToUpper(),
            ApellidoNombre       = $"{p.Apellido?.ToUpper(),-30}{p.Nombre?.ToUpper()}",
            CuitCuil             = p.CuitCuil,
            Sexo                 = p.Sexo,
            FechaNacimiento      = p.FechaNacimiento,
            CalleNocod           = p.CalleNocod?.ToUpper(),
            NumeracionCalle      = (p.NumeracionCalle + "     ")[..5],
            Piso                 = (p.Piso + "    ")[..4],
            Departamento         = (p.Departamento + "    ")[..4],
            Barrio               = p.Barrio?.ToUpper(),
            CodigoPostalAuxiliar = p.CodigoPostalAuxiliar,
            CodigoProvincia      = (p.CodigoProvincia + "               ")[..15],
            Pais                 = p.Pais ?? "ARGE",
            Telefono             = p.Telefono,
            TelefonoMovil        = p.TelefonoMovil,
            Email                = p.Email
        });

        return nuevoId;
    }

    public async Task ActualizarPersona(Persona p)
    {
        using var conn = db.Create();
        await conn.ExecuteAsync("""
            UPDATE PERSONAS SET
                CALLE_NOCOD          = @CalleNocod,
                NUMERACION_CALLE     = @NumeracionCalle,
                PISO                 = @Piso,
                DEPARTAMENTO         = @Departamento,
                BARRIO               = @Barrio,
                CODIGO_POSTAL_AUXILIAR = @CodigoPostalAuxiliar,
                TELEFONO             = @Telefono,
                TELEFONO_MOVIL       = @TelefonoMovil,
                E_MAIL               = @Email,
                FECHA_AC             = GETDATE()
            WHERE RTRIM(IDENTIFICADOR) = @Identificador
            """, new
        {
            p.Identificador, p.CalleNocod, p.NumeracionCalle,
            p.Piso, p.Departamento, p.Barrio,
            p.CodigoPostalAuxiliar, p.Telefono, p.TelefonoMovil, p.Email
        });
    }
}
