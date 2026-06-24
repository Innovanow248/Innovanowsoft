<%@ Page Language="C#" MasterPageFile="~/MasterPage/Ingresos.Master" AutoEventWireup="true" CodeBehind="TipoPlanesPago.aspx.cs" Inherits="webIngresos.TipoPlanesPago" %>


<asp:Content ID="Content1" ContentPlaceHolderID="cphContenidoIngreso" runat="Server">
     <style type="text/css">
         .error{          
            border: 1px solid #FE2E2E; font-size:10pt; color: #000099
            }

         .borderless td.borderless {
             border: none;


         }

         #example td:nth-child(9) {
            text-align: center;
        }
          #example td:nth-child(10) {
            text-align: center;
        }

      </style>
   <script>
       var idEditar;
       var idBorrar;
       var idJurisdiccion = '4000';
       var arrayPlanes = [];
       //prueba

       $(document).ready(function () {

           // Evento para el cambio en los botones de radio Actualizable
           $('input[name="Actualiza"]').change(MostrarPeriodicidad);

           $('input[name="ActualizaE"]').change(MostrarPeriodicidad);

           traertributos("#ddltributo");
           traertributos('#ddltributoE');
           $('#agregarnuevo').hide();
           if (TieneAccion('ALTA', Nombre_Pagina())) $('#agregarnuevo').show();

           traerTipoPlanes();
           // $("#txtnombrezonaed").prop('disabled', true);

           $('#btnInsertar').click(function () {
               var Actualizable = $("input[name='Actualiza']:checked").val();


               if ($("#ddltributo").val() == 0 || $("#txtcodigoplan").val() == "" || $("#txtdesignacion").val() == "" ||
                   $("#txtdecretoresolucion").val() == "" || $("#ddlSoloUsoDev").val() == 0 /*|| $("#txtobservaciones").val() == ""*/ ||
                   $("#txtcantidadcuotas").val() == "" || $("#txtdiaprimervenci").val() == ""
                   || (Actualizable == 'S' && $("#ddlPeriodo").val() == 0)) {

                   swal("Faltan datos", "Complete todos los datos requeridos.", "error");

               } else {

                   var tipoTribut = $("#ddltributo").val();
                   var Codigop = $("#txtcodigoplan").val();
                   var Designa = $("#txtdesignacion").val();
                   var DecreSol = $("#txtdecretoresolucion").val();
                   var SolUsoDev = $("#ddlSoloUsoDev").val();
                   var Observ = $("#txtobservaciones").val();
                   var CantiCuot = $("#txtcantidadcuotas").val();
                   var DiaPriVen = $("#txtdiaprimervenci").val();
                   var Actualizable = $("input[name='Actualiza']:checked").val();
                   var Periodicidad = $("#ddlPeriodo").val();
                   //var mensaje = validacionAgregar();

                   var Parametros = '';
                   Parametros = Cargar_Parametro("Codigop", Codigop, Parametros);
                   Parametros = Cargar_Parametro("Designa", Designa, Parametros);
                   Parametros = Cargar_Parametro("DecreSol", DecreSol, Parametros);
                   Parametros = Cargar_Parametro("SolUsoDev", SolUsoDev, Parametros);
                   Parametros = Cargar_Parametro("Observ", Observ, Parametros);
                   Parametros = Cargar_Parametro("CantiCuot", CantiCuot, Parametros);
                   Parametros = Cargar_Parametro("DiaPriVen", DiaPriVen, Parametros);
                   Parametros = Cargar_Parametro("tipoTribut", tipoTribut, Parametros);
                   Parametros = Cargar_Parametro("actualiza", Actualizable, Parametros);
                   Parametros = Cargar_Parametro("periodo", Periodicidad, Parametros);

                   $.ajax({
                       url: "TipoPlanesPago.aspx/Insertar",
                       type: "post",
                       contentType: "application/json; charset=utf-8",
                       data: Parametros,
                       beforeSend: function () {
                           AbrirLoading();
                       },
                       success: function (data) {

                           traerTipoPlanes();

                           limpiar();
                           $('#myModal').modal('hide');
                           CerrarLoading();
                           swal("Alta realizada!", "Los datos han sido dados de alta con éxito.", "success");
                       },
                       error: function (xhr, ajaxOptions, thrownError) {
                           CerrarLoading();
                       }
                   });
               }

           });

           $('#btnCerrarA').click(function () {
               limpiar();
           });


           //$('input[type="text"]:required').click(function () {

           //    $(this).removeClass('error');

           //});

           $('#btnGrabar').click(function () {

               var Codigop = $("#txtcodigoplanE").val();
               var Designa = $("#txtdesignacionE").val();
               var DecreSol = $("#txtdecretoresolucionE").val();
               var SolUsoDev = $("#ddlSoloUsoDevE").val();
               var Observ = $("#txtobservacionesE").val();
               var CantiCuot = $("#txtcantidadcuotasE").val();
               var DiaPriVen = $("#txtdiaprimervenciE").val();
               var ActualizaE = $("input[name='ActualizaE']:checked").val();
               var Periodicidad = $("#ddlPeriodoE").val();
               var TipoTributo = $("#ddltributoE").val();
               //var mensaje = validacionAgregar();

               var Parametros = '';
               Parametros = Cargar_Parametro("Codigop", Codigop, Parametros);
               Parametros = Cargar_Parametro("Designa", Designa, Parametros);
               Parametros = Cargar_Parametro("DecreSol", DecreSol, Parametros);
               Parametros = Cargar_Parametro("SolUsoDev", SolUsoDev, Parametros);
               Parametros = Cargar_Parametro("Observ", Observ, Parametros);
               Parametros = Cargar_Parametro("CantiCuot", CantiCuot, Parametros);
               Parametros = Cargar_Parametro("id", idEditar, Parametros);
               Parametros = Cargar_Parametro("DiaPriVen", DiaPriVen, Parametros);
               Parametros = Cargar_Parametro("actualiza", ActualizaE, Parametros);
               Parametros = Cargar_Parametro("periodo", Periodicidad, Parametros);
               Parametros = Cargar_Parametro("tributo", TipoTributo, Parametros);


               $.ajax({
                   url: "TipoPlanesPago.aspx/Editar",
                   type: "post",
                   data: Parametros,
                   beforeSend: function () {
                       AbrirLoading();
                   },
                   contentType: "application/json",
                   success: function (data) {

                       traerTipoPlanes();
                       $('#divEditar').modal('hide');
                       swal("Modificado!", "Los datos han sido modificados con éxito.", "success");
                       CerrarLoading();
                   },
                   error: function (xhr, ajaxOptions, thrownError) {
                       CerrarLoading();
                   }
               });

           });

           $('#btnBorrar').click(function () {
               $.ajax({
                   url: "TipoPlanesPago.aspx/Borrado",
                   type: "post",
                   data: "{ID_TIPO_PLANESPAGO: '" + idBorrar + "'}",
                   contentType: "application/json",
                   success: function (data) {

                       $('#divBorrar').modal('hide');
                       if (data.d == '') {
                           traerTipoPlanes();
                           swal("Baja realizada", "Los datos han sido dados de baja con éxito.", "success");
                       } else {
                           swal('', data.d, "error");
                       }

                   },
                   error: function (xhr, ajaxOptions, thrownError) {

                   }
               });
           });

           //ACCIONES DEL BOTON CERRAR DEL POPUP DE BORRADO
           $('#btnCerrar').click(function () {
               document.getElementById('body_borrar').style.display = 'block';
               document.getElementById('footer_borrar').style.display = 'block';
               document.getElementById('body_ok').style.display = 'none';
               document.getElementById('footer_ok').style.display = 'none';
               $('#divBorrar').modal('hide');
           });

           $('#agregarnuevo').click(function () {
               $('#myModal').modal('show');

               if ($('input[name="Actualiza"]:checked').val() !== 'S') {
                   $('#periodicidad').hide();
                   $('#ddlPeriodo').prop('disabled', true).hide();
               }

               $("#ddlSoloUsoDev").prop('disabled', true);
               $("#ddlSoloUsoDev").val('S');

           });
       });

       function MostrarPeriodicidad(tipo) {

           var tipo = $(this).attr('name');
           var valorActualizable = $('input[name="' + tipo + '"]:checked').val();

           if (tipo == 'Actualiza') {

               if (valorActualizable === 'S') {
                   $('#periodicidad').show();
                   $('#ddlPeriodo').prop('disabled', false).show();
               } else {
                   $('#periodicidad').hide();
               }

           } else
               if (tipo == 'ActualizaE') {
                   if (valorActualizable === 'S') {
                       $('#periodicidadE').show();
                       $('#ddlPeriodoE').prop('disabled', false);
                   } else {
                       $('#periodicidadE').hide();

                   }

               }


       }

       var traerTipoPlanes = function () {

           $.ajax({
               url: "TipoPlanesPago.aspx/getTipoPlanes",
               type: "post",
               contentType: "application/json",
               success: function (data) {


                   var arrayPlanes = [];
                   var tablaId = "#example";
                   var AccionEditar = TieneAccion('MODIFICACION', Nombre_Pagina());
                   var AccionBaja = TieneAccion('BAJA', Nombre_Pagina());

                   for (i = 0; i < data.d.length; i++) {
                       var dataFechaBaja = data.d[i].FEC_BAJA;
                       var fechaBaja = mostrarBaja(dataFechaBaja);
                       var Editar = '';
                       var Delete = '';

                       if (fechaBaja == '') {
                           if (AccionEditar)
                               Editar = '<a href="#" onclick="return Editar(' + data.d[i].ID_TIPO_PLANESPAGO + ')"  class="btn btn-warning-alt btn-xs"><span class="glyphicon glyphicon glyphicon-pencil"></span></a>';
                           if (AccionBaja)
                               Delete = '<a href="#" onclick="return Borrar(' + data.d[i].ID_TIPO_PLANESPAGO + ')"  class="btn btn-danger-alt btn-xs"><span class="glyphicon glyphicon glyphicon-trash"></span></a>';
                       }
                       arrayPlanes.push([data.d[i].CODIGO_PLAN, data.d[i].DESIGNACION_PLAN, data.d[i].TRIBUTO, data.d[i].DECRETO_RESOLUCION, data.d[i].SOLO_USO_DEVENGAMIENTO, data.d[i].OBSERVACIONES, data.d[i].CANTIDAD_CUOTAS, data.d[i].DIA_PRIMER_VENCIMIENTO, fechaBaja, Editar, Delete]);

                   }

                   var campoBaja = 8;
                   cargarTabla(tablaId, arrayPlanes, campoBaja);

               },
               error: function (xhr, ajaxOptions, thrownError) {

               }
           });
       }

       //Carga combo tipos de tributo 

       var traertributos = function (ddl) {
           $.ajax({
               type: "POST",
               url: "TipoPlanesPago.aspx/getTiposTributo",
               data: "{}",
               beforeSend: function () {
                   AbrirLoading()
               },
               contentType: "application/json; charset=utf-8",
               dataType: "json",
               success: function (data, st) {
                   if (st == 'success') {

                       $(ddl).empty();
                       if (data.d.length > 0) {
                           $(ddl).empty().append('<option selected="selected" value="0">--Seleccione un Tributo--</option>');
                           $.each(data.d, function () {

                               $(ddl).append($("<option></option>").val(this['ID_TIPO_TIBUTO']).html(this['CONCEPTO']));
                           });
                       }
                       else {
                           $(ddl).empty().append('<option selected="selected" value="0">Not available<option>');
                       }
                   }

                   CerrarLoading();

               },
               failure: function (data) {
                   CerrarLoading();
               }
           });
       }


       //var validacionAgregar = function () {

       //    if ($("#txtnombrezonanvo").val() == "") {
       //        return "Debe ingresar una Zona!";
       //    }
       //    if ($("#txtnombreabrenvo").val() == "") {
       //        return "Debe ingresar una Abreviación para la Zona!";
       //    }

       //    return "";
       //}

       //var validacionEditar = function () {

       //    if ($("#txtnombrezonaed").val() == "") {
       //        return "Debe ingresar una Zona!";
       //    }
       //    if ($("#txtnombreabreed").val() == "") {
       //        return "Debe ingresar una Abreviación para la Zona!";
       //    }

       //    return "";
       //}

       function limpiar() {
           $("#ddltributo").val(0);
           $("#txtcodigoplan").val("");
           $("#txtdesignacion").val("");
           $("#txtdecretoresolucion").val("");
           $("#ddlSoloUsoDev").val("");
           $("#txtobservaciones").val("");
           $("#txtcantidadcuotas").val("");
           $("#txtdiaprimervenci").val("");
           $("#RadioNo").prop("checked", true);
           $('#periodicidad').hide();

       }
       //IMPLEMENTACION DEL POPUP DE BORRADO
       function Borrar(id) {
           $('#divBorrar').modal('show');
           idBorrar = id;
       }

       function comprobarCamposRequired() {

           var correcto = true;
           var campos = $('input[type="text"]:required');
           var select = $('select:required');
           $(campos).each(function () {
               if ($(this).val() == '') {
                   correcto = false;
                   $(this).addClass('error');
               }
           });
           return correcto;
       }

       function Editar(id) {
           $('#divEditar').modal('show');
           $.ajax({
               url: "TipoPlanesPago.aspx/Traer_p_Editar",
               type: "post",
               data: "{p_Id: '" + id + "'}",
               contentType: "application/json",
               success: function (data) {

                   for (var i = 0; i < data.d.length; i++) {
                       /*traertributos('#ddltributoE')*/
                       idEditar = data.d[i].ID_TIPO_PLANESPAGO;
                       $("#txtcodigoplanE").val(data.d[i].CODIGO_PLAN);
                       $("#txtdesignacionE").val(data.d[i].DESIGNACION_PLAN);
                       $("#txtdecretoresolucionE").val(data.d[i].DECRETO_RESOLUCION);
                       $("#ddlSoloUsoDevE").val(data.d[i].SOLO_USO_DEVENGAMIENTO);
                       $("#txtobservacionesE").val(data.d[i].OBSERVACIONES);
                       $("#txtcantidadcuotasE").val(data.d[i].CANTIDAD_CUOTAS);
                       $("#txtdiaprimervenciE").val(data.d[i].DIA_PRIMER_VENCIMIENTO);
                       $("#ddltributoE").val(data.d[i].ID_TIPO_TRIBUTO);
                       var valorActualizable = data.d[i].ACTUALIZABLE;

                       if (valorActualizable === 'S') {
                           $("#radioSiE").prop("checked", true);
                           $('#ddlPeriodoE').prop('disabled', false);
                           $('#periodicidadE').show();
                           $("#ddlPeriodoE").val(data.d[i].PERIODO);

                       } else if (valorActualizable === 'N') {
                           $("#RadioNoE").prop("checked", true);
                           $('#ddlPeriodoE').prop('disabled', true);
                           $('#periodicidadE').hide();
                       }

                   }
               },
               error: function (xhr, ajaxOptions, thrownError) {

               }

           });
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
        <h3>Consulta de Tipos Planes de Pago</h3>
        <div class ="contenido row" style ="padding-bottom: 0; padding-top:0">
            <table class="table borderless">
                <tr>
                    <td class="col-md-3 borderless" style = "padding-top: 0; padding-left: 0">                        
                    </td>
                    <td class="col-md-2 pull-right">No Vigente</td>
                    <td style="background-color: #C40000" class="col-md-1 pull-right" style="color: #C40000">.</td>      
                </tr>
            </table>
        </div>
        <br/>
        <div>
            <table width="100%" class="table table-striped table-bordered" id="example" cellspacing="0">
                <thead>
                    <tr>
                    <%--   <th style="display: none;">ID_TIPO_PLANESPAGO</th>--%>
                        <th>CODIGO PLAN</th>
                        <th>DESIGNACION PLAN</th>
                        <th>TRIBUTO</th>
                        <th>DECRETO RESOLUCION</th>
                        <th>SOLO USO DEVENGAMIENTO</th>
                        <th>OBSERVACIONES</th>
                        <th>CANTIDAD CUOTAS</th>
                        <th>DIA PRIMER VENCIMIENTO</th>
                        <th>FECHA BAJA</th>
                        <th>EDITAR</th>
                        <th>BORRAR</th>
                    </tr>
                </thead>
            </table>

            <table>
                <tr>
                    <td>
                        <button type="button"  id="agregarnuevo" class="btn btn-primary btn-lg" data-toggle="modal" <%--data-target="#myModal"--%>>Agregar Nuevo</button>
                    </td>
                </tr>
            </table>
<%--            <button type="button" onclick="location.href = '<%=ConfigurationManager.AppSettings["ROOT_PATH"] + "/Bienvenida.aspx"%>';" class="btn btn-primary btn-lg" id="btnSalir">
                Salir
            </button>--%>
        </div>
    </div>

    <%--Modal Agregar--%>
    <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
        <div class="vertical-alignment-helper">
            <div class="modal-dialog vertical-align-center" role="document">
                <div class="modal-content">
                    <div class="modal-body">
                        <div id="panelNo" class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title">ALTA TIPOS PLANES DE PAGO</h3>
                            </div>
                              <div class="panel-body">
                                 <div class="row">
                                    <div class="form-group col-md-3 ">
                                        <label for="txtcodigoplan" class="control-label"><%--<span style="color: red">* </span>--%>*Codigo Plan:</label>
                                        <input id="txtcodigoplan" placeholder="Codigo Plan" type="text" class="form-control"/>
                                    </div>
                                    <div class="form-group col-md-9 ">
                                        <label for="txtdesignacion" class="control-label"><%--<span style="color: red">* </span>--%>*Designacion Forma de Pago:</label>
                                        <input id="txtdesignacion" placeholder="Designacion Forma de Pago" type="text" class="form-control"/>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="form-group col-md-6 ">
                                        <label for="txtdecretoresolucion" class="control-label"><%--<span style="color: red">* </span>--%>*Decreto Resolucion</label>
                                        <input id="txtdecretoresolucion" placeholder="Decreto Resolucion" type="text" class="form-control"/>
                                    </div>                            
                                    <div  <%--id="zonainsert"--%> class="col-md-6">
                                        <label for="ddlSoloUsoDev" class="control-label"><%--<span style="color: red">* </span>--%>Solo Uso Devengamiento</label>
                                        <select id="ddlSoloUsoDev" name="ddlSoloUsoDev" class="btn btn-primary dropdown-toggle"  style="width: 100%">
                                             <option value="0">Seleccione Solo Devengamiento</option>
                                            <option value="S">S</option>   
                                             <option value="N">N</option>                                                                                                                                
                                        </select>                                        
                                   </div>
                                </div>
                                <div class="row">
                                    <div class="form-group col-md-12 ">
                                        <label for="txtobservaciones" class="control-label"><%--<span style="color: red">* </span>--%>Observaciones:</label>
                                        <input id="txtobservaciones" placeholder="Observaciones" type="text" class="form-control"/>
                                    </div>
                                </div>
                               <div class="row">
                                    <div class="form-group col-md-6 ">
                                        <label for="txtcantidadcuotas" class="control-label"><%--<span style="color: red">* </span>--%>*Cantidad Cuotas:</label>
                                        <input id="txtcantidadcuotas" placeholder="Cantidad Cuotas" type="text" class="form-control"/>
                                    </div>
                                   <div class="form-group col-md-6">
                                        <label for="txtdiaprimervenci" class="control-label"><%--<span style="color: red">* </span>--%>*Dia Primer Vencimiento:</label>
                                        <input id="txtdiaprimervenci" placeholder="Dia Primer Vencimiento" type="text" class="form-control"/>
                                    </div>
                                 

                              </div>
                               <div class="row">                               
                                 <div class="col-md-6">
                                       <label for="ddltributo" class="control-label"><%--<span style="color: red">* </span>--%>*Asociar a Tipo Tributo</label>
                                   <select id="ddltributo" name="ddltributo" class="btn btn-primary dropdown-toggle" style="width: 250px">
                                  </select>        
                                     
                                  </div>      
                                     <div class="row">
                                        <div class="col-md-6">
                                            <label for="lblActualiza" class="control-label">*Actualizable: </label>
                                            <div id="RadioActualiza" class="input-group  col-sm-12">
                                                <label class="radio-inline">
                                                    <input id="radioSi" value="S" name="Actualiza" type="radio" >
                                                    SI
                                                </label>
                                                <label class="radio-inline">
                                                    <input id="RadioNo" value="N" name="Actualiza" type="radio" checked >
                                                    NO
                                                </label>
                                            </div>
                                        </div>
                                        <br />
                                    </div>
                                    <div  class="col-md-6" id="periodicidad">
                                        <label for="ddlPeriodo" class="control-label" style="margin-top:5px"> <%--<span style="color: red">* </span>--%>*Periodicidad</label>
                                        <select id="ddlPeriodo" name="ddlPeriodo" class="btn btn-primary dropdown-toggle"  style="width: 100%">
                                             <option value="0">--Seleccione Periodicidad--</option>
                                             <option value="MENSUAL">Mensual</option>   
                                             <option value="BIMESTRAL">Bimestral</option>
                                             <option value="SEMESTRAL">Semestral</option>   
                                             <option value="ANUAL">Anual</option>
                                        </select>                                        
                                   </div>
                              </div>
                            </div>
                            <div>
                                <div class="modal-footer">
                                    <button type="button" id="btnCerrarA" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                                    <button type="button" id="btnInsertar" class="btn btn-primary">Agregar</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%--Modal editar--%>
    <div class="modal fade" id="divEditar" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
        <div class="vertical-alignment-helper">
            <div class="modal-dialog vertical-align-center" role="document">
                <div class="modal-content">
                    <div class="modal-body">
                        <div id="panelNo" class="panel panel-primary">
                            <div class="panel-heading">
                                <h3 class="panel-title">EDICIÓN TIPOS PLANES DE PAGO </h3>
                            </div>
                            <div class="panel-body">
                                 <div class="row">
                                    <div class="form-group col-md-3 ">
                                        <label for="txtcodigoplanE" class="control-label"><%--<span style="color: red">* </span>--%>Codigo Plan:</label>
                                        <input id="txtcodigoplanE" placeholder="Codigo Plan" type="text" class="form-control"/>
                                    </div>
                                    <div class="form-group col-md-9 ">
                                        <label for="txtdesignacionE" class="control-label"><%--<span style="color: red">* </span>--%>Designacion Forma de Pago:</label>
                                        <input id="txtdesignacionE" placeholder="Designacion Forma de Pago" type="text" class="form-control"/>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="form-group col-md-6 ">
                                        <label for="txtdecretoresolucionE" class="control-label"><%--<span style="color: red">* </span>--%>Decreto Resolucion</label>
                                        <input id="txtdecretoresolucionE" placeholder="Decreto Resolucion" type="text" class="form-control"/>
                                    </div>                            
                                    <div  <%--id="zonainsert"--%> class="col-md-6">
                                        <label for="ddlSoloUsoDevE" class="control-label"><%--<span style="color: red">* </span>--%>Solo Uso Devengamiento</label>
                                        <select id="ddlSoloUsoDevE" name="ddlSoloUsoDevE" class="btn btn-primary dropdown-toggle"  style="width: 100%">
                                             <option value="0">Seleccione Uso Devengamiento</option>
                                             <option value="S">S</option>   
                                             <option value="N">N</option>                                                                                                                                
                                        </select>                                        
                                   </div>
                                </div>
                                <div class="row">
                                    <div class="form-group col-md-12 ">
                                        <label for="txtobservacionesE" class="control-label"><%--<span style="color: red">* </span>--%>Observaciones:</label>
                                        <input id="txtobservacionesE" placeholder="Observaciones" type="text" class="form-control"/>
                                    </div>
                                </div>
                               <div class="row">
                                    <div class="form-group col-md-6 ">
                                        <label for="txtcantidadcuotasE" class="control-label"><%--<span style="color: red">* </span>--%>Cantidad Cuotas:</label>
                                        <input id="txtcantidadcuotasE" placeholder="Cantidad Cuotas" type="text" class="form-control"/>
                                    </div>
                                   <div class="form-group col-md-6">
                                        <label for="txtdiaprimervenciE" class="control-label"><%--<span style="color: red">* </span>--%>Dia Primer Vencimiento:</label>
                                        <input id="txtdiaprimervenciE" placeholder="Dia Primer Vencimiento" type="text" class="form-control"/>
                                    </div>
                                   <div class="col-md-6">
                                           <label for="ddltributoE" class="control-label"><%--<span style="color: red">* </span>--%>*Asociar a Tipo Tributo</label>
                                           <select id="ddltributoE" name="ddltributoE" class="btn btn-primary dropdown-toggle" style="width: 250px">
                                           </select>
                                       </div>
                                   <div class="col-md-6">
                                            <label for="lblActualizaE" class="control-label">Actualizable: </label>
                                            <div id="RadioActualizaE" class="input-group  col-sm-12">
                                                <label class="radio-inline">
                                                    <input id="radioSiE" value="S" name="ActualizaE" type="radio" >
                                                    SI
                                                </label>
                                                <label class="radio-inline">
                                                    <input id="RadioNoE" value="N" name="ActualizaE" type="radio"  >
                                                    NO
                                                </label>
                                            </div>
                                        </div>
                                     <div  class="col-md-6" id="periodicidadE">
                                        <label for="ddlPeriodoE" class="control-label" style="margin-top:5px"> <%--<span style="color: red">* </span>--%>*Periodicidad</label>
                                        <select id="ddlPeriodoE" name="ddlPeriodoE" class="btn btn-primary dropdown-toggle"  style="width: 100%">
                                             <option value="0">--Seleccione Periodicidad--</option>
                                             <option value="MENSUAL">Mensual</option>   
                                             <option value="BIMESTRAL">Bimestral</option>
                                             <option value="SEMESTRAL">Semestral</option>   
                                             <option value="ANUAL">Anual</option>
                                        </select>                                        
                                   </div>
                                        <br />
                                    </div>     

                              </div>
                            </div>
                            <div>
                                <div class="modal-footer">
                                    <button type="button" id="btnCerrarE" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                                    <button type="button" id="btnGrabar" class="btn btn-primary">Grabar</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


     <%--POPUP DE BORRADO--%>
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
                                <asp:Label ID="Label1" runat="server" Text="¿Desea dar de baja El Plan de Pago seleccionado?" />
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
