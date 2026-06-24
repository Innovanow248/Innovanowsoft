using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using webIngresos.Framework;
using System.Text;
using System.IO;
using System.Threading.Tasks;
using blIngresos;
using System.Collections;
using System.Web.DynamicData;

namespace webIngresos
{
    public partial class DevengamientoV2 : webBasePage
    {
        public DevengamientoV2()
        {

            this.Load += DevengamientoV2_Load;
        }

        private void DevengamientoV2_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static blIngresos.blT_OBLIGACIONESEntidadColeccion obtenerDatosContribuyente(string ClaveBien, string TipoTributo)
        {
            blIngresos.blT_OBLIGACIONES bl = new blIngresos.blT_OBLIGACIONES();
            blIngresos.blT_OBLIGACIONESEntidadColeccion colObligaciones = bl.TraerObligacionesDeuda(ClaveBien, TipoTributo, UsuarioLogueado().JurisdiccionId);

            return colObligaciones;

        }

        [WebMethod]
        public static blIngresos.blT_DEVENGAMIENTOEntidadColeccion obtenerDatosCuenta(string ClaveBien, int IdTipoTributo)
        {

            blIngresos.blT_DEVENGAMIENTO bl = new blIngresos.blT_DEVENGAMIENTO();
            blIngresos.blT_DEVENGAMIENTOEntidadColeccion colDatos = bl.ConsultaDatos(ClaveBien, IdTipoTributo, UsuarioLogueado().JurisdiccionId);

            return colDatos;

        }

        [WebMethod]
        public static blIngresos.blT_OBLIGACIONESEntidadColeccion mostrarObligaciones(string idTributoContribuyente)
        {
            blIngresos.blT_OBLIGACIONES bl = new blIngresos.blT_OBLIGACIONES();
            blIngresos.blT_OBLIGACIONESEntidadColeccion colObligacionesDetalle = bl.TraerGrillaSec(idTributoContribuyente);

            return colObligacionesDetalle;

        }


        [WebMethod]
        public static blIngresos.blT_OBLIGACIONESEntidadColeccion mostrarDetalleObligaciones(string idTributoContribuyente, string idObligacion)
        {
            blIngresos.blT_OBLIGACIONES bl = new blIngresos.blT_OBLIGACIONES();
            blIngresos.blT_OBLIGACIONESEntidadColeccion colObligacionesDetalle = bl.TraerGrillaSecDet(idTributoContribuyente, idObligacion);

            return colObligacionesDetalle;

        }

        [WebMethod]
        public static blIngresos.blT_VENCIMIENTOSEntidadColeccion traerVencimientos(int anioConsulta, int tipoTributo)
        {
            blIngresos.blT_VENCIMIENTOS bl = new blIngresos.blT_VENCIMIENTOS();
            blIngresos.blT_VENCIMIENTOSEntidadColeccion colVencimientos = bl.TraerVencimientos(UsuarioLogueado().JurisdiccionId, anioConsulta, tipoTributo);

            return colVencimientos;

        }

        [WebMethod]
        public static string obtenerSimulacion(string P_ID_TRIBUTO_CONTRIBUYENTE, string P_TIPO_TRIBUTO, int P_EJERCICIO_LIQ, string[] P_NRO_CUOTA, Int32? P_MODALIDAD)
        {
            blIngresos.blT_SIMULACION bl = new blIngresos.blT_SIMULACION();

            DataTable lista = new DataTable();

            var idJurisdiccion = UsuarioLogueado().JurisdiccionId;

            string P_CUOTAS = null;
            if (P_NRO_CUOTA != null && P_NRO_CUOTA.Length > 0)
            {
                P_CUOTAS = string.Join(",", P_NRO_CUOTA); // "0,1"
            }

            lista = bl.obtenerSimulacion(P_ID_TRIBUTO_CONTRIBUYENTE, P_TIPO_TRIBUTO, P_EJERCICIO_LIQ, P_CUOTAS, P_MODALIDAD, idJurisdiccion);

            string jsonString = JsonConvert.SerializeObject(lista, Formatting.Indented);
            return jsonString;
        }


        [WebMethod]
        public static string PRUEBA_PORCENTAJE_CARGA(int P_ID_TIPO_TRIBUTO)
        {
            blIngresos.blT_DEVENGAMIENTO_V2 bl = new blIngresos.blT_DEVENGAMIENTO_V2();
            string res = "";

            var idJurisdiccion = UsuarioLogueado().JurisdiccionId;

            res = bl.PRUEBA_PORCENTAJE_CARGA(idJurisdiccion, P_ID_TIPO_TRIBUTO);

            return res;
        }

        [WebMethod]
        public static blIngresos.blT_PORCENTAJE_CARGAEntidadColeccion CONSULTAR_PORCENTAJE_CARGA(int P_ID_TIPO_TRIBUTO)
        {
            blIngresos.blT_PORCENTAJE_CARGA bl = new blIngresos.blT_PORCENTAJE_CARGA();
            blIngresos.blT_PORCENTAJE_CARGAEntidadColeccion colVencimientos = bl.CONSULTAR_PORCENTAJE_CARGA(UsuarioLogueado().JurisdiccionId, P_ID_TIPO_TRIBUTO);

            return colVencimientos;

        }

        [WebMethod]
        public static blIngresos.blT_PORCENTAJE_CARGAEntidadColeccion CONSULTAR_ESTADO_DEVENGAMIENTO()
        {
            blIngresos.blT_PORCENTAJE_CARGA bl = new blIngresos.blT_PORCENTAJE_CARGA();
            blIngresos.blT_PORCENTAJE_CARGAEntidadColeccion colVencimientos = bl.CONSULTAR_ESTADO_DEVENGAMIENTO(UsuarioLogueado().JurisdiccionId);

            return colVencimientos;

        }


        [WebMethod]
        public static blIngresos.blT_TIPOS_TRIBUTOSEntidadColeccion TRIBUTOS_CON_DEVENGAMIENTO()
        {
            Int32 idJurisdiccion = Convert.ToInt32(HttpContext.Current.Session["IdJur"]);
            Int32 cantidad = 0;
            blIngresos.blT_TIPOS_TRIBUTOS bl = new blIngresos.blT_TIPOS_TRIBUTOS();
            blIngresos.blT_TIPOS_TRIBUTOSEntidadColeccion colTipoTributos = bl.TRIBUTOS_CON_DEVENGAMIENTO(idJurisdiccion);

            return colTipoTributos;

        }

    }
}