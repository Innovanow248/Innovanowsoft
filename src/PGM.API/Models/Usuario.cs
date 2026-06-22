namespace PGM.API.Models;

public class Usuario
{
    public string CodigoUsuario  { get; set; } = "";
    public string CodigoGrupo   { get; set; } = "";
    public string Descripcion   { get; set; } = "";
    public string Identificador { get; set; } = "";
    public string? DireccionIp  { get; set; }
    public DateTime? FechaCaducacion { get; set; }
    public int? IdArea          { get; set; }
}

public class LoginRequest
{
    public string Usuario  { get; set; } = "";
    public string Password { get; set; } = "";
}

public class LoginResponse
{
    public string Token          { get; set; } = "";
    public string Usuario        { get; set; } = "";
    public string Grupo          { get; set; } = "";
    public string Identificador  { get; set; } = "";
    public List<string> Permisos { get; set; } = [];
}
