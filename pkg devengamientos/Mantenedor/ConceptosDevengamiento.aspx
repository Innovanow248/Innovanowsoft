<%@ Page Language="C#" MasterPageFile="~/MasterPage/Ingresos.Master" AutoEventWireup="true" CodeBehind="ConceptosDevengamiento.aspx.cs" Inherits="webIngresos.ConceptosDevengamiento" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphContenidoIngreso" runat="Server">

    <style>
        .btn-ttc {
            color: white;
            text-shadow: 0 -1px 0 rgba(0, 0, 0, 0.25);
            background-color: #ff3d3d;
        }
    </style>

    <script>
        var idEditar = "";
        var idBorrar = "";
        var valorE = '';
        var porcentajeE = '';

        var comboAnioConsulta = "#ddlAnioConsulta";
        var comboAnioClonacion = "#ddlAnioClonacion";

        $(document).ready(function () {

            var comboAnioConsulta = '';
            var conceptoDevengamiento = [];
            $('#contenidoConceptos').hide();
            traerTributos();

            var mensaje = 'ok';

            $('#btnConsulta').click(function () {

                comboAnioConsulta = $("#ddlAnioConsulta").val();
                comboTipoTributo = $("#ddltributo").val();

                var mensaje = controlarValorparaConsultar();
                if (mensaje == "") {

                    var btn = $(this);
                    btn.button('loading');

                    //document.getElementById('concepto').style.display = 'none';
                    conceptoDevengamiento.length = 0;

                    $('#contenidoConceptos').show();

                    $('#divClonar').hide();
                    if (TieneAccion('CLONAR', Nombre_Pagina())) $('#divClonar').show();

                    traerConceptosDevengamiento(comboAnioConsulta, comboTipoTributo);

                    $('#btnConsulta').button('reset');

                } else {
                    swal("Parece que faltan datos", mensaje, "warning");

                }
            });

            $('#radioPorcentajeE').bind("change", function () {
                $('#radioValorE').prop('checked', false);
                $("#txtMontoE").val("");
                $("#txtMontoE").prop('placeholder', 'Porcentaje');
                $("#txtMontoE").prop('disabled', false);
            });
            $('#radioValorE').bind("change", function () {
                $('#radioPorcentajeE').prop('checked', false);
                $("#txtMontoE").val("");
                $("#txtMontoE").prop('placeholder', 'Valor');
                $("#txtMontoE").prop('disabled', false);
            });

            $('#btnModalGuardarE').click(function () {

                radioValidacionE();

                if (mensaje == 'ok') {
                    $.ajax({
                        url: "ConceptosDevengamiento.aspx/Editar",
                        type: "post",
                        data: "{ ID_TIPOCON_ANIO: '" + idEditar + "', porcentaje: '" + porcentajeE + "', valor: '" + valorE + "' }",
                        //+ "porcentaje: '" + porcentajeE + "', "
                        //+  "valor: '" + valorE + "' }",
                        contentType: "application/json",
                        success: function (data) {

                            $('#modalEditar').modal('hide');
                            traerConceptosDevengamiento(comboAnioConsulta, comboTipoTributo);
                            swal("Modificado!", "Los datos han sido modificados con éxito.", "success");

                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            $('#modalEditar').modal('hide');
                            swal("Hubo un problema!", "Error al modificar datos.", "error");
                        }
                    });


                } else {
                    swal("Parece que faltan datos!", mensaje, "warning");
                }

            });

            $('#btnClonar').click(function () {

                var mensaje = controlarvalorparaclonar()
                if (mensaje == "") {
                    
                    var btn = $(this);
                    btn.button('loading');


                    $.ajax({
                        url: "ConceptosDevengamiento.aspx/getClonarPorAnio",
                        data: "{anioConsulta: '" + $("#ddlAnioConsulta").val() +
                            "', anioClonacion: '" + $("#ddlAnioClonacion").val() +
                            "', tipoTributo: '" + $("#ddltributo").val() +
                            "'}",
                        type: "post",


                        contentType: "application/json",
                        success: function (data) {
                            swal("La clonacion ha sido Exitosa!", mensaje, "success");

                            $("#ddlAnioConsulta").val($("#ddlAnioClonacion").val());

                            traerConceptosDevengamiento($("#ddlAnioClonacion").val(), comboTipoTributo);
                            btn.button('reset');

                        },
                        error: function (xhr, ajaxOptions, thrownError) {

                        }
                    });

                } else {
                    swal("Hubo un Error", mensaje, "error");


                }

            });

            $('#btnBorrar').click(function () {
                
                $.ajax({
                    url: "ConceptosDevengamiento.aspx/Borrar",
                    type: "post",
                    beforeSend: function () {
                        AbrirLoading();
                    },
                    data: "{ID_TIPOCON_ANIO: '" + idBorrar + "'}",
                    contentType: "application/json",
                    async: false,
                    success: function (data) {

                        comboAnioConsulta = $("#ddlAnioConsulta").val();
                        comboTipoTributo = $("#ddltributo").val();
                        $('#divBorrar').modal('hide');
                        traerConceptosDevengamiento(comboAnioConsulta, comboTipoTributo);
                        swal("Baja realizada!", "Los datos han sido dados de baja con éxito.", "success");
                        CerrarLoading();
                    },
                    error: function (xhr, ajaxOptions, thrownError) {
                        $('#divBorrar').modal('hide');
                        swal("Hubo un problema!", "Error al dar de baja.", "error");
                        CerrarLoading();
                    }
                });
            });

        });

        function controlarvalorparaclonar() {


            if ($("#ddlAnioClonacion").val() == 0) {

                return "Debe Seleccionar el año de clonacion!";

            }

            if ($("#ddlAnioConsulta").val() == 0) {

                return "Debe Seleccionar el año de consulta!";

            }

            if ($("#ddlAnioConsulta").val() == $("#ddlAnioClonacion").val()) {

                return "El año de consulta debe ser diferente al año de clonacion!";
            }

            return '';
        }

        var traerConceptosDevengamiento = function (p_comboAnioConsulta, p_comboTipoTributo) {
            $.ajax({
                url: "ConceptosDevengamiento.aspx/getConceptosDevengamiento",
                type: "post",
                data: "{ ANIO_CONSULTA: '" + p_comboAnioConsulta
                    + "', TIPO_TRIBUTO : '" + p_comboTipoTributo
                    + "' }",
                //            +  id_jurisdiccion: '" + id_jurisdiccion
                //            + "',id_tipo_tributo : '" + valor + "'}",
                contentType: "application/json",
                success: function (data) {

                    if (data.d.length != 0) {

                        var conceptoDevengamiento = [];
                        var tablaId = "#concepto";
                        var AccionEditar = TieneAccion('MODIFICACION', Nombre_Pagina());
                        var AccionBaja = TieneAccion('BAJA', Nombre_Pagina());

                        for (i = 0; i < data.d.length; i++) {

                            if (data.d[i].IMPACTO == '-') {
                                var impacto = 0;
                            } else if (data.d[i].IMPACTO == '+') {
                                var impacto = 1;
                            }

                            var idCodCatTipo = data.d[i].ID_CODIGO_CATEGORIA;
                            var Editar = '';
                            var Borrar = '';
                            var fechabaja = mostrarBaja(data);

                            if (fechabaja == '') {

                                var descripcion = "'" + data.d[i].DESCRIPCION + "'";
                                if (AccionEditar)
                                    Editar = '<a href="#" onclick="return editar(' + data.d[i].ID_TIPO_CONCEPTO_ANIO + ', ' + descripcion + ', ' + impacto + ', ' + data.d[i].PORCENTAJE + ', ' + data.d[i].VALOR + ')"  class="btn btn-warning-alt btn-xs"><span class="glyphicon glyphicon glyphicon-pencil"></span></a>';
                                if (AccionBaja)
                                    Borrar = '<a href="#" onclick="return Borrar(' + data.d[i].ID_TIPO_CONCEPTO_ANIO + ')"  class="btn btn-danger-alt btn-xs"><span class="glyphicon glyphicon glyphicon-trash"></span></a>';
                            }
                            
                            conceptoDevengamiento.push([data.d[i].ANIO_EJERCICIO, data.d[i].DESCRIPCION, data.d[i].IMPACTO, data.d[i].PORCENTAJE, data.d[i].VALOR, fechabaja, Editar, Borrar]);

                        }


                        cargarTabla(tablaId, conceptoDevengamiento, 5);

                    } else {
                        $('#contenidoConceptos').hide();
                        swal("Parece que faltan datos", "No hay datos para esa búsqueda", "warning");
                    }

                },
                error: function (xhr, ajaxOptions, thrownError) {

                }
            });
        }




        //tributos
        var traerTributos = function () {
            $.ajax({
                type: "POST",
                url: "ConceptosDevengamiento.aspx/getTiposTributo",
                //data: "{ idJurisdiccion: '" + idJurisdiccion + "'}",
                contentType: "application/json; charset=utf-8",
                beforeSend: function () {
                    AbrirLoading();
                },
                dataType: "json",
                success: function (data, st) {
                    if (st == 'success') {
                        if (data.d.length > 0) {

                            $("#ddltributo").empty().append('<option selected="selected" value="0">--Seleccione el Tributo--</option>');
                            $.each(data.d, function () {

                                $("#ddltributo").append($("<option></option>").val(this['TIPO_TRIBUTO']).html(this['CONCEPTO']));
                            });

                        }
                        else {
                            $("#ddltributo").empty().append('<option selected="selected" value="0">No disponible<option>');
                        }

                    }
                    CerrarLoading();
                },

                failure: function (data) {
                    CerrarLoading();
                    alert(data.d);

                }
            });
        }

        function controlarValorparaConsultar() {

            if ($("#ddlAnioConsulta").val() == 0) {
                return "Debe Seleccionar el año de consulta!";
            }
            return '';
        }

        var radioValidacionE = function () {

            if ($("#radioPorcentajeE").prop('checked') == true) {
                porcentajeE = $("#txtMontoE").val();
                valorE = '0';
            } else if ($("#radioValorE").prop('checked') == true) {
                valorE = $("#txtMontoE").val();
                porcentajeE = '0';
            } else {
                mensaje = '';
            }

        }

        var editar = function (id, descripcion, impacto, porcentaje, valor) {

            $('#modalEditar').modal('show');
            //var porcentajeData = porcentaje
            //var valorData = valor;
            var impactoEditar = '';

            if (impacto == 1) {
                var impactoEditar = '+';
            } else if (impacto == 0) {
                var impactoEditar = '-';
            }

            idEditar = id;
            valorE = valor;
            porcentajeE = porcentaje;

            $("#txtDescripcionE").prop('disabled', true);
            $("#txtDescripcionE").val(descripcion);


            $("#<%=ddlImpactoE.ClientID %>").val(impactoEditar);

            $("#radioPorcentajeE").prop('checked', false);
            $("#radioValorE").prop('checked', false);
            $("#txtMontoE").prop('disabled', false);

            $("#btnModalGuardarE").prop('disabled', false);
            $("#btnModalGuardarE").show();

            if (porcentaje != "0") {
                $("#radioPorcentajeE").prop('checked', true);
                $("#txtMontoE").val(porcentaje);

            } else if (valor >= "1") {
                $("#radioValorE").prop('checked', true);
                $("#txtMontoE").val(valor);
            }

            $("#radioPorcentajeE").prop('disabled', true);
            $("#radioValorE").prop('disabled', true);
            $("#<%=ddlImpactoE.ClientID %>").prop('disabled', true);

        }

        function Borrar(id) {
            $('#divBorrar').modal('show');
            idBorrar = id;
        }

        function mostrarBaja(data) {
            if (data.d[i].FEC_BAJA != null) {
                var str = data.d[i].FEC_BAJA.replace('/Date(', '');
                var str2 = str.replace(')/', '');
                var fecha = new Date(parseInt(str2));
                var date = getFormattedDate(fecha);
            }
            else {
                var date = '';
            }
            return date;
        }

    </script>

    <div id="loading">
        <div id="img">
            <div style="width: 100%; height: auto;">
                <img src="<%=ConfigurationManager.AppSettings["ROOT_PATH"] + "/Estilos/Imagenes/gifCarga.gif"%>" style="width: 95px; height: auto;">
            </div>
            <div style="width: 100%; text-align: center;">
                <h5 style="color: rgba(0,0,0, .5);">Procesando...</h5>
            </div>
        </div>
    </div>
    <div class="contenido">
        <h3>Consulta de Conceptos de Devengamiento</h3>
        <p>Seleccione el año de consulta para buscar los Conceptos.</p>
        <br />
        <div class="">

            <label for="ddlAnioConsulta">
                <h4>Año de Consulta:</h4>
            </label>
            <select id="ddlAnioConsulta" name="ddlAnioConsulta" class="btn btn-primary dropdown-toggle">
                <option value="0">--Seleccione el año--</option>
                <option value="1996">1996</option>
                <option value="1997">1997</option>
                <option value="1998">1998</option>
                <option value="1999">1999</option>
                <option value="2000">2000</option>
                <option value="2001">2001</option>
                <option value="2002">2002</option>
                <option value="2003">2003</option>
                <option value="2004">2004</option>
                <option value="2005">2005</option>
                <option value="2006">2006</option>
                <option value="2007">2007</option>
                <option value="2008">2008</option>
                <option value="2009">2009</option>
                <option value="2010">2010</option>
                <option value="2011">2011</option>
                <option value="2012">2012</option>
                <option value="2013">2013</option>
                <option value="2014">2014</option>
                <option value="2015">2015</option>
                <option value="2016">2016</option>
                <option value="2017">2017</option>
                <option value="2018">2018</option>
                <option value="2019">2019</option>
                <option value="2020">2020</option>
                <option value="2021">2021</option>
                <option value="2022">2022</option>
                <option value="2023">2023</option>
                <option value="2024">2024</option>
                <option value="2025">2025</option>
                <option value="2026">2026</option>
            </select>

            <label for="ddltributo">
                <h4 style="padding-left: 30px">Tipo Tributo:</h4>
            </label>
            <select id="ddltributo" name="ddltributo" class="btn btn-primary dropdown-toggle" style="width: 250px">
            </select>

            <div>
                <br />
                <button type="button" id="btnConsulta" class="btn btn-primary">Consultar</button>
            </div>
            <br />
            <div id="contenidoConceptos">
                <table width="100%" class="table table-striped table-bordered" id="concepto" cellspacing="0">
                    <thead>
                        <tr>
                            <th>AÑO DE EJERCICIO</th>
                            <th>DESCRIPCIÓN</th>
                            <th>IMPACTO</th>
                            <th>PORCENTAJE</th>
                            <th>VALOR</th>
                            <th>FECHA BAJA</th>
                            <th>EDITAR</th>
                            <th>BAJA</th>
                        </tr>
                    </thead>
                </table>
                <div id="divClonar">
                    <h3>Operacion a Realizar</h3>
                </br>
                <table>
                    <tr>
                        <td>
                            <button type="button" id="btnClonar" class="btn btn-ttc">Clonar</button>
                        </td>
                        <td>
                            <h4 style="margin-left: 50px;">Año Clonacion Destino</h4>
                        </td>
                        <td>
                            <select id="ddlAnioClonacion" name="ddlAnioClonacion" class="btn btn-ttc dropdown-toggle" style="margin-left: 5px;">
                                <option value="0">--Seleccione el año--</option>
                                 <option value="1996">1996</option>
                                 <option value="1997">1997</option>
                                 <option value="1998">1998</option>
                                 <option value="1999">1999</option>
                                 <option value="2000">2000</option>
                                 <option value="2001">2001</option>
                                 <option value="2002">2002</option>
                                 <option value="2003">2003</option>
                                 <option value="2004">2004</option>
                                 <option value="2005">2005</option>
                                 <option value="2006">2006</option>
                                 <option value="2007">2007</option>
                                 <option value="2008">2008</option>
                                 <option value="2009">2009</option>
                                 <option value="2010">2010</option>
                                 <option value="2011">2011</option>
                                 <option value="2012">2012</option>
                                <option value="2013">2013</option>
                                <option value="2014">2014</option>
                                <option value="2015">2015</option>
                                <option value="2016">2016</option>
                                <option value="2017">2017</option>
                                <option value="2018">2018</option>
                                <option value="2019">2019</option>
                                <option value="2020">2020</option>
                                <option value="2021">2021</option>
                                <option value="2022">2022</option>
                                <option value="2023">2023</option>
                                <option value="2024">2024</option>
                                <option value="2025">2025</option>
                                <option value="2026">2026</option>
                            </select>
                        </td>
                    </tr>
                </table>
                </div>

                
                <div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="modalEditar" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static" data-keyboard="false">
            <div class="vertical-alignment-helper">
                <div class="modal-dialog vertical-align-center" role="document">
                    <div class="modal-content">
                        <div class="modal-body">
                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h3 class="panel-title" id="H5">EDITAR CONCEPTO</h3>
                                </div>
                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="descripcion" class="control-label">Descripción</label>
                                            <input type="text" name="descripcion" class="form-control" id="txtDescripcionE" placeholder="Ingrese la Descripción" value="" />
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-4">
                                            <label for="lblMontoE" class="control-label">Monto</label>
                                            <div class="auto-style1">
                                                <div id="radioBtnMontoE" class="btn-group" data-toggle="buttons">
                                                    <label style="margin-right: 7px;">
                                                        <input type="radio" id="radioPorcentajeE" value="01" name="radioPorcentajeE" />
                                                        Porcentaje
                                                    </label>

                                                    <label>
                                                        <input type="radio" id="radioValorE" value="02" name="radioValorE" />
                                                        Valor
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <label for="txtMontoE" class="control-label"></label>
                                            <input id="txtMontoE" type="text" class="form-control" name="Monto" placeholder="" disabled onkeypress="return solonumeros(event)" />

                                        </div>
                                        <%--<div class="col-md-4">
                                        <label for="porcentaje" class="control-label"><span style="color: red">* </span>Porcentaje</label>
                                        <input type="text" name="porcentaje" class="form-control" id="txtPorcentajeE" placeholder="Porcentaje" value="" onkeypress="return solonumeros(event);"/>
                                    </div>
                                    <div class="col-md-4">
                                        <label for="valor" class="control-label"><span style="color: red">* </span>Valor</label>
                                        <input type="text" name="valor" class="form-control" id="txtValorE" placeholder="Valor" value="" onkeypress="return solonumeros(event);"/>
                                    </div>--%>
                                        <div class="col-md-4">
                                            <label for="ddlImpactoE" class="control-label">Impacto</label>
                                            <asp:DropDownList ID="ddlImpactoE" runat="server" Class="btn btn-primary dropdown-toggle" Style="width: 100%">
                                                <asp:ListItem Value="">Seleccionar</asp:ListItem>
                                                <asp:ListItem Value="-">-</asp:ListItem>
                                                <asp:ListItem Value="+">+</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>

                                <div class="modal-footer">
                                    <button type="button" id="btnModalCerrarE" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                                    <button type="button" id="btnModalGuardarE" class="btn btn-primary">Grabar</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal fade" id="divBorrar" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
            <div class="vertical-alignment-helper">
                <div class="modal-dialog vertical-align-center" role="document">
                    <div class="modal-content">
                        <div class="modal-body" style="padding-bottom: 0">
                            <div id="panelNo" class="panel panel-primary">
                                <div class="panel-heading">
                                    <h4 class="modal-title" id="H3">DAR DE BAJA</h4>
                                </div>
                                <div id="footer_borrar" class="modal-footer">
                                    <asp:Label ID="Label1" runat="server" Text="¿Desea dar de baja el Registro Seleccionado?" />
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">No</button>
                                    <button type="button" id="btnBorrar" class="btn btn-primary">Si</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
</asp:Content>
