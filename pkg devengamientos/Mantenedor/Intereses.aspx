<%@ Page Language="C#" MasterPageFile="~/MasterPage/Ingresos.Master" AutoEventWireup="true" CodeBehind="Intereses.aspx.cs" Inherits="webIngresos.Mantenedor.Intereses" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphContenidoIngreso" runat="Server">

    <style>

        .modal-ku {
              width: 400px;
              margin: auto;
            }
    </style>

    <script>

        var var_TIPO_TRIBUTO;
        var var_ID_INTERES_SELECCIONADO;


        $(document).ready(function () {

            TributoxJurisdiccionTodos("#ddltributo");
            TributoxJurisdiccionTodos("#ddlTiposTributosA");
            TributoxJurisdiccion("#ddlTiposTributosE");
            TributoxJurisdiccionTodos("#ddlTiposTributosV");

            $('#btnConsulta').click(function () {


                var_TIPO_TRIBUTO = $('#ddltributo').val();

                if (var_TIPO_TRIBUTO == "0") {
                    Alerta('Seleccione un filtro para la consulta.');
                }
                else if (var_TIPO_TRIBUTO == "1") {
                    mostrar("DivTabla");
                    TraerTodos();
                }
                else {

                    mostrar("DivTabla");
                    TraerIntereses();
                }

            });

            $('#btnAgregar').click(function () {
                $('#modalAgregar').modal('show');

            });

            $('#btnEditar').click(function () {
                $('#modalEditar').modal('show');

            });

            $('#btnModalGuardar').click(function () {
                var Parametros = '';
                var Correcto = true;

                var fechaDesde = $('#txtFechaDesde').val();
                var fechaHasta = $('#txtFechaHasta').val();

                //--------------------validar---------------------------------//

                Correcto = Correcto && validar_campo_obligatorio('#ddlTiposTributosA', 'Seleccione un tributo.');
                Correcto = Correcto && validar_campo_obligatorio('#txtMontoA', 'Ingrese un porcentual.');
                Correcto = Correcto && validar_campo_obligatorio('#txtFechaDesde', 'Ingrese una fecha desde.');
                Correcto = Correcto && validar_campo_obligatorio('#txtFechaHasta', 'Ingrese una fecha hasta.');
                Correcto = Correcto && validarFechaDesdeHasta(fechaDesde, fechaHasta);


                //------------------------------------------------------------//

                if (Correcto) {


                    Parametros = Cargar_Parametro("P_TIPO_TRIBUTO", $("#ddlTiposTributosA").val(), Parametros);

                    var porcentual = $("#txtMontoA").val();
                    if (porcentual == '') porcentual = 0;

                    Parametros = Cargar_Parametro("P_PORCENTUAL", transformar_a_double(porcentual), Parametros);
                    Parametros = Cargar_Parametro("P_OBSERVACION", $("#txtObservacion").val(), Parametros);
                    Parametros = Cargar_Parametro("P_FECHA_DESDE", fechaDesde, Parametros);
                    Parametros = Cargar_Parametro("P_FECHA_HASTA", fechaHasta, Parametros);

                    $.ajax({
                        url: "Intereses.aspx/INSERTAR_INTERES",
                        type: "post",
                        beforeSend: function () {
                            AbrirLoading();
                        },
                        data: Parametros,
                        contentType: "application/json",
                        success: function (data) {

                            if (data.d == "OK") {
                                mostrar("DivTabla");
                                $('#modalAgregar').modal('hide');

                                var_TIPO_TRIBUTO = $("#ddlTiposTributosA").val();

                                Exito("El interés se agregó correctamente.");

                                if (var_TIPO_TRIBUTO == '1') {
                                    TraerTodos();
                                }
                                else {

                                    TraerIntereses();
                                }
                                limpiar_alta();
                                CerrarLoading();
                            }
                            else {
                                CerrarLoading();
                                Error(data.d);
                            }

                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            var err = eval("(" + xhr.responseText + ")");
                            Error(err.Message);
                            CerrarLoading();

                        }
                    });
                }
            });

            $('#btnModalGuardarE').click(function () {
                var Parametros = '';
                var Correcto = true;

                var fechaDesde = $('#txtFechaDesdeE').val();
                var fechaHasta = $('#txtFechaHastaE').val();

                //--------------------validar---------------------------------//

                Correcto = Correcto && validar_campo_obligatorio('#ddlTiposTributosE', 'Seleccione un tributo.');
                Correcto = Correcto && validar_campo_obligatorio('#txtMontoE', 'Ingrese un porcentual.');
                Correcto = Correcto && validar_campo_obligatorio('#txtFechaDesdeE', 'Ingrese una fecha desde.');
                Correcto = Correcto && validar_campo_obligatorio('#txtFechaHastaE', 'Ingrese una fecha hasta.');
                Correcto = Correcto && validarFechaDesdeHastaE(fechaDesde, fechaHasta);


                //------------------------------------------------------------//

                if (Correcto) {

                    Parametros = Cargar_Parametro("P_ID_CONFIGURACION", var_ID_INTERES_SELECCIONADO, Parametros);
                    Parametros = Cargar_Parametro("P_TIPO_TRIBUTO", $("#ddlTiposTributosE").val(), Parametros);
                    Parametros = Cargar_Parametro("P_TIPO_TRIBUTO", $("#ddlTiposTributosE").val(), Parametros);

                    var porcentual = $("#txtMontoE").val();
                    if (porcentual == '') porcentual = 0;

                    Parametros = Cargar_Parametro("P_PORCENTUAL", transformar_a_double(porcentual), Parametros);
                    Parametros = Cargar_Parametro("P_OBSERVACION", $("#txtObservacionE").val(), Parametros);
                    Parametros = Cargar_Parametro("P_FECHA_DESDE", fechaDesde, Parametros);
                    Parametros = Cargar_Parametro("P_FECHA_HASTA", fechaHasta, Parametros);

                    $.ajax({
                        url: "Intereses.aspx/EDITAR_INTERES",
                        type: "post",
                        beforeSend: function () {
                            AbrirLoading();
                        },
                        data: Parametros,
                        contentType: "application/json",
                        success: function (data) {

                            if (data.d == "OK") {
                                mostrar("DivTabla");
                                $('#modalEditar').modal('hide');

                                var_TIPO_TRIBUTO = $("#ddlTiposTributosE").val();

                                Exito("Los cambios se guardaron con éxito.");

                                TraerIntereses();
                                var_ID_INTERES_SELECCIONADO = null;
                                //limpiar_alta();
                                CerrarLoading();

                            }
                            else {
                                CerrarLoading();
                                Error(data.d);
                            }

                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            Error(thrownError);
                            CerrarLoading();

                        }
                    });
                }
            });
        });


        function TraerIntereses() {

            $('#ddltributo').val(var_TIPO_TRIBUTO);

            var Parametros = '';
            Parametros = Cargar_Parametro("P_TIPO_TRIBUTO", var_TIPO_TRIBUTO, Parametros);


            $.ajax({
                url: "Intereses.aspx/TRAER_INTERESES",
                type: "post",
                beforeSend: function () {
                    AbrirLoading();
                },
                contentType: "application/json",
                data: Parametros,
                success: function (data) {
                    //var_TIPO_TRIBUTO = null;
                    mostrar("DivTabla");
                    CargarGrillaIntereses(data);

                    CerrarLoading();

                },
                error: function (xhr, ajaxOptions, thrownError) {
                    Error(thrownError);
                    CerrarLoading();
                }
            });
        }

        function TraerTodos() {

            //$('#ddltributo').val(var_TIPO_TRIBUTO);

            $.ajax({
                url: "Intereses.aspx/TRAER_TODOS",
                type: "post",
                beforeSend: function () {
                    AbrirLoading();
                },
                contentType: "application/json",
               // data:,
                success: function (data) {

                    CargarGrillaIntereses(data);

                },
                error: function (xhr, ajaxOptions, thrownError) {
                    Error(thrownError);
                    CerrarLoading();
                }
            });
        }

        function CargarGrillaIntereses(data) {

            AbrirLoading();

            var intereses = [];

            for (i = 0; i < data.d.length; i++) {

                var Ver = "<a href='#' onclick='return Ver(" + data.d[i].ID_CONFIGURACION + ");'  class='btn btn-primary btn-xs'><span class='glyphicon glyphicon-eye-open'></span></a>";
                var Editar = "<a href='#' onclick='return Editar(" + data.d[i].ID_CONFIGURACION + ");'  class='btn btn-warning-alt btn-xs'><span class='glyphicon glyphicon-pencil'></span></a>";

                var tributo = data.d[i].TRIBUTO;
                var porcentual = data.d[i].PORCENTUAL;
                var fechaDesde = mostrarBaja(data.d[i].FECHA_DESDE);
                var fechaHasta = mostrarBaja(data.d[i].FECHA_HASTA);

                intereses.push([
                    tributo,
                    transformar_double_a_string(porcentual),
                    fechaDesde,
                    fechaHasta,
                    Ver,
                    Editar
                ]);
            }

            Dar_Formato_Tabla_Alineacion_Baja($('#TablaIntereses'), intereses);

            mostrar("DivTabla");

            CerrarLoading();

        }

        function Ver(ID_CONFIGURACION) {

            $.ajax({
                url: "Intereses.aspx/TRAER_PARA_EDITAR",
                type: "post",
                beforeSend: function () {
                    AbrirLoading();
                },
                data: "{ID_CONFIGURACION: '" + ID_CONFIGURACION + "'}",
                contentType: "application/json",
                success: function (data) {

                    CerrarLoading();

                    $('#modalVer').modal('show');


                    var tipo_tributo = data.d.TIPO_TRIBUTO;
                    var porcentual = transformar_double_a_string(data.d.PORCENTUAL);
                    var observacion = data.d.OBSERVACION;
                    var fecha_desde = data.d.FECHA_DESDE;
                    var fecha_hasta = data.d.FECHA_HASTA;

                    $("#ddlTiposTributosV").val(tipo_tributo);
                    $("#txtMontoV").val(porcentual);
                    $("#txtObservacionV").val(observacion);
                    document.getElementById('txtFechaDesdeV').valueAsDate = new Date(parseInt(fecha_desde.substr(6)));
                    document.getElementById('txtFechaHastaV').valueAsDate = new Date(parseInt(fecha_hasta.substr(6)));

                },
                error: function (xhr, ajaxOptions, thrownError) {
                    CerrarLoading();
                    var err = eval("(" + xhr.responseText + ")");
                    Error(err.Message);
                }
            });
        }

        function Editar(ID_CONFIGURACION) {

            $.ajax({
                url: "Intereses.aspx/TRAER_PARA_EDITAR",
                type: "post",
                beforeSend: function () {
                    AbrirLoading();
                },
                data: "{ID_CONFIGURACION: '" + ID_CONFIGURACION + "'}",
                contentType: "application/json",
                success: function (data) {

                    CerrarLoading();

                    var_ID_INTERES_SELECCIONADO = ID_CONFIGURACION;

                    $('#modalEditar').modal('show');


                    var tipo_tributo = data.d.TIPO_TRIBUTO;
                    var porcentual = transformar_double_a_string(data.d.PORCENTUAL);
                    var observacion = data.d.OBSERVACION;
                    var fecha_desde = data.d.FECHA_DESDE;
                    var fecha_hasta = data.d.FECHA_HASTA;

                    $("#ddlTiposTributosE").val(tipo_tributo);
                    $("#txtMontoE").val(porcentual);
                    $("#txtObservacionE").val(observacion);
                    document.getElementById('txtFechaDesdeE').valueAsDate = new Date(parseInt(fecha_desde.substr(6)));
                    document.getElementById('txtFechaHastaE').valueAsDate = new Date(parseInt(fecha_hasta.substr(6)));

                },
                error: function (xhr, ajaxOptions, thrownError) {
                    CerrarLoading();
                    var err = eval("(" + xhr.responseText + ")");
                    Error(err.Message);
                }
            });
        }

        function limpiar_alta() {
            var_ID_TIPO_CONCEPTO = null;

            $("#txtConceptoA").val('');
            $("#txtDescripcionA").val('');
            $("#ddlTiposTributosA").val(0);
            $("#ddlImpactoA").val('');
            $("#ddlMasivoA").val('');
            $("#txtPorcentajeA").val('');
            $("#txtValorA").val('');
            $("#txtTipo_cuotaA").val('');
            $("#txtMontoA").val('');
            $("#txtFechaDesde").val('');
            $("#txtFechaHasta").val('');
            $("#txtObservacion").val('');





        }

        //################################################# UTILS #################################################
        function Error(data) {

            swal({
                text: data,
                icon: "error",
                dangerMode: false,
                confirmButtonText: "Aceptar"
            });
        }

        function Alerta(data) {

            swal({
                text: data,
                icon: "warning",
                dangerMode: false,
                confirmButtonText: "Aceptar"
            });
        }

        function Exito(data) {

            swal({
                text: data,
                icon: "success",
                dangerMode: false,
                confirmButtonText: "Aceptar"
            });
        }

        function mostrar(idElementoHTML) {
            var x = document.getElementById(idElementoHTML);
            x.style.display = "block";
        }

        function ocultar(idElementoHTML) {
            var x = document.getElementById(idElementoHTML);
            x.style.display = "none";
        }

        var TributoxJurisdiccionTodos = function (ddl) {
            $.ajax({
                type: "POST",
                url: ruta + "/Bienvenida.aspx/getTipoTributosxJuri ",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data, st) {
                    if (st == 'success') {
                        if (data.d.length > 0) {

                            $(ddl).empty().append('<option selected="selected" value="0">-- Seleccione un Tributo --</option>');
                            $(ddl).append('<option value="1"> Todos </option>');

                            $.each(data.d, function () {

                                $(ddl).append($("<option></option>").val(this['TIPO_TRIBUTO']).html(this['CONCEPTO']));
                            });

                        }
                        else {
                            $(ddl).empty().append('<option selected="selected" value="0">No disponible<option>');
                        }
                    }

                },
                failure: function (data) {
                    alert(data.d);
                }
            });
        }

        //################################################# VALIDACIONES #################################################
        function validar_campo_obligatorio(campo, mensaje) {

            if ($(campo).val() != null) {
                if ($(campo).val().trim() == '' || $(campo).val() == 0) {
                    Alerta(mensaje);
                    return false;
                }
                else
                    return true;
            }
            else {
                Alerta(mensaje);
                return false;
            }
        }

        function validar_campo_numerico(campo, mensaje) {
            var pattern = /^[0-9]+(\,[0-9]{1,2})?$/; // valida si es numero con coma 
            var res = pattern.test($(campo).val());

            if (res) {
                return true;
            }
            Alerta(mensaje);
            return false;
        }

        function transformar_a_double(str) {
            var numStr = str.replace(/,/g, ".");
            return parseFloat(numStr);
        }

        function transformar_double_a_string(num) {
            var numStr = num.toString().replace(/\./g, ',');
            return numStr;
        }

        function validar_campo_num(e) {
            var regex = /^[0-9,]*$/;
            var str = String.fromCharCode(!e.charCode ? e.which : e.charCode);

            if (regex.test(str)) {

                return true;
            }
            e.preventDefault();
            return false;

        }

        function validar_campo_alfanum(e) {
            var regex = new RegExp("^[a-zA-Z0-9]+$");
            var str = String.fromCharCode(!e.charCode ? e.which : e.charCode);
            if (regex.test(str)) {
                return true;
            }

            e.preventDefault();
            return false;
        }

        function validar_fecha(campo, mensaje) {
            var d = new Date($(campo).val());
            var res = d instanceof Date && !isNaN(d);

            if (!res) {
                Alerta(mensaje);
                return false;
            }
            return true;
        }

        function validar_combo_vacio(combo) {
            if ($(combo).val() == 0) {
                return null;
            }

        }

        function validar_tamanio_tc(campo, mensaje) {
            if ($(campo).val().length > 2) {
                Alerta(mensaje);
                return false;
            }

            return true;
        }

        function validarFechaDesdeHastaE(f1, f2) {

            var anioDesde = parseInt(f1.substr(0, 4));
            var mesDesde = parseInt(f1.substr(5, 2)) - 1;
            var diaDesde = parseInt(f1.substr(8, 2));

            var anioHasta = parseInt(f2.substr(0, 4));
            var mesHasta = parseInt(f2.substr(5, 2)) - 1;
            var diaHasta = parseInt(f2.substr(8, 2));

            var dia = new Date();
            var diaHoy = dia.getDate();
            var mesHoy = dia.getMonth(); //esto te devuelve un mes del 0 al 11 odio Javascript
            var anioHoy = dia.getFullYear();

            var fechaHoy = new Date(anioHoy, mesHoy, diaHoy);

            var fechaDesde = new Date(anioDesde, mesDesde, diaDesde);
            var fechaHasta = new Date(anioHasta, mesHasta, diaHasta);




            if (fechaDesde >= fechaHasta) {
                Alerta("'Fecha hasta' debe ser posterior a 'Fecha desde.'");
                return false;
            }
            return true;
        }

        function validarFechaDesdeHasta(f1, f2) {

            var anioDesde = parseInt(f1.substr(0, 4));
            var mesDesde = parseInt(f1.substr(5, 2)) - 1;
            var diaDesde = parseInt(f1.substr(8, 2));

            var anioHasta = parseInt(f2.substr(0, 4));
            var mesHasta = parseInt(f2.substr(5, 2)) - 1;
            var diaHasta = parseInt(f2.substr(8, 2));

            var dia = new Date();
            var diaHoy = dia.getDate();
            var mesHoy = dia.getMonth(); //esto te devuelve un mes del 0 al 11 odio Javascript
            var anioHoy = dia.getFullYear();

            var fechaHoy = new Date(anioHoy, mesHoy, diaHoy);

            var fechaDesde = new Date(anioDesde, mesDesde, diaDesde);
            var fechaHasta = new Date(anioHasta, mesHasta, diaHasta);




            if (fechaDesde >= fechaHasta) {
                Alerta("'Fecha hasta' debe ser posterior a 'Fecha desde.'");
                return false;
            }
            //if (fechaDesde < fechaHoy) {
            //    Alerta("'Fecha desde' debe ser posterior a la fecha actual.");
            //    return false;
            //}
            return true;
        }

        //comentario prueba sacar
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

        <h3>Intereses Escalonados</h3>

        <table>
            <tr>
                <td>
                    <label style="padding-right: 10px">
                        <h4>Tipo Tributo:</h4>
                    </label>
                    <select id="ddltributo" name="ddltributo" class="btn btn-primary dropdown-toggle" style="width: 250px"></select>
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 10px;">
                    <button type="button" id="btnConsulta" class="btn btn-primary" style="text-align: center; width: 125px"><i class="glyphicon glyphicon-search" aria-hidden="true" style="padding-right: 10px;"></i>Consultar</button>
                </td>
            </tr>
        </table>



        <%--###################################################### TABLA ####################################################--%>
        <div id="DivTabla" style="display: none">
            <table style="width: 100%;" class="table table-striped table-bordered table-hover table-condensed" id="TablaIntereses">
                <thead>
                    <tr class="Estilo_Fila">
                        <th style="text-align: center" class="export">TIPO TRIBUTO</th>
                        <th style="text-align: center" class="export derecha">PORCENTUAL</th>
                        <th style="text-align: center" class="export">FECHA DESDE</th>
                        <th style="text-align: center" class="export">FECHA HASTA</th>
                        <th style="text-align: center">VER</th>
                        <th style="text-align: center">EDITAR</th>
                    </tr>
                </thead>
            </table>

        </div>
        <table>
            <tr>
                <div>
                    <button type="button" id="btnAgregar" class="btn btn-success-alt" style="text-align: center; width: 125px"><i class="glyphicon glyphicon-plus" aria-hidden="true" style="padding-right: 10px;"></i>Agregar</button>
                </div>
            </tr>
        </table>


        <%--################################################## MODAL AGREGAR ########################################################--%>
        <div class="modal fade" id="modalAgregar" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static" data-keyboard="false">
            <div class="vertical-alignment-helper">
                <div class="modal-dialog vertical-align-center" role="document">
                    <div class="modal-content modal-ku" >
                        <div class="modal-body">
                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h3 class="panel-title" id="H4">GENERAR INTERÉS</h3>
                                </div>

                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="ddlTiposTributosA" class="control-label"><span style="color: red">* </span>Tipo Tributo</label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <select id="ddlTiposTributosA" class="btn btn-primary dropdown-toggle" name="ddlTiposTributosA" style="width: 100%;">
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <div class="modal-body">

                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="tipo_cuota" class="control-label"><span style="color: red">* </span>Porcentual</label>
                                            <input type="text" name="monto" class="form-control" id="txtMontoA" placeholder="Ingrese un Valor" value="" style="width: 100%;" onkeypress="return validar_campo_num(event)" maxlength="4" onpaste="return false;" />
                                        </div>
                                    </div>
                                </div>

                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="txtObservacion">Observacion:</label>
                                            <textarea id="txtObservacion" rows="3" class="form-control" name="txtObservacion" placeholder="OBSERVACION" style="resize: none;" maxlength="200"></textarea>
                                        </div>
                                    </div>
                                </div>

                                <%-- PANEL FECHAS--%>
                                    <div class="modal-body">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <label for="txtFechaDesde"><span style="color: red">* </span>Fecha desde</label>
                                                <input id="txtFechaDesde" type="date" class="form-control" placeholder="DD/MM/YYYY"/>

                                            </div>
                                            <div class="col-md-6">
                                                <label for="txtFechaHasta"><span style="color: red">* </span>Fecha hasta</label>
                                                <input id="txtFechaHasta" type="date" class="form-control" placeholder="DD/MM/YYYY"/>
                                            </div>
                                        </div>
                                    </div>


                                <div class="modal-footer">
                                    <button type="button" id="btnModalGuardar" class="btn btn-primary">Guardar</button>
                                    <button type="button" id="btnModalCerrar" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    <%--################################################## MODAL EDITAR ########################################################--%>
        <div class="modal fade " id="modalEditar" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static" data-keyboard="false">
            <div class="vertical-alignment-helper">
                <div class="modal-dialog vertical-align-center" role="document">
                    <div class="modal-content modal-ku" >
                        <div class="modal-body">
                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h3 class="panel-title" id="H4">EDITAR INTERÉS</h3>
                                </div>

                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="ddlTiposTributosA" class="control-label"><span style="color: red">* </span>Tipo Tributo</label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <select id="ddlTiposTributosE" class="btn btn-primary dropdown-toggle" name="ddlTiposTributosA" style="width: 100%;" disabled>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <div class="modal-body">

                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="tipo_cuota" class="control-label"><span style="color: red">* </span>Porcentual</label>
                                            <input type="text" name="monto" class="form-control" id="txtMontoE" placeholder="Ingrese un Valor" value="" style="width: 100%;" onkeypress="return validar_campo_num(event)" maxlength="4" onpaste="return false;" />
                                        </div>
                                    </div>
                                </div>

                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="txtObservacion">Observacion:</label>
                                            <textarea id="txtObservacionE" rows="3" class="form-control" name="txtObservacion" placeholder="OBSERVACION" style="resize: none;"  maxlength="200"></textarea>
                                        </div>
                                    </div>
                                </div>

                                <%-- PANEL FECHAS--%>
                                    <div class="modal-body">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <label for="txtFechaDesde"><span style="color: red">* </span>Fecha desde</label>
                                                <input id="txtFechaDesdeE" type="date" class="form-control" placeholder="DD/MM/YYYY"/>

                                            </div>
                                            <div class="col-md-6">
                                                <label for="txtFechaHasta"><span style="color: red">* </span>Fecha hasta</label>
                                                <input id="txtFechaHastaE" type="date" class="form-control" placeholder="DD/MM/YYYY"/>
                                            </div>
                                        </div>
                                    </div>


                                <div class="modal-footer">
                                    <button type="button" id="btnModalGuardarE" class="btn btn-primary">Guardar</button>
                                    <button type="button" id="btnModalCerrarE" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    <%--################################################## MODAL VER ########################################################--%>
        <div class="modal fade" id="modalVer" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static" data-keyboard="false">
            <div class="vertical-alignment-helper">
                <div class="modal-dialog vertical-align-center" role="document">
                    <div class="modal-content modal-ku" >
                        <div class="modal-body">
                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h3 class="panel-title" id="H4">CONSULTAR INTERÉS</h3>
                                </div>

                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="ddlTiposTributosV" class="control-label">Tipo Tributo</label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <select id="ddlTiposTributosV" class="btn btn-primary dropdown-toggle" name="ddlTiposTributosV" style="width: 100%;" disabled>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <div class="modal-body">

                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="tipo_cuota" class="control-label">Porcentual</label>
                                            <input type="text" name="monto" class="form-control" id="txtMontoV" placeholder="Ingrese un Valor" value="" style="width: 100%;" onkeypress="return validar_campo_num(event)" maxlength="4" onpaste="return false;" readonly/>
                                        </div>
                                    </div>
                                </div>

                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="txtObservacion">Observacion:</label>
                                            <textarea id="txtObservacionV" rows="3" class="form-control" placeholder="OBSERVACION" style="resize: none;" readonly></textarea>
                                        </div>
                                    </div>
                                </div>

                                <%-- PANEL FECHAS--%>
                                    <div class="modal-body">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <label for="txtFechaDesde">Fecha desde</label>
                                                <input id="txtFechaDesdeV" type="date" class="form-control" placeholder="DD/MM/YYYY" readonly/>

                                            </div>
                                            <div class="col-md-6">
                                                <label for="txtFechaHasta">Fecha hasta</label>
                                                <input id="txtFechaHastaV" type="date" class="form-control" placeholder="DD/MM/YYYY" readonly/>
                                            </div>
                                        </div>
                                    </div>

                                <div class="modal-footer">
                                    <button type="button" id="btnModalCerrarV" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>





    </div>
</asp:Content>
