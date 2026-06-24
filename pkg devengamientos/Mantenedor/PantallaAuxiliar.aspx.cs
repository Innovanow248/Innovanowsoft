using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using webIngresos.Framework;

namespace webIngresos
{
    public partial class PantallaAuxiliar : webBasePage
    {
        public PantallaAuxiliar()
        {

            this.Load += PantallaAuxiliar_Load;
        }

        private void PantallaAuxiliar_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string PRUEBA_PORCENTAJE_CARGA(int P_ID_TIPO_TRIBUTO)
        {
            blIngresos.blT_DEVENGAMIENTO_V2 bl = new blIngresos.blT_DEVENGAMIENTO_V2();

            var idJurisdiccion = UsuarioLogueado().JurisdiccionId;

            string res = bl.PRUEBA_PORCENTAJE_CARGA(idJurisdiccion, P_ID_TIPO_TRIBUTO);

            return res;
        }

        [WebMethod]
        public static string devengar(string P_ID_TRIBUTO_CONTRIBUYENTE, string P_TIPO_TRIBUTO, int P_EJERCICIO_LIQ, string P_NRO_CUOTA, int? P_MODALIDAD, string P_MODO, decimal? P_MONTO)
        {
            blIngresos.blT_DEVENGAMIENTO_V2 bl = new blIngresos.blT_DEVENGAMIENTO_V2();
            string res = "";
            var idJurisdiccion = UsuarioLogueado().JurisdiccionId;
            var usrIng = UsuarioLogueado().NombreUsuario;
			res = bl.devengarCalera(P_ID_TRIBUTO_CONTRIBUYENTE, P_TIPO_TRIBUTO, P_EJERCICIO_LIQ, P_NRO_CUOTA, P_MODALIDAD, usrIng, P_MODO, P_MONTO);
			return res;
        }

        [WebMethod]
        public static string devengarSuministroEnergia(string P_ID_TRIBUTO_CONTRIBUYENTE, string P_TIPO_TRIBUTO, int P_EJERCICIO_LIQ, string P_NRO_CUOTA, string P_MODO,
           int P_CANTIDADSELECCIONADA, Double P_MONTO)
        {
            blIngresos.blT_DEVENGAMIENTO_V2 bl = new blIngresos.blT_DEVENGAMIENTO_V2();
            string res = "";

            var idJurisdiccion = UsuarioLogueado().JurisdiccionId;
            var usrIng = UsuarioLogueado().NombreUsuario;

            if (P_ID_TRIBUTO_CONTRIBUYENTE == "null")
            {
                P_ID_TRIBUTO_CONTRIBUYENTE = null;
            }

            switch (idJurisdiccion)
            {
                case 4000://CALERA
                    res = bl.devengarSuministro(P_ID_TRIBUTO_CONTRIBUYENTE, P_TIPO_TRIBUTO, P_EJERCICIO_LIQ, P_NRO_CUOTA, usrIng, P_MODO, P_CANTIDADSELECCIONADA, P_MONTO);
                    break;


                default:
                    break;
            }

            return res;
        }
    }
}