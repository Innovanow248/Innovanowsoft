<%@ Page Language="C#" MasterPageFile="~/MasterPage/Ingresos.Master" AutoEventWireup="true" CodeBehind="PantallaAuxiliar.aspx.cs" Inherits="webIngresos.PantallaAuxiliar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphContenidoIngreso" runat="Server">

    <script type="text/javascript">
        var idJurisdiccion = <%=Session["IdJur"]%>;

        $(document).ready(function () {

          //  PRUEBA_PORCENTAJE_CARGA();
            devengar();
            settimeout(() => {
                window.close();
            }, 500);

        });//Termina el ready
        var ID_TIPO_TRIBUTO_ESPECIAL;

        function PRUEBA_PORCENTAJE_CARGA() {//seria el devengamiento

            console.log("DEVENGAMIENTO INICIADO");
            var ajaxData = {
                P_ID_TIPO_TRIBUTO: 12
            }

            $.ajax({
                url: "PantallaAuxiliar.aspx/PRUEBA_PORCENTAJE_CARGA",
                type: "post",
                data: JSON.stringify(ajaxData),
                contentType: "application/json",
                async: true,
                success: function (data) {
                    if (data.d != null) {
                        var PORCENTAJE = data.d[0].PORCENTAJE;
                        var ESTADO = data.d[0].ESTADO;
                        var PROCESADAS = data.d[0].PROCESADAS;
                        var TOTAL = data.d[0].TOTAL;
                        var TIEMPO_UNITARIO = data.d[0].TIEMPO_UNITARIO;
                        var MENSAJE_ERROR = data.d[0].MENSAJE_ERROR;

                        console.log('|' + PROCESADAS + '|' + TOTAL + '|');
                    }
                    else {
                        console.log('PRUEBA_PORCENTAJE_CARGA: ERROR');

                    }
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    console.log('PRUEBA_PORCENTAJE_CARGA: ERROR');
                }
            });

            return true;
        }

        function devengar() {

            var ajaxData = getUrlParameters();

            if (ID_TIPO_TRIBUTO_ESPECIAL == 'SUEN') {
                metodo = 'devengarSuministroEnergia';
            } else {
                metodo = 'devengar';
            }

            console.log(JSON.stringify(ajaxData));

            $.ajax({
                beforeSend: function () {
                    AbrirLoading();
                },
                url: "PantallaAuxiliar.aspx/" + metodo + "",
                type: "post",
                data: JSON.stringify(ajaxData),
                contentType: "application/json",
                success: function (data) {

                    if (data.d == "") {
                        AlertaExito("Correcto!", "Se ha devengado con exito.", "success");

                        if (ajaxData.P_MODO = 'S') {
                            obtenerSimulacion(ajaxData.P_ID_TRIBUTO_CONTRIBUYENTE, ajaxData.P_TIPO_TRIBUTO, ajaxData.P_EJERCICIO_LIQ, ajaxData.P_NRO_CUOTA, ajaxData.P_MODALIDAD, ajaxData.P_MONTO);
                        }

                    }
                    else {
                        AlertaError.log("Hubo un problema!" + " Error al Liquidar la cuenta " + data.d);
                        console.log("Hubo un problema!" + " Error al Liquidar la cuenta " + data.d);

                        CerrarLoading();
                    }

                },
                error: function (xhr, ajaxOptions, thrownError) {

                    console.log("Error message: " + thrownError);
                    AlertaError("Hubo un problema! " + xhr.status + " - " + thrownError);

                    CerrarLoading();
                }
            });
        }



        function getUrlParameters() {
            const params = {};
            const queryString = window.location.search.slice(1);

            if (queryString) {
                const pairs = queryString.split('&');

                for (let i = 0; i < pairs.length; i++) {
                    const pair = pairs[i].split('=');
                    const key = decodeURIComponent(pair[0]);
                    const value = decodeURIComponent(pair[1] || '');

                    if (value == 'SUEN') //DESMALESADO TIENE OTROS PARAMETROS
                    {
                        ID_TIPO_TRIBUTO_ESPECIAL = value;
                    };

                    if (params[key]) {
                        if (Array.isArray(params[key])) {
                            params[key].push(value);
                        } else {
                            params[key] = [params[key], value];
                        }
                    } else {
                        params[key] = value;
                    }
                }
            }

            return params;
        }

        function AlertaError(data) {

            swal({
                text: data,
                icon: "error",
                dangerMode: false,
                confirmButtonText: "Aceptar"
            });
        }

    </script>

    <div>
    </div>


</asp:Content>
