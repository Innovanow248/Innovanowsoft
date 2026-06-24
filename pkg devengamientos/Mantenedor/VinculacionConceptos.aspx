<%@ Page Language="C#" MasterPageFile="~/MasterPage/Ingresos.Master" AutoEventWireup="true" CodeBehind="VinculacionConceptos.aspx.cs" Inherits="webIngresos.Mantenedor.VinculacionConceptos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphContenidoIngreso" runat="Server">

    <style>
        .tam {
            width: 300px;
        }

        div.dt-button-collection{
            width: 280px;
        }

        .btn-green {
            background-color: #28A745;
        }

        .btn-green:hover {
            background-color: #1CC944 !important;
        }

        .swal-button--cancel {
            color:#333333;
            background-color: #F0F0F0;
        }

        .swal-button--cancel:hover {
            background-color: #E8E8E8 !important;
        }

        .btn-grey {
            color:#333333 !important;
            background-color: #F0F0F0;
        }

        .btn-grey:hover  {
            background-color: #E8E8E8 !important;
        }

    </style>

    <script>

        var var_ID_TIPO_CONCEPTO;
        var var_TIPO_TRIBUTO;
        var conceptos_seleccionados = new Array();
        var concepto_padre_seleccionado = null;
        var TRIBUTO_SELECCIONADO;
        var ANIO_SELECCIONADO;
        var CUOTA_SELECCIONADA;
        var GRILLA_PRINCIPAL = null;
        var GRILLA_CONCEPTOS = null;
        const COL_MODALIDAD = 3;
        const COL_ZONA = 2;


        $(document).ready(function () {
            CUOTA_SELECCIONADA = -1;
            AbrirLoading();

            TributosConConceptos("#ddltributo");
            TributosConConceptos("#ddlTiposTributosA");
            cargarAnios('#ddlAnioConsulta');

            CerrarLoading();

            setAncho();

            $('#btnAgregar').click(function () {
                AbrirLoading();
                cargarGrillaConceptosVacia();
                mostrarModal('#modalAgregar');

                CerrarLoading();

            });

            $('#btnConsulta').click(function () {

                if (validarConsulta()) cargarGrillaPrincipal();
            });

            $('#btnModalGuardar').click(function () {

                if (validarGuardar()) guardar();
                $('#ddlCuotaConsulta').val(CUOTA_SELECCIONADA);

            });

            $('#ddlTiposTributosA').bind("change", function () {
                AbrirLoading();

                if ($('#ddlTiposTributosA').val() == "") {

                    $('#ddlConceptoPadre').val("");
                    deshabilitar('#ddlConceptoPadre');

                    $('#ddlAnio').val("");
                    deshabilitar('#ddlAnio');

                    $('#ddlCuota').val("-1");
                    deshabilitar('#ddlCuota');

                    $('#ddlCumplidor').val("");
                    deshabilitar('#ddlCumplidor');

                    $('#ddlZona').val("");
                    deshabilitar('#ddlZona');

                    $('#ddlModalidad').val("");
                    deshabilitar('#ddlModalidad');

                    //ocultar('#divTablaConceptosA');
                }
                else {

                    $('#ddlAnio').val("");
                    deshabilitar('#ddlAnio');

                    $('#ddlCuota').val("-1");
                    deshabilitar('#ddlCuota');

                    $('#ddlCumplidor').val("");
                    deshabilitar('#ddlCumplidor');

                    $('#ddlZona').val("");
                    deshabilitar('#ddlZona');

                    $('#ddlModalidad').val("");
                    deshabilitar('#ddlModalidad');

                    //ocultar('#divTablaConceptosA');

                    if ($('#ddlTiposTributosA').val() == 6) {
                        mostrar('#divZona');
                        ocultar('#divModalidad');
                    }
                    else if ($('#ddlTiposTributosA').val() == 12) {
                        mostrar('#divModalidad');
                        ocultar('#divZona');

                    }
                    else {
                        ocultar('#divZona');
                        ocultar('#divModalidad');

                    }


                    TRIBUTO_SELECCIONADO = $('#ddlTiposTributosA').val();
                    //cargarAnios('#ddlAnio');

                    cargarConceptosPadres('#ddlConceptoPadre');

                }


                CerrarLoading();
            });

            $('#ddlAnio').bind("change", function () {

                if ($('#ddlAnio').val() == "") {
                    $('#ddlCuota').val("-1");
                    deshabilitar('#ddlCuota');

                    $('#ddlCumplidor').val("");
                    deshabilitar('#ddlCumplidor');

                    $('#ddlZona').val("");
                    deshabilitar('#ddlZona');

                    $('#ddlModalidad').val("");
                    deshabilitar('#ddlModalidad');

                    //ocultar('#divTablaConceptosA');
                }
                else {

                    $('#ddlCuota').val("-1");

                    $('#ddlZona').val("");
                    deshabilitar('#ddlZona');

                    $('#ddlModalidad').val("");
                    deshabilitar('#ddlModalidad');

                    $('#ddlCumplidor').val("");
                    deshabilitar('#ddlCumplidor');

                    //ocultar('#divTablaConceptosA');

                    cargarCuotas('#ddlCuota');
                    ANIO_SELECCIONADO = $('#ddlAnio').val();

                }



            });

            $('#ddlCuota').bind("change", function () {

                if ($('#ddlCuota').val() == "-1") {

                    $('#ddlZona').val("");
                    deshabilitar('#ddlZona');

                    $('#ddlModalidad').val("");
                    deshabilitar('#ddlModalidad');

                    $('#ddlCumplidor').val("");
                    deshabilitar('#ddlCumplidor');

                }
                else {
                    if ($('#ddlTiposTributosA').val() == 6) {

                        cargarZonas('#ddlZona');
                        habilitar('#ddlZona');

                        $('#ddlZona').val("");

                        $('#ddlCumplidor').val("");
                        deshabilitar('#ddlCumplidor');
                    }
                    else if ($('#ddlTiposTributosA').val() == 12) {
                        habilitar('#ddlModalidad');

                        $('#ddlModalidad').val("");

                        $('#ddlCumplidor').val("");
                        deshabilitar('#ddlCumplidor');
                    }
                    else {
                        habilitar('#ddlCumplidor');

                    }




                    CUOTA_SELECCIONADA = $('#ddlCuota').val();
                }
                //ocultar('#divTablaConceptosA');


            });

            $('#ddlZona').bind("change", function () {
                if ($('#ddlZona').val() == "") {
                    deshabilitar('#ddlCumplidor');
                }
                else {
                    habilitar('#ddlCumplidor');
                }
                //ocultar('#divTablaConceptosA');
                $('#ddlCumplidor').val("");



            });

            $('#ddlModalidad').bind("change", function () {

                if ($('#ddlModalidad').val() == "") {
                    deshabilitar('#ddlCumplidor');
                }
                else {
                    if (comprobarVencimientos()) habilitar('#ddlCumplidor');

                }
                //ocultar('#divTablaConceptosA');
                $('#ddlCumplidor').val("");
            });

            $('#ddltributo').bind("change", function () {

                TRIBUTO_SELECCIONADO = $('#ddltributo').val();
                cargarAnios('#ddlAnioConsulta');
                cargarCuotasConsulta('#ddlCuotaConsulta');

            });

            $('#ddlAnioConsulta').bind("change", function () {
                if ($('#ddlAnioConsulta').val() != "") {
                    ANIO_SELECCIONADO = $('#ddlAnioConsulta').val();
                    cargarCuotasConsulta('#ddlCuotaConsulta');
                }


            });

            $('#ddlCuotaConsulta').bind("change", function () {
                CUOTA_SELECCIONADA = $('#ddlCuotaConsulta').val();

            });


            $('#ddlConceptoPadre').bind("change", function () {

                if ($('#ddlConceptoPadre').val() == "") {

                    $('#ddlAnio').val("");
                    deshabilitar('#ddlAnio');

                }
                $('#ddlCuota').val("-1");
                deshabilitar('#ddlCuota');

                $('#ddlZona').val("");
                deshabilitar('#ddlZona');

                $('#ddlModalidad').val("");
                deshabilitar('#ddlModalidad');

                $('#ddlCumplidor').val("");
                deshabilitar('#ddlCumplidor');

                //ocultar('#divTablaConceptosA');

                cargarAnios('#ddlAnio');
            });

            $('#ddlCumplidor').bind("change", function () {

                cargarGrillaConceptosIncluir();


                //if ($('#ddlCumplidor').val() == "") {
                //    ocultar('#divTablaConceptosA');

                //}
                //else {
                //    cargarGrillaConceptosIncluir();

                //}
            });

        });

        function cargarCuotas(ddl) {
            var ajaxData = {
                P_ID_TIPO_TRIBUTO: $("#ddlTiposTributosA").val(),
                P_ANIO_EJERCICIO: $("#ddlAnio").val()
            }

            AbrirLoading();

            $.ajax({
                type: "POST",
                url: "VinculacionConceptos.aspx/TRAER_CUOTAS",
                data: JSON.stringify(ajaxData),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data, st) {
                    if (st == 'success') {
                        if (data.d.length > 0) {

                            habilitar(ddl);

                            $(ddl).empty().append('<option selected="selected" value="-1">-- Seleccione un Nro. Cuota --</option>');
                            $.each(data.d, function () {

                                $(ddl).append($("<option></option>").val(this['NRO_CUOTA']).html(this['NRO_CUOTA']));
                            });

                        }
                        else {

                            $(ddl).empty().prepend('<option selected="selected" value="">No disponible</option>');

                        }
                    }

                },
                failure: function (data) {
                    alert(data.d);
                }
            });

            CerrarLoading();
        }

        function cargarCuotasConsulta(ddl) {

            if (TRIBUTO_SELECCIONADO != 0 && ANIO_SELECCIONADO != null) {

                var ajaxData = {
                    P_ID_TIPO_TRIBUTO: TRIBUTO_SELECCIONADO,
                    P_ANIO_EJERCICIO: ANIO_SELECCIONADO
                }

                AbrirLoading();


                $.ajax({
                    type: "POST",
                    url: "VinculacionConceptos.aspx/TRAER_CUOTAS",
                    data: JSON.stringify(ajaxData),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data, st) {
                        if (st == 'success') {
                            if (data.d.length > 0) {

                                habilitar(ddl);

                                $(ddl).empty().append('<option selected="selected" value="-1">-- Seleccione un Nro. Cuota --</option>');
                                $.each(data.d, function () {

                                    $(ddl).append($("<option></option>").val(this['NRO_CUOTA']).html(this['NRO_CUOTA']));
                                });

                            }
                            else {

                                $(ddl).empty().prepend('<option selected="selected" value="">No disponible</option>');

                            }
                        }

                    },
                    failure: function (data) {
                        alert(data.d);
                    }
                });

                CerrarLoading();
            }
        }

        function cargarCuotasConsultaCargada(ddl, nroCuota) {

            if (TRIBUTO_SELECCIONADO != 0 && ANIO_SELECCIONADO != null) {

                var ajaxData = {
                    P_ID_TIPO_TRIBUTO: TRIBUTO_SELECCIONADO,
                    P_ANIO_EJERCICIO: ANIO_SELECCIONADO
                }

                AbrirLoading();


                $.ajax({
                    type: "POST",
                    url: "VinculacionConceptos.aspx/TRAER_CUOTAS",
                    data: JSON.stringify(ajaxData),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data, st) {
                        if (st == 'success') {
                            if (data.d.length > 0) {

                                habilitar(ddl);

                                $(ddl).empty().append('<option value="-1">-- Seleccione un Nro. Cuota --</option>');
                                $.each(data.d, function () {
                                    var option = $("<option></option>").val(this['NRO_CUOTA']).html(this['NRO_CUOTA']);

                                    if (this['NRO_CUOTA'] == nroCuota) {
                                        option.attr("selected", "selected");
                                    }
                                    $(ddl).append(option);
                                });

                            }
                            else {

                                $(ddl).empty().prepend('<option selected="selected" value="">No disponible</option>');

                            }
                        }

                    },
                    failure: function (data) {
                        alert(data.d);
                    }
                });

                CerrarLoading();


            }



        }

        function cargarZonas(ddl) {


            var ajaxData = {
                P_ID_TIPO_TRIBUTO: $("#ddlTiposTributosA").val(),
                P_ANIO_EJERCICIO: $("#ddlAnio").val(),
                P_NRO_CUOTA: $("#ddlCuota").val()
            }

            AbrirLoading();


            $.ajax({
                type: "POST",
                url: "VinculacionConceptos.aspx/TRAER_ZONAS",
                data: JSON.stringify(ajaxData),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data, st) {
                    if (st == 'success') {
                        if (data.d.length > 0) {

                            habilitar(ddl);

                            $(ddl).empty().append('<option selected="selected" value="">-- Seleccione una Zona --</option>');
                            $.each(data.d, function () {

                                $(ddl).append($("<option></option>").val(this['N_ZONA']).html(this['N_ZONA']));
                            });

                        }
                        else {

                            $(ddl).empty().prepend('<option selected="selected" value="">No disponible</option>');

                        }
                    }

                },
                failure: function (data) {
                    alert(data.d);
                }
            });

            CerrarLoading();


        }

        function cargarConceptosPadres(ddl) {

            habilitar(ddl);

            var ajaxData = {
                P_ID_TIPO_TRIBUTO: $("#ddlTiposTributosA").val().toUpperCase()
            }

            $.ajax({
                type: "POST",
                data: JSON.stringify(ajaxData),
                url: "VinculacionConceptos.aspx/TRAER_CONCEPTOS_PADRE",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data, st) {
                    if (st == 'success') {
                        if (data.d.length > 0) {

                            $(ddl).empty().append('<option selected="selected" value="">-- Seleccione un Concepto --</option>');
                            $.each(data.d, function () {

                                $(ddl).append($("<option></option>").val(this['ID_TIPO_CONCEPTO']).html(this['DESCRIPCION_CONCEPTO_PADRE']));
                            });

                        }
                        else {

                            $(ddl).empty().prepend('<option selected="selected" value="">No disponible</option>');

                        }
                    }

                },
                failure: function (data) {
                    alert(data.d);
                }
            });
        }

        function verObservacion(id) {

            AbrirLoading();

            var ajaxData = {
                P_ID_CONCEPTO_VENCIMIENTO: id
            }

            $.ajax({
                type: "POST",
                data: JSON.stringify(ajaxData),
                url: "VinculacionConceptos.aspx/TRAER_OBSERVACION",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data, st) {
                    if (st == 'success') {

                        if (data.d.length > 0) {
                            var obs = data.d[0].OBSERVACION;
                            if (obs != null) document.getElementById("textObservacionV").innerHTML = obs;
                            else document.getElementById("textObservacionV").innerHTML = "";

                        }
                        else {
                            document.getElementById("textObservacionV").innerHTML = "";

                        }


                        mostrarModal('#modal_Observacion');
                    }

                },
                failure: function (data) {
                    alert(data.d);
                }
            });

            CerrarLoading();
        }

        function cargarGrillaConceptosVacia() { //esta negrada es para que aparezca la tabla con "Ningún dato disponible en esta tabla" si estás leyendo todo este mensaje tenés que salir un poco afuera
            var arrayConceptos = [];

            GRILLA_CONCEPTOS = formatear_tabla($('#tablaConceptosA'), arrayConceptos);

            GRILLA_CONCEPTOS.column(2).visible(true);

            mostrar('#divTablaConceptosA');
        }

        function cargarGrillaConceptosIncluir() {

            AbrirLoading();

            var zonas = $("#ddlZona").val() == "" ? null : $("#ddlZona").val();
            var modalidad = $("#ddlModalidad").val() == "" ? -1 : $("#ddlModalidad").val();
            var nro_cuota = $("#ddlCuota").val() == "-1" ? -1 : $("#ddlCuota").val();

            var ajaxData = {
                P_ID_TIPO_TRIBUTO: $("#ddlTiposTributosA").val(),
                P_ID_CONCEPTO_PADRE: $("#ddlConceptoPadre").val(),
                P_ANIO_EJERCICIO: $("#ddlAnio").val(),
                P_CUMPLIDOR: $("#ddlCumplidor").val().toUpperCase(),
                P_ZONA: zonas,
                P_MODALIDAD: modalidad,
                P_NRO_CUOTA: nro_cuota
            }

            $.ajax({
                type: "POST",
                data: JSON.stringify(ajaxData),
                url: "VinculacionConceptos.aspx/TRAER_CONCEPTOS_PARAMETRIZAR",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data, st) {

                    var arrayConceptos = [];
                    var idConcepto = '';

                    if (data.d != null && data.d.length > 0) {
                        for (i = 0; i < data.d.length; i++) {
                            idConcepto = data.d[i].ID_TIPO_CONCEPTO;

                            var checkDetalle = '<input type="checkbox" id="' + idConcepto.toString() + '" onClick="seleccionarConcepto(' + "'" +
                                idConcepto.toString() + "'" +
                                ');" name="check" class="editor-active checkS">';

                            arrayConceptos.push([
                                data.d[i].CONCEPTO,
                                data.d[i].DESCRIPCION_CONCEPTO_VINCULADO,
                                checkDetalle
                            ]);
                        }
                    }

                    //Dar_Formato_Tabla_Alineacion_Baja($('#tablaConceptosA'), arrayConceptos);

                    GRILLA_CONCEPTOS = formatear_tabla($('#tablaConceptosA'), arrayConceptos);

                    GRILLA_CONCEPTOS.column(2).visible(true);

                    mostrar('#divTablaConceptosA');

                },
                failure: function (data) {
                    alert(data.d);
                }
            });

            CerrarLoading();
        }

        function cargarGrillaPrincipal() {
            AbrirLoading();
            if (GRILLA_PRINCIPAL) {
                GRILLA_PRINCIPAL.column(COL_MODALIDAD).visible(true);
                GRILLA_PRINCIPAL.column(COL_ZONA).visible(true);
            }

            var ajaxData = {
                P_ID_TIPO_TRIBUTO: TRIBUTO_SELECCIONADO,
                P_ANIO_EJERCICIO: ANIO_SELECCIONADO,
                P_NRO_CUOTA: CUOTA_SELECCIONADA
            }

            $.ajax({
                url: "VinculacionConceptos.aspx/TRAER_CONCEPTOS_VENCIMIENTOS",
                type: "post",
                data: JSON.stringify(ajaxData),
                beforeSend: function () {
                    AbrirLoading();
                },
                async: false,
                contentType: "application/json",
                success: function (data) {

                    var arrayConceptosVencimientos = [];

                    //var ocultarColModalidad = $("#ddltributo").val() != 12; //si no es agua no muestro la modalidad
                    //var ocultarColZona = $("#ddltributo").val() != 6;// si no es propiedad no muestro la zona

                    var tieneModalidad = $("#ddltributo").val() == 12;
                    var tieneZona = $("#ddltributo").val() == 6;


                    for (i = 0; i < data.d.length; i++) {

                        var fecBaja = formatoFecha(data.d[i].FEC_BAJA);

                        var btnVer = "<a href='#' onclick='return verObservacion(" + data.d[i].ID_CONCEPTO_VENCIMIENTO + ");'  class='btn btn-primary btn-xs'><span class='glyphicon glyphicon-eye-open'></span></a>";
                        //var btnEditar = "<a href='#' onclick='return editar(" + data.d[i].ID_CONCEPTO_VENCIMIENTO + ");'  class='btn btn-warning-alt btn-xs'><span class='glyphicon glyphicon-pencil'></span></a>";
                        var btnBaja = "<a href='#' onclick='return baja(" + data.d[i].ID_CONCEPTO_VENCIMIENTO + ',' + data.d[i].NRO_CUOTA + ");'  class='btn btn-danger-alt btn-xs'><span class='glyphicon glyphicon-trash'></span></a>";


                        if (fecBaja != null && fecBaja != '') btnBaja = '';

                        var cumplidor = data.d[i].CUMPLIDOR == 1 ? 'CUMPLIDOR' : 'NO CUMPLIDOR';

                        var fila;

                        if (tieneModalidad) {
                            fila = [
                                data.d[i].EJERCICIO,
                                data.d[i].NRO_CUOTA,
                                data.d[i].ID_OBSA_MODALIDAD,
                                data.d[i].DESCRIPCION_CONCEPTO_PADRE,
                                data.d[i].CONCEPTO_VINCULADO,
                                data.d[i].DESCRIPCION_CONCEPTO_VINCULADO,
                                cumplidor,
                                btnVer,
                                btnBaja,
                                fecBaja
                            ]
                        }
                        else if (tieneZona) {
                            fila = [
                                data.d[i].EJERCICIO,
                                data.d[i].NRO_CUOTA,
                                data.d[i].N_ZONA,
                                data.d[i].DESCRIPCION_CONCEPTO_PADRE,
                                data.d[i].CONCEPTO_VINCULADO,
                                data.d[i].DESCRIPCION_CONCEPTO_VINCULADO,
                                cumplidor,
                                btnVer,
                                btnBaja,
                                fecBaja
                            ]
                        }
                        else {
                            fila = [
                                data.d[i].EJERCICIO,
                                data.d[i].NRO_CUOTA,
                                data.d[i].DESCRIPCION_CONCEPTO_PADRE,
                                data.d[i].CONCEPTO_VINCULADO,
                                data.d[i].DESCRIPCION_CONCEPTO_VINCULADO,
                                cumplidor,
                                btnVer,
                                btnBaja,
                                fecBaja
                            ]
                        }

                        arrayConceptosVencimientos.push(fila);
                    }

                    if (tieneModalidad) {
                        ocultar("#divTablaZona");
                        ocultar("#divTabla");

                        GRILLA_PRINCIPAL = formatear_tabla($('#TablaConceptosModalidad'), arrayConceptosVencimientos);
                        mostrar("#divTablaModalidad");



                    }
                    else if (tieneZona) {
                        ocultar("#divTablaModalidad");
                        ocultar("#divTabla");

                        GRILLA_PRINCIPAL = formatear_tabla($('#TablaConceptosZona'), arrayConceptosVencimientos);
                        mostrar("#divTablaZona");

                    }
                    else {
                        ocultar("#divTablaZona");
                        ocultar("#divTablaModalidad");

                        GRILLA_PRINCIPAL = formatear_tabla($('#TablaConceptos'), arrayConceptosVencimientos);
                        mostrar("#divTabla");

                    }

                    //if (ocultarColModalidad) GRILLA_PRINCIPAL.column(COL_MODALIDAD).visible(false);
                    //if (ocultarColZona) GRILLA_PRINCIPAL.column(COL_ZONA).visible(false);

                    CerrarLoading();
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    CerrarLoading();
                }
            });

            CerrarLoading();

            //CUOTA_SELECCIONADA = -1;
        }

        function guardar() {

            AbrirLoading();

            //validarInsertar();

            var zonas = $("#ddlZona").val() == "" ? null : $("#ddlZona").val();
            var modalidad = $("#ddlModalidad").val() == "" ? -1 : $("#ddlModalidad").val();

            var ajaxData = {
                P_ID_TIPO_TRIBUTO: $("#ddlTiposTributosA").val(),
                P_ANIO_EJERCICIO: $("#ddlAnio").val(),
                P_NRO_CUOTA: $("#ddlCuota").val(),
                P_ID_CONCEPTO_PADRE: $("#ddlConceptoPadre").val(),
                P_CUMPLIDOR: $("#ddlCumplidor").val(),
                P_CONCEPTOS_VINCULADOS: conceptos_seleccionados.toString(),
                P_OBSERVACION: $("#textObservacion").val(),
                P_ZONA: zonas,
                P_MODALIDAD: modalidad
            }

            $.ajax({
                type: "POST",
                data: JSON.stringify(ajaxData),
                url: "VinculacionConceptos.aspx/INSERTAR_VINCULACION_CONCEPTOS",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {

                    if (data.d == 'OK') {
                        Exito('La Vinculación de Conceptos se agregó correctamente.');

                        $('#ddltributo').val(TRIBUTO_SELECCIONADO);
                        $('#ddlAnioConsulta').val(ANIO_SELECCIONADO);
                        cargarCuotasConsultaCargada('#ddlCuotaConsulta', CUOTA_SELECCIONADA);
                        //cargarCuotasConsulta('#ddlCuotaConsulta');

                        habilitar('#ddltributo');
                        habilitar('#ddlAnioConsulta');
                        habilitar('#ddlCuotaConsulta');

                        cargarGrillaPrincipal();
                        ocultarModal('#modalAgregar');
                        limpiarModalAgregar();
                    }
                    else {
                        Error(data.d);
                    }


                },
                failure: function (data) {
                    Error(data.d);

                }
            });

            CerrarLoading();

        }

        function comprobarVencimientos() {

            AbrirLoading();

            //validarInsertar();

            var ajaxData = {
                P_ID_TIPO_TRIBUTO: $("#ddlTiposTributosA").val(),
                P_ANIO_EJERCICIO: $("#ddlAnio").val(),
                P_NRO_CUOTA: $("#ddlCuota").val(),
                P_MODALIDAD: $("#ddlModalidad").val()


            }

            $.ajax({
                type: "POST",
                data: JSON.stringify(ajaxData),
                url: "VinculacionConceptos.aspx/COMPROBAR_VENCIMIENTOS",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {

                    if (data.d != 'OK') {
                        Alerta('No se encontraron vencimientos para esta modalidad.');
                        return false;

                    }
                    else {
                        return true;
                    }


                },
                failure: function (data) {
                    Error(data.d);

                }
            });

            CerrarLoading();
        }


        function seleccionarTodos(idTabla, colCheckbox) {

            var cols = $(idTabla).DataTable().column(colCheckbox).nodes();

            conceptos_seleccionados = [];

            if ($('#chkTodos').prop('checked')) {
                for (var i = 0; i < cols.length; i += 1) {
                    cols[i].querySelector("input[type='checkbox']").checked = true;
                }

                var tabla = $(idTabla).DataTable().column(colCheckbox).data();

                tabla.each(function (i) {
                    var elemento = $(i).prop('id');

                    conceptos_seleccionados.push(elemento);
                });

            }
            else {
                for (var i = 0; i < cols.length; i += 1) {
                    cols[i].querySelector("input[type='checkbox']").checked = false;
                }
                conceptos_seleccionados = [];
            }

        }

        function seleccionarConcepto(idConcepto) {

            if ($('#' + idConcepto).prop('checked')) {
                conceptos_seleccionados.push(idConcepto.toString());
            }
            else {
                var index = conceptos_seleccionados.findIndex(e => e == idConcepto);
                if (index != -1) {
                    conceptos_seleccionados.splice(index, 1);
                }
                if ($('#chkTodos').prop('checked')) $("#chkTodos").prop("checked", false);
            }

        }

        function baja(idConceptoVencimiento, nroCuota) {
            swal({
                text: "¿Desea dar de baja la Vinculación de Conceptos?",
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
                        var ajaxData = {
                            P_ID_CONCEPTO_VENCIMIENTO: idConceptoVencimiento
                        }

                        $.ajax({
                            type: "POST",
                            data: JSON.stringify(ajaxData),
                            url: "VinculacionConceptos.aspx/BAJA_VINCULACION",
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (data, st) {
                                CerrarLoading();
                                Exito('La Vinculación de Conceptos se dio de baja correctamente.');
                                cargarGrillaPrincipal();

                            },
                            failure: function (data) {
                                CerrarLoading();
                                alert(data.d);
                            }
                        });

                    }
                });
        }

        function editar() {
            return;
        }

        function ver() {
            return;
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

        function mostrar(idElemento) {
            //var x = document.getElementById(idElementoHTML);
            //x.style.display = "block";

            $(idElemento).show();
        }

        function ocultar(idElemento) {
            //var x = document.getElementById(idElementoHTML);
            //x.style.display = "none";
            $(idElemento).hide();

        }

        function mostrarModal(idModal) {
            $(idModal).modal("show");

        }

        function ocultarModal(idModal) {
            $(idModal).modal("hide");

        }

        //function ocultarColumna(idTabla, col) {
        //    $(idTabla + ' tr > *:nth-child(' + col + ')').hide();
        //}

        function ocultarColumna(tabla, col) {
            // Hide the column on the first page
            table.column(column_index).visible(false);

            // Loop through each page of the table and hide the column
            table.on('draw', function () {
                table.page().nodes().each(function () {
                    $(this).find('td').eq(column_index).hide();
                });
            });
        }

        function mostrarColumna(idTabla, col) {
            $(idTabla + ' tr > *:nth-child(' + col + ')').show();
        }

        function habilitar(idElemento) {
            $(idElemento).prop("disabled", false);

        }

        function deshabilitar(idElemento) {
            $(idElemento).prop("disabled", true);

        }

        function formatoFecha(data) {
            //data = data.d[i].FECHA_BAJ

            if (data != null) {
                var str = data.replace('/Date(', '');
                var str2 = str.replace(')/', '');
                var fecha = new Date(parseInt(str2));
                var fechaFormat = getFormattedDate(fecha);
            }
            else {
                var fechaFormat = '';
            }
            return fechaFormat;
        }

        function cargarAnios(ddl) {
            habilitar(ddl);
            const now = new Date();
            const currentYear = now.getFullYear();

            $(ddl).empty().append('<option selected="selected" value="">-- Seleccione un Período --</option>');

            for (let anio = currentYear; anio > currentYear - 5; anio--) {
                $(ddl).append($("<option></option>").val(anio).html(anio));
            }

        }

        function validarDdl(ddl, mensaje) {
            if ($(ddl).val() == "" || $(ddl).val() == null || $(ddl).val() == -1) {
                Alerta(mensaje);
                return false;
            }
            return true;
        }

        function validarConsulta() {
            var resultado = true;

            if ($('#ddltributo').val() == 0 && $('#ddlAnioConsulta').val() == 0) {
                Alerta('Seleccione un filtro para la consulta.');
                return false;
            }

            resultado = resultado && validarDdl('#ddltributo', 'Seleccione un Tributo.')
                && validarDdl('#ddlAnioConsulta', 'Seleccione un Período.');

            return resultado;
        }

        function validarGuardar() {
            var resultado = true;

            resultado = resultado
                && validarDdl('#ddlTiposTributosA', 'Seleccione un Tributo.')
                && validarDdl('#ddlConceptoPadre', 'Seleccione un Concepto Padre.')
                && validarDdl('#ddlAnio', 'Seleccione un Período.')
                && validarDdl('#ddlCuota', 'Seleccione un Nro. Cuota.');


            if ($('#ddlTiposTributosA').val() == 6) resultado = resultado && validarDdl('#ddlZona', 'Seleccione una Zona.');
            if ($('#ddlTiposTributosA').val() == 12) resultado = resultado && validarDdl('#ddlModalidad', 'Seleccione una Modalidad.');

            resultado = resultado
                && validarDdl('#ddlCumplidor', 'Seleccione un Aplica a.')
                && validarConceptosSeleccionados('Seleccione un Concepto a Vincular.');

            return resultado;
        }

        function TributosConConceptos(ddl) {
            $.ajax({
                type: "POST",
                url: "VinculacionConceptos.aspx/TRIBUTOS_CON_CONCEPTOS ",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data, st) {
                    if (st == 'success') {
                        if (data.d.length > 0) {

                            $(ddl).empty().append('<option selected="selected" value="">-- Seleccione un Tributo --</option>');
                            $.each(data.d, function () {

                                $(ddl).append($("<option></option>").val(this['ID_TIPO_TIBUTO']).html(this['CONCEPTO']));
                            });

                        }
                        else {
                            $(ddl).empty().prepend('<option selected="selected" value="">No disponible</option>');

                        }
                    }

                },
                failure: function (data) {
                    alert(data.d);
                }
            });
        }

        function limpiarModalAgregar() {

            $('#ddlTiposTributosA').val("");

            $('#ddlConceptoPadre').val("");
            deshabilitar('#ddlConceptoPadre');

            $('#ddlAnio').val("");
            deshabilitar('#ddlAnio');

            $('#ddlCuota').val("-1");
            deshabilitar('#ddlCuota');

            $('#ddlCumplidor').val("");
            deshabilitar('#ddlCumplidor');

            $('#ddlZona').val("");
            deshabilitar('#ddlZona');

            $('#ddlModalidad').val("");
            deshabilitar('#ddlModalidad');

            document.getElementById("textObservacion").value = "";
            document.getElementById("chkTodos").checked = false;


            //ocultar('#divTablaConceptosA');
            var table = $('#tablaConceptosA').DataTable();
            table.clear().draw();


            conceptos_seleccionados = new Array();
            concepto_padre_seleccionado = null;
            ocultar('#divZona');
            ocultar('#divModalidad');

        }

        function validarConceptosSeleccionados(mensaje) {
            if (conceptos_seleccionados.length <= 0) {
                Alerta(mensaje);
                return false;
            }
            return true;
        }

        function setAncho() {
            const labelElement = document.getElementById('lblNroCuota');
            const labelWidth = labelElement.offsetWidth;
            const width = labelWidth.toString() + 'px';
            $('#lblTributo').css('width', width);
            $('#lblPeriodo').css('width', width);
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

    <div class="contenido" style="padding-top: 0px">

        <h3>Vinculación de Conceptos </h3>

        <div class="row">
            <div class="col-md-12 d-flex justify-content-center align-items-center">
                <label id="lblTributo" class="control-label" style="margin-right: 10px;margin-top: 10px; margin-bottom: 10px; font-weight: normal; font-size: 18px"><span style="color: red; font-size: 18px">* </span>Tributo:</label>

                    <div class="btn-group" data-toggle="buttons">
                                                <select id="ddltributo" name="ddltributo" class="btn btn-primary dropdown-toggle" style="width: 250px"></select>

                    </div>
            </div>
        </div>


        <div class="row">
            <div class="col-md-12 d-flex justify-content-center align-items-center">
                <label id="lblPeriodo" class="control-label" style="margin-right: 10px;margin-top: 10px; margin-bottom: 10px; font-weight: normal; font-size: 18px"><span style="color: red; font-size: 18px">* </span>Período:</label>

                <div class="btn-group" data-toggle="buttons">
                    <select id="ddlAnioConsulta" class="btn btn-primary dropdown-toggle" style="width: 250px" disabled>
                        <option value="" selected>-- Seleccione un Año --</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-12 d-flex justify-content-center align-items-center">
                <label id="lblNroCuota" class="control-label" style="margin-right: 10px;margin-top: 10px; margin-bottom: 10px; font-weight: normal; font-size: 18px">    Nro. Cuota:</label>

                    <div class="btn-group" data-toggle="buttons">
                        <select id="ddlCuotaConsulta" class="btn btn-primary dropdown-toggle" style="width: 250px">
                            <option value="-1" selected>-- Seleccione un Nro. Cuota --</option>
                            <option value="-1" >No disponible</option>
                        </select>

                    </div>
            </div>
        </div>


        <div style="margin-bottom:10px; margin-top:10px">
            <button type="button" id="btnConsulta" class="btn btn-primary" style="text-align: center; width: 125px"><i class="glyphicon glyphicon-search" aria-hidden="true" style="padding-right: 10px;"></i>Consultar</button>
        </div>


        <%--###################################################### TABLA ####################################################--%>
        <div id="divTabla" style="display: none">
            <h3 style="font-size:22px">Detalle de la Consulta: </h3>

            <table style="width: 100%;" class="table table-striped table-bordered table-hover table-condensed" id="TablaConceptos">
                <thead>
                    <tr class="Estilo_Fila">
                        <th style="text-align: center;vertical-align: middle" class="export centro">PERÍODO</th>
                        <th style="text-align: center;vertical-align: middle" class="export derecha colvis">NRO. CUOTA</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">CONCEPTO PADRE</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">CONCEPTO VINCULADO</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">DESCRIPCIÓN CONCEPTO VINCULADO</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">APLICA A</th>
                        <th style="text-align: center;vertical-align: middle" class="colvis">OBSERVACIÓN</th>
                        <th style="text-align: center;vertical-align: middle" class="colvis">BAJA</th>
                        <th style="text-align: center;vertical-align: middle" class="export centro colvis">FECHA BAJA</th>

                    </tr>
                </thead>
            </table>


        </div>
        <%--###################################################### TABLA MODALIDAD ####################################################--%>
        <div id="divTablaModalidad" style="display: none">
            <h3 style="font-size:22px">Detalle de la Consulta: </h3>

            <table style="width: 100%;" class="table table-striped table-bordered table-hover table-condensed" id="TablaConceptosModalidad">
                <thead>
                    <tr class="Estilo_Fila">
                        <th style="text-align: center;vertical-align: middle" class="export centro">PERÍODO</th>
                        <th style="text-align: center;vertical-align: middle" class="export derecha colvis">NRO. CUOTA</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">MODALIDAD</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">CONCEPTO PADRE</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">CONCEPTO VINCULADO</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">DESCRIPCIÓN CONCEPTO VINCULADO</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">APLICA A</th>
                        <th style="text-align: center;vertical-align: middle" class="colvis">OBSERVACIÓN</th>
                        <th style="text-align: center;vertical-align: middle" class="colvis">BAJA</th>
                        <th style="text-align: center;vertical-align: middle" class="export centro colvis">FECHA BAJA</th>

                    </tr>
                </thead>
            </table>


        </div>
        <%--###################################################### TABLA ZONA ####################################################--%>
        <div id="divTablaZona" style="display: none">
            <h3 style="font-size:22px">Detalle de la Consulta: </h3>

            <table style="width: 100%;" class="table table-striped table-bordered table-hover table-condensed" id="TablaConceptosZona">
                <thead>
                    <tr class="Estilo_Fila">
                        <th style="text-align: center;vertical-align: middle" class="export centro">PERÍODO</th>
                        <th style="text-align: center;vertical-align: middle" class="export derecha colvis">NRO. CUOTA</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">ZONAS</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">CONCEPTO PADRE</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">CONCEPTO VINCULADO</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">DESCRIPCIÓN CONCEPTO VINCULADO</th>
                        <th style="text-align: center;vertical-align: middle" class="export colvis">APLICA A</th>
                        <th style="text-align: center;vertical-align: middle" class="colvis">OBSERVACIÓN</th>
                        <th style="text-align: center;vertical-align: middle" class="colvis">BAJA</th>
                        <th style="text-align: center;vertical-align: middle" class="export centro colvis">FECHA BAJA</th>

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
                <div class="modal-dialog vertical-align-center modal-lg" role="document">
                    <div class="modal-content">
                        <div class="modal-body">
                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h3 class="panel-title" id="H4">GENERAR VINCULACIÓN DE CONCEPTOS</h3>
                                </div>

                                <div class="modal-body">
                                    <div class="row" style="margin-left: 15px">

                                        <div class="col-md-4">
                                            <div class="row">
                                                <label style="margin-bottom: 10px">
                                                    <span style="color: red">* </span>
                                                    Tributo:
                                               
                                                </label>
                                            </div>
                                            <div class="row">
                                                <select id="ddlTiposTributosA" name="ddlTiposTributosA" class="btn btn-primary dropdown-toggle" style="width: 250px"></select>
                                            </div>


                                        </div>

                                        <div class="col-md-4">
                                            <div class="row">
                                                <label style="margin-bottom: 10px">
                                                    <span style="color: red">* </span>
                                                    Concepto Padre:
                                               
                                                </label>
                                            </div>

                                            <div class="row">
                                                <select id="ddlConceptoPadre" name="ddlTiposTributosA" class="btn btn-primary dropdown-toggle" style="width: 250px" disabled>
                                                    <option value="" selected>-- Seleccione un Concepto --</option>

                                                </select>

                                            </div>

                                        </div>

                                        <div class="col-md-4">
                                            <div class="row">
                                                <label style="margin-bottom: 10px">
                                                    <span style="color: red">* </span>

                                                    Período:
                                               
                                                </label>
                                            </div>
                                            <div class="row">
                                                <select id="ddlAnio" class="btn btn-primary dropdown-toggle" style="width: 250px" disabled>
                                                    <option value="" selected>-- Seleccione un Período --</option>

                                                </select>
                                            </div>


                                        </div>



                                    </div>

                                    <div class="row" style="margin-left: 15px; margin-top: 15px">

                                        <div class="col-md-4">
                                            <div class="row">
                                                <label style="margin-bottom: 10px">
                                                    <span style="color: red">* </span>

                                                    Nro. Cuota:
                                               
                                                </label>
                                            </div>

                                            <div class="row">
                                                <select id="ddlCuota" class="btn btn-primary dropdown-toggle" style="width: 250px" disabled>
                                                    <option value="-1" selected>-- Seleccione un Nro. Cuota --</option>

                                                </select>
                                            </div>
                                        </div>

                                        <div id="divZona" class="col-md-4" style="display: none">
                                            <div class="row">
                                                <label style="margin-bottom: 10px">
                                                    <span style="color: red">* </span>

                                                    Zonas:
                                               
                                                </label>
                                            </div>

                                            <div class="row">
                                                <select id="ddlZona" class="btn btn-primary dropdown-toggle" style="width: 250px" disabled>
                                                    <option value="" selected>-- Seleccione una Zona --</option>

                                                </select>
                                            </div>


                                        </div>

                                        <div id="divModalidad" class="col-md-4" style="display: none">
                                            <div class="row">
                                                <label style="margin-bottom: 10px">
                                                    <span style="color: red">* </span>

                                                    Modalidad:
                                               
                                                </label>
                                            </div>

                                            <div class="row">
                                                <select id="ddlModalidad" class="btn btn-primary dropdown-toggle" style="width: 250px" disabled>
                                                    <option value="" selected>-- Seleccione una Modalidad --</option>
                                                    <option value="1">CUOTA FIJA</option>
                                                    <option value="2">MEDIDOR</option>

                                                </select>
                                            </div>


                                        </div>



                                        <div class="col-md-4">
                                            <div class="row">
                                                <label style="margin-bottom: 10px">
                                                    <span style="color: red">* </span>

                                                    Aplica a:
                                               
                                                </label>
                                            </div>

                                            <div class="row">
                                                <select id="ddlCumplidor" name="ddlCumplidor" class="btn btn-primary dropdown-toggle" style="width: 250px" disabled>
                                                    <option value="" selected>-- Seleccione un Tipo --</option>
                                                    <option value="C">Cumplidores</option>
                                                    <option value="NC">No cumplidores</option>
                                                    <option value="T">Todos</option>

                                                </select>
                                            </div>
                                        </div>


                                    </div>

                                    <div class="row" style="margin-left: 15px; margin-top: 15px">
                                        <label style="margin-bottom: 10px">
                                            <span style="color: red">* </span>

                                            Conceptos a Vincular:
                                       
                                        </label>
                                    </div>

                                    <div class="row" style="margin-left: 15px; margin-right: 15px">
                                        <div id="divTablaConceptosA" style="margin-top: 10px">
                                            <table style="width: 100%;" class="table table-striped table-bordered table-hover table-condensed" id="tablaConceptosA">
                                                <thead>
                                                    <tr class="Estilo_Fila">
                                                        <th style="text-align: center;vertical-align: middle" class="export">CONCEPTO</th>
                                                        <th style="text-align: center;vertical-align: middle" class="export colvis">DESCRIPCIÓN</th>
                                                        <th style="text-align: center;vertical-align: middle" class="centro">
                                                            <input type="checkbox" id="chkTodos" onclick="seleccionarTodos('#tablaConceptosA',2)" name="chkTodos" class="editor-active checkS" />
                                                        </th>

                                                    </tr>
                                                </thead>
                                            </table>
                                        </div>
                                    </div>

                                    <div class="row" style="margin-left: 15px;">
                                        <label style="margin-bottom: 10px">
                                            Observación:
                                       
                                        </label>
                                    </div>
                                    <div class="row" style="margin-left: 15px; margin-right: 15px;">

                                        <textarea id="textObservacion" style="height: 100px; width: 100%; padding: 1%; resize: none"></textarea>
                                    </div>
                                </div>


                                <div class="modal-footer">
                                    <button type="button" id="btnModalGuardar" class="btn btn-primary">Guardar</button>
                                    <button style="margin-right:15px" type="button" id="btnModalCerrar" class="btn btn-secondary btn-grey" data-dismiss="modal" onclick="limpiarModalAgregar()">Cancelar</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>


        <%--    ################################################################### MODAL OBSERVACION ###################################################################  --%>
        <div class="modal fade" id="modal_Observacion" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-size" role="document" style="width: 50%;">
                <div class="modal-content">
                <div class="modal-body">
                    <div id="panelDO" class="panel panel-borde" style="padding-bottom: 15px">
                        <div class="titulo-panel" style="padding-left:5px">
                            <h2 class="panel-title"><strong>CONSULTAR OBSERVACIÓN VINCULACIÓN</strong></h2>
                        </div>
                        <div>
                            <label style="padding-left: 15px; padding-top:10px">
                                Observación:
                                       
                            </label>
                        </div>


                        <div class="panel-body" style="padding-top:0px;padding-right:10px">
                            <div class="panel-body"  style="padding-top:0px;padding-bottom:0px">
                                <div class="row">
                                    <%--                                    placeholder="Ingrese una observación..."--%>
                                    <textarea id="textObservacionV" style="height: 100px; width: 98%; padding: 1%; resize: none" readonly></textarea>
                                </div>
                            </div>
                        </div>

                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary btn-grey" data-dismiss="modal" style="margin-right:7px">Cerrar</button>
                            </div>
                    </div>
                </div>
</div>            
</div>
        </div>

    </div>


</asp:Content>