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
    public partial class Intereses : webBasePage
    {

        public Intereses()
        {
            this.Load += Intereses_Load;

        }

        void Intereses_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static String INSERTAR_INTERES(string P_TIPO_TRIBUTO, double P_PORCENTUAL, String P_OBSERVACION, DateTime P_FECHA_DESDE, DateTime P_FECHA_HASTA)
        {

            blIngresos.Mantenedor.bl_Intereses bl = new blIngresos.Mantenedor.bl_Intereses();
            blIngresos.Mantenedor.bl_InteresesEntidad ent = new blIngresos.Mantenedor.bl_InteresesEntidad();

            ent.TIPO_TRIBUTO = P_TIPO_TRIBUTO;
            ent.PORCENTUAL = P_PORCENTUAL;
            ent.OBSERVACION = P_OBSERVACION;
            ent.FECHA_DESDE = P_FECHA_DESDE;
            ent.FECHA_HASTA = P_FECHA_HASTA;
            ent.ID_JURISDICCION = UsuarioLogueado().JurisdiccionId;

            return bl.INSERTAR_INTERES(ent);
        }

        [WebMethod]
        public static String EDITAR_INTERES(int P_ID_CONFIGURACION,string P_TIPO_TRIBUTO, double P_PORCENTUAL, String P_OBSERVACION, DateTime P_FECHA_DESDE, DateTime P_FECHA_HASTA)
        {

            blIngresos.Mantenedor.bl_Intereses bl = new blIngresos.Mantenedor.bl_Intereses();
            blIngresos.Mantenedor.bl_InteresesEntidad ent = new blIngresos.Mantenedor.bl_InteresesEntidad();

            ent.ID_CONFIGURACION = P_ID_CONFIGURACION;
            ent.TIPO_TRIBUTO = P_TIPO_TRIBUTO;
            ent.PORCENTUAL = P_PORCENTUAL;
            ent.OBSERVACION = P_OBSERVACION;
            ent.FECHA_DESDE = P_FECHA_DESDE;
            ent.FECHA_HASTA = P_FECHA_HASTA;
            ent.ID_JURISDICCION = UsuarioLogueado().JurisdiccionId;

            return bl.EDITAR_INTERES(ent);
        }


        [WebMethod]
        public static blIngresos.Mantenedor.bl_InteresesColeccion TRAER_INTERESES(String P_TIPO_TRIBUTO)
        {
            return new blIngresos.Mantenedor.bl_Intereses().TRAER_INTERESES(P_TIPO_TRIBUTO, UsuarioLogueado().JurisdiccionId);
        }

        [WebMethod]
        public static blIngresos.Mantenedor.bl_InteresesColeccion TRAER_TODOS()
        {
            return new blIngresos.Mantenedor.bl_Intereses().TRAER_TODOS(UsuarioLogueado().JurisdiccionId);
        }

        [WebMethod]
        public static blIngresos.Mantenedor.bl_InteresesEntidad TRAER_PARA_EDITAR(int ID_CONFIGURACION)
        {

            blIngresos.Mantenedor.bl_Intereses bl = new blIngresos.Mantenedor.bl_Intereses();
            blIngresos.Mantenedor.bl_InteresesEntidad ent = bl.BUSCAR_INTERES_X_ID(ID_CONFIGURACION);

            return ent;
        }

    }
}