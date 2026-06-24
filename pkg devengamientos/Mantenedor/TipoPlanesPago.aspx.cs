using blIngresos;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using webIngresos.Framework;

namespace webIngresos
{
    public partial class TipoPlanesPago : webBasePage
    {
        public TipoPlanesPago()
        {
            this.Load += TipoPlanesPago_Load;

        }

        private void TipoPlanesPago_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static blIngresos.blT_Tipos_PlanesPagoEntidadColeccion getTipoPlanes()
        {
            int idJurisdiccion = Convert.ToInt32(HttpContext.Current.Session["IdJur"]);
            blIngresos.blT_Tipos_PlanesPago bl = new blIngresos.blT_Tipos_PlanesPago();
            blIngresos.blT_Tipos_PlanesPagoEntidadColeccion colTipoPlanes = bl.Traer_TipoPlanes(idJurisdiccion);

            return colTipoPlanes;

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
        public static blIngresos.blT_Tipos_PlanesPagoEntidadColeccion Traer_p_Editar(Nullable<Int32> p_Id)
        {

            blIngresos.blT_Tipos_PlanesPago blTipoServicio = new blIngresos.blT_Tipos_PlanesPago();
            blIngresos.blT_Tipos_PlanesPagoEntidadColeccion colConsultarTipoPlanes = blTipoServicio.Traer_p_Editar(p_Id);

            return colConsultarTipoPlanes;
        }


        [WebMethod]
        public static void Insertar(string Codigop, string Designa, string DecreSol, string SolUsoDev, string Observ, int CantiCuot, int DiaPriVen, int tipoTribut, string actualiza, string periodo)
        {
            blIngresos.blT_Tipos_PlanesPago bl = new blIngresos.blT_Tipos_PlanesPago();
            blIngresos.blT_Tipos_PlanesPagoEntidad ent = new blIngresos.blT_Tipos_PlanesPagoEntidad();

            ent.ID_TIPO_TRIBUTO = tipoTribut;
            ent.CODIGO_PLAN = Codigop;
            ent.DESIGNACION_PLAN = Designa;
            ent.DECRETO_RESOLUCION = DecreSol;
            ent.SOLO_USO_DEVENGAMIENTO = SolUsoDev;
            ent.OBSERVACIONES = Observ;
            ent.CANTIDAD_CUOTAS = CantiCuot;
            ent.DIA_PRIMER_VENCIMIENTO = DiaPriVen;
            ent.ID_JURISDICCION = Convert.ToInt32(HttpContext.Current.Session["IdJur"]);
            ent.ACTUALIZABLE = actualiza;
            ent.PERIODO = periodo;
            ent.FEC_ING = System.DateTime.Now;
            ent.USR_ING = UsuarioLogueado().NombreUsuario;

            bl.Insertar(ent);

        }

        [WebMethod]
        public static void Editar(string Codigop, string Designa, string DecreSol, string SolUsoDev, string Observ, int CantiCuot, int DiaPriVen, int id, string actualiza, string periodo, int tributo)
        {
            blIngresos.blT_Tipos_PlanesPago bl = new blIngresos.blT_Tipos_PlanesPago();
            blIngresos.blT_Tipos_PlanesPagoEntidad ent = new blIngresos.blT_Tipos_PlanesPagoEntidad(id);
            ent.CODIGO_PLAN = Codigop;
            ent.DESIGNACION_PLAN = Designa;
            ent.DECRETO_RESOLUCION = DecreSol;
            ent.SOLO_USO_DEVENGAMIENTO = SolUsoDev;
            ent.OBSERVACIONES = Observ;
            ent.CANTIDAD_CUOTAS = CantiCuot;
            ent.DIA_PRIMER_VENCIMIENTO = DiaPriVen;
            ent.ID_JURISDICCION = Convert.ToInt32(HttpContext.Current.Session["IdJur"]);
            ent.USR_MOD = UsuarioLogueado().NombreUsuario;
            ent.FEC_MOD = System.DateTime.Now;
            ent.ACTUALIZABLE = actualiza;
            ent.PERIODO = periodo;
            ent.ID_TRIBUTO = tributo;
            bl.Editar(ent);
        }

        [WebMethod]
        public static void Borrado(Int32 ID_TIPO_PLANESPAGO)
        {
            blIngresos.blT_Tipos_PlanesPago bl = new blIngresos.blT_Tipos_PlanesPago();
            blIngresos.blT_Tipos_PlanesPagoEntidad ent = new blIngresos.blT_Tipos_PlanesPagoEntidad(ID_TIPO_PLANESPAGO);
            //ent.FEC_BAJA = System.DateTime.Now;
            ent.USR_BAJA = UsuarioLogueado().NombreUsuario;
            bl.Eliminar(ent);

        }

    }
}