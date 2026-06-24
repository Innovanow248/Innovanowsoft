using blIngresos;
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
    public partial class AltaConceptos : webBasePage
    {

        public AltaConceptos()
        {
            this.Load += AltaConceptos_Load;

        }

        void AltaConceptos_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static blIngresos.Mantenedor.bl_AltaConceptosColeccion BUSCAR_CONCEPTOS(string TIPO_TRIBUTO)
        {
            return new blIngresos.Mantenedor.bl_AltaConceptos().BUSCAR_CONCEPTOS(TIPO_TRIBUTO, UsuarioLogueado().JurisdiccionId);
        }

        [WebMethod]
        public static void ELIMINAR_TIPO_CONCEPTO(int ID_TIPO_CONCEPTO)
        {

            blIngresos.Mantenedor.bl_AltaConceptos bl = new blIngresos.Mantenedor.bl_AltaConceptos();
            blIngresos.Mantenedor.bl_AltaConceptosEntidad ent = new blIngresos.Mantenedor.bl_AltaConceptosEntidad();

            ent.ID_TIPO_CONCEPTO = ID_TIPO_CONCEPTO;
            ent.USR_BAJA = UsuarioLogueado().NombreUsuario;

            bl.ELIMINAR_TIPO_CONCEPTO(ent);

        }

        [WebMethod]
        public static blIngresos.Mantenedor.bl_AltaConceptosEntidad TRAER_PARA_EDITAR(int ID_TIPO_CONCEPTO)
        {

            blIngresos.Mantenedor.bl_AltaConceptos bl = new blIngresos.Mantenedor.bl_AltaConceptos();
            blIngresos.Mantenedor.bl_AltaConceptosEntidad ent = bl.BUSCAR_TIPO_CONCEPTO_X_ID(ID_TIPO_CONCEPTO);

            return ent;
        }

        [WebMethod]
        public static void EDITAR_TIPO_CONCEPTO(int ID_TIPO_CONCEPTO, String TIPO_TRIBUTO, String CONCEPTO, String DESCRIPCION, String IMPACTO, Nullable<Double> PORCENTAJE,
                                    Nullable<Double> VALOR, String TIPO_CUOTA, String MASIVO)
        {

            blIngresos.Mantenedor.bl_AltaConceptos bl = new blIngresos.Mantenedor.bl_AltaConceptos();
            blIngresos.Mantenedor.bl_AltaConceptosEntidad ent = new blIngresos.Mantenedor.bl_AltaConceptosEntidad();
            blT_TIPOS_TRIBUTOS tributo = new blT_TIPOS_TRIBUTOS();
            var response = tributo.BuscarPorTipoTributo(TIPO_TRIBUTO);
            ent.ID_TIPO_CONCEPTO = ID_TIPO_CONCEPTO;
            ent.id_TIPO_TRIBUTO = Convert.ToInt32(response.ID_TIPO_TIBUTO);
            ent.CONCEPTO = CONCEPTO;
            ent.DESCRIPCION_TIPO_CONCEPTO = DESCRIPCION;
            ent.IMPACTO = IMPACTO;
            ent.PORCENTAJE = PORCENTAJE;
            ent.VALOR = VALOR;
            ent.TIPO_CUOTA = TIPO_CUOTA;
            ent.MASIVO = MASIVO;
            ent.USR_MOD = UsuarioLogueado().NombreUsuario;

            bl.EDITAR_TIPO_CONCEPTO(ent);

        }


        [WebMethod]
        public static void INSERTAR_TIPO_CONCEPTO(string TIPO_TRIBUTO, String CONCEPTO, String DESCRIPCION, String IMPACTO, Nullable<Double> PORCENTAJE,
                                    Nullable<Double> VALOR, String TIPO_CUOTA, String MASIVO)
        {

            blIngresos.Mantenedor.bl_AltaConceptos bl = new blIngresos.Mantenedor.bl_AltaConceptos();
            blIngresos.Mantenedor.bl_AltaConceptosEntidad ent = new blIngresos.Mantenedor.bl_AltaConceptosEntidad();

            ent.TIPO_TRIBUTO = TIPO_TRIBUTO;
            ent.CONCEPTO = CONCEPTO;
            ent.DESCRIPCION_TIPO_CONCEPTO = DESCRIPCION;
            ent.IMPACTO = IMPACTO;
            ent.PORCENTAJE = PORCENTAJE;
            ent.VALOR = VALOR;
            ent.TIPO_CUOTA = TIPO_CUOTA;
            ent.MASIVO = MASIVO;
            ent.USR_ING = UsuarioLogueado().NombreUsuario;
            ent.ID_JURISDICCION = UsuarioLogueado().JurisdiccionId;

            bl.INSERTAR_TIPO_CONCEPTO(ent);
        }

        //########################################## COMBOS ##########################################

        [WebMethod]
        public static blIngresos.Mantenedor.bl_AltaConceptosColeccion BUSCAR_COMBO_TIPO_TRIBUTO()
        {
            return new blIngresos.Mantenedor.bl_AltaConceptos().BUSCAR_COMBO_TIPO_TRIBUTO();
        }

    }
}