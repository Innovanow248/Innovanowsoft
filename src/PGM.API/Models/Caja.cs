namespace PGM.API.Models;

public class SesionCajero
{
    public string Cajero        { get; set; } = "";
    public DateTime FechaCaja   { get; set; }
    public string NroSession    { get; set; } = "";
    public bool Cerrado         { get; set; }
    public bool Transferido     { get; set; }
}

public class AbrirSesionRequest
{
    public string Cajero     { get; set; } = "";
    public DateTime FechaCaja { get; set; } = DateTime.Today;
}

public class FormaPagoItem
{
    public string TipoMoneda     { get; set; } = "";   // EF=efectivo CH=cheque TJ=tarjeta
    public decimal Importe       { get; set; }
    // Cheque
    public string? NroCheque    { get; set; }
    public string? Banco        { get; set; }
    public DateTime? FechaAcred { get; set; }
    // Tarjeta
    public string? TipoTarjeta  { get; set; }
    public string? NroTarjeta   { get; set; }
    public string? Autorizacion { get; set; }
    public string? NroCupon     { get; set; }
    public string? PlanTarjeta  { get; set; }
}

public class CobroVentanillaRequest
{
    public string   Cajero      { get; set; } = "";
    public DateTime FechaCaja   { get; set; }
    public string   NroSession  { get; set; } = "";
    public List<string> NrosInternos { get; set; } = new();
    public DateTime FechaPago   { get; set; } = DateTime.Today;
    public List<FormaPagoItem> FormasPago { get; set; } = new();
    public decimal ImpVuelto    { get; set; }
}

public class CobroVentanillaResult
{
    public bool    Exitoso      { get; set; }
    public string  Mensaje      { get; set; } = "";
    public string? NroOperacion { get; set; }
    public List<string> Errores { get; set; } = new();
}

public class OperacionResumen
{
    public string   NroOperacion { get; set; } = "";
    public DateTime FechaCaja    { get; set; }
    public decimal  ImpPago      { get; set; }
    public decimal  ImpVuelto    { get; set; }
    public string   TipoMoneda   { get; set; } = "";
}

public class ResumenSesion
{
    public string   Cajero          { get; set; } = "";
    public DateTime FechaCaja       { get; set; }
    public string   NroSession      { get; set; } = "";
    public bool     Cerrado         { get; set; }
    public int      CantOperaciones { get; set; }
    public decimal  TotalEfectivo   { get; set; }
    public decimal  TotalCheque     { get; set; }
    public decimal  TotalTarjeta    { get; set; }
    public decimal  TotalGeneral    { get; set; }
    public List<OperacionResumen> Operaciones { get; set; } = new();
}

public class CerrarSesionRequest
{
    public string   Cajero       { get; set; } = "";
    public DateTime FechaCaja    { get; set; }
    public string   NroSession   { get; set; } = "";
    public decimal  DiferenciaCierre { get; set; }
}

public class CajeroUsuario
{
    public string Cajero      { get; set; } = "";
    public string Descripcion { get; set; } = "";
    public bool   Habilitado  { get; set; }
    public int    Nivel       { get; set; }
    public bool   EsEncargado { get; set; }
}

public class CrearCajeroRequest
{
    public string Cajero      { get; set; } = "";
    public string Descripcion { get; set; } = "";
    public int    Nivel       { get; set; } = 1;
}
