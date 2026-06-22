namespace PGM.API.Models;

public class PortalLoginRequest
{
    public string Identificador { get; set; } = "";
    public string Password      { get; set; } = "";
}

public class PortalLoginResponse
{
    public string Token         { get; set; } = "";
    public string Identificador { get; set; } = "";
    public string Nombre        { get; set; } = "";
    public string Apellido      { get; set; } = "";
}

public class PortalPagoRequest
{
    public string NroInterno { get; set; } = "";
    public string FechaPago  { get; set; } = "";
}
