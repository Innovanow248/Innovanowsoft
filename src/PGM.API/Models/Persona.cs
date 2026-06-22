namespace PGM.API.Models;

public class Persona
{
    public string  Identificador    { get; set; } = "";
    public string  TipoDocumento    { get; set; } = "";
    public string  Documento        { get; set; } = "";
    public string? Apellido         { get; set; }
    public string? Nombre           { get; set; }
    public string? CuitCuil         { get; set; }
    public string? Sexo             { get; set; }
    public DateTime? FechaNacimiento { get; set; }
    public string? CalleNocod       { get; set; }
    public string? NumeracionCalle  { get; set; }
    public string? Piso             { get; set; }
    public string? Departamento     { get; set; }
    public string? Barrio           { get; set; }
    public string? CodigoPostalAuxiliar { get; set; }
    public string? CodigoProvincia  { get; set; }
    public string? Pais             { get; set; }
    public string? Telefono         { get; set; }
    public string? TelefonoMovil    { get; set; }
    public string? Email            { get; set; }
    public string? Domicilio        { get; set; }
    public string? Localidad        { get; set; }
}

public class PersonaBusqueda
{
    public string? CuitCuil   { get; set; }
    public string? Documento  { get; set; }
    public string? Apellido   { get; set; }
    public string? Identificador { get; set; }
}
