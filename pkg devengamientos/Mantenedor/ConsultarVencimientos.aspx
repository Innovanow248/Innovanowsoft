<%@ Page Language="C#" MasterPageFile="~/MasterPage/Ingresos.Master" AutoEventWireup="true" CodeBehind="ConsultarVencimientos.aspx.cs" Inherits="webIngresos.ConsultarVencimientos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphContenidoIngreso" runat="Server">
   
    <style type="text/css">
        .border-less td.border-less {
            border: none;
        }

        .datepicker {
            z-index: 1151 !important;
        }

        .borderless td.borderless {
            border: none;
        }

        .border-less td.border-less {
            border: none;
        }

        .btn-ttc /*,
        .btn-ttc:hover,
        .btn-ttc:active */ {
            color: white;
            text-shadow: 0 -1px 0 rgba(0, 0, 0, 0.25);
            background-color: #ff3d3d;
            outline: none;
        }

        .ancho {
            width: 232px !important;
        }

        .contenido {
            padding: 0px 20px;
            padding-bottom: 20px;
        }

        .swal-title {
            font-size: 16px;
            font-weight: normal;
        }

        .swal-text {
            text-align: center;
        }

        .swal-button--confirm {
            background-color: #28A745 !important;
        }

                .btn-green {
            background-color: #28A745;
        }

        .btn-green:hover {
            background-color: #1CC944 !important;
        }
    </style>

     <!-- Include Datepicker JavaScript source -->
    <script type="text/javascript" src="<%=ConfigurationManager.AppSettings["ROOT_PATH"] + "/Scripts/bootstrap-datepicker.js"%>"></script>
    <link rel="stylesheet" href="<%=ConfigurationManager.AppSettings["ROOT_PATH"] + "/Estilos/bootstrap-datepicker3.css"%>"/>


    <script>

        var idEditar;
        var idBorrar;
        var idJurisdiccion = '2372';
        var arrayVencimientos = [];
        var combotributo = "#ddltributo";
        var anioConsulta = "#ddlAnioConsulta";
        var comboAnioConsulta = "#ddlAnioConsulta";
        var comboAnioClonacion = "#ddlAnioClonacion";


        $(document).ready(function () {

            traerTributos();
            $('#tabla').hide();
            $('#tablaAgua').hide();
            $('#tablaProp').hide();


            $('#agregarnuevo').hide();

            $('#divClonar').hide();

            comboZona("#ddZonaI");
            comboZona("#ddZonaE");
            comboModalidad("#ddlModalidadE");
            comboModalidad("#ddlModalidad");

            $("#ddlNumeroCuotaE").prop("disabled", true);
            $("#ddlTipoCuotaE").prop("disabled", true);
            $("#ddZonaE").prop("disabled", true);
            $("#ddlModalidadE").prop("disabled", true);

            $('#btnConsulta').click(function () {
                var mensaje = controlarvalorparaconsultar()
                if (mensaje == "") {

                    var btn = $(this);
                    btn.button('loading');

                    $("#ddltributo").val();

                    document.getElementById('tabla').style.display = 'none';
                    document.getElementById('tablaProp').style.display = 'none';
                    document.getElementById('tablaAgua').style.display = 'none';
                    $('#agregarclonar').show();

                    arrayVencimientos.length = 0;

                    //$('#tablaAgua').show();
                    BuscarVencimientos(comboAnioConsulta);


                } else {
                    swal("", mensaje, "warning");

                }

            });

            $('#btnClonar').click(function () {

                var comboAnioConsulta = $("#ddlAnioConsulta").val();
                var comboAnioClonacion = $("#ddlAnioClonacion").val();
                var combotributo = $("#ddltributo").val();
                var mensaje = controlarValorparaClonar()
                if (mensaje == "") {

                    var btn = $(this);
                    btn.button('loading');
                    //document.getElementById('tabla').style.display = 'none';
                    arrayVencimientos.length = 0;

                    $.ajax({
                        url: "ConsultarVencimientos.aspx/getClonarPorAnio",
                        data: "{anioConsulta: '" + comboAnioConsulta +
                            "', anioClonacion: '" + comboAnioClonacion +
                            "', idTipoTributo: '" + combotributo +
                            "'}",
                        type: "post",
                        contentType: "application/json",
                        success: function (data) {
                            if (data.d == -2) {
                                swal("", "Existen datos para el Año Clonación Destino seleccionado", "error");
                                btn.button('reset');
                                return;
                            }
                            if (data.d == -1) {
                                swal("", "El Año de Consulta no tiene datos activos", "error");
                                btn.button('reset');
                                return;

                            } else swal("", "La Clonación se realizó correctamente", "success");
                            $("#ddlAnioConsulta").val($("#ddlAnioClonacion").val());
                            BuscarVencimientos(comboAnioConsulta);

                            btn.button('reset');
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                        }
                    });

                } else {
                    swal("", mensaje, "error");
                }
                btn.button('reset');
            });


            $('#btnInsertar').click(function () {

                var idTipoTributo = $("#ddltributo").val();
                var NumCuota = $("#ddlNumeroCuotaI").val();
                var FecPrimerVto = $("#dtp_fecha_primerVtoI").val();
                var FecSegundVto = $("#dtp_fecha_segundoVtoI").val();
                var FecTercerVto = $("#dtp_fecha_TercerVtoI").val();
                var NTipo = $("#ddlTipoCuotaI").val();
                var NZona = $("#ddZonaI").val();
                var Modalidad = $("#ddlModalidad").val();
                var DESC_PRIMER_VTO = $("#desc_primer_vto").val();
                var DESC_SEGUNDO_VTO = $("#desc_segundo_vto").val();
                var DESC_TERCER_VTO = $("#desc_tercer_vto").val();


                if (NZona == null) {

                    NZona = "";
                }

                if (Modalidad == 0) {

                    Modalidad = "";
                }

                var mensaje = controlarvaloringreso()

                if (mensaje != "") {

                    swal("", mensaje, "error");
                } else {

                    var anioConsulta = $("#ddlAnioConsulta").val();

                    //var ajaxData = {
                    //    IdTT: idTipoTributo,
                    //    NC: NumCuota,
                    //    FecPrimer: FecPrimerVto,
                    //    FecSegund: FecSegundVto,
                    //    FecTercer: FecTercerVto,
                    //    ntipo: NTipo,
                    //    nzona: NZona,
                    //    ano: anioConsulta,
                    //    moda: Modalidad,
                    //    P_DESC_PRIMER_VTO: DESC_PRIMER_VTO,
                    //    P_DESC_SEGUNDO_VTO: DESC_SEGUNDO_VTO,
                    //    P_DESC_TERCER_VTO: DESC_TERCER_VTO
                    //};

                    //var jsonData = JSON.stringify(ajaxData);
                    $.ajax({
                        url: "ConsultarVencimientos.aspx/Insertar",
                        type: "post",
                        beforeSend: function () {
                            AbrirLoading();
                        },
                        contentType: "application/json; charset=utf-8",
                        data: "{IdTT: '" + idTipoTributo + "',  NC: '" + NumCuota + "', FecPrimer: '" + FecPrimerVto + "', FecSegund: '" + FecSegundVto + "', FecTercer: '" + FecTercerVto + "', ntipo: '" + NTipo + "', nzona: '" + NZona + "', ano: '" + anioConsulta + "', moda: '" + Modalidad + "', P_DESC_PRIMER_VTO: '" + DESC_PRIMER_VTO + "', P_DESC_SEGUNDO_VTO: '" + DESC_SEGUNDO_VTO + "', P_DESC_TERCER_VTO: '" + DESC_TERCER_VTO + "'}",
                        async: false,
                        success: function (data) {

                            if (data.d == "") {
                                BuscarVencimientos(comboAnioConsulta);
                                limpiarPopUpAlta();
                                $('#myModal').modal('hide');
                                swal("", "El Vencimiento se agregó correctamente.", "success");
                            } else
                                swal(data.d, "", "error")
                            CerrarLoading();
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            CerrarLoading();
                        },
                    });


                }

            });

            $('#btnGrabar').click(function () {

                if ($("#ddltributo").val() == 0 || $("#ddlNumeroCuotaE").val() == "" || $("#dtp_fecha_primerVtoE").val() == "" || $("#dtp_fecha_segundoVtoE").val() == "" || $("#ddlTipoCuotaE").val() == 0 || $("#ddZonaE").val() == 0) {

                    var mensaje = controlarValorEditar()

                    swal("", mensaje, "error");

                } else {

                    var idTipoTributo = $("#ddltributo").val();
                    var NumCuota = $("#ddlNumeroCuotaE").val();
                    var FecPrimerVto = $("#dtp_fecha_primerVtoE").val();
                    var FecSegundVto = $("#dtp_fecha_segundoVtoE").val();
                    var FecTercerVto = $("#dtp_fecha_TercerVtoE").val();
                    var NTipo = $("#ddlTipoCuotaE").val();
                    var NZona = $("#ddZonaE").val();
                    var Modalidad = $("#ddlModalidadE").val();
                    var DESC_PRIMER_VTO = $("#desc_primer_vtoE").val();
                    var DESC_SEGUNDO_VTO = $("#desc_segundo_vtoE").val();
                    var DESC_TERCER_VTO = $("#desc_tercer_vtoE").val();

                    if (NZona == null) {

                        NZona = "";
                    }
                    if (Modalidad == null) {

                        Modalidad = "";
                    }
                    swal({
                        title: "¿Desea modificar el Vencimiento?",
                        text: "Se modificarán las obligaciones y comprobantes correspondientes",
                        icon: "warning",
                        buttons: true,
                        dangerMode: true,
                        buttons: {
                            confirm: {
                                text: "Confirmar",
                                value: true,
                                className: "btn-green"
                            },
                            cancel: "Cancelar"
                        }
                    })
                        .then((willDelete) => {
                            if (willDelete) {
                                AbrirLoading();

                                //var ajaxData = {
                                //    id: idEditar,
                                //    IdTT: idTipoTributo,
                                //    NC: NumCuota,
                                //    FecPrimer: FecPrimerVto,
                                //    FecSegund: FecSegundVto,
                                //    FecTercer: FecTercerVto,
                                //    ntipo: NTipo,
                                //    nzona: NZona,
                                //    moda: Modalidad,
                                //    P_DESC_PRIMER_VTO: DESC_PRIMER_VTO,
                                //    P_DESC_SEGUNDO_VTO: DESC_SEGUNDO_VTO,
                                //    P_DESC_TERCER_VTO: DESC_TERCER_VTO
                                //};

                                //var jsonData = JSON.stringify(ajaxData);

                                $.ajax({
                                    url: "ConsultarVencimientos.aspx/Editar",
                                    type: "post",
                                    beforeSend: function () {
                                        AbrirLoading();
                                    },
                                    data: "{id: '" + idEditar + "',  IdTT: '" + idTipoTributo + "', NC: '" + NumCuota + "', FecPrimer: '" + FecPrimerVto + "', FecSegund: '" + FecSegundVto + "', FecTercer: '" + FecTercerVto + "', ntipo: '" + NTipo + "', nzona: '" + NZona + "', moda: '" + Modalidad + "', P_DESC_PRIMER_VTO: '" + DESC_PRIMER_VTO + "', P_DESC_SEGUNDO_VTO: '" + DESC_SEGUNDO_VTO + "', P_DESC_TERCER_VTO: '" + DESC_TERCER_VTO + "'}",
                                    contentType: "application/json",
                                    async: false,
                                    success: function (data) {

                                        BuscarVencimientos(comboAnioConsulta);
                                        limpiarPopUpEditar();
                                        $('#divEditar').modal('hide');
                                        swal("", "Los cambios se guardaron con éxito.", "success");

                                    },
                                    error: function (xhr, ajaxOptions, thrownError) {
                                        CerrarLoading();
                                    }
                                });
                                CerrarLoading();
                            }
                        });


                }


            });

            //$('#btnBorrar').click(function () {
            //    var idTipoTributo = $("#ddltributo").val();
            //    $.ajax({
            //        url: "ConsultarVencimientos.aspx/Borrado",
            //        type: "post",
            //        beforeSend: function () {
            //            AbrirLoading();
            //        },
            //        data: "{ID_VENCIMIENTOS: '" + idBorrar + "',  IdTT: '" + idTipoTributo + "'}",
            //        contentType: "application/json",
            //        async: false,
            //        success: function (data) {

            //            BuscarVencimientos(comboAnioConsulta);

            //            $('#divBorrar').modal('hide');
            //            swal("Baja realizada!", "Los datos han sido dados de baja con éxito.", "success");
            //        },
            //        error: function (xhr, ajaxOptions, thrownError) {
            //            CerrarLoading();
            //        }, 
            //    });
            //});
            $('#btnCerrar').click(function () {
                document.getElementById('body_borrar').style.display = 'block';
                document.getElementById('footer_borrar').style.display = 'block';
                document.getElementById('body_ok').style.display = 'none';
                document.getElementById('footer_ok').style.display = 'none';
                $('#divBorrar').modal('hide');

            });


            $('#agregarnuevo').click(function () {
                $('#myModal').modal('show');

                //var value = CUOTA_EXTRA;
                //if ($("#ddltributo").val() == '5') {

                //    $("#ddlTipoCuotaI").prop('disabled', true);
                //  $("#ddlTipoCuotaI").val('CUOTA_EXTRA', 'disabled', true);

                //    $("#ddlTipoCuotaI option[value=" + value + "]").removeAttr('disabled');
                //    $("#ddlTipoCuotaI").val('CUOTA');


                //} else {

                //    $("#ddlTipoCuotaI").prop('disabled', false);
                //    $("#ddlTipoCuotaI").val('0');
                //}
                $("#zonainsert").hide();
                $("#modalidadSelect").hide();
                if ($("#ddltributo").val() == '6') {

                    $("#zonainsert").show();
                    $("#ddZonaI").multiselect("enable");
                }
                else if ($("#ddltributo").val() == '12') {
                    $("#modalidadSelect").show();
                    $("#ddZonaI").val('');
                } else {
                    $("#ddZonaI").val('');
                    $("#ddZonaI").multiselect("disable");
                }
            });


            $("#ddlAnioConsulta").bind("change", function () {

                $('#tabla').hide();
                $('#tablaProp').hide();
                $('#tablaAgua').hide();//oculta la tabla para evitar errores al editar e insertar
                $('#agregarclonar').hide();

                var startDate = '01/01/' + $("#ddlAnioConsulta").val();

                $("#dtp_fecha_primerVtoI").datepicker({
                    startDate: startDate,
                    autoclose: true,
                    format: "dd/mm/yyyy",

                });


                $("#dtp_fecha_segundoVtoI").datepicker({
                    autoclose: true,
                    format: "dd/mm/yyyy"

                });

                $('#dtp_fecha_primerVtoE').datepicker({
                    startDate: startDate,
                    autoclose: true,
                    format: "dd/mm/yyyy"

                });

                $('#dtp_fecha_segundoVtoE').datepicker({
                    autoclose: true,
                    format: "dd/mm/yyyy"
                });

                $('#dtp_fecha_TercerVtoI').datepicker({
                    autoclose: true,
                    format: "dd/mm/yyyy"
                });

                $('#dtp_fecha_TercerVtoE').datepicker({
                    autoclose: true,
                    format: "dd/mm/yyyy"
                });


            });

            $("#ddltributo").bind("change", function () {

                $('#tabla').hide();
                $('#tablaProp').hide();
                $('#tablaAgua').hide();//oculta la tabla para evitar errores al editar e insertar
                $('#agregarclonar').hide();


            });


            $("#dtp_fecha_primerVtoI").bind("change", function () {  // al cambiar el primer vencimiento el segundo se setea segun el valor que traiga la funcion.

                $.ajax({
                    url: "ConsultarVencimientos.aspx/BuscarSegundoVenc",
                    data: "{anioConsulta: '" + $("#ddlAnioConsulta").val() + "', idTipoTributo: '" + $("#ddltributo").val() +
                        "'}",
                    type: "post",
                    async: false,
                    contentType: "application/json",
                    success: function (data) {

                        if ($("#dtp_fecha_primerVtoI").val() != "") {

                            var dias = data.d;

                            //---

                            var date1 = $("#dtp_fecha_primerVtoI").val();

                            var date2 = date1.split("/");
                            var date3 = date2[1] + "/" + date2[0] + "/" + date2[2];
                            var date4 = new Date(date3);


                            date4.setDate(date4.getDate() + dias);
                            var date5 = convertDate(date4);
                            $("#dtp_fecha_segundoVtoI").val(date5);

                            $("#dtp_fecha_segundoVtoI").datepicker('setStartDate', date1);

                            //--

                        }

                    },
                    error: function (xhr, ajaxOptions, thrownError) {

                    },


                });

            });

            $("#dtp_fecha_segundoVtoI").on("change", function () {

                if ($("#dtp_fecha_primerVtoI").val() != "") {

                    var date1 = $("#dtp_fecha_segundoVtoI").val();

                    var date2 = date1.split("/");
                    var date3 = date2[1] + "/" + date2[0] + "/" + date2[2];
                    var date4 = new Date(date3);

                    $("#dtp_fecha_TercerVtoI").datepicker('setStartDate', date4);
                    $("#dtp_fecha_TercerVtoI").datepicker('setDate', null);

                }

            });

            $("#dtp_fecha_primerVtoE").on("change", function () {

                $.ajax({
                    url: "ConsultarVencimientos.aspx/BuscarSegundoVenc",
                    data: "{anioConsulta: '" + $("#ddlAnioConsulta").val() + "', idTipoTributo: '" + $("#ddltributo").val() +
                        "'}",
                    type: "post",
                    async: false,
                    contentType: "application/json",
                    success: function (data) {


                        if ($("#dtp_fecha_primerVtoE").val() != "") {

                            var dias = data.d;

                            //---
                            var date1 = $("#dtp_fecha_primerVtoE").val();

                            var date2 = date1.split("/");
                            var date3 = date2[1] + "/" + date2[0] + "/" + date2[2];
                            var date4 = new Date(date3);

                            date4.setDate(date4.getDate() + dias);
                            var date5 = convertDate(date4);


                            $("#dtp_fecha_segundoVtoE").val(date5);
                            $("#dtp_fecha_segundoVtoE").datepicker('setStartDate', date4);
                            $("#dtp_fecha_TercerVtoE").datepicker('setDate', null);
                            $("#dtp_fecha_TercerVtoE").datepicker('setStartDate', date4);

                            //--
                        }

                    },
                    error: function (xhr, ajaxOptions, thrownError) {

                    },


                });

                //if ($("#dtp_fecha_primerVtoE").val() != "") {


                //    var date1 = $("#dtp_fecha_primerVtoE").val();

                //    var date2 = date1.split("/");
                //    var date3 = date2[1] + "/" + date2[0] + "/" + date2[2];
                //    var date4 = new Date(date3);


                //    $("#dtp_fecha_segundoVtoE").datepicker('setDate', null);
                //    $("#dtp_fecha_segundoVtoE").datepicker('setStartDate', date4);
                //    $("#dtp_fecha_TercerVtoE").datepicker('setDate', null);
                //    $("#dtp_fecha_TercerVtoE").datepicker('setStartDate', date4);

                //}

            });


            $("#dtp_fecha_segundoVtoE").on("change", function () {



                if ($("#dtp_fecha_primerVtoE").val() != "") {


                    var date1 = $("#dtp_fecha_segundoVtoE").val();

                    var date2 = date1.split("/");
                    var date3 = date2[1] + "/" + date2[0] + "/" + date2[2];
                    var date4 = new Date(date3);

                    //$("#dtp_fecha_TercerVtoE").datepicker('setDate', null);
                    $("#dtp_fecha_TercerVtoE").datepicker('setStartDate', date4);


                }

            });





        });  // termina ready    



        var BuscarVencimientos = function (comboAnioConsulta) {

            //document.getElementById('tabla').style.display = 'none';
            var comboAnioConsulta = $("#ddlAnioConsulta").val();
            arrayVencimientos.length = 0;

            $.ajax({
                url: "ConsultarVencimientos.aspx/getVencimientos",
                data: "{anioConsulta: '" + comboAnioConsulta + "', tipoTributo: '" + $("#ddltributo").val() +
                    "'}",
                type: "post",
                contentType: "application/json",
                beforeSend: function () {
                    AbrirLoading();
                },
                success: function (data) {

                    var arrayVencimientos = [];
                    var AccionEditar = TieneAccion('MODIFICACION', Nombre_Pagina());
                    var AccionBaja = TieneAccion('BAJA', Nombre_Pagina());
                    if (data.d.length == 0) {
                        if ($("#ddltributo").val() == 6) {
                            document.getElementById('tablaProp').style.display = 'block';
                            var tabla = Dar_Formato_Tabla_Alineacion_Baja($('#ConsuVenciProp'), arrayVencimientos)
                        }
                        if ($("#ddltributo").val() == 12) {
                            document.getElementById('tablaAgua').style.display = 'block';
                            var tabla = Dar_Formato_Tabla_Alineacion_Baja($('#ConsuVenciAgua'), arrayVencimientos)
                        }
                        if ($("#ddltributo").val() != 12 && $("#ddltributo").val() != 6) {
                            document.getElementById('tabla').style.display = 'block';
                            var tabla = Dar_Formato_Tabla_Alineacion_Baja($('#ConsuVenci'), arrayVencimientos)
                        }
                    }
                    ;

                    for (i = 0; i < data.d.length; i++) {

                        var Editar = '';
                        var Delete = '';


                        var fechaBaja = data.d[i].FEC_BAJA;

                        var fechaVencimiento1 = data.d[i].FECHA_PRIMER_VTO
                        var fechaVencimiento2 = data.d[i].FECHA_SEGUNDO_VTO
                        var fechaVencimiento3 = data.d[i].FECHA_TERCER_VTO

                        var baja = mostrarBaja(fechaBaja);
                        var vto1 = mostrarBaja(fechaVencimiento1);
                        var vto2 = mostrarBaja(fechaVencimiento2);
                        var vto3 = mostrarBaja(fechaVencimiento3);

                        if (baja == '') {
                            if (AccionEditar)
                                Editar = '<a href="#" onclick="return Editar(' + data.d[i].ID_VENCIMIENTOS + ')"  class="btn btn-warning-alt btn-xs"><span class="glyphicon glyphicon glyphicon-pencil"></span></a>';
                            if (AccionBaja)
                                Delete = '<a href="#" onclick="return Borrar(' + data.d[i].ID_VENCIMIENTOS + ')"  class="btn btn-danger-alt btn-xs"><span class="glyphicon glyphicon glyphicon-trash"></span></a>';
                        }
                        //arrayVencimientos.push([data.d[i].EJERCICIO, data.d[i].NRO_CUOTA, vto1, vto2, vto3, data.d[i].N_TIPO, data.d[i].N_ZONA, data.d[i].DESCRIPCION, Editar, Delete, baja]);

                        var tablaHTML;

                        if ($("#ddltributo").val() == 6) {
                            $('#tablaProp').show();
                            $('#tablaAgua').hide();
                            $('#tabla').hide();
                            arrayVencimientos.push([data.d[i].EJERCICIO, data.d[i].NRO_CUOTA, vto1, vto2, vto3, data.d[i].N_TIPO, data.d[i].N_ZONA, Editar, Delete, baja])
                            //var tabla = formatear_tabla($('#ConsuVenciProp'), arrayVencimientos);
                            tablaHTML = '#ConsuVenciProp';

                            var campoBaja = 10;

                        }
                        if ($("#ddltributo").val() == 12) {
                            $('#tablaAgua').show();
                            $('#tablaProp').hide();
                            $('#tabla').hide();
                            arrayVencimientos.push([data.d[i].EJERCICIO, data.d[i].NRO_CUOTA, vto1, vto2, vto3, data.d[i].N_TIPO, data.d[i].DESCRIPCION, Editar, Delete, baja]);

                            tablaHTML = '#ConsuVenciAgua';
                            //var tabla = formatear_tabla($('#ConsuVenciAgua'), arrayVencimientos);

                            var campoBaja = 10;

                        }
                        if ($("#ddltributo").val() != 12 && $("#ddltributo").val() != 6) {
                            $('#tabla').show();
                            $('#tablaProp').hide();
                            $('#tablaAgua').hide();
                            arrayVencimientos.push([data.d[i].EJERCICIO, data.d[i].NRO_CUOTA, vto1, vto2, vto3, data.d[i].N_TIPO, Editar, Delete, baja]);
                            //var tabla = formatear_tabla($('#ConsuVenci'), arrayVencimientos);
                            tablaHTML = '#ConsuVenci';
                            var campoBaja = 9;

                        }
                    }

                    var tabla = formatear_tabla($(tablaHTML), arrayVencimientos);

                    //cargarTabla(tablaHTML, arrayVencimientos, campoBaja);
                    $('#btnConsulta').button('reset');
                    if (TieneAccion('ALTA', Nombre_Pagina())) $('#agregarnuevo').show();
                    if (TieneAccion('CLONAR', Nombre_Pagina())) $('#divClonar').show();
                    CerrarLoading();

                },
                error: function (xhr, ajaxOptions, thrownError) {

                },


            });

        }

        //traer listado de zonas
        var comboZona = function (combo) {
            $.ajax({
                type: "POST",
                url: "ConsultarVencimientos.aspx/getZona",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data, st) {
                    if (st == 'success') {
                        if (data.d.length > 0) {
                            $(combo).empty();//.append('<option selected="selected" value="0">Seleccione Zona</option>');
                            $.each(data.d, function () {
                                $(combo).append($("<option></option>").val(this['CONCEPTO_ABREVIADO']).html(this['CONCEPTO']));

                            });
                        }
                        else {
                            $(combo).empty().append('<option selected="selected" value="0">Not available<option>');
                        }
                    }

                    $(combo).multiselect({
                        nonSelectedText: '--Seleccione una Zona--',
                        includeSelectAllOption: true,
                        selectAllText: 'TODOS',
                        allSelectedText: 'TODOS',
                        enableFiltering: true,
                        filterPlaceholder: 'Buscar...',
                        enableCaseInsensitiveFiltering: true,
                        numberDisplayed: 2
                    });
                    $(combo).multiselect('rebuild');
                }

            });
        }

        //traer modalidad
        var comboModalidad = function (combo) {
            $.ajax({
                type: "POST",
                url: "ConsultarVencimientos.aspx/traer_modalidad",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data, st) {
                    if (st == 'success') {
                        if (data.d.length > 0) {
                            $(combo).empty();//.append('<option selected="selected" value="0">Seleccione Zona</option>');

                            $(combo).append('<option selected="selected" value="0">--Seleccione una Modalidad--</option>');
                            $.each(data.d, function () {
                                $(combo).append($("<option></option>").val(this['ID_OBSA_MODALIDAD']).html(this['DESCRIPCION']));
                            });
                        }
                        else {
                            $(combo).empty().append('<option selected="selected" value="0">Not available<option>');
                        }
                    }
                }

            });
        }

        //traer listado de tributos
        function traerTributos() {
            $.ajax({
                type: "POST",
                url: "ConsultarVencimientos.aspx/getTiposTributo",
                data: "{ idJurisdiccion: '" + idJurisdiccion + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data, st) {
                    if (st == 'success') {
                        if (data.d.length > 0) {

                            $("#ddltributo").empty().append('<option selected="selected" value="0">--Seleccione un Tributo--</option>');
                            $.each(data.d, function () {

                                $("#ddltributo").append($("<option></option>").val(this['ID_TIPO_TIBUTO']).html(this['CONCEPTO']));
                            });

                        }
                        else {
                            $("#ddltributo").empty().append('<option selected="selected" value="0">No disponible<option>');
                        }

                    }

                },

                failure: function (data) {
                    alert(data.d);
                }
            });
        }


        function controlarValorparaClonar() {
            if ($("#ddlAnioClonacion").val() == 0) {
                return "Seleccione un Año Clonación Destino";
            }
            if ($("#ddlAnioConsulta").val() >= $("#ddlAnioClonacion").val()) {
                return "El Año de Clonación Destino debe ser mayor al Año de Consulta";
            }
            return '';
        }


        function controlarvalorparaconsultar() {
            if ($("#ddltributo").val() == 0 & $("#ddlAnioConsulta").val() == 0) {
                return "Seleccione un filtro para la consulta.";
            }
            if ($("#ddltributo").val() == 0) {
                return "Seleccione un Tributo para buscar.";
            }
            if ($("#ddlAnioConsulta").val() == 0) {
                return "Seleccione un Año Ejercicio para buscar.";
            }
            return '';
        }
        function controlarvaloringreso() {
            if ($("#ddlNumeroCuotaI").val() == "") {
                return "Seleccione un Nro. Cuota.";
            }
            if ($("#ddZonaI").val() == "" && $("#ddltributo").val() == 6) {
                return "Seleccione una Zona.";
            }
            if ($("#ddlTipoCuotaI").val() == 0) {
                return "Seleccione un Tipo Cuota.";
            }
            if ($("#ddlModalidad").val() == 0 && $("#ddltributo").val() == 12) {
                return "Seleccione una Modalidad.";
            }
            if ($("#dtp_fecha_primerVtoI").val() == "") {
                return "Ingrese una Fecha Primer Vto.";
            }
            if ($("#dtp_fecha_segundoVtoI").val() == "") {
                return "Ingrese una Fecha Segundo Vto.";
            }
            if ($("#desc_primer_vto").val() == "") {
                return "Ingrese un Descuento Primer Vto.";
            }
            if ($("#desc_segundo_vto").val() == "") {
                return "Ingrese un Descuento Segundo Vto.";
            }


            return '';
        }
        function controlarValorEditar() {
            if ($("#dtp_fecha_primerVtoE").val() == "") {
                return "Ingrese una Fecha Primer Vto.";
            }
            if ($("#dtp_fecha_segundoVtoE").val() == "") {
                return "Ingrese una Fecha Segundo Vto.";
            }
            if ($("#desc_primer_vtoE").val() == "") {
                return "Ingrese un Descuento Primer Vto.";
            }
            if ($("#desc_segundo_vtoE").val() == "") {
                return "Ingrese un Descuento Segundo Vto.";
            }

            return '';
        }


        function Borrar(id) {
            var idTipoTributo = $("#ddltributo").val();
            idBorrar = id;
            swal({
                title: "",
                text: "¿Desea dar de baja el Vencimiento?",
                icon: "warning",
                buttons: true,
                dangerMode: true,
                buttons: {
                    confirm: "Confirmar",
                    cancel: "Cancelar"
                }
            })
                .then((willDelete) => {
                    if (willDelete) {
                        $.ajax({
                            url: "ConsultarVencimientos.aspx/Borrado",
                            type: "post",
                            beforeSend: function () {
                                AbrirLoading();
                            },
                            data: "{ID_VENCIMIENTOS: '" + idBorrar + "',  IdTT: '" + idTipoTributo + "'}",
                            contentType: "application/json",
                            async: false,
                            success: function (data) {
                                BuscarVencimientos(comboAnioConsulta);
                                swal("", "El Vencimiento se dió de baja correctamente.", "success");
                            },
                            error: function (xhr, ajaxOptions, thrownError) {
                                CerrarLoading();
                            }
                        });
                        CerrarLoading();
                    }
                });
        }

        function Editar(id) {

            //$("#ddlNumeroCuotaE").prop("disabled", true);
            //$("#ddlTipoCuotaE").prop("disabled", true);
            //$("#ddZonaE").prop( "disabled", true );

            $('#divEditar').modal('show');
            $.ajax({
                url: "ConsultarVencimientos.aspx/Traer_p_Editar",
                type: "post",
                data: "{p_Id: '" + id + "'}",
                contentType: "application/json",
                success: function (data) {


                    idEditar = data.d[0].ID_VENCIMIENTOS;

                    $("#ddlNumeroCuotaE").val(data.d[0].NRO_CUOTA);
                    $("#ddlTipoCuotaE").val(data.d[0].N_TIPO);

                    if (data.d[0].N_ZONA) {
                        var arrayZona = data.d[0].N_ZONA.toString().split(',');
                    }
                    $("#ddZonaE").val(arrayZona);
                    $("#ddZonaE").multiselect('refresh');


                    if (data.d[0].FECHA_PRIMER_VTO != null) {
                        var str = data.d[0].FECHA_PRIMER_VTO.replace('/Date(', '');
                        var str2 = str.replace(')/', '');
                        var fecha = new Date(parseInt(str2));
                        var date = getFormattedDate(fecha);
                        $("#dtp_fecha_primerVtoE").val(date);
                    }


                    if (data.d[0].FECHA_SEGUNDO_VTO != null) {
                        var str = data.d[0].FECHA_SEGUNDO_VTO.replace('/Date(', '');
                        var str2 = str.replace(')/', '');
                        var fecha = new Date(parseInt(str2));
                        var date = getFormattedDate(fecha);
                        $("#dtp_fecha_segundoVtoE").val(date);
                    }


                    if (data.d[0].FECHA_TERCER_VTO != null) {
                        var str = data.d[0].FECHA_TERCER_VTO.replace('/Date(', '');
                        var str2 = str.replace(')/', '');
                        var fecha = new Date(parseInt(str2));
                        var date = getFormattedDate(fecha);
                        $("#dtp_fecha_TercerVtoE").val(date);
                    }

                    if (data.d[0].DESC_PRIMER_VTO != null) {
                        $("#desc_primer_vtoE").val(data.d[0].DESC_PRIMER_VTO);
                    }
                    else {
                        $("#desc_primer_vtoE").val("");

                    }


                    if (data.d[0].DESC_SEGUNDO_VTO != null) {
                        $("#desc_segundo_vtoE").val(data.d[0].DESC_SEGUNDO_VTO);
                    }
                    else {
                        $("#desc_segundo_vtoE").val("");

                    }


                    if (data.d[0].DESC_TERCER_VTO != null) {
                        $("#desc_tercer_vtoE").val(data.d[0].DESC_TERCER_VTO);
                    }
                    else {
                        $("#desc_tercer_vtoE").val("");

                    }


                    $("#ddlModalidadE").val('refresh');
                    $("#ddlModalidadE").val(data.d[0].ID_OBSA_MODALIDAD);


                    if ($("#ddltributo").val() == '5') {

                        //$("#ddlTipoCuotaE").prop('disabled', true);
                        // $("#ddlTipoCuotaE").val('DDJJ');
                    } else {
                        //$("#ddlTipoCuotaE").prop('disabled', false);                       
                    }
                    if ($("#ddltributo").val() == '6') {
                        //$("#ddZonaE").multiselect("enable");
                        $("#ddZonaE").multiselect("disable");
                        $("#zonaedit").show();
                        $("#modalidadEdit").hide();


                    } else
                        if ($("#ddltributo").val() == '12') {
                            $("#zonaedit").hide();
                            $("#ddlModalidadE").val();
                        }
                        else {
                            $("#ddZonaE").val('');
                            $("#ddZonaE").multiselect("disable");
                            $("#zonaedit").hide();
                            $("#modalidadEdit").hide();
                        }

                    //-- VALIDACIONES NO PERMITEN INSERTAR FECHAS ANTERIORES A LA DEL VENCIMIENTO ANTERIOR

                    if ($("#dtp_fecha_primerVtoE").val() != "") {


                        var date1 = $("#dtp_fecha_primerVtoE").val();

                        var date2 = date1.split("/");
                        var date3 = date2[1] + "/" + date2[0] + "/" + date2[2];
                        var date4 = new Date(date3);

                        $("#dtp_fecha_segundoVtoE").datepicker('setStartDate', date4);
                        $("#dtp_fecha_TercerVtoE").datepicker('setStartDate', date4);

                    }


                    if ($("#dtp_fecha_primerVtoE").val() != "") {


                        var date1 = $("#dtp_fecha_segundoVtoE").val();

                        var date2 = date1.split("/");
                        var date3 = date2[1] + "/" + date2[0] + "/" + date2[2];
                        var date4 = new Date(date3);

                        $("#dtp_fecha_TercerVtoE").datepicker('setStartDate', date4);

                    }

                    //--

                },
                error: function (xhr, ajaxOptions, thrownError) {

                }
            });
        }

        //FecPrimerVto = FecPrimerVto.substr(3, 2) + "/" + FecPrimerVto.substr(0, 2) + FecPrimerVto.substr(5, 5);
        // FecSegundVto = FecSegundVto.substr(3, 2) + "/" + FecSegundVto.substr(0, 2) + FecSegundVto.substr(5, 5);
        //FecTercerVto = FecTercerVto.substr(3, 2) + "/" + FecTercerVto.substr(0, 2) + FecTercerVto.substr(5, 5);

        //var FecPrimerVto = document.getElementById("dtp_fecha_primerVtoE").value.split("/");
        //var FecSegundVto = document.getElementById("dtp_fecha_segundoVtoE").value.split("/");
        //var FecTercerVto = document.getElementById("dtp_fecha_TercerVtoE").value.split("/");
        //var vto1 = new Date(parseInt(FecPrimerVto[2]), parseInt(FecPrimerVto[1] - 1), parseInt(FecPrimerVto[0]));
        //var vto2 = new Date(parseInt(FecSegundVto[2]), parseInt(FecSegundVto[1] - 1), parseInt(FecSegundVto[0]));
        //var vto3 = new Date(parseInt(FecTercerVto[2]), parseInt(FecTercerVto[1] - 1), parseInt(FecTercerVto[0]));


        function limpiarPopUpEditar() {

            $("#ddlNumeroCuotaE").val(0);
            $("#dtp_fecha_primerVtoE").val("");
            $("#dtp_fecha_segundoVtoE").val("");
            $("#dtp_fecha_TercerVtoE").val("");
            $("#ddlTipoCuotaE").val(0);
            $("#ddZonaE").val('');
            $("#ddZonaE").multiselect('refresh');
            $("#ddlModadlidadE").val(0);

        }


        function limpiarPopUpAlta() {

            $("#ddlNumeroCuotaI").val("");
            $("#dtp_fecha_primerVtoI").val("");
            $("#dtp_fecha_segundoVtoI").val("");
            $("#dtp_fecha_TercerVtoI").val("");
            $("#ddlTipoCuotaI").val(0);
            $("#ddZonaI").val('');
            $("#ddZonaI").multiselect('refresh');
            $("#ddlModalidad").val(0);

        };

        function getFormattedDate(date) {

            var year = date.getFullYear();
            var month = (1 + date.getMonth()).toString();
            month = month.length > 1 ? month : '0' + month;
            var day = date.getDate().toString();
            day = day.length > 1 ? day : '0' + day;
            return day + '/' + month + '/' + year;
        }

        function mostrarBaja(dataFecha) {
            if (dataFecha != null) {
                var str = dataFecha.replace('/Date(', '');
                var str2 = str.replace(')/', '');
                var fecha = new Date(parseInt(str2));
                var fechaFormat = getFormattedDate(fecha);
            }
            else {
                var fechaFormat = '';
            }
            return fechaFormat;
        }

        function convertDate(inputFormat) { // convierte desde date javascrip al formato del datepicker
            function pad(s) { return (s < 10) ? '0' + s : s; }
            var d = new Date(inputFormat)
            return [pad(d.getDate()), pad(d.getMonth() + 1), d.getFullYear()].join('/')
        }

        function validar_campo_num(e) {
            var regex = /^[0-9]*$/;
            var str = String.fromCharCode(!e.charCode ? e.which : e.charCode);

            if (regex.test(str)) {

                return true;
            }
            e.preventDefault();
            return false;

        }

    </script>

    <div id="loading">
        <div id="img">
            <div style="width: 10px; height: auto;">
                <img src="<%=ConfigurationManager.AppSettings["ROOT_PATH"] + "/Estilos/Imagenes/gifCarga.gif"%>" style="width: 95px; height: auto;">
            </div>
            <div style="width: 100%; text-align: center;">
                <h5 style="color: rgba(0,0,0, .5);">Procesando...</h5>
            </div>
        </div>
    </div>

    <div class="contenido">
        <h3 style="margin-top:10px">Gestión de Vencimientos</h3>          
        <table class="table border-less" style="margin-bottom:0px">
            <tr>
                
                <td class="col-md-3 border-less" style="padding-top: 0; padding-left: 0; width:390px">

                    <label for="ddlAnioConsulta">
                        <h4 style="margin-right:10px"><span style="color: red">* </span>Año Ejercicio:</h4>
                    </label>
                    <select id="ddlAnioConsulta" name="ddlAnioConsulta" class="btn btn-primary dropdown-toggle" style="width: 185px"<%-- multiple="multiple" --%>>
                        <option value="0">--Seleccione un Año--</option>                        
                        <option value="2026">2026</option>
                        <option value="2025">2025</option>
                        <option value="2024">2024</option>
                        <option value="2023">2023</option>
                        <option value="2022">2022</option>
                        <option value="2021">2021</option>
                        <option value="2020">2020</option>
                        <option value="2019">2019</option>
                        <option value="2018">2018</option>
                        <option value="2017">2017</option>
                        <option value="2016">2016</option>
                        <option value="2015">2015</option>
                        <option value="2014">2014</option>
                        <option value="2013">2013</option>
                        <option value="2012">2012</option>
                        <option value="2011">2011</option>
                        <option value="2010">2010</option>
                        <option value="2009">2009</option>
                        <option value="2008">2008</option>
                        <option value="2007">2007</option>
                        <option value="2006">2006</option>
                        <option value="2005">2005</option>
                        <option value="2004">2004</option>
                        <option value="2003">2003</option>
                        <option value="2002">2002</option>
                        <option value="2001">2001</option>
                        <option value="2000">2000</option>
                        <option value="1999">1999</option>
                        <option value="1998">1998</option>
                        <option value="1997">1997</option>
                        <option value="1996">1996</option>
                    </select>   
                </td>    
               <td class="col-md-3 border-less" style="padding-top: 0; padding-left: 0; width:390px">
                    <label for="ddltributo">
                        <h4 style="margin-right:10px"><span style="color: red">* </span>Tributo:</h4>
                    </label>
                    <select id="ddltributo" name="ddltributo" class="btn btn-primary dropdown-toggle" style="width: 235px">
                    </select>
                   <td class="col-md-2 pull-right">No Vigente</td>
                 <td style="background-color: #c40000" class="col-md-1 pull-right" style="color: #c40000">.</td>
                </td>
                  
            </tr>
        </table>      
            <div>                    
                <button type="button" id="btnConsulta" class="btn btn-primary" style="text-align: left; width: 125px"><i class="glyphicon glyphicon-search" aria-hidden="true" style="padding-right: 10px;"></i>Consultar</button>                
            </div>
      
       <div id="tablas">
        <div id="tabla">
            <h3>Detalle de la Consulta:</h3>
            <%--<hr style="border: 0.5pt solid rgba(0, 0, 0, .1);" />--%>
            <table class="table table-striped table-hover table-bordered" id="ConsuVenci" width="100%">
                <thead>
                    <tr>    
                        <th class="fecha export text-center">AÑO EJERCICIO</th>
                        <th class="derecha export text-center">NRO. CUOTA</th>
                        <th class="fecha export text-center">PRIMER VTO.</th>
                        <th class="fecha export text-center">SEGUNDO VTO.</th>
                        <th class="fecha export text-center">TERCER VTO.</th>
                        <th class="izquierda export text-center">TIPO CUOTA</th>                    
                        <th class="text-center">EDITAR</th>
                        <th class="text-center">BAJA</th>
                        <th class="fecha export text-center">FECHA BAJA</th>
                    </tr>
                </thead>
            </table>                      
         </div>

        <div id="tablaProp">
            <h3>Detalle de la Consulta:</h3>
            <table class="table table-striped table-hover table-bordered" id="ConsuVenciProp" width="100%">
                <thead>
                    <tr>    
                        <th class="fecha export text-center">AÑO EJERCICIO</th>
                        <th class="derecha export text-center">NRO. CUOTA</th>
                        <th class="fecha export text-center">PRIMER VTO.</th>
                        <th class="fecha export text-center">SEGUNDO VTO.</th>
                        <th class="fecha export text-center">TERCER VTO.</th>
                        <th class="izquierda export text-center">TIPO CUOTA</th>
                        <th class="izquierda export text-center">ZONA</th>                       
                        <th class="text-center">EDITAR</th>
                        <th class="text-center">BAJA</th>
                        <th class="fecha export text-center">FECHA BAJA</th>
                    </tr>
                </thead>
            </table>                       
        </div>

        <div id="tablaAgua">
            <h3>Detalle de la Consulta:</h3>
            <table class="table table-striped table-hover table-bordered" id="ConsuVenciAgua" width="100%">
                <thead>
                    <tr>    
                        <th class="fecha export text-center">AÑO EJERCICIO</th>
                        <th class="derecha export text-center">NRO. CUOTA</th>
                        <th class="fecha export text-center">PRIMER VTO.</th>
                        <th class="fecha export text-center">SEGUNDO VTO.</th>
                        <th class="fecha export text-center">TERCER VTO.</th>
                        <th class="izquierda export text-center">TIPO CUOTA</th>
                        <th class="izquierda export text-center">MODALIDAD</th>                        
                        <th class="text-center">EDITAR</th>
                        <th class="text-center">BAJA</th>
                        <th class="fecha export text-center">FECHA BAJA</th>
                    </tr>
                </thead>
            </table>            
          </div> 
       </div>
        <div id="agregarclonar">
          <table id="Agregar">
                <tr>
                    <td>
                        <button type="button" id="agregarnuevo" class="btn btn-success-alt" style="text-align: left; width: 125px"><i class="glyphicon glyphicon-plus" aria-hidden="true" style="padding-right: 10px;"></i>Agregar</button>                          
                    </td>                    
                </tr>
            </table>            
        <div id="divClonar">
            <hr style="border: 0.5pt solid rgba(0, 0, 0, .1);" />
          <h3>Operación a Realizar</h3>            
            <table>
                <tr>                    
                    <td>
                        <h4 style="margin-right:10px">Año Clonación Destino:</h4>
                    </td>                      
                    <td>
                        <select id="ddlAnioClonacion" name="ddlAnioClonacion" class="btn btn-ttc dropdown-toggle">
                        <option value="0">--Seleccione un Año--</option>
                        <option value="2026">2026</option>
                        <option value="2025">2025</option>
                        <option value="2024">2024</option>
                        <option value="2023">2023</option>
                        <option value="2022">2022</option>
                        <option value="2021">2021</option>
                        <option value="2020">2020</option>
                        <option value="2019">2019</option>
                        <option value="2018">2018</option>
                        <option value="2017">2017</option>
                        <option value="2016">2016</option>
                        <option value="2015">2015</option>
                        <option value="2014">2014</option>
                        <option value="2013">2013</option>
                        <option value="2012">2012</option>
                        <option value="2011">2011</option>
                        <option value="2010">2010</option>
                        <option value="2009">2009</option>
                        <option value="2008">2008</option>
                        <option value="2007">2007</option>
                        <option value="2006">2006</option>
                        <option value="2005">2005</option>
                        <option value="2004">2004</option>
                        <option value="2003">2003</option>
                        <option value="2002">2002</option>
                        <option value="2001">2001</option>
                        <option value="2000">2000</option>
                        <option value="1999">1999</option>
                        <option value="1998">1998</option>
                        <option value="1997">1997</option>
                        <option value="1996">1996</option>
                        </select>
                    </td>
                </tr>
                
            </table>
                <tr>
                    <td>
                        <button type="button" id="btnClonar" class="btn btn-ttc">Clonar</button>                        
                   </td>
              </tr> 
         </div>
        </div>
     <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" onload="return limpiarPopUpAlta()" data-backdrop="static" data-keyboard="false">
        <div class="vertical-alignment-helper">
            <div class="modal-dialog vertical-align-center <%--modal-size--%>" role="document"style="width:820px">
                <div class="modal-content">
                    <div class="modal-body">
                        <div id="panelNo" class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title" id="H2">GENERAR VENCIMIENTO</h3>
                            </div>
                            <div id="alert_placeholderE"></div>
                            <div class="panel-body">
                                <div class="row">

                                    <div class="col-md-4">
                                        <label for="ddlNumeroCuotaI" class="control-label"><span style="color: red">* </span>Nro. Cuota:</label>
                                        <select id="ddlNumeroCuotaI" name="ddlAnioConsulta" class="btn btn-primary dropdown-toggle" style="width: 100%">
                                            <option value="">--Seleccione una Cuota--</option>
                                            <option value="0">0</option>
                                            <option value="1">1</option>
                                            <option value="2">2</option>
                                            <option value="3">3</option>
                                            <option value="4">4</option>
                                            <option value="5">5</option>
                                            <option value="6">6</option>
                                            <option value="7">7</option>
                                            <option value="8">8</option>
                                            <option value="9">9</option>
                                            <option value="10">10</option>
                                            <option value="11">11</option>
                                            <option value="12">12</option>
                                        </select>
                                            <%--onkeypress="return soloNumeros(event)" width="60%" />--%>
                                    </div>
                                    <div class="col-md-4">
                                        <label for="ddlTipoCuotaI" class="control-label"><span style="color: red">* </span>Tipo Cuota:</label>
                                        <select id="ddlTipoCuotaI" name="ddlAnioConsulta" class="btn btn-primary dropdown-toggle" style="width: 100%">
                                            <option value="0">--Seleccione un Tipo--</option>
                                            <option value="CUOTA">CUOTA</option>
                                            <option value="CUOTA_EXTRA">CUOTA_EXTRA</option>                                          
                                            <option value="DDJJ">DDJJ</option>
                                        </select>
                                    </div>

                                    <div  id="modalidadSelect" class="col-md-4">
                                           <label for="ddlModalidad" class="control-label"><span style="color: red">* </span>Modalidad:</label><br />
                                            <select id="ddlModalidad" name="ddlModalidad" class="btn btn-primary dropdown-toggle" style="width: 100%">                                                
                                            </select>
                                         
                                      </div>                                   

                                    <div id="zonainsert" class="col-md-4">
                                        <label for="ddZonaI" class="control-label"><span style="color: red">* </span>Zona:</label><br />
                                        <select id="ddZonaI" name="ddZonaI" class="btn btn-default dropdown-toggle ancho" multiple="multiple" style="width: 100%">
                                        </select>
                                    </div>
                                </div>
                                <div class="row">
                                    </br>
                                        <div class="col-md-4">
                                            <label for="dtp_fecha_primerVtoI" class="control-label"><span style="color: red">* </span>Fecha Primer Vto.:</label>
                                            <input id="dtp_fecha_primerVtoI" placeholder="DD/MM/YYYY" type="text" class="form-control" style="width: 100%"/>
                                        </div>                            

                                <div class="col-md-4">
                                    <label for="dtp_fecha_segundoVtoI" class="control-label"><span style="color: red">* </span>Fecha Segundo Vto.:</label>
                                    <input id="dtp_fecha_segundoVtoI" placeholder="DD/MM/YYYY" type="text" class="form-control" style="width: 100%"/>
                                </div>

                                <div class="col-md-4">
                                    <label for="dtp_fecha_TercerVtoI" class="control-label">Fecha Tercer Vto.:</label>
                                    <input id="dtp_fecha_TercerVtoI" placeholder="DD/MM/YYYY" type="text" class="form-control" style="width: 100%"/>
                                </div>
                                </div>

                                <div class="row">
                                    </br>
                                        <div class="col-md-4">
                                            <label for="desc_primer_vto" class="control-label"><span style="color: red">* </span>Descuento Primer Vto.:</label>
                                            <input id="desc_primer_vto" placeholder="Ingrese un porcentaje." type="text" class="form-control" style="width: 100%" onkeypress="return validar_campo_num(event)" maxlength="3"/>
                                        </div>

                                    <div class="col-md-4">
                                        <label for="desc_segundo_vto" class="control-label"><span style="color: red">* </span>Descuento Segundo Vto.:</label>
                                        <input id="desc_segundo_vto" placeholder="Ingrese un porcentaje." type="text" class="form-control" style="width: 100%" onkeypress="return validar_campo_num(event)" maxlength="3"/>
                                    </div>

                                    <div class="col-md-4">
                                        <label for="desc_tercer_vto" class="control-label">Descuento Tercer Vto.:</label>
                                        <input id="desc_tercer_vto" placeholder="Ingrese un porcentaje." type="text" class="form-control" style="width: 100%" onkeypress="return validar_campo_num(event)" maxlength="3"/>
                                    </div>
                                </div>

                            </div>
                            <div class="modal-footer">
                                <button type="button" id="btnInsertar" class="btn btn-primary">Guardar</button>
                                <button onclick="limpiarPopUpAlta()" type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="divEditar" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" onload="return" limpiarPopUpEditar()" data-backdrop="static" data-keyboard="false">
        <div class="vertical-alignment-helper">
            <div class="modal-dialog vertical-align-center<%-- modal-size--%>" role="document" style="width:820px">
                <div class="modal-content">
                    <div class="modal-body">
                        <div id="panelNo" class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title" id="H4">EDITAR VENCIMIENTO</h3>
                           </div>                          
                                <div id="alert_placeholderE"></div>                                              
                                    <div class="panel-body">
                                        <div class="row">
                                            <div class="col-md-4">
                                                <label for="ddlNumeroCuotaE" class="control-label"><span style="color: red">* </span>Numero Cuota:</label>
                                                <select id="ddlNumeroCuotaE" name="ddlAnioConsulta" class="btn btn-primary dropdown-toggle" style="width: 100%">
                                                    <option value="">--Seleccione una Cuota--</option>
                                                    <option value="0">0</option>
                                                    <option value="1">1</option>
                                                    <option value="2">2</option>
                                                    <option value="3">3</option>
                                                    <option value="4">4</option>
                                                    <option value="5">5</option>
                                                    <option value="6">6</option>
                                                    <option value="7">7</option>
                                                    <option value="8">8</option>
                                                    <option value="9">9</option>
                                                    <option value="10">10</option>
                                                    <option value="11">11</option>
                                                    <option value="12">12</option>
                                                </select>
                                            </div>
                                         
                                    <div class="col-md-4">
                                        <label for="ddlTipoCuotaE" class="control-label"><span style="color: red">* </span>Tipo Cuota:</label>
                                        <select id="ddlTipoCuotaE" name="ddlAnioConsulta" class="btn btn-primary dropdown-toggle" style="width: 100%">
                                           <option value="0">--Seleccione un Tipo--</option>
                                            <option value="CUOTA">CUOTA</option>
                                            <option value="CUOTA_EXTRA">CUOTA_EXTRA</option>
                                            <option value="DDJJ">DDJJ</option>
                                        </select>
                                    </div>
                                     <div id="zonaedit" class="col-md-4">
                                          <label for="ddZonaE" class="control-label"><span style="color: red">* </span>Zona:</label><br />
                                            <select id="ddZonaE" name="ddZonaE" class="btn btn-default dropdown-toggle ancho" multiple="multiple" style="width: 100%">
                                            </select>
                                     </div>
                                            <div id="modalidadEdit" class="col-md-4">
                                                <label for="ddlModalidadE" class="control-label"><span style="color: red">* </span>Modalidad:</label><br />
                                                <select id="ddlModalidadE" name="ddlModalidadE" class="btn btn-primary dropdown-toggle" style="width: 100%">
                                                </select>

                                            </div>
                                        </div>
                                <div class="row">
                                    </br>
                                        <div class="col-md-4">
                                            <label for="dtp_fecha_primerVtoE" class="control-label"><span style="color: red">* </span>Fecha Primer Vto.:</label>
                                            <input id="dtp_fecha_primerVtoE" placeholder="DD/MM/YYYY" type="text"  class="form-control" style="width: 100%"/>
                                        </div>

                                    <div class="col-md-4">
                                        <label for="dtp_fecha_segundoVtoE" class="control-label"><span style="color: red">* </span>Fecha Segundo Vto.:</label>
                                        <input id="dtp_fecha_segundoVtoE" placeholder="DD/MM/YYYY" type="text" class="form-control" style="width: 100%"/>
                                    </div>

                                    <div class="col-md-4">
                                        <label for="dtp_fecha_TercerVtoE" class="control-label">Fecha Tercer Vto.:</label>
                                        <input id="dtp_fecha_TercerVtoE" placeholder="DD/MM/YYYY" type="text" class="form-control" style="width: 100%"/>
                                    </div>
                                </div>


                                <div class="row">
                                    </br>
                                <div class="col-md-4">
                                    <label for="desc_primer_vtoE" class="control-label"><span style="color: red">* </span>Descuento Primer Vto.:</label>
                                    <input id="desc_primer_vtoE" placeholder="Ingrese un porcentaje." type="text" class="form-control" style="width: 100%" onkeypress="return validar_campo_num(event)" maxlength="3" />
                                </div>

                                    <div class="col-md-4">
                                        <label for="desc_segundo_vtoE" class="control-label"><span style="color: red">* </span>Descuento Segundo Vto.:</label>
                                        <input id="desc_segundo_vtoE" placeholder="Ingrese un porcentaje." type="text" class="form-control" style="width: 100%" onkeypress="return validar_campo_num(event)" maxlength="3" />
                                    </div>

                                    <div class="col-md-4">
                                        <label for="desc_tercer_vtoE" class="control-label">Descuento Tercer Vto.:</label>
                                        <input id="desc_tercer_vtoE" placeholder="Ingrese un porcentaje." type="text" class="form-control" style="width: 100%" onkeypress="return validar_campo_num(event)" maxlength="3" />
                                    </div>
                                </div>
                                             
                                    </div>
                                <div class="modal-footer">
                                    <button type="button" id="btnGrabar" class="btn btn-primary">Guardar</button>
                                    <button onclick="limpiarPopUpEditar()" type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>                                    
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
                                    <h4 class="modal-title" id="H3">¿Desea eliminar el Vencimientos?</h4>
                                </div>                           
                                <div id="footer_borrar" class="modal-footer">
                                    <asp:Label ID="Label1" runat="server" Text="¿Desea dar de baja el Registro Seleccionado?"/>
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                                    <button type="button" id="btnBorrar" class="btn btn-primary">Eliminar</button>
                                </div>
                            </div>                           
                        </div>
                    </div>
                </div>
            </div>
        </div>

</asp:Content>
