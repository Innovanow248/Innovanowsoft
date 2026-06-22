namespace SAF.API.Models;

public record LoginRequest(string Usuario, string Password);

public class LoginResponse
{
    public string Token         { get; set; } = "";
    public string Usuario       { get; set; } = "";
    public string Grupo         { get; set; } = "";
    public string Identificador { get; set; } = "";
    public List<string> Permisos { get; set; } = [];
}

public class UsuarioSAF
{
    public string CodigoUsuario  { get; set; } = "";
    public string CodigoGrupo   { get; set; } = "";
    public string Identificador { get; set; } = "";
}
