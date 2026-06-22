using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using SAF.API.Repositories;
using SAF.API.Services;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// ── Base de datos ──────────────────────────────────────────────────────────
var connStr = builder.Configuration.GetConnectionString("PROGRAM")!;
builder.Services.AddSingleton(new DbConnectionFactory(connStr));

// ── Repositorios ───────────────────────────────────────────────────────────
builder.Services.AddScoped<IUsuarioRepository, UsuarioRepository>();
builder.Services.AddScoped<IPresupuestoRepository, PresupuestoRepository>();
builder.Services.AddScoped<ICompromisosRepository, CompromisosRepository>();
builder.Services.AddScoped<IOrdenesPageRepository, OrdenesPageRepository>();
builder.Services.AddScoped<IFacturasRepository, FacturasRepository>();
builder.Services.AddScoped<IProveedoresRepository, ProveedoresRepository>();
builder.Services.AddScoped<INotasPedidoRepository, NotasPedidoRepository>();
builder.Services.AddScoped<IAreasRepository, AreasRepository>();

// ── Servicios ──────────────────────────────────────────────────────────────
builder.Services.AddScoped<IAuthService, AuthService>();

// ── JWT ────────────────────────────────────────────────────────────────────
var jwtSection = builder.Configuration.GetSection("Jwt");
var secret     = jwtSection["Secret"]!;

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(opt =>
    {
        opt.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer           = true,
            ValidateAudience         = true,
            ValidateLifetime         = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer              = jwtSection["Issuer"],
            ValidAudience            = jwtSection["Audience"],
            IssuerSigningKey         = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret))
        };
    });

builder.Services.AddAuthorization();

// ── CORS ───────────────────────────────────────────────────────────────────
var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>()!;
builder.Services.AddCors(opt =>
    opt.AddDefaultPolicy(p => p.WithOrigins(allowedOrigins)
                                .AllowAnyHeader()
                                .AllowAnyMethod()));

// ── Swagger / Controllers ──────────────────────────────────────────────────
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "SAF API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization", Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "bearer", BearerFormat = "JWT", In = Microsoft.OpenApi.Models.ParameterLocation.Header
    });
    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                    { Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseCors();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
