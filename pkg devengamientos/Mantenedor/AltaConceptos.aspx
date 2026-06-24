<%@ Page Language="C#" MasterPageFile="~/MasterPage/Ingresos.Master" AutoEventWireup="true" CodeBehind="AltaConceptos.aspx.cs" Inherits="webIngresos.Mantenedor.AltaConceptos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphContenidoIngreso" runat="Server">

    <style>
        .tam{
            width:300px;
        }
    </style>

    <script>


        var var_ID_TIPO_CONCEPTO;
        var var_TIPO_TRIBUTO;

        $(document).ready(function () {

           // Cargar_ddl("#ddltributo", "N", "BUSCAR_COMBO_TIPO_TRIBUTO", "-- Seleccione un tipo de tributo --", "ID_TIPO_TRIBUTO", "CONCEPTO_TRIBUTO");
            //BUSCAR
			TributoxJurisdiccion("#ddltributo");
                TributoxJurisdiccion("#ddlTiposTributosA");
                TributoxJurisdiccion("#ddlTiposTributosE");
                TributoxJurisdiccion("#ddlTiposTributosV");
                CerrarLoading();
            


            $('#btnConsulta').click(function () {


                var_TIPO_TRIBUTO = $('#ddltributo').val();

                if (var_TIPO_TRIBUTO == "0") {
                    Alerta('Seleccione un tipo de tributo.');
                }
                else {

                    mostrar("DivTabla");
                    TraerTiposConcepto();
                }

            });            


            $('#btnAgregar').click(function () {
                $('#radioPorcentajeA').prop('checked', true);
                $('#modalAgregar').modal('show');

            });

            $('#btnModalGuardar').click(function () {
                var Parametros = '';
                var Correcto = true;

                //--------------------validar---------------------------------//

                Correcto = Correcto && validar_campo_obligatorio('#txtConceptoA', "Debe ingresar un tipo de concepto.");
                Correcto = Correcto && validar_campo_obligatorio('#txtDescripcionA', "Debe ingresar una descripción.");
                Correcto = Correcto && validar_campo_obligatorio('#ddlTiposTributosA', "Debe ingresar un tipo de tributo.");
                Correcto = Correcto && validar_campo_obligatorio('#ddlImpactoA', "Debe seleccionar un impacto.");
                Correcto = Correcto && validar_campo_obligatorio('#ddlMasivoA', "Debe seleccionar masivo");
                Correcto = Correcto && validar_campo_numerico('#txtMontoA', "El porcentaje o valor debe ser un número positivo, máximo dos decimales.");
                Correcto = Correcto && validar_tamanio_tc('#txtTipo_cuotaA', "Tipo de cuota demasiado largo.");
                Correcto = Correcto && validar_campo_obligatorio('#txtTipo_cuotaA', "Debe ingresar un tipo de cuota.");

                //------------------------------------------------------------//

                if (Correcto) {
                    var concepto = $("#txtConceptoA").val().trim();
                    var descripcion = $("#txtDescripcionA").val().trim();

                    Parametros = Cargar_Parametro("TIPO_TRIBUTO", $("#ddlTiposTributosA").val(), Parametros);
                    Parametros = Cargar_Parametro("CONCEPTO", concepto, Parametros);
                    Parametros = Cargar_Parametro("DESCRIPCION", descripcion, Parametros);
                    Parametros = Cargar_Parametro("IMPACTO", $("#ddlImpactoA").val(), Parametros);

                    var monto_porcentaje = $("#txtMontoA").val();
                    if (monto_porcentaje == '') monto_porcentaje = 0;
                    monto_porcentaje = transformar_a_double(monto_porcentaje);
                    
                    if (document.getElementById('radioPorcentajeA').checked) {
                        Parametros = Cargar_Parametro("PORCENTAJE", monto_porcentaje, Parametros);
                        Parametros = Cargar_Parametro("VALOR", 0, Parametros); 
                    }
                    else {
                        Parametros = Cargar_Parametro("VALOR", monto_porcentaje, Parametros);
                        Parametros = Cargar_Parametro("PORCENTAJE", 0, Parametros);
                    }

                    var tipo_cuota = $("#txtTipo_cuotaA").val().toUpperCase();
                    Parametros = Cargar_Parametro("TIPO_CUOTA", tipo_cuota, Parametros);
                    Parametros = Cargar_Parametro("MASIVO", $("#ddlMasivoA").val(), Parametros);

                    $.ajax({
                        url: "AltaConceptos.aspx/INSERTAR_TIPO_CONCEPTO",
                        type: "post",
                        beforeSend: function () {
                            AbrirLoading();
                        },
                        data: Parametros,
                        contentType: "application/json",
                        success: function (data) {
                            mostrar("DivTabla");
                            $('#modalAgregar').modal('hide');
							sessionStorage.clear();
                            var_TIPO_TRIBUTO = $("#ddlTiposTributosA").val();

                            Exito("Tipo de concepto agregado con éxito.");
							limpiarConceptosCache();
                            TraerTiposConcepto();
                            limpiar_alta();
                            CerrarLoading();
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            var err = eval("(" + xhr.responseText + ")");
                            alert(err.Message);
                            CerrarLoading();

                        }
                    });
                }
            });

            $('#btnModalGuardarE').click(function () {
                var Parametros = '';
                var Correcto = true;

                //--------------------validar---------------------------------//

                Correcto = Correcto && validar_campo_obligatorio('#txtConceptoE', "Debe ingresar un tipo de concepto.");
                Correcto = Correcto && validar_campo_obligatorio('#txtDescripcionE', "Debe ingresar una descripción.");
                Correcto = Correcto && validar_campo_obligatorio('#ddlTiposTributosE', "Debe ingresar un tipo de tributo.");
                Correcto = Correcto && validar_campo_obligatorio('#ddlImpactoE', "Debe seleccionar un impacto.");
                Correcto = Correcto && validar_campo_obligatorio('#ddlMasivoE', "Debe seleccionar masivo.");
                //Correcto = Correcto && validar_campo_obligatorio('#txtMontoA', "Debe ingresar un valor o un porcentaje.");
                Correcto = Correcto && validar_campo_numerico('#txtMontoE', "El porcentaje o valor debe ser un número positivo, máximo dos decimales.");
                Correcto = Correcto && validar_tamanio_tc('#txtTipo_cuotaE', "Tipo de cuota demasiado largo.");
                Correcto = Correcto && validar_campo_obligatorio('#txtTipo_cuotaE', "Debe ingresar un tipo de cuota.");

                //------------------------------------------------------------//

                if (Correcto) {

                    var concepto = $("#txtConceptoE").val().trim();
                    var descripcion = $("#txtDescripcionE").val().trim();

                    Parametros = Cargar_Parametro("ID_TIPO_CONCEPTO", var_ID_TIPO_CONCEPTO, Parametros);
                    Parametros = Cargar_Parametro("TIPO_TRIBUTO", $("#ddlTiposTributosE").val(), Parametros);
                    Parametros = Cargar_Parametro("CONCEPTO", concepto, Parametros);
                    Parametros = Cargar_Parametro("DESCRIPCION", descripcion, Parametros);
                    Parametros = Cargar_Parametro("IMPACTO", $("#ddlImpactoE").val(), Parametros);

                    var monto_porcentaje = $("#txtMontoE").val();
                    if (monto_porcentaje == '') monto_porcentaje = 0;
                    monto_porcentaje = transformar_a_double(monto_porcentaje);

                    if (document.getElementById('radioPorcentajeE').checked) {
                        Parametros = Cargar_Parametro("PORCENTAJE", monto_porcentaje, Parametros);
                        Parametros = Cargar_Parametro("VALOR", 0, Parametros);
                    }
                    else {
                        Parametros = Cargar_Parametro("VALOR", monto_porcentaje, Parametros);
                        Parametros = Cargar_Parametro("PORCENTAJE", 0, Parametros);
                    }

                    var tipo_cuota = $("#txtTipo_cuotaE").val().toUpperCase();
                    Parametros = Cargar_Parametro("TIPO_CUOTA", tipo_cuota, Parametros);
                    Parametros = Cargar_Parametro("MASIVO", $("#ddlMasivoE").val(), Parametros);

                    $.ajax({
                        url: "AltaConceptos.aspx/EDITAR_TIPO_CONCEPTO",
                        type: "post",
                        beforeSend: function () {
                            AbrirLoading();
                        },
                        data: Parametros,
                        contentType: "application/json",
                        success: function (data) {
                            var_TIPO_TRIBUTO = $("#ddlTiposTributosE").val();

                            $('#modalEditar').modal('hide');
                            TraerTiposConcepto();
                            limpiar_alta();
                            CerrarLoading();
                            Exito("Cambios aplicados con éxito.");
							limpiarConceptosCache();
                        },
                        error: function (xhr, ajaxOptions, thrownError) {

                            var err = eval("(" + xhr.responseText + ")");
                            alert(err.Message);
                            CerrarLoading();

                        }
                    });
                }
            });

            $('#radioPorcentajeA').bind("change", function () {
                $('#radioValorA').prop('checked', false);
                $("#txtMontoA").val("");
                $("#txtMontoA").prop('placeholder', 'Ingrese un porcentaje');
                $("#txtMontoA").prop('disabled', false);
                $("#txtMontoA").attr('maxlength', 3);
            });

            $('#radioValorA').bind("change", function () {
                $('#radioPorcentajeA').prop('checked', false);
                $("#txtMontoA").val("");
                $("#txtMontoA").prop('placeholder', 'Ingrese un valor');
                $("#txtMontoA").prop('disabled', false);
                $("#txtMontoA").attr('maxlength', 9);

            });

            $('#radioPorcentajeE').bind("change", function () {
                $('#radioValorE').prop('checked', false);
                $("#txtMontoE").val("");
                $("#txtMontoE").prop('placeholder', 'Ingrese un porcentaje');
                $("#txtMontoE").prop('disabled', false);
                $("#txtMontoE").attr('maxlength', 3);
            });

            $('#radioValorE').bind("change", function () {
                $('#radioPorcentajeE').prop('checked', false);
                $("#txtMontoE").val("");
                $("#txtMontoE").prop('placeholder', 'Ingrese un valor');
                $("#txtMontoE").prop('disabled', false);
                $("#txtMontoE").attr('maxlength', 9);
            });

        });

		function limpiarConceptosCache() {
			sessionStorage.removeItem("conceptsCache");
		}

        function TraerTiposConcepto() {
            //var_ID_TIPO_CONCEPTO = null;

            $('#ddltributo').val(var_TIPO_TRIBUTO);

            var Parametros = '';
			//switch (var_TIPO_TRIBUTO) {
   //             case
   //                 "2":
			//		var_TIPO_TRIBUTO = 'AUAU';
			//		break;
			//	case "4":
			//		// Aquí debes agregar qué quieres que pase cuando sea 6
			//		// Por ejemplo:
			//		var_TIPO_TRIBUTO = 'CECE';
   //                 break;
			//	case "5":
			//		// Aquí debes agregar qué quieres que pase cuando sea 6
			//		// Por ejemplo:
			//		var_TIPO_TRIBUTO = 'CICI';
   //                 break;
			//	case "6":
			//		// Aquí debes agregar qué quieres que pase cuando sea 6
			//		// Por ejemplo:
			//		var_TIPO_TRIBUTO = 'ININ';
   //                 break;
			//	case "12":
			//		// Aquí debes agregar qué quieres que pase cuando sea 6
			//		// Por ejemplo:
			//		var_TIPO_TRIBUTO = 'OBSA';
   //                 break;
			//	case "18":
			//		// Aquí debes agregar qué quieres que pase cuando sea 6
			//		// Por ejemplo:
			//		var_TIPO_TRIBUTO = 'TASA_GENERAL';
   //                 break;

			//	default:
			//		// Opcionalmente puedes poner algo si no es ninguno de los anteriores
			//		break;
			//}
            Parametros = Cargar_Parametro("TIPO_TRIBUTO", var_TIPO_TRIBUTO, Parametros);

            $.ajax({
                url: "AltaConceptos.aspx/BUSCAR_CONCEPTOS",
                type: "post",
                beforeSend: function () {
                    AbrirLoading();
                },
                contentType: "application/json",
                data: Parametros,
                success: function (data) {
                    //var_TIPO_TRIBUTO = null;
                    mostrar("DivTabla");
                    CargarGrillaConceptos(data);
                    //if (data.d.length > 0) {
                    //}
                    //else {
                    //    ocultar("DivTabla");
                    //    Alerta("No se encontraron datos.");
                    //}
                    CerrarLoading();

                },
                error: function (xhr, ajaxOptions, thrownError) {
                    Error(thrownError);
                    CerrarLoading();
                }
            });
        }
            
        function Cargar_ddl(cmb, Multiselect, NombreFuncion, Mensaje, ID, CAMPO) {
            $.ajax({
                type: "post",
                beforeSend: function () {
                    AbrirLoading();
                },
                url: "AltaConceptos.aspx/" + NombreFuncion,
                contentType: "application/json; charset=utf-8",
                success: function (data, st) {
                    CerrarLoading();
                    if (st == 'success') {
                        if (data.d.length > 0) {
                            $(cmb).empty();
                            if (Multiselect == 'N')
                                $(cmb).empty().append('<option selected="selected" value="0">' + Mensaje + '</option>');
                            $.each(data.d, function () {
                                $(cmb).append($("<option></option>").val(this[ID]).html(this[CAMPO]));
                            });
                        }
                        else {
                            $(cmb).empty().append('<option selected="selected" value="0">No Disponible<option>');
                        }
                    }
                    if (Multiselect == 'S') {
                        Dar_Formato_Multiselect(cmb, "Modulo");
                    }
                },
                failure: function (data) {
                    CerrarLoading();
                    alert(data.d);
                }
            });
        }

        function CargarGrillaConceptos(data) {

            AbrirLoading();

            var conceptos = [];

            for (i = 0; i < data.d.length; i++) {

                var Ver = "<a href='#' onclick='return Ver(" + data.d[i].ID_TIPO_CONCEPTO + ");'  class='btn btn-primary btn-xs'><span class='glyphicon glyphicon-eye-open'></span></a>";
                var Editar = "<a href='#' onclick='return Editar(" + data.d[i].ID_TIPO_CONCEPTO + ");'  class='btn btn-warning-alt btn-xs'><span class='glyphicon glyphicon-pencil'></span></a>";
                var Eliminar = "<a href='#' onclick='return Eliminar(" + data.d[i].ID_TIPO_CONCEPTO + ");'  class='btn btn-danger-alt btn-xs'><span class='glyphicon glyphicon-trash'></span></a>";

                if (data.d[i].FEC_BAJA == null || data.d[i].FEC_BAJA == "/Date(1546225200000)/") {
                    conceptos.push([
                        data.d[i].CONCEPTO,
                        data.d[i].DESCRIPCION_TIPO_CONCEPTO,
                        data.d[i].TIPO_TRIBUTO,
                        data.d[i].CONCEPTO_TRIBUTO,
                        Ver,
                        Editar,
                        Eliminar,
                        null
                    ]);
                }
                else {
                    conceptos.push([
                        data.d[i].CONCEPTO,
                        data.d[i].DESCRIPCION_TIPO_CONCEPTO,
                        data.d[i].TIPO_TRIBUTO,
                        data.d[i].CONCEPTO_TRIBUTO,
                        Ver,
                        "",
                        "",
                        mostrarBaja(data.d[i].FEC_BAJA)
                    ]);
                }
            }

            Dar_Formato_Tabla_Alineacion_Baja($('#TablaConceptos'), conceptos);


            CerrarLoading();

        }

        function Eliminar(ID_TIPO_CONCEPTO) {
            var_ID_TIPO_CONCEPTO = ID_TIPO_CONCEPTO;

            swal({
                text: "¿Está seguro de querer dar de baja este tipo de concepto?",
                icon: "warning",
                buttons: true,
                dangerMode: false,
                /*buttons: ["Cancelar", "Eliminar"],*/
                buttons: {
                    confirm: 'Eliminar',
                    cancel: 'Cancelar'
                }
            })
                .then((willDelete) => {
                    if (willDelete) {
                        AbrirLoading();
                        var Parametros = '';
                        Parametros = Cargar_Parametro("ID_TIPO_CONCEPTO", var_ID_TIPO_CONCEPTO, Parametros);

                        $.ajax({
                            url: "AltaConceptos.aspx/ELIMINAR_TIPO_CONCEPTO",
                            type: "post",
                            beforeSend: function () {
                                AbrirLoading();
                            },
                            contentType: "application/json; charset=utf-8",
                            data: Parametros,
                            success: function (data) {
                                var_TIPO_TRIBUTO = $("#ddltributo").val();

                                TraerTiposConcepto();
                                CerrarLoading();
                                Alerta("Dado de baja con exito.");
                            },
                            error: function (xhr, ajaxOptions, thrownError) {
                                CerrarLoading();
                                alert(thrownError);
                            }
                        });


                    }
                });

        }

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

        function Ver(ID_TIPO_CONCEPTO) {

            $.ajax({
                url: "AltaConceptos.aspx/TRAER_PARA_EDITAR",
                type: "post",
                beforeSend: function () {
                    AbrirLoading();
                },
                data: "{ID_TIPO_CONCEPTO: '" + ID_TIPO_CONCEPTO + "'}",
                contentType: "application/json",
                success: function (data) {
                    CerrarLoading();
                    var_ID_TIPO_CONCEPTO = ID_TIPO_CONCEPTO;

                    $('#modalVer').modal('show');

                    $("#txtConceptoV").val(data.d.CONCEPTO);
                    $("#txtDescripcionV").val(data.d.DESCRIPCION_TIPO_CONCEPTO);
                    //$("#ddlTiposTributosV").val(data.d.TIPO_TRIBUTO);
                    $("#ddlTiposTributosV").val(var_TIPO_TRIBUTO);
                    $("#ddlImpactoV").val(data.d.IMPACTO);
                    $("#ddlMasivoV").val(data.d.MASIVO);

                    if (data.d.VALOR != 0) {
                        document.getElementById('lblMontoV').innerHTML = 'Valor';
                        $("#txtMontoV").val(data.d.VALOR);
                    }
                    else {
                        document.getElementById('lblMontoV').innerHTML = 'Porcentaje';
                        $("#txtMontoV").val(data.d.PORCENTAJE + "%");
                    }

                    $("#txtTipo_cuotaV").val(data.d.TIPO_CUOTA);

                    if (data.d.FEC_BAJA != null) {
                        mostrar("divFechaBaja");

                        var str = data.d.FEC_BAJA.replace('/Date(', '').replace(')/', '');
                        var fecha = new Date(parseInt(str));
                        var date = getFormattedDate(fecha);

                        $("#txtFechaBaja").val(date);
                    }
                    else {
                        ocultar("divFechaBaja");
                    }
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    CerrarLoading();
                    var err = eval("(" + xhr.responseText + ")");
                    alert(err.Message);
                }
            });
        }

        function Editar(ID_TIPO_CONCEPTO) {

            $.ajax({
                url: "AltaConceptos.aspx/TRAER_PARA_EDITAR",
                type: "post",
                beforeSend: function () {
                    AbrirLoading();
                },
                data: "{ID_TIPO_CONCEPTO: '" + ID_TIPO_CONCEPTO + "'}",
                contentType: "application/json",
                success: function (data) {
                    CerrarLoading();
                    var_ID_TIPO_CONCEPTO = ID_TIPO_CONCEPTO;

                    $('#modalEditar').modal('show');

                    $("#txtConceptoE").val(data.d.CONCEPTO);
                    $("#txtDescripcionE").val(data.d.DESCRIPCION_TIPO_CONCEPTO);
                    $("#ddlTiposTributosE").val(var_TIPO_TRIBUTO);
                    $("#ddlImpactoE").val(data.d.IMPACTO);
                    $("#ddlMasivoE").val(data.d.MASIVO);

                    if (data.d.VALOR != 0) {
                        $('#radioValorE').prop('checked', true);
                        $('#radioPorcentajeE').prop('checked', false);

                        var str = data.d.VALOR.toString();
                        var numStr = str.replace(/\./g, ',');

                        $("#txtMontoE").val(numStr);
                    }
                    else {
                        $('#radioPorcentajeE').prop('checked', true);
                        $('#radioValorE').prop('checked', false);

                        var str = data.d.PORCENTAJE.toString();
                        var numStr = str.replace(/\./g, ',');

                        $("#txtMontoE").val(numStr);
                    }

                    $("#txtTipo_cuotaE").val(data.d.TIPO_CUOTA);

                },
                error: function (xhr, ajaxOptions, thrownError) {
                    CerrarLoading();
                    var err = eval("(" + xhr.responseText + ")");
                    alert(err.Message);
                }
            });
        }

        function limpiar_alta() {
            var_ID_TIPO_CONCEPTO = null;

            $("#txtConceptoA").val('');
            $("#txtDescripcionA").val('');
            $("#ddlTiposTributosA").val('');
            $("#ddlImpactoA").val('');
            $("#ddlMasivoA").val('');
            $("#txtPorcentajeA").val('');
            $("#txtValorA").val('');
            $("#txtTipo_cuotaA").val('');
            $("#txtMontoA").val('');


        }

        function mostrar(idElementoHTML) {
            var x = document.getElementById(idElementoHTML);
            x.style.display = "block";
        }

        function ocultar(idElementoHTML) {
            var x = document.getElementById(idElementoHTML);
            x.style.display = "none";
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

        function validar_campo_num(e) {
            var regex = /^[0-9,]*$/;
            var str = String.fromCharCode(!e.charCode ? e.which : e.charCode);

            if (regex.test(str)) {
                
                return true;
            }
            e.preventDefault();
            return false;

        }

        function validar_campo_alfanum(e){
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

        function validar_tamanio_tc(campo,mensaje) {
            if ($(campo).val().length > 2) {
                Alerta(mensaje);
                return false;
            }
                
            return true;
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


    
<%--    <div class="container">--%>
        
        <h3>Alta Tipo Concepto </h3>

        <table>
            <tr>
                <td>
                    <label style="padding-right:10px">
                        <h4>Tipo Tributo:</h4>
                    </label>
                    <select id="ddltributo" name="ddltributo" class="btn btn-primary dropdown-toggle" style="width: 250px"></select>
                </td>
            </tr>
            <tr>
                <td style=" padding-bottom: 10px;">
                    <button type="button" id="btnConsulta" class="btn btn-primary" style="text-align: center; width: 125px"><i class="glyphicon glyphicon-search" aria-hidden="true" style="padding-right: 10px;"></i>Consultar</button>
                </td>
            </tr>
        </table>





        <%--###################################################### TABLA ####################################################--%>
    <div id="DivTabla" style="display: none">
        <table style="width: 100%;" class="table table-striped table-bordered table-hover table-condensed" id="TablaConceptos">
            <thead>
                <tr class="Estilo_Fila">
                    <th style="text-align: center" class="export">CONCEPTO</th>
                    <th style="text-align: center" class="export">DESCRIPCIÓN CONCEPTO</th>
                    <th style="text-align: center" class="export">TIPO TRIBUTO</th>
                    <th style="text-align: center" class="export">CONCEPTO TRIBUTO</th>
                    <th style="text-align: center" >VER</th>
                    <th style="text-align: center">EDITAR</th>
                    <th style="text-align: center">BAJA</th>
                    <th style="text-align: center" class="export">FECHA BAJA</th>

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
                <div class="modal-content">
                    <div class="modal-body">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title" id="H4">GENERAR TIPO CONCEPTO</h3>
                            </div>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="concepto" class="control-label"><span style="color: red">* </span>Concepto</label>
                                        <input type="text" name="concepto"  class="form-control" id="txtConceptoA" placeholder="Ingrese un Concepto (Max. 10 caracteres)" value="" maxlength="10" />
                                    </div>
                                </div>
                            </div>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="descripcion" class="control-label"><span style="color: red">* </span>Descripción</label>
                                        <input type="text" name="descripcion"  class="form-control" id="txtDescripcionA" placeholder="Ingrese una Descripción (Max. 100 caracteres)" value="" maxlength="100" />
                                    </div>
                                </div>
                            </div>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-8">
                                        <label for="ddlTiposTributosA" class="control-label"><span style="color: red">* </span>Tipo Tributo</label>
                                        <select id="ddlTiposTributosA" class="btn btn-primary dropdown-toggle" name="ddlTiposTributosA" style="width: 300px;">
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-4">
                                        <label for="ddlImpacto" class="control-label"><span style="color: red">* </span>Impacto</label>
                                        <select id="ddlImpactoA" class="btn btn-primary dropdown-toggle" name="ddlImpactoV" style="width: 150px;">
                                            <option value="">Seleccionar</option>                                            
                                            <option value="+">+</option>
                                            <option value="-">-</option>
                                        </select>
                                    </div>

                                    <div class="col-md-4">
                                        <label for="ddlMasivo" class="control-label"><span style="color: red">* </span>Masivo</label>
                                        <select id="ddlMasivoA" class="btn btn-primary dropdown-toggle" name="ddlImpactoV" style="width: 150px;">
                                            <option value="">Seleccionar</option>                                            
                                            <option value="S">S</option>
                                            <option value="N">N</option>
                                        </select>
                                    </div>

                                </div>
                            </div>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="auto-style1">
                                            <div id="radioBtnMontoA" class="btn-group" data-toggle="buttons">
                                                <label style="margin-right: 7px;">
                                                    <input type="radio" id="radioPorcentajeA" value="01" name="radioPorcentajeA" />Porcentaje
                                                </label>
                                                <label>
                                                    <input type="radio" id="radioValorA" value="02" name="radioValorA" />Valor
                                                </label>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-6">
                                        <input type="text" name="monto" class="form-control" id="txtMontoA" placeholder="Ingrese un Valor" value="" style="width: 300px;" onkeypress="return validar_campo_num(event)" maxlength="3" onpaste="return false;"/>
                                    </div>
                                </div>
                            </div>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="tipo_cuota" class="control-label"><span style="color: red">* </span>Tipo cuota</label>
                                        <input type="text" name="tipo_cuota" class="form-control" id="txtTipo_cuotaA" placeholder="Ingrese un Tipo de Cuota (Max. 2 caracteres)" maxlength="2" onkeypress="return validar_campo_alfanum(event)"/>
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
    <div class="modal fade" id="modalEditar" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static" data-keyboard="false">
        <div class="vertical-alignment-helper">
            <div class="modal-dialog vertical-align-center" role="document">
                <div class="modal-content">
                    <div class="modal-body">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title" id="H4">EDITAR TIPO CONCEPTO</h3>
                            </div>


                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="concepto" class="control-label">Concepto</label>
                                        <input type="text" name="concepto"  class="form-control" id="txtConceptoE" placeholder="Ingrese un Concepto (Max. 10 caracteres)" value="" maxlength="10"/>
                                    </div>
                                </div>
                            </div>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="descripcion" class="control-label">Descripción</label>
                                        <input type="text" name="descripcion"  class="form-control" id="txtDescripcionE" placeholder="Ingrese una Descripción (Max. 100 caracteres)" value="" maxlength="100"/>
                                    </div>
                                </div>
                            </div>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-8">
                                        <label for="ddlTiposTributosE" class="control-label">Tipo Tributo</label>
                                        <select id="ddlTiposTributosE" class="btn btn-primary dropdown-toggle" name="ddlTiposTributosE" style="width: 300px;" disabled>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-4">
                                        <label for="ddlImpacto" class="control-label"><%--<span style="color: red">* </span>--%>Impacto</label>
                                        <select id="ddlImpactoE" class="btn btn-primary dropdown-toggle" name="ddlImpactoV" style="width: 150px;">
                                            <option value="">Seleccionar</option>                                            
                                            <option value="+">+</option>
                                            <option value="-">-</option>
                                        </select>
                                    </div>

                                    <div class="col-md-4">
                                        <label for="ddlMasivo" class="control-label"><%--<span style="color: red">* </span>--%>Masivo</label>
                                        <select id="ddlMasivoE" class="btn btn-primary dropdown-toggle" name="ddlImpactoV" style="width: 150px;">
                                            <option value="">Seleccionar</option>                                            
                                            <option value="S">S</option>
                                            <option value="N">N</option>
                                        </select>
                                    </div>

                                </div>
                            </div>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="auto-style1">
                                            <div id="radioBtnMontoE" class="btn-group" data-toggle="buttons">
                                                <label style="margin-right: 7px;">
                                                    <input type="radio" id="radioPorcentajeE" value="01" name="radioPorcentajeE" />Porcentaje
                                                </label>
                                                <label>
                                                    <input type="radio" id="radioValorE" value="02" name="radioValorE" />Valor
                                                </label>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-6">
                                        <input type="text" name="montoE" class="form-control" id="txtMontoE" placeholder="Ingrese un Valor" value="" style="width: 300px;" onkeypress="return validar_campo_num(event)" maxlength="3" onpaste="return false;"/>

                                    </div>
                                </div>
                            </div>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="tipo_cuota" class="control-label">Tipo cuota</label>
                                        <input type="text" name="tipo_cuota"  class="form-control" id="txtTipo_cuotaE" placeholder="Ingrese un Tipo de Cuota (Max. 2 caracteres)" maxlength="2" onkeypress="return validar_campo_alfanum(event)"/>

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
                <div class="modal-content">
                    <div class="modal-body">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title" id="H4">CONSULTA TIPO CONCEPTO</h3>
                            </div>

                            <%--------------------------------------------------------------%>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="concepto" class="control-label">Concepto</label>
                                        <input type="text" name="concepto"  class="form-control" id="txtConceptoV" placeholder="Ingrese un Concepto" value="" readonly />
                                    </div>
                                </div>
                            </div>

                           <%--------------------------------------------------------------%>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="descripcion" class="control-label"></span>Descripción</label>
                                        <input type="text" name="descripcion"  class="form-control" id="txtDescripcionV" placeholder="Ingrese una Descripción" value="" readonly/>
                                    </div>
                                </div>
                            </div>

                           <%--------------------------------------------------------------%>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-8">
                                        <label for="ddlTiposTributosV" class="control-label">Tipo Tributo</label>
                                        <select id="ddlTiposTributosV" class="btn btn-primary dropdown-toggle" style="width: 300px;" disabled>
                                        </select>
                                    </div>
                                </div>
                            </div>

                           <%--------------------------------------------------------------%>

                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-4">
                                        <label for="ddlImpacto" class="control-label">Impacto</label>
                                        <select id="ddlImpactoV" class="btn btn-primary dropdown-toggle" name="ddlImpactoV" style="width: 150px;" disabled>
                                            <option value="">Seleccionar</option>                                            
                                            <option value="+">+</option>
                                            <option value="-">-</option>
                                        </select>
                                    </div>

                                    <div class="col-md-4">
                                        <label for="ddlMasivo" class="control-label">Masivo</label>
                                        <select id="ddlMasivoV" class="btn btn-primary dropdown-toggle" name="ddlImpactoV" style="width: 150px;" disabled>
                                            <option value="">Seleccionar</option>                                            
                                            <option value="S">S</option>
                                            <option value="N">N</option>
                                        </select>
                                    </div>

                                </div>
                            </div>

                           <%--------------------------------------------------------------%>

                            <div class="modal-body">
                                <div class="row">

                                    <div class="col-md-6">
                                        <label class="control-label" id="lblMontoV"></label>
                                        <input type="text" name="montoV"  class="form-control" id="txtMontoV" value="" readonly/>
                                    </div>

                                    <div class="col-md-6">
                                        <label for="tipo_cuota" class="control-label">Tipo cuota</label>
                                        <input type="text" name="tipo_cuota" class="form-control" id="txtTipo_cuotaV" placeholder="Ingrese un Tipo de Cuota" value="" readonly />
                                    </div>

                                </div>
                            </div>

                           <%--------------------------------------------------------------%>

                            <div class="modal-body">
                                <div class="row" id="divFechaBaja" style="display: none">
                                    <div class="col-md-6" >
                                        <label class="control-label" id="lblFechBaja">Fecha baja</label>
                                        <input type="text"  class="form-control" id="txtFechaBaja" value="" readonly/>
                                    </div>
                                </div>
                            </div>

                           <%--------------------------------------------------------------%>


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
