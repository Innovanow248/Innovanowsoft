
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using webIngresos.Framework;
using System.Globalization;


namespace webIngresos
{
    public partial class ConsultarVencimientos : webBasePage
    {
        public ConsultarVencimientos()
        {
            this.Load += ConsultarVencimientos_Load;
        }

        private void ConsultarVencimientos_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static blIngresos.blT_VENCIMIENTOSEntidadColeccion getVencimientos(int anioConsulta, int tipoTributo)
        {
            int id_jurisdiccion = Convert.ToInt32(HttpContext.Current.Session["IdJur"]);
            blIngresos.blT_VENCIMIENTOS bl = new blIngresos.blT_VENCIMIENTOS();
            blIngresos.blT_VENCIMIENTOSEntidadColeccion colConsultarVencimientos = bl.TraerVencimientos(id_jurisdiccion, anioConsulta, tipoTributo);
            return colConsultarVencimientos;
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
        public static blIngresos.blt_obsa_modalidadEntidadColeccion traer_modalidad()
        {
            Int32 cantidad = 0;
            blIngresos.blt_obsa_modalidad bl = new blIngresos.blt_obsa_modalidad();
            Int32 jur = 2372;

            blIngresos.blt_obsa_modalidadEntidadColeccion col = bl.Buscar(null, null, jur, null, null, null, null, null, null, null, null, ref cantidad);

            return col;

        }

        [WebMethod]
        public static blIngresos.blT_INMUEBLES_ZONASEntidadColeccion getZona()
        {
            Int32 cantidad = 0;
            blIngresos.blT_INMUEBLES_ZONAS bl = new blIngresos.blT_INMUEBLES_ZONAS();
            blIngresos.blT_INMUEBLES_ZONASEntidadColeccion col = bl.Buscar_jurisdiccion(null, null, null, null, null, null, null, null, null, Convert.ToInt32(HttpContext.Current.Session["IdJur"]), null, null, ref cantidad);
            return col;

        }

        [WebMethod]
        public static Int16 getClonarPorAnio(int anioConsulta, int anioClonacion, int idTipoTributo)
        {

            blIngresos.blT_VENCIMIENTOS bl = new blIngresos.blT_VENCIMIENTOS();
            DateTime fechaIngreso = System.DateTime.Today;
            string usuario = UsuarioLogueado().NombreUsuario;
            Int16 valor = bl.ClonarporAnio(anioConsulta, anioClonacion, Convert.ToInt32(UsuarioLogueado().JurisdiccionId), idTipoTributo, fechaIngreso, usuario);

            return valor;


        }

        [WebMethod]
        public static blIngresos.blT_VENCIMIENTOSEntidadColeccion Traer_p_Editar(Nullable<Int32> p_Id)
        {

            blIngresos.blT_VENCIMIENTOS blTipoServicio = new blIngresos.blT_VENCIMIENTOS();
            blIngresos.blT_VENCIMIENTOSEntidadColeccion colConsultarVencimientos = blTipoServicio.Traer_p_Editar(p_Id);

            return colConsultarVencimientos;
        }

        [WebMethod]
        public static string Insertar(int IdTT, int NC, String FecPrimer, String FecSegund, String FecTercer, String ntipo, String nzona, String ano, Nullable<Int32> moda, Nullable<Int32> P_DESC_PRIMER_VTO, Nullable<Int32> P_DESC_SEGUNDO_VTO, Nullable<Int32> P_DESC_TERCER_VTO)
        {
            blIngresos.blT_VENCIMIENTOS bl = new blIngresos.blT_VENCIMIENTOS();
            blIngresos.blT_VENCIMIENTOSEntidad ent = new blIngresos.blT_VENCIMIENTOSEntidad();


            DateTime? vto3 = null;
            DateTime? vto2 = null;
            //DateTime vto1 = Convert.ToDateTime(FecPrimer);
            //DateTime vto2 = Convert.ToDateTime(FecSegund);
            if (FecSegund != "")
            {
                vto2 = Convert.ToDateTime(FecSegund);
            }
            if (FecTercer != "")
            {
                vto3 = Convert.ToDateTime(FecTercer);
            }

            ent.ID_TIPO_TIBUTO = IdTT;
            ent.NRO_CUOTA = NC;
            ent.FECHA_PRIMER_VTO = Convert.ToDateTime(FecPrimer);  // vto1;
            ent.FECHA_SEGUNDO_VTO = vto2;
            ent.FECHA_TERCER_VTO = vto3;
            ent.N_TIPO = ntipo;
            ent.N_ZONA = nzona;
            ent.EJERCICIO = ano;
            ent.ID_JURISDICCION = Convert.ToInt32(HttpContext.Current.Session["IdJur"]);
            ent.DESC_PRIMER_VTO = P_DESC_PRIMER_VTO;
            ent.DESC_SEGUNDO_VTO = P_DESC_SEGUNDO_VTO;
            ent.DESC_TERCER_VTO = P_DESC_TERCER_VTO;

            //if (moda == null)
            //{
            //    moda = 0;
            //}
            ent.ID_OBSA_MODALIDAD = moda; /*Convert.ToInt32(moda);*/

            //ent.FEC_ING = System.DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");
            ent.USR_ING = UsuarioLogueado().NombreUsuario;
            return bl.Insertar(ent);

        }

        [WebMethod]
        public static void Editar(Int32 id, int IdTT, int NC, string FecPrimer, string FecSegund, string FecTercer, String ntipo, String nzona, Nullable<Int32> moda, Nullable<Int32> P_DESC_PRIMER_VTO, Nullable<Int32> P_DESC_SEGUNDO_VTO, Nullable<Int32> P_DESC_TERCER_VTO)
        {

            blIngresos.blT_VENCIMIENTOS bl = new blIngresos.blT_VENCIMIENTOS();
            blIngresos.blT_VENCIMIENTOSEntidad ent = new blIngresos.blT_VENCIMIENTOSEntidad(id);

            DateTime? vto3 = null;
            DateTime? vto2 = null;
            // DateTime vto1 = Convert.ToDateTime(FecPrimer);
            //DateTime vto2 = Convert.ToDateTime(FecSegund);
            if (FecSegund != "")
            {
                vto2 = Convert.ToDateTime(FecSegund);
            }
            if (FecTercer != "")
            {

                vto3 = Convert.ToDateTime(FecTercer);
            }

            ent.ID_TIPO_TIBUTO = IdTT;
            ent.NRO_CUOTA = NC;
            ent.FECHA_PRIMER_VTO = Convert.ToDateTime(FecPrimer);  // vto1;
            ent.FECHA_SEGUNDO_VTO = vto2;
            ent.FECHA_TERCER_VTO = vto3;
            ent.N_TIPO = ntipo;
            ent.N_ZONA = nzona;
            ent.ID_JURISDICCION = Convert.ToInt32(HttpContext.Current.Session["IdJur"]);
            ent.ID_OBSA_MODALIDAD = Convert.ToInt32(moda);
            ent.DESC_PRIMER_VTO = P_DESC_PRIMER_VTO;
            ent.DESC_SEGUNDO_VTO = P_DESC_SEGUNDO_VTO;
            ent.DESC_TERCER_VTO = P_DESC_TERCER_VTO;

            ent.FEC_MOD = System.DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");
            ent.USR_MOD = UsuarioLogueado().NombreUsuario;

            bl.Editar(ent);

        }


        [WebMethod]
        public static void Borrado(Int32 ID_VENCIMIENTOS, int IdTT)
        {
            blIngresos.blT_VENCIMIENTOS bl = new blIngresos.blT_VENCIMIENTOS();
            blIngresos.blT_VENCIMIENTOSEntidad ent = new blIngresos.blT_VENCIMIENTOSEntidad(ID_VENCIMIENTOS);
            //ent.FEC_BAJA = System.DateTime.Now;
            ent.USR_BAJA = UsuarioLogueado().NombreUsuario;
            ent.ID_JURISDICCION = UsuarioLogueado().JurisdiccionId;
            ent.ID_TIPO_TIBUTO = IdTT;
            bl.Eliminar(ent);
        }

        [WebMethod]
        public static Int32 BuscarSegundoVenc(Int32 anioConsulta, Int32 idTipoTributo)
        {

            blIngresos.blT_VENCIMIENTOS bl = new blIngresos.blT_VENCIMIENTOS();
            Int32 seg_venc = bl.Buscar_Segundo_Venc(anioConsulta, Convert.ToInt32(UsuarioLogueado().JurisdiccionId), idTipoTributo);

            return seg_venc;

        }

    }
}