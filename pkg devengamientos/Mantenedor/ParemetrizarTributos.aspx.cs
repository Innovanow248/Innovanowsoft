using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using webIngresos.Framework;
using System.Data;
using System.Web.Services;
using Newtonsoft.Json;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;

namespace webIngresos.Mantenedor
{
    public partial class ParemetrizarTributos : webBasePage
    {

        public ParemetrizarTributos()
        {

            this.Load += ParemetrizarTributos_Load;
            
        }

        private void ParemetrizarTributos_Load(object sender, EventArgs e)
        {
              
        }

      
        

        [WebMethod]
        public static blIngresos.blT_TIPOS_TRIBUTOSEntidadColeccion BuscarTributos()
        {
            return new blIngresos.blT_TIPOS_TRIBUTOS().BuscarTributo(Convert.ToInt32(HttpContext.Current.Session["IdJur"]));
        }
        //Metodo para llenar el combobox de buscar TiposTributos
        [WebMethod]
        public static blIngresos.blT_TIPOS_TRIBUTOSEntidadColeccion LLenarCombo()
        {
            return new blIngresos.blT_TIPOS_TRIBUTOS().LLenarrComboTipoTributo(Convert.ToInt32(HttpContext.Current.Session["IdJur"]));
        }
        

        [WebMethod]
        public static void Borrado(Int32 PARAMETROTIPOTRIBUTO)
        {
            var USR_ING = UsuarioLogueado().NombreUsuario;
            var ID_JURISDICCION = Convert.ToInt32(HttpContext.Current.Session["IdJur"]);
            new blIngresos.blT_TIPOS_TRIBUTOS().EliminarTributo(PARAMETROTIPOTRIBUTO, USR_ING, ID_JURISDICCION);
        }

        [WebMethod]
        public static void Insertar(Int32 TRIBUTO_ID,String MASIVO,String DECLARATIVO)
        {
            try
            {

                blIngresos.blT_TIPOS_TRIBUTOS bl = new blIngresos.blT_TIPOS_TRIBUTOS();
                blIngresos.blT_TIPOS_TRIBUTOSEntidad ent = new blIngresos.blT_TIPOS_TRIBUTOSEntidad();
                ent.ID_TIPO_TIBUTO = TRIBUTO_ID;
                ent.ID_JURISDICCION = Convert.ToInt32(HttpContext.Current.Session["IdJur"]);
                ent.USR_ING = UsuarioLogueado().NombreUsuario;
                ent.MASIVO = MASIVO;
                ent.DECLARATIVO = DECLARATIVO;

                bl.InsertarTipoTributo(ent);

            }

            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        [WebMethod]
        public static blIngresos.blT_DEPARTAMENTOSEntidad TraerparaEditar(Int32 DEPARTAMENTO_ID)
        {
            return new blIngresos.blT_DEPARTAMENTOSEntidad(DEPARTAMENTO_ID);
        }

        [WebMethod]
        public static void Editar(String ID_DEPARTAMENTO, String NOMBRE, String PROVINCIA_ID)
        {
            try
            {
                blIngresos.blT_DEPARTAMENTOS bl = new blIngresos.blT_DEPARTAMENTOS();
                blIngresos.blT_DEPARTAMENTOSEntidad ent = new blIngresos.blT_DEPARTAMENTOSEntidad();
                ent.ID_DEPARTAMENTO = Convert.ToInt32(ID_DEPARTAMENTO);
                ent.N_DEPARTAMENTO = NOMBRE;
                ent.ID_PROVINCIA = Convert.ToInt32(PROVINCIA_ID);
                ent.USERID_ACT = UsuarioLogueado().NombreUsuario;


                bl.Editar(ent);
            }
            catch (Exception ex)
            {

                throw new Exception(ex.Message);
            }


        }


        

        [WebMethod]

        //lleno el combo
        public static string getTipoTributos()
        {
            Int32 id_Jurdiccion = Convert.ToInt32(HttpContext.Current.Session["IdJur"]);
            blIngresos.blT_TIPOS_TRIBUTOS bl = new blIngresos.blT_TIPOS_TRIBUTOS();
            DataTable tabla = bl.getTipoTributo(id_Jurdiccion);
            var JSONString = new StringBuilder();
            if (tabla.Rows.Count > 0)
            {
                JSONString.Append("[");
                for (int i = 0; i < tabla.Rows.Count; i++)
                {
                    JSONString.Append("{");
                    for (int j = 0; j < tabla.Columns.Count; j++)
                    {
                        if (j < tabla.Columns.Count - 1)
                        {
                            JSONString.Append("\"" + tabla.Columns[j].ColumnName.ToString() + "\":" + "\"" + tabla.Rows[i][j].ToString() + "\",");
                        }
                        else if (j == tabla.Columns.Count - 1)
                        {
                            JSONString.Append("\"" + tabla.Columns[j].ColumnName.ToString() + "\":" + "\"" + tabla.Rows[i][j].ToString() + "\"");
                        }
                    }
                    if (i == tabla.Rows.Count - 1)
                    {
                        JSONString.Append("}");
                    }
                    else
                    {
                        JSONString.Append("},");
                    }
                }
                JSONString.Append("]");
            }
            return JSONString.ToString();

        }

    }
}