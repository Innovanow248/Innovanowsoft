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

// ── Seguridad admin ────────────────────────────────────────────────────────────

public class UsuarioAdmin
{
    public string  CodigoUsuario   { get; set; } = "";
    public string  CodigoGrupo     { get; set; } = "";
    public string  Descripcion     { get; set; } = "";
    public string  Identificador   { get; set; } = "";
    public DateTime? FechaCaducacion { get; set; }
    public int?    IdArea          { get; set; }
    public List<string> Permisos   { get; set; } = [];
}

public class CrearUsuarioRequest
{
    public string  CodigoUsuario   { get; set; } = "";
    public string  Password        { get; set; } = "";
    public string  CodigoGrupo     { get; set; } = "";
    public string  Descripcion     { get; set; } = "";
    public string? Identificador   { get; set; }
    public DateTime? FechaCaducacion { get; set; }
    public List<string> Permisos   { get; set; } = [];
}

public class ActualizarUsuarioRequest
{
    public string  CodigoGrupo     { get; set; } = "";
    public string  Descripcion     { get; set; } = "";
    public string? Identificador   { get; set; }
    public DateTime? FechaCaducacion { get; set; }
    public List<string> Permisos   { get; set; } = [];
}

public class CambiarPasswordRequest
{
    public string NuevoPassword { get; set; } = "";
}

public class GrupoItem
{
    public string Codigo        { get; set; } = "";
    public int    TotalUsuarios { get; set; }
}
