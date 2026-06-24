<%@ Page Language="C#" MasterPageFile="~/MasterPage/Ingresos.Master" AutoEventWireup="true" CodeBehind="ParemetrizarTributos.aspx.cs" Inherits="webIngresos.Mantenedor.ParemetrizarTributos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphContenidoIngreso" runat="Server">
    <script>
        var ruta = "<%=ConfigurationManager.AppSettings["ROOT_PATH"]%>";
       
        var idEditar;
        var Declarativo = '';
        $(document).ready(function () {

            //BuscarDepartamentos();
            //Cargar_Provincias("#ddlProvincia", ruta, 'N');
            //Cargar_Provincias("#ddlProvinciaE", ruta, 'N');
            //Cargar_Provincias("#ddlProvinciaBusqueda", ruta, 'N');
            

           <%-- getTipoTributos("#<%=cboTipoTributo.ClientID%>");
            getProvincias("#<%=cboTipoTributo.ClientID %>");
            getProvincias("#<%=cboTipoTributo.ClientID %>");--%>
           // var SolUsoDev = $("#ddlSoloUsoDev").val();
           //
            //llamar del loading
            llenarCombo("#<%=cboTipoTributos.ClientID %>")
           // llenarCombo();
            //llenarComboPrueba();
            BuscarTributos();
            document.getElementById('divTablaDepartamentos').style.display = 'block';
            document.getElementById("radioSI").checked = false;
            document.getElementById("radioNO").checked = true;
            document.getElementById("radioDeclarativoSI").checked = false;
            document.getElementById("radioDeclarativoNO").checked = true;

            $('#btnInsertar').click(function () {
                $('#MensajeAlta').html("");
                var Mensaje = '';
                var Masivo = '';
                
                Mensaje = ControlarValoresInsertar();
                if (document.getElementById("radioSI").checked) {
                    
                    Masivo = $("#radioSI").val();
                   
                    //document.getElementById("radioNO").checked = false;
                }
                if (document.getElementById("radioNO").checked) {
                    Masivo = $("#radioNO").val();
                    
                }
                if (document.getElementById("radioDeclarativoSI").checked) {
                    Declarativo = $("#radioDeclarativoSI").val();
                }
                if (document.getElementById("radioDeclarativoNO").checked) {
                    Declarativo = $("#radioDeclarativoNO").val();
                }

                if (Mensaje == '') {
                    var Parametros = '';
                  //BORRAR  Parametros = Cargar_Parametro("NOMBRE", $("#txtNombre").val(), Parametros);
                    Parametros = Cargar_Parametro("TRIBUTO_ID", $("#<%=cboTipoTributos.ClientID %>").val(),Parametros);

                    $.ajax({
                        url: "ParemetrizarTributos.aspx/Insertar",
                        type: "post",
                        data: "{TRIBUTO_ID: '" + $("#<%=cboTipoTributos.ClientID %>").val() +"', MASIVO: '" +Masivo +"',DECLARATIVO: '"+Declarativo+"'}",
                        contentType: "application/json",
                        success: function (data) {
                            $('#divLoading').hide();
                            //$('#loading').hide();

                            BuscarTributos();
                            llenarCombo("#<%=cboTipoTributos.ClientID %>");
                            document.getElementById("radioSI").checked = false;
                            document.getElementById("radioNO").checked = true;
                            document.getElementById("radioDeclarativoSI").checked = false;
                            document.getElementById("radioDeclarativoNO").checked = true;
                            $('#AltaTipoTributos').modal('hide');
                            limpiar_alta();
                            swal("El Tributo se inserto correctamente!", "", "success");
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            $('#MensajeAlta').html("<div class='alert alert-danger' role='alert'><strong>Error al insertar los datos.</strong></div>");
                        }
                    });
                }
                else
                    $('#MensajeAlta').html("<div class='alert alert-danger' role='alert'><strong>" + Mensaje + "</strong></div>");
            });

            $('#btnEditar').click(function () {
                $('#MensajeEdicion').html("");
                var Mensaje = '';

                Mensaje = ControlarValoresEditar();

                if (Mensaje == '') {
                    var Parametros = '';
                    Parametros = Cargar_Parametro("ID_DEPARTAMENTO", idEditar, Parametros);
                    Parametros = Cargar_Parametro("NOMBRE", $("#txtNombreE").val(), Parametros);
                    Parametros = Cargar_Parametro("PROVINCIA_ID", $("#<%=ddlProvinciaE.ClientID %>").val(), Parametros);

                    $.ajax({
                        url: "DepartamentosListado.aspx/Editar",
                        type: "post",
                        data: Parametros,
                        contentType: "application/json",
                        success: function (data) {
                            $('#divLoading').hide();
                            //$('#loading').hide();

                            BuscarDepartamentos();

                            $('#divEditar').modal('hide');
                            limpiar_edicion();
                            swal("El departamento se modifico correctamente!", "", "success");

                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            $('#MensajeEdicion').html("<div class='alert alert-danger' role='alert'><strong>Error al modificar los datos." + xhr.responseJSON.Message + "</strong></div>");
                        }
                    });
                }
                else
                    $('#MensajeEdicion').html("<div class='alert alert-danger' role='alert'><strong>" + Mensaje + "</strong></div>");
            });

            $('#btnAlta').click(function () {

                if ($("#<%=cboTipoTributos.ClientID %>").val() != '0') {
                    var idProvinciaAlta = $("#<%=cboTipoTributos.ClientID %>").val();
                    $("#<%=cboTipoTributos.ClientID %>").val(idProvinciaAlta);
                }

            });

        });
        //pasar id juridiccion
        //funcion para buscar los tributos
        function BuscarTributos() {
            var Parametros = '';
      
            $.ajax({
                url: "ParemetrizarTributos.aspx/BuscarTributos",
                type: "post",
                contentType: "application/json",
              
                success: function (data) {
                    $('#divLoading').hide();
                    //$('#loading').hide();
                    var TributoListado = [];

                    for (i = 0; i < data.d.length; i++) {

                        var Delete = '<a href="#" onclick="return Borrar(' + data.d[i].ID_TIPO_TIBUTO + ')"  class="btn btn-danger-alt btn-xs"><span class="glyphicon glyphicon glyphicon-trash"></span></a>';

                        TributoListado.push([data.d[i].CONCEPTO,data.d[i].MASIVO,data.d[i].DECLARATIVO ,Delete]);
                    }
                    var ColumnaAlineacion = '1,C'; //NUMERO DE COLUMNA,I/C/D --IZQUIERDA/CENTRO/DERECHA 
                    Dar_Formato_Tabla_Alineacion($('#TablaTributo'), TributoListado, ColumnaAlineacion);
                    llenarCombo("#<%=cboTipoTributos.ClientID %>");

                },
                error: function (xhr, ajaxOptions, thrownError) {

                }
            });
        }
        //fin de la funcion buscar tributo

        //llenarCombo
        function llenarCombo(ddlComboTributo) {
            //st = 'success';
            $.ajax({
                
                url: "ParemetrizarTributos.aspx/getTipoTributos",
                type: "post",
                contentType: "application/json",
                success: function (data,st) {
                  if (st == 'success') {
                        var json = JSON.parse(data.d);
                        if (json != null) {

                            $(ddlComboTributo).empty();
                            $(ddlComboTributo).append('<option value="0" selected="selected">--Seleccione--</option>');

                            json.forEach(function (e) {

                                $(ddlComboTributo).append($("<option></option>").val(e.ID_TIPO_TIBUTO).html(e.CONCEPTO));

                            });
                        }
                     else {
                            $(ddlComboTributo).empty().append('<option selected="selected" value="0">No disponible<option>');
                     }

                  }
                },
                failure: function (data) {
                    alert(data.d);
                }
            });
        };

      


        
        function ControlarValoresInsertar() {
            var Mensaje = '';



            if ($("#<%=cboTipoTributos.ClientID %>").val() == "0") {
                Mensaje = "Por favor seleccione una Tipo Tributo.";
                return Mensaje;
            }

            return Mensaje;
        }

        function ControlarValoresEditar() {
            var Mensaje = '';

            if ($("#txtNombreE").val() == '') {
                Mensaje = "Por favor Ingrese el nombre.";
                return Mensaje;
            }

            if ($("#<%=ddlProvinciaE.ClientID %>").val() == "0") {
                Mensaje = "Por favor seleccione una Provincia.";
                return Mensaje;
            }

            return Mensaje;
        }

        function Borrar(id) {
            //var r = confirm("¿Esta por eliminar el registro desea continuar?");
            $('#Mensaje').html("");
            limpiar_alta();
            
            swal({
                //title: "¿Está seguro?",
                text: "¿Está seguro de querer eliminar este registro?",
                icon: "warning",
                buttons: true,
                dangerMode: true,
                buttons: ["Cancelar!", "Aceptar"],
            })
                .then((willDelete) => {

                    if (willDelete) {
                        $('#divLoading').show();
                        $.ajax({
                            url: "ParemetrizarTributos.aspx/Borrado",
                            type: "post",
                            data: "{PARAMETROTIPOTRIBUTO: '" + id + "'}",
                            contentType: "application/json",
                            success: function (data) {
                                BuscarTributos();
                                swal("El Tributo se elimino correctamente!", "", "success");
                               // alertify.alert("Registro eliminado correctamente.");
                            },
                            error: function (xhr, ajaxOptions, thrownError) {
                                BuscarTributos();
                                swal("No se puede borrar", "No se puede borrar un TipoTributo ", "warning");
                                //$('#Mensaje').html("<div class='alert alert-danger' role='alert'><strong>" + xhr.responseJSON.Message + "</strong></div>"); 
                            }
                        });
                    }

                });
        }

        <%--function limpiar_edicion() {
            $("#txtNombreE").val("");
            $("#<%=ddlProvinciaE.ClientID %>").val("0");
            //$("#ddlProvinciaE").val('');       
            //$("#ddlProvinciaE").multiselect('refresh');
            $('#MensajeEdicion').html("");
        }--%>

        function limpiar_alta() {
            
            $("#<%=cboTipoTributos.ClientID %>").val("0");
            $('#MensajeAlta').html("");
        }

      <%--  function Editar(id) {
            $('#divEditar').modal('show');
            $.ajax({
                url: "DepartamentosListado.aspx/TraerparaEditar",
                type: "post",
                data: "{DEPARTAMENTO_ID: '" + id + "'}",
                contentType: "application/json",
                success: function (data) {
                    idEditar = data.d.ID_DEPARTAMENTO;
                    var idProvincia = data.d.ID_PROVINCIA;
                    $("#txtNombreE").val(data.d.N_DEPARTAMENTO);
                    $("#<%=ddlProvinciaE.ClientID %>").val(idProvincia);

                    //$('#ddlProvinciaE').multiselect('select', [data.d.ID_PROVINCIA]);
                    //$('#ddlProvinciaE').multiselect('rebuild');                               
                },
                error: function (xhr, ajaxOptions, thrownError) {

                }
            });
        }--%>
    </script>
    <div class="contenido">
    <h3>CONSULTA DE TIPO TRIBUTOS</h3>
        <p>Pantalla para vincular los Tributos a visualizar</p>
    </div>
    <br />
   <%-- <div id="loading">
        <div id="img">
            <div style="width: 100%; height: auto;">
                <img src="<%=ConfigurationManager.AppSettings["ROOT_PATH"] + "/Estilos/Imagenes/gifCarga.gif"%>" style="width: 95px; height: auto;" />
                <img src="<%=ConfigurationManager.AppSettings["ROOT_PATH"] + "/Estilos/Imagenes/tenor.gif"%>" style="width: 175px; height: auto; margin-top:5px;">
            </div>
            <div style="width: 100%; text-align: center;">
                <h5 style="color: rgba(0,0,0, .5);">Cargando...</h5>
            </div>
        </div>
    </div>--%>
    
    <div id="divLoading" class="text-center">
         <div id="Mensaje"></div>
        <img src="<%=ConfigurationManager.AppSettings["ROOT_PATH"] + "/Estilos/Imagenes/loading.gif"%>" width="40" height="40" class="ui-icon-image" />
    </div>

    <div class="contenido">
       
        <br />
        <div id="divTablaDepartamentos">
            <table style="width: 100%" class="table table-striped table-bordered" id="TablaTributo">
                <thead>
                    <tr class="Estilo_Fila">
                        <th class="Estilo_Columna">TRIBUTO</th>
                        <th class="Estilo Columuna">MASIVO</th>
                        <th class="Estilo Columuna">DECLARATIVO</th>                                     
                        <th class="Estilo_Columna">BORRAR</th>
                      <%--  <th class="Estilo_Columna">Masivo</th>--%>
                    </tr>
                </thead>
            </table>
        </div>
        <button type="button" id="btnAlta" class="btn btn-primary " data-toggle="modal" data-target="#AltaTipoTributos">
            Agregar
        </button>

    </div>

    <div class="modal fade" id="AltaTipoTributos" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
               <%-- <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">ALTA DEPARTAMENTOS</h4>
                </div>--%>

                <div class="modal-body" style="padding-bottom: 10px;">
                    <div id="panelNo" class="panel panel-primary">                        
                        <div class="panel-heading">
                            <h2 class="panel-title">ALTA TIPO TRIBUTO</h2>
                            
                        </div>
                        <div class="panel-body">
                            <div id="panelD" class="panel panel-default" style="padding-bottom: 15px">
                                <div class="panel-heading">
                                    <h2 class="panel-title">Datos de alta de Tipo Tributo</h2>
                                                        <div id="MensajeAlta"></div>
                                </div>
                                <div class="panel-body">
                            <table>
                                <tr>

                                    <td>
                                        <h4>Tipo Tributo:</h4>
                                    </td>
                                    <td>
                                        <div class="col-md-3">
                                            <asp:DropDownList ID="cboTipoTributos" runat="server" CssClass="btn btn-primary dropdown-toggle" Style="width: 253px">
                                                <asp:ListItem Value="0">--Seleccione TipoTributo--</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </td>
                                    <td>
                                    </td>
                                </tr>
                                <tr>
                                   <td><h4>Es Masivo</h4></td>
                                      <td >
                                        <div class="btn-group" data-toggle="buttons">
                                                <input type="radio" id="radioSI"  value="S" name="options" /> SI
                                                <input type="radio" id="radioNO" value="N" name="options" /> NO
                                        </div>
                                     </td>
                                    
                                </tr>
                                <tr>
                                    <td><h4 style="margin-right:10px">Es Declarativo</h4></td>
                                    <td>
                                        <div class="btn-group" data-toggle="buttons">
                                                <input type="radio" id="radioDeclarativoSI"  value="S" name="optionsDeclarativo" /> SI
                                                <input type="radio" id="radioDeclarativoNO" value="N" name="optionsDeclarativo" /> NO
                                        </div>
                                     </td>
                                </tr>
                            </table>
                               
                        </div>
                    </div>
                </div>
                </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="limpiar_alta()" data-dismiss="modal">Cerrar</button>
                    <button type="button" id="btnInsertar" class="btn btn-primary">Insertar</button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="divEditar" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
               <%-- <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="H1">EDICION DEPARTAMENTOS</h4>
                </div>--%>
                <div class="modal-body" style="padding-bottom: 10px;">
                    <div id="panelNo" class="panel panel-primary">                        
                        <div class="panel-heading">
                            <h2 class="panel-title">EDITAR DEPARTAMENTO</h2>
                        </div>
                        <div class="panel-body">
                             <div id="panelD" class="panel panel-default" style="padding-bottom: 15px">
                                <div class="panel-heading">
                                    <h2 class="panel-title">Datos de edicion de departamento</h2>
                                     <div id="MensajeEdicion"></div>
                                </div>
                                <div class="panel-body">
                            <table>
                                <tr>
                                    <td>
                                        <h4>Nombre:</h4>
                                    </td>
                                    <td>
                                        <input id="txtNombreE" type="text" class="form-control" name="txtNombreE" placeholder="NOMBRE" onblur="this.value=this.value.toUpperCase()" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        <h4>Provincia:</h4>
                                    </td>
                                    <td>
                                        <div class="col-md-3">
                                            <asp:DropDownList ID="ddlProvinciaE" runat="server" CssClass="btn btn-primary dropdown-toggle" Style="width: 253px">
                                                <asp:ListItem Value="0">--Seleccione Provincia--</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
                </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="limpiar_edicion()" data-dismiss="modal">Cerrar</button>
                    <button type="button" id="btnEditar" class="btn btn-primary">Grabar</button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

