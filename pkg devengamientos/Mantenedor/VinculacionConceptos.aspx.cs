using blIngresos.Seguridad;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using webIngresos.Framework;

namespace webIngresos.Mantenedor
{
    public partial class VinculacionConceptos : webBasePage
    {

        public VinculacionConceptos()
        {
            this.Load += VinculacionConceptos_Load;

        }

        void VinculacionConceptos_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static blIngresos.bl_VinculacionConceptosColeccion TRAER_CONCEPTOS_VENCIMIENTOS(int P_ID_TIPO_TRIBUTO, int P_ANIO_EJERCICIO, Int32? P_NRO_CUOTA)
        {

            blIngresos.bl_VinculacionConceptos bl = new blIngresos.bl_VinculacionConceptos();
            blIngresos.bl_VinculacionConceptosColeccion conceptos = bl.TRAER_CONCEPTOS_VENCIMIENTOS(UsuarioLogueado().JurisdiccionId, P_ID_TIPO_TRIBUTO, P_ANIO_EJERCICIO, P_NRO_CUOTA);

            return conceptos;

        }

        [WebMethod]
        public static blIngresos.bl_VinculacionConceptosColeccion TRAER_CUOTAS(int P_ID_TIPO_TRIBUTO, int P_ANIO_EJERCICIO)
        {

            blIngresos.bl_VinculacionConceptos bl = new blIngresos.bl_VinculacionConceptos();
            blIngresos.bl_VinculacionConceptosColeccion conceptos = bl.TRAER_CUOTAS(UsuarioLogueado().JurisdiccionId, P_ID_TIPO_TRIBUTO, P_ANIO_EJERCICIO);

            return conceptos;

        }

        [WebMethod]
        public static blIngresos.bl_VinculacionConceptosColeccion TRAER_CONCEPTOS_PADRE(int P_ID_TIPO_TRIBUTO)
        {

            blIngresos.bl_VinculacionConceptos bl = new blIngresos.bl_VinculacionConceptos();
            blIngresos.bl_VinculacionConceptosColeccion conceptos = bl.TRAER_CONCEPTOS_PADRE(UsuarioLogueado().JurisdiccionId, P_ID_TIPO_TRIBUTO);

            return conceptos;

        }

        [WebMethod]
        public static blIngresos.bl_VinculacionConceptosColeccion TRAER_ZONAS(int P_ID_TIPO_TRIBUTO, int P_NRO_CUOTA, int P_ANIO_EJERCICIO)
        {

            blIngresos.bl_VinculacionConceptos bl = new blIngresos.bl_VinculacionConceptos();
            blIngresos.bl_VinculacionConceptosColeccion conceptos = bl.TRAER_ZONAS(UsuarioLogueado().JurisdiccionId, P_ID_TIPO_TRIBUTO, P_NRO_CUOTA, P_ANIO_EJERCICIO);

            return conceptos;

        }

        [WebMethod]
        public static blIngresos.bl_VinculacionConceptosColeccion TRAER_OBSERVACION(int P_ID_CONCEPTO_VENCIMIENTO)
        {

            blIngresos.bl_VinculacionConceptos bl = new blIngresos.bl_VinculacionConceptos();
            blIngresos.bl_VinculacionConceptosColeccion conceptos = bl.TRAER_OBSERVACION(P_ID_CONCEPTO_VENCIMIENTO);

            return conceptos;

        }

        [WebMethod]
        public static blIngresos.bl_VinculacionConceptosColeccion TRAER_CONCEPTOS_PARAMETRIZAR(int P_ID_TIPO_TRIBUTO, int P_ID_CONCEPTO_PADRE, int P_ANIO_EJERCICIO, string P_CUMPLIDOR, int P_MODALIDAD, string P_ZONA, int P_NRO_CUOTA)
        {

            blIngresos.bl_VinculacionConceptos bl = new blIngresos.bl_VinculacionConceptos();
            blIngresos.bl_VinculacionConceptosColeccion conceptos = bl.TRAER_CONCEPTOS_PARAMETRIZAR(UsuarioLogueado().JurisdiccionId, P_ID_TIPO_TRIBUTO, P_ID_CONCEPTO_PADRE, P_ANIO_EJERCICIO, P_CUMPLIDOR, P_MODALIDAD, P_ZONA, P_NRO_CUOTA);

            return conceptos;

        }

        [WebMethod]
        public static string INSERTAR_VINCULACION_CONCEPTOS(int P_ID_TIPO_TRIBUTO, int P_ANIO_EJERCICIO, int P_NRO_CUOTA, int P_ID_CONCEPTO_PADRE, string P_CUMPLIDOR, string P_CONCEPTOS_VINCULADOS, string P_OBSERVACION, int P_MODALIDAD, string P_ZONA)
        {

            blIngresos.bl_VinculacionConceptos bl = new blIngresos.bl_VinculacionConceptos();

            string mensaje = bl.INSERTAR_VINCULACION_CONCEPTOS(UsuarioLogueado().JurisdiccionId, P_ID_TIPO_TRIBUTO, P_ANIO_EJERCICIO, P_NRO_CUOTA, P_ID_CONCEPTO_PADRE, P_CUMPLIDOR, P_CONCEPTOS_VINCULADOS, P_OBSERVACION, UsuarioLogueado().NombreUsuario, P_MODALIDAD, P_ZONA);

            return mensaje;

        }

        [WebMethod]
        public static string COMPROBAR_VENCIMIENTOS(int P_ID_TIPO_TRIBUTO, int P_ANIO_EJERCICIO, int P_NRO_CUOTA, int P_MODALIDAD)
        {

            blIngresos.bl_VinculacionConceptos bl = new blIngresos.bl_VinculacionConceptos();

            string mensaje = bl.COMPROBAR_VENCIMIENTOS(UsuarioLogueado().JurisdiccionId, P_ID_TIPO_TRIBUTO, P_ANIO_EJERCICIO, P_NRO_CUOTA, P_MODALIDAD);

            return mensaje;

        }

        [WebMethod]
        public static void BAJA_VINCULACION(int P_ID_CONCEPTO_VENCIMIENTO)
        {

            blIngresos.bl_VinculacionConceptos bl = new blIngresos.bl_VinculacionConceptos();

            bl.BAJA_VINCULACION(P_ID_CONCEPTO_VENCIMIENTO, UsuarioLogueado().NombreUsuario);

        }

        [WebMethod]
        public static blIngresos.blT_TIPOS_TRIBUTOSEntidadColeccion TRIBUTOS_CON_CONCEPTOS()
        {
            Int32 idJurisdiccion = Convert.ToInt32(HttpContext.Current.Session["IdJur"]);
            Int32 cantidad = 0;
            blIngresos.blT_TIPOS_TRIBUTOS bl = new blIngresos.blT_TIPOS_TRIBUTOS();
            blIngresos.blT_TIPOS_TRIBUTOSEntidadColeccion colTipoTributos = bl.BUSCAR_TRIB_CONCEPTOS(idJurisdiccion);

            return colTipoTributos;

        }
    }
}