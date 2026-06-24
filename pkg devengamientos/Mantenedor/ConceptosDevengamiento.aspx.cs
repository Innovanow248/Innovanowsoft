using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using webIngresos.Framework;


namespace webIngresos
{
    public partial class ConceptosDevengamiento : webBasePage
    {
        public ConceptosDevengamiento()
        {
            this.Load += ConceptosDevengamiento_Load;

        }

        private void ConceptosDevengamiento_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static blIngresos.blT_TIPOS_CONCEPTOSEntidadColeccion getConceptosDevengamiento(Int32 ANIO_CONSULTA, String TIPO_TRIBUTO)
        {
            
            Int32 ID_JURISDICCION = Convert.ToInt32(HttpContext.Current.Session["IdJur"]);

            
            blIngresos.blT_TIPOS_CONCEPTOS bl = new blIngresos.blT_TIPOS_CONCEPTOS();
            blIngresos.blT_TIPOS_CONCEPTOSEntidadColeccion col = bl.Buscar_Conceptos_Devengamiento(ANIO_CONSULTA, TIPO_TRIBUTO, ID_JURISDICCION);

            return col;

        }
        [WebMethod]
        public static void Editar(Int32 ID_TIPOCON_ANIO, string porcentaje, string valor)
        {

            blIngresos.blT_TIPOS_CONCEPTOS bl = new blIngresos.blT_TIPOS_CONCEPTOS();
            blIngresos.blT_TIPOS_CONCEPTOSEntidad entidad = new blIngresos.blT_TIPOS_CONCEPTOSEntidad();

            entidad.ID_TIPO_CONCEPTO_ANIO = ID_TIPOCON_ANIO;
            
            
            entidad.USR_MOD = UsuarioLogueado().NombreUsuario;
            entidad.FEC_MOD = DateTime.Now;

            entidad.PORCENTAJE = Convert.ToDouble(porcentaje.Replace(".", ","));
            entidad.VALOR = Convert.ToDouble(valor.Replace(".", ","));
            
            entidad.ID_JURISDICCION = Convert.ToInt32(HttpContext.Current.Session["IdJur"]);

            bl.Editar_Concepto_Devengamiento(entidad);

        }

        [WebMethod]
        public static Int16 getClonarPorAnio(int anioConsulta, int anioClonacion, String tipoTributo)
        {

            blIngresos.blT_TIPOS_CONCEPTOS bl = new blIngresos.blT_TIPOS_CONCEPTOS();
            DateTime fechaIngreso = System.DateTime.Today;
            string usuario = UsuarioLogueado().NombreUsuario;

            Int16 valor = bl.ClonarporAnio(anioConsulta, anioClonacion, Convert.ToInt32(UsuarioLogueado().JurisdiccionId), tipoTributo, fechaIngreso, usuario);

            return valor;


        }

        [WebMethod]
        public static blIngresos.blT_TIPOS_TRIBUTOSEntidadColeccion getTiposTributo()
        {

            Int32 cantidad = 0;
            blIngresos.blT_TIPOS_TRIBUTOS bl = new blIngresos.blT_TIPOS_TRIBUTOS();
            blIngresos.blT_TIPOS_TRIBUTOSEntidadColeccion col = bl.Buscar(null, null, null, null, null, null, null, null, Convert.ToInt32(HttpContext.Current.Session["IdJur"]), null, null, ref cantidad);

            return col;

        }

        [WebMethod]
        public static void Borrar(Int32 ID_TIPOCON_ANIO)
        {

            blIngresos.blT_TIPOS_CONCEPTOS bl = new blIngresos.blT_TIPOS_CONCEPTOS();
            //blIngresos.blT_TIPOS_CONCEPTOSEntidad ent = new bl.blT_TIPOS_CONCEPTOSEntidad();
            //ent.ID_TIPO_CONCEPTO = ID_TIPOCON_ANIO;
            Int32 ID_CON_ANIO = ID_TIPOCON_ANIO;
            DateTime FEC_BAJA = System.DateTime.Today;
            string USR_BAJA = UsuarioLogueado().NombreUsuario;

            bl.Borrar(ID_CON_ANIO, FEC_BAJA, USR_BAJA);
        }

    }
}