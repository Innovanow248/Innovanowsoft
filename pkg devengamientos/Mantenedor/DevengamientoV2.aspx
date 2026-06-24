<%@ Page Language="C#" MasterPageFile="~/MasterPage/Ingresos.Master" AutoEventWireup="true" CodeBehind="DevengamientoV2.aspx.cs" Inherits="webIngresos.DevengamientoV2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphContenidoIngreso" runat="Server">
	<style>
	    .btn span.glyphicon2 {
	        opacity: 0;
	    }

	    .btn.active span.glyphicon2 {
	        opacity: 1;
	    }

	    #estadoDeuda {
	        padding: 1px 5px;
	        background-color: #F2910E;
	        color: rgba(255, 255, 255, .8);
	        margin-right: 3px;
	        transition: all .3s ease;
	    }

	        #estadoDeuda:hover {
	            background-color: #F2800E;
	            color: white;
	        }

	    #estadoCuenta {
	        padding: 1px 5px;
	        background-color: #4ABE35;
	        color: rgba(255, 255, 255, .8);
	        transition: all .3s ease;
	    }

	        #estadoCuenta:hover {
	            background-color: #3FAE2B;
	            color: white;
	        }

	    #bntEstadoDeudaTotal {
	        padding: 1px 5px;
	        background-color: #F2910E;
	        color: rgba(255, 255, 255, .8);
	        margin-right: 3px;
	        transition: all .3s ease;
	    }

	        #bntEstadoDeudaTotal:hover {
	            background-color: #F2800E;
	            color: white;
	        }

	    #btnEstadoCuentaTotal {
	        padding: 1px 5px;
	        background-color: #4ABE35;
	        color: rgba(255, 255, 255, .8);
	        transition: all .3s ease;
	    }

	        #btnEstadoCuentaTotal:hover {
	            background-color: #3FAE2B;
	            color: white;
	        }

	    .tooltipT {
	        position: relative;
	        display: inline-block;
	    }

	        .tooltipT .tooltiptext {
	            visibility: hidden;
	            width: 80px;
	            background-color: #555;
	            color: #fff;
	            text-align: center;
	            border-radius: 6px;
	            padding: 5px 0;
	            position: absolute;
	            z-index: 1;
	            bottom: 125%;
	            left: 50%;
	            margin-left: -60px;
	            transition: opacity 0.3s;
	        }

	            .tooltipT .tooltiptext::after {
	                content: "";
	                position: absolute;
	                top: 100%;
	                left: 50%;
	                border-width: 5px;
	                border-style: solid;
	                border-color: #555 transparent transparent transparent;
	            }

	        .tooltipT:hover .tooltiptext {
	            visibility: visible;
	            opacity: 1;
	        }

	    #a {
	        color: #0a55be;
	        text-decoration: underline;
	    }

	        #a:hover {
	            color: #0a55be;
	        }


	    .formato_titulo {
	        font-size: 24px;
	        padding-left: 20px;
	        padding-bottom: 10px;
	    }

	    .formato_etiqueta_filtros {
	        font-size: 18px;
	        padding-right: 10px;
	        padding-left: 20px;
	    }

	    .radio_anio {
	        position: relative; /* make the label a positioned element */
	        padding-right: 30px; /* add padding to the right */
	    }

	        .radio_anio input[type="radio"] {
	            position: absolute; /* position the radio button absolutely */
	            right: 10px; /* move it to the right */
	        }

	    .radio_masivo {
	        position: relative; /* make the label a positioned element */
	        padding-right: 30px; /* add padding to the right */
	    }

	        .radio_masivo input[type="radio"] {
	            position: absolute; /* position the radio button absolutely */
	            right: 10px; /* move it to the right */
	        }

	    td {
	        padding-bottom: 10px;
	    }

	    div.dt-button-collection {
	        width: 200px;
	    }

	    .table-cell {
	        width: auto;
	    }

	    .col {
	        width: auto; /* set width to 100% of parent element */
	    }

	        .col:first-child {
	            padding-right: 15px; /* add padding to match the default gutter of Bootstrap columns */
	        }

	        .col:last-child {
	            padding-left: 15px; /* add padding to match the default gutter of Bootstrap columns */
	        }
	    /*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
	    #loading-bar {
	        width: calc(100%);
	        height: 20px;
	        background-color: #f2f2f2;
	        border-radius: 20px;
	        position: relative;
	        margin: 50px auto;
	        box-shadow: inset 0 0 5px rgba(0, 0, 0, 0.2);
	    }

	    #loading-progress {
	        height: 100%;
	        background-color: #4CAF50;
	        border-radius: 20px;
	        position: absolute;
	        top: 0;
	        left: 0;
	        box-shadow: 0 0 5px rgba(0, 0, 0, 0.2);
	        transition: width 0.5s ease;
	        animation: lightAnimation 2s linear infinite;
	    }

	    @keyframes lightAnimation {
	        0% {
	            box-shadow: 0 0 5px rgba(0, 0, 0, 0.2);
	        }

	        50% {
	            box-shadow: 0 0 20px rgba(0, 0, 0, 0.5);
	        }

	        100% {
	            box-shadow: 0 0 5px rgba(0, 0, 0, 0.2);
	        }
	    }

	    #loading-text {
	        position: absolute;
	        top: 50%;
	        left: 50%;
	        transform: translate(-50%, -50%);
	        color: #555;
	        font-size: 14px;
	        font-weight: bold;
	    }

	    .card {
	        width: 300px;
	        padding: 20px;
	        background-color: #f1f1f1;
	        border-radius: 10px;
	    }
	</style>

	<div>
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


		<div id="divDevengamiento">

			<h3 class="formato_titulo">Generar Devengamiento</h3>

			<table id="tablaParametros">
				<%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------%>
				<tr>
					<td id='colTipoTributo' class="table-cell">

						<div class="formato_etiqueta_filtros">

							<h4>
								<span style="color: red">* </span>

								Tipo Tributo :</h4>
						</div>

					</td>
					<td>
						<div id="divtipotributo">
							<select id="ddlTributo" name="ddlTributo" class="btn btn-primary dropdown-toggle" style="width: 250px"></select>
						</div>
					</td>
				</tr>
				<%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------%>
				<tr id="divTipoDevengamiento" style="display: none">
					<td class="table-cell">


						<h4 class="formato_etiqueta_filtros">
							<span style="color: red">* </span>


							Tipo de Devengamiento:</h4>


					</td>
                    <td>
                        <label class="btn btn-warning">
                            <input type="radio" name="tipoDevengamiento" value="1" autocomplete="off" checked>
                            ANUAL
                        </label>
                        <label class="btn btn-warning">
                            <input type="radio" name="tipoDevengamiento" value="2" autocomplete="off">
                            CUOTAS
                        </label>
                    </td>
				</tr>
				<%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------%>
				<tr id="divMasivo" style="display: none">
					<td class="table-cell">
						<div>

							<h4 class="formato_etiqueta_filtros">

								<span style="color: red">* </span>

								Masivo :</h4>

						</div>
					</td>
					<td>
						<label class="btn btn-warning radio_masivo" style="width: 60px">
							NO
                            <input type="radio" id="radioMasivoNo" value="02" name="options" checked />
						</label>
						<label class="btn btn-warning radio_masivo" id="labelMasivoSi" style="width: 60px">
							SI
                            <input type="radio" id="radioMasivoSi" value="01" name="options" />
						</label>

						<br />
					</td>
				</tr>

				<%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------%>
				<tr id="divModalidad" style="display: none">
					<td class="table-cell">
						<div class="formato_etiqueta_filtros">

							<h4>
								<span style="color: red">* </span>


								Modalidad :</h4>
						</div>

					</td>
					<td>
						<div>
							<select id="ddlModalidadAgua" class="btn btn-primary dropdown-toggle" style="width: 250px">
								<option value="0">--Seleccione Modalidad--</option>
								<option value="1">CUOTA FIJA</option>
								<option value="2">MEDIDOR</option>
								<option value="3">AGUAS CORDOBESAS</option>
							</select>
						</div>

					</td>

				</tr>

				<%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------%>
				<tr id="divAnioConsulta" style="display: none">
					<td class="table-cell">
						<div>
							<h4 class="formato_etiqueta_filtros">
								<span style="color: red">* </span>

								Año a Devengar :</h4>
						</div>
					</td>
					<td>
						<select id="ddlAnioConsulta" name="ddlAnioConsulta" class="btn btn-primary dropdown-toggle" style="width: 250px">
							<option value="0">--Seleccione el año--</option>
						</select>

						<select id="ddlMeses" class="btn btn-primary dropdown-toggle" style="width: 250px; display: none" disabled>
							<option value="">--Seleccione el mes--</option>
						</select>


						<br />
					</td>
					<td>
						<div id="divMesesMultiselect" style="margin-left: 4px">
							<select id="ddlMesesMultiselect" multiple="multiple" class="btn btn-primary dropdown-toggle" style="width: 250px;" disabled>
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
					</td>
				</tr>
				<%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------%>
				<tr id="divCuotas" style="display: none">
					<td class="table-cell">
						<div id="divDdlCuotasDevengamiento">
							<h4 class="formato_etiqueta_filtros">Cuota(s) a Devengar:</h4>
						</div>
					</td>
					<td>
						<select id="ddlCuotasDevengamiento" name="ddlTributo" class="btn btn-primary dropdown-toggle" style="width: 125px"></select>
						<br />
					</td>
				</tr>
				<%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------%>

				<%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------%>
				<tr id="divMonto" style="display: none">
					<td>
						<div id="colTituloMonto" style="margin-left: 20px; margin-right: 10px" class="table-cell">
							<span id="spanMonto" style="color: red; display: none">* </span>

							<h4>
								<span style="color: red">*</span> Importe :</h4>
						</div>
					</td>
					<td style="padding-right: 4px">
						<div style="width: 250px">
							<input id="txtMonto" type="text" class="form-control" name="Monto" onkeypress="return soloNumeros(event)" placeholder="Importe a Devengar" onblur="this.value=this.value.toUpperCase()" style="width: 250px" />

						</div>
					</td>
				</tr>
			</table>
		</div>


		<table id="divCuenta" style="display: none">
			<tr>
				<td>
					<div id="colTituloCuenta" style="margin-left: 20px; margin-right: 10px" class="table-cell">
						<span id="spanCuenta" style="color: red; display: none">* </span>

						<h4>
							<span style="color: red">*</span> Cuenta :</h4>
					</div>
				</td>
				<td style="padding-right: 4px">
					<div style="width: 250px">
						<input id="txtNroCuenta" type="text" class="form-control" name="Cuenta" placeholder="Nro. Cuenta" onblur="this.value=this.value.toUpperCase()" style="width: 250px" />

					</div>
				</td>
				<td>
					<div>
						<button type="button" id="btnConsulta" data-loading-text="<i class='fa fa-spinner fa-spin'></i> Buscando Obligaciones..." class="btn btn-primary">Consultar</button>

					</div>
				</td>
			</tr>
		</table>


		<div id="divInternet" style="margin-left: 20px; margin-right: 10px; gap: 10px; display: none;">
			<div style="display: flex; margin-left: 10px">
				<label>Nro de cuota :</label>
				<select class="form-control" id="selectInternet" style="width: 250px; margin-bottom: 10px; margin-left: 20px;">
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
			<div style="display: flex; margin-left: 10px">
				<label>Numero de cuenta :</label>
				<input type="text" class="form-control" style="width: 250px; margin-bottom: 10px; margin-left: 20px;" id="txtNroCuentaInternet" />
			</div>

		</div>

		<div id="divBotones" class="formato_etiqueta_filtros">
			<button type="button" id="btnDevengar" style="background-color: #eb0000" class="btn btn-primary">Devengar</button>
			<button type="button" id="btnSimular" class="btn btn-primary" <%--style="visibility:hidden"--%>>Simular</button>

			<button type="button" id="btnPrueba" style="display: none" onclick="javascript:window.open(pruebaBarraCarga(),'','width=500,height=400,left=100,top=100,toolbar=yes');void 0" class="btn btn-primary">Devengar</button>

			<%--            <div class="card">
                <h1>My Card</h1>
                <p>This is a sample card with round borders.</p>
            </div>--%>

			<div id="loading-barra" style="display: none; padding-top: 20px">
				<div id="mensaje-devengamiento">
					<h4>Se está llevando a cabo el devengamiento. Por favor espere.</h4>

				</div>

				<div id="loading-bar" style="margin-top: 0px">
					<div id="loading-progress"></div>
					<div id="loading-text">Iniciando...</div>
				</div>
			</div>

			<%-- Datos del Contribuyente --%>
			<div id="DivTitular" style="padding-left: 20px; padding-right: 10px; display: none">
				<hr style="border: 0.5pt solid rgba(0, 0, 0, .1);" />

				<h3 class="titulo">Datos del contribuyente</h3>
				<table>
					<tr>
						<td>
							<div style="padding-right: 10px">
								<label for="txtNombreContrib">
									<h4>Nombre :</h4>
								</label>

							</div>
						</td>

						<td>
							<label>
								<input id="txtNombreContrib" type="text" class="form-control" name="txtNombreContrib" style="width: 200px;" placeholder="NOMBRE" onblur="this.value=this.value.toUpperCase()" disabled="disabled" />
							</label>
						</td>
					</tr>
					<tr>
						<td>
							<div style="padding-right: 10px">
								<label for="txtApellidoContrib">
									<h4>Apellido :</h4>
								</label>
							</div>
						</td>
						<td>
							<label>
								<input id="txtApellidoContrib" type="text" class="form-control" name="txtApellidoContrib" style="width: 200px;" placeholder="APELLIDO" onblur="this.value=this.value.toUpperCase()" disabled="disabled" />
							</label>
						</td>
					</tr>
					<tr>
						<td>
							<div style="padding-right: 10px">
								<label for="txtDNIContrib">
									<h4>D.N.I :</h4>
								</label>
							</div>
						</td>
						<td>
							<label>
								<input id="txtDNIContrib" type="text" class="form-control" name="txtDNIContrib" style="width: 200px;" placeholder="DNI" onblur="this.value=this.value.toUpperCase()" disabled="disabled" />
							</label>
						</td>
					</tr>
					<tr>
						<td>
							<div style="padding-right: 10px">
								<label for="txtCuilContrib">
									<h4>CUIL :</h4>
								</label>
							</div>
						</td>
						<td>
							<label>
								<input id="txtCuilContrib" type="text" class="form-control" name="txtCuilContrib" style="width: 200px;" placeholder="CUIL" onblur="this.value=this.value.toUpperCase()" disabled="disabled" />
							</label>
						</td>
					</tr>
				</table>

				<hr style="border: 0.5pt solid rgba(0, 0, 0, .1);" />
				<h3 class="titulo">Datos de la Cuenta</h3>

				<table>
					<tr>
						<td style="padding-right: 10px">
							<label for="txtFechaAlta">
								<h4>Fecha Alta :</h4>
							</label>

						</td>
						<td>
							<label>
								<input id="txtFechaAlta" type="text" class="form-control" name="txtFechaAlta" style="width: 180px;" placeholder="FECHA ALTA" onblur="this.value=this.value.toUpperCase()" disabled="disabled" />
							</label>
						</td>


					</tr>
					<tr id="rowModalidad">

						<td id="lblModalidad" name="nameModalidad" style="padding-right: 10px">
							<label>
								<h4>Modalidad :</h4>
							</label>

						</td>
						<td>
							<label>
								<input id="txtModalidad" name="nameModalidad" type="text" class="form-control" style="width: 180px;" placeholder="MODALIDAD" onblur="this.value=this.value.toUpperCase()" disabled="disabled" />
							</label>
						</td>


					</tr>
					<tr id="rowCategoria">
						<td id="lblCateg" name="nameCategoria" style="padding-right: 10px">
							<label>
								<h4>Categoria :</h4>
							</label>

						</td>
						<td>
							<label>
								<input id="txtCategoria" type="text" class="form-control" name="nameCategoria" style="width: 180px;" placeholder="CATEGORIA" onblur="this.value=this.value.toUpperCase()" disabled="disabled" />
							</label>
						</td>
					</tr>
					<tr id="rowTipo">
						<td id="lblTipo" name="nameTipo" style="padding-right: 10px">
							<label>
								<h4>Tipo :</h4>
							</label>

						</td>
						<td>
							<label>
								<input id="txtTipo" type="text" class="form-control" name="nameTipo" style="width: 180px;" placeholder="TIPO" onblur="this.value=this.value.toUpperCase()" disabled="disabled" />
							</label>
						</td>
					</tr>
				</table>
			</div>



			<div id="divObligaciones" style="padding-left: 20px; padding-right: 10px; display: none">
				<hr style="border: 0.5pt solid rgba(0, 0, 0, .1);" />

				<h3 class="titulo">Obligaciones</h3>
				<table width="100%" class="table table-striped table-hover table-bordered" id="tablaObligaciones" cellspacing="0">
					<thead>
						<tr class="Estilo_Fila">
							<th style="text-align: center" class="export">AÑO CUOTA</th>
							<th style="text-align: center" class="export">NÚMERO CUOTA</th>
							<th style="text-align: center" class="export">ESTADO DEUDA</th>
							<th style="text-align: center" class="export">FECHA PRIMER VTO.</th>
							<th style="text-align: center" class="export moneda">CAPITAL FACTURADO</th>
							<th style="text-align: center" class="export moneda">INTERESES</th>
							<th style="text-align: center" class="export moneda">SALDO</th>
							<th style="text-align: center" class="export">IDT</th>
							<th style="text-align: center" class="export">IDO</th>
							<th style="text-align: center" class="export">en_plandepago</th>
							<th style="text-align: center" class="export">en_extrajudicial</th>
							<th style="text-align: center" class="export">en_judicial</th>
							<th style="text-align: center" class="export">en_prelegal</th>
						</tr>
					</thead>
				</table>
			</div>


			<div id="divObligacionesDet" style="padding-left: 20px; padding-right: 10px; display: none">
				<hr style="border: 0.5pt solid rgba(0, 0, 0, .1);" />

				<h3 class="titulo">Detalle de Obligaciones</h3>
				<table width="100%" class="table table-striped table-hover table-bordered" id="tablaDetalles" cellspacing="0">
					<thead>
						<tr class="Estilo_Fila">
							<th style="text-align: center" class="export">AÑO CUOTA</th>
							<th style="text-align: center" class="export">NÚMERO CUOTA</th>
							<th style="text-align: center" class="export">CONCEPTO</th>
							<th style="text-align: center" class="export">FECHA MOVIMIENTO</th>
							<th style="text-align: center" class="export moneda">DÉBITO CAPITAL</th>
							<th style="text-align: center" class="export moneda">DÉBITO INTERES</th>
							<th style="text-align: center" class="export moneda">CRÉDITO CAPITAL</th>
							<th style="text-align: center" class="export moneda">CRÉDITO INTERÉS</th>
						</tr>
					</thead>
					<tfoot>
						<tr>
							<th style="text-align: right;" colspan="7"></th>
							<th style="text-align: right;"></th>
						</tr>
					</tfoot>
				</table>

			</div>

			<div class="modal fade" id="divConsultarNomApe" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
				<div class="modal-dialog modal-lg" role="document">
					<div class="modal-content">
						<div class="modal-body">
							<div id="panelNoE" class="panel panel-primary">
								<div class="panel-heading">
									<button type="button" class="close" data-dismiss="modal" aria-label="Close">
										<span aria-hidden="true">&times;</span>
									</button>
									<h3 class="panel-title" id="B1">BUSCAR PERSONA</h3>
								</div>
								<div class="panel-body">
									<h4><span>APELLIDO Y NOMBRE : </span>
										<input id="txtApellidoNombre" type="text" class="form-control" name="nombreapellido" placeholder="APELLIDO/NOMBRE" size="10" onblur="this.value=this.value.toUpperCase()" /></h4>
									<button type="button" id="btnConsultaPersona" class="btn btn-primary">Consultar</button>

									<div id="alert_placeholderPersona"></div>
								</div>
								<div class="modal-body">
									<div id="tablaPers" style="display: none">
										<table width="100%" class="table table-striped table-hover" id="tablaPersonas" cellspacing="0">
											<thead>
												<tr>
													<th>NOMBRE</th>
													<th>APELLIDO</th>
													<th>CUIL</th>
													<th>SELECCIONAR</th>
												</tr>
											</thead>
										</table>
									</div>
								</div>
								<div class="modal-footer">
									<button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

		</div>
	</div>

	<script type="text/javascript">
		//###################### VARIABLES GLOBALES ######################

		var idJurisdiccion = <%=Session["IdJur"]%>;

		const COL_IDT = 7;
		const COL_IDO = 8;
		const COL_en_plandepago = 9;
		const COL_en_extrajudicial = 10;
		const COL_en_judicial = 11;
		const COL_en_prelegal = 12;
		var intervaloConsulta;

		//################### VARIABLES GLOBALES DEVENGAMIENTO###################
		var G_ESTADO_DEVENGAMIENTO;
		var G_PROGRESO_DEVENGAMIENTO;
		var G_PROGRESO_DEVENGAMIENTO_AUX;
		var G_MENSAJE_ERROR;

		var G_ID_TRIBUTO_CONTRIBUYENTE;
		var G_MASIVO;
		var G_MODO;
		var G_TIPO_TRIBUTO;
		var G_EJERCICIO_LIQ;
		var G_NRO_CUOTA;
		var G_MODALIDAD;
		//#########################################################
		//##############################################################

		$(document).ready(function () {

			//TributoxJurisdiccion("#ddlTributo");
			TributosConDevengamiento("#ddlTributo");
			cargarAnios('#ddlAnioConsulta');
			ConsultarEstadoDevengamiento();
			iniciarMultiselect('#ddlMesesMultiselect');
			//comprobarEstadoDevengamiento();

			$('#ddlTributo').bind("change", function () {
				limpiarPantalla();
				mostrarParametrosJurisdiccion(idJurisdiccion, $('#ddlTributo').val());

			});

			$('#ddlModalidadAgua').bind("change", function () {
				if ($('#ddlModalidadAgua').val() === "3") {
					mostrar('#divMonto');
					mostrar('#ddlMeses');
					$('#radioAnual').prop('disabled', true);
					$('#radioAnual').prop('checked', false);
					$('#radioCuotas').prop('checked', true);
				}
				else {
					$('#radioAnual').prop('disabled', false);
					ocultar('#divMonto');
				}
			})


			$('#radioMasivoNo').bind("change", function () {
				mostrarParametrosRadioMasivo("NO");
			});

			$('#radioMasivoSi').bind("change", function () {
				mostrarParametrosRadioMasivo("SI");
			});

			//$('#radioAnual').bind("change", function () {
			//	mostrarParametrosTipoDevengamiento($('#radioAnual').val(), $('#ddlTributo').val());
			//});

            //$('#radioCuotas').bind("change", function () {
			//	mostrarParametrosTipoDevengamiento($('#radioCuotas').val(), $('#ddlTributo').val());
			//});

            $('input[name="tipoDevengamiento"]').on('change', function () {
                mostrarParametrosTipoDevengamiento(
                    $(this).val(),
                    $('#ddlTributo').val()
                );
            });

			$('#ddlAnioConsulta').bind("change", function () {

				if (validarAnioConsulta()) {
					cargarCuotas($("#ddlMeses"), $("#ddlAnioConsulta").val(), obtenerIdTipoTributo($('#ddlTributo').val()));
					cargarCuotasMultiselect($("#ddlMesesMultiselect"), $("#ddlAnioConsulta").val(), obtenerIdTipoTributo($('#ddlTributo').val()));
				}

			});


			$('#btnConsulta').click(function () {
				AbrirLoading();

				if (validarConsulta()) {
					obtenerDatosContribuyente();
					obtenerDatosCuenta();
					mostrarObligaciones(G_ID_TRIBUTO_CONTRIBUYENTE);
				}
				CerrarLoading();

			});

			$('#tablaObligaciones').on('click', 'tr', function () {

				AbrirLoading();

				var table = $('#tablaObligaciones').DataTable();
				var tr = $(this).closest('tr');
				var row = table.row(tr);
				var idTributoContribuyente = row.data()[COL_IDT];
				var idObligacion = row.data()[COL_IDO];

				if ($(this).hasClass('selected')) {
					$(this).removeClass('selected');
				}
				else {
					table.$('tr.selected').removeClass('selected');
					$(this).addClass('selected');
				}

				var ajaxData = {
					idTributoContribuyente: idTributoContribuyente,
					idObligacion: idObligacion
				}

				$.ajax({
					url: "DevengamientoV2.aspx/mostrarDetalleObligaciones",
					type: "post",
					data: JSON.stringify(ajaxData),
					contentType: "application/json",
					async: false,
					success: function (data) {

						var arrayObligacionesDetalle = [];
						var total = 0;

						for (i = 0; i < data.d.length; i++) {
							var Concepto = data.d[i].CONCEPTODETOBL;

							var dateString = data.d[i].FECHA_MOVIMIENTO.substr(6);
							var currentTime = new Date(parseInt(dateString));
							var month = ("0" + (currentTime.getMonth() + 1)).slice(-2);
							var day = ("0" + currentTime.getDate()).slice(-2);
							var year = currentTime.getFullYear();
							var dateFM = day + '/' + month + '/' + year;

							var capFacturado = data.d[i].CAPITAL_FACTURADO == null ? 0 : data.d[i].CAPITAL_FACTURADO;
							var intFacturado = data.d[i].INTERESES_FACTURADOS == null ? 0 : data.d[i].INTERESES_FACTURADOS;
							var capCobrado = data.d[i].CAPITAL_COBRADO == null ? 0 : data.d[i].CAPITAL_COBRADO;
							var intCobrado = data.d[i].INTERESES_COBRADOS == null ? 0 : data.d[i].INTERESES_COBRADOS;

							total += capFacturado + intFacturado - capCobrado - intCobrado;

							arrayObligacionesDetalle.push([
								data.d[i].ANO_CUOTA,
								data.d[i].NRO_CUOTA,
								Concepto,
								dateFM,
								capFacturado,
								intFacturado,
								capCobrado,
								intCobrado
							]);
						}

						var tabla = formatear_tabla($('#tablaDetalles'), arrayObligacionesDetalle);
						var texto = '(Total Saldo $' + formatNumber(total).toString() + ')';
						var footerTh = $('#tablaDetalles tfoot th:nth-child(2)');
						footerTh.text(texto);

						mostrar('#divObligacionesDet');
					},
					error: function (xhr, ajaxOptions, thrownError) {

					}
				});

				CerrarLoading();
			});

			$('#btnDevengar').click(function () {
				if (validarDevengamiento()) {
					AbrirLoading();
					devengar('G');
				}
			});


			$('#btnSimular').click(function () {
				if (validarSimulacion()) {
					AbrirLoading();
					devengar('S');
				}

			});

		});//Termina el ready

		//     function devengarInternet() {
		//var nroCuenta = $('#txtNroCuentaInternet').val();
		//var nroCuota = $('#selectInternet').val();

		//$.ajax({
		//	type: "POST",
		//	url: "/Internet/InternetManaged.aspx/GenerarDevengamiento",
		//	contentType: "application/json; charset=utf-8",
		//	dataType: "json",
		//	data: JSON.stringify({
		//		numeroDeCuenta: nroCuenta,
		//		numeroCuota: nroCuota,
		//	}),
		//	success: function (response) {
		//                 if (response.d) {
		//                     alert('Se genero la cuota con exito')
		//                 }

		//	},
		//	error: function (error) {
		//		console.error("Error al obtener conceptos:", error);
		//	}
		//});
		//     }

		function devengar(modo) {

			G_MODO = modo;

			G_MASIVO = $("input[name='options']:checked").val();

			G_TIPO_TRIBUTO = $("#ddlTributo").val();

			G_EJERCICIO_LIQ = $("#ddlAnioConsulta").val();


			var modalidad = $("#ddlModalidadAgua").val();
			if (modalidad == 0) {
				G_MODALIDAD = -1;

			}
			else {
				G_MODALIDAD = modalidad;
				G_MONTO = $("#txtMonto").val();
			}



			var anual = $("input[name='tipoDevengamiento']:checked").val();
			var meses = $("#ddlMeses").val();
			var mesesMultiselect = $("#ddlMesesMultiselect").val();
			var nroCuota;

			if (G_MASIVO == "02") {
				obtenerDatosCuenta();
			}
			else {
				G_ID_TRIBUTO_CONTRIBUYENTE = null;
			}

			if (anual == "1") {
				nroCuota = obtenerCuotaAnual(G_TIPO_TRIBUTO);
			}
			else {
				if (mesesMultiselect == null || mesesMultiselect == "") {
					nroCuota = meses;
				}
				else {
					nroCuota = mesesMultiselect;
				}
			}

			if (G_TIPO_TRIBUTO == 'SUEN') {

				G_MONTO = $("#txtMonto").val();

				G_CANTIDADSELECCIONADA = mesesMultiselect.length;
			}

			G_NRO_CUOTA = nroCuota;

			abrirVentanaAuxiliar();
		}

		function obtenerSimulacion() {

			if (G_MASIVO == "02") {
				obtenerDatosCuenta();
			}
			else {
				G_ID_TRIBUTO_CONTRIBUYENTE = null;
			}

            var cuotasArray = [];

            if (Array.isArray(G_NRO_CUOTA)) {
                cuotasArray = G_NRO_CUOTA;
            } else if (G_NRO_CUOTA !== null && G_NRO_CUOTA !== undefined && G_NRO_CUOTA !== '') {
                cuotasArray = [G_NRO_CUOTA];
            }

			var ajaxData = {
				P_ID_TRIBUTO_CONTRIBUYENTE: G_ID_TRIBUTO_CONTRIBUYENTE,
				P_TIPO_TRIBUTO: G_TIPO_TRIBUTO,
				P_EJERCICIO_LIQ: G_EJERCICIO_LIQ,
                P_NRO_CUOTA: cuotasArray,
				P_MODALIDAD: G_MODALIDAD
			}

			$.ajax({
				beforeSend: function () {
					AbrirLoading();
				},
				url: "DevengamientoV2.aspx/obtenerSimulacion",
				type: "post",
				data: JSON.stringify(ajaxData),
				contentType: "application/json",
				success: function (data) {

					if (data.d != null) {
						// Obtener el primer objeto del arreglo
						var obj = JSON.parse(data.d);

						const primerObjeto = obj[0];

						// Obtener las llaves del objeto
						const llaves = Object.keys(primerObjeto);

						var arrayCP = [];
						arrayCP.push(llaves);

						for (i = 0; i < obj.length; i++) {
							var arregloAux = []
							llaves.forEach(llave =>
								arregloAux.push(obj[i][llave])
							);

							arrayCP.push(arregloAux);
						}

						exportToCsv(arrayCP);

						Exito("Se realizó la simulación con éxito. Verifique.");
						CerrarLoading()
					}
				},
				error: function (xhr, ajaxOptions, thrownError) {
					console.log("Error status: " + xhr.status);
					console.log("Error message: " + thrownError);
					AlertaError("Hubo un problema! " + xhr.status + " - " + thrownError);
					CerrarLoading();
				}
			});
		}

		function obtenerDatosContribuyente() {
			var ajaxData = {
				ClaveBien: $("#txtNroCuenta").val().toUpperCase(),
				TipoTributo: $("#ddlTributo").val()
			}

			$.ajax({
				url: "DevengamientoV2.aspx/obtenerDatosContribuyente",
				type: "post",
				data: JSON.stringify(ajaxData),
				contentType: "application/json",
				async: false,
				success: function (data) {

					if (data.d.length > 0) {

						$("#txtNombreContrib").val(data.d[0].NOMBRE);
						$("#txtApellidoContrib").val(data.d[0].APELLIDO);
						$("#txtDNIContrib").val(data.d[0].DOCUMENTO_NRO);
						$("#txtCuilContrib").val(data.d[0].CUIL);

					}
					else {
						CerrarLoading();
						Alerta("No se encontraron datos para este tributo.");
						limpiarTablasObligaciones();
					}

				},
				error: function (xhr, ajaxOptions, thrownError) {
					CerrarLoading();
					Alerta('No se encontraron datos para este tributo.');

				}
			});

		}

		function obtenerDatosCuenta() {

			var tipoTributo = $("#ddlTributo").val();
			var idTipoTributo = obtenerIdTipoTributo(tipoTributo);

			var ajaxData = {
				ClaveBien: $("#txtNroCuenta").val().toUpperCase(),
				IdTipoTributo: idTipoTributo
			}

			$.ajax({
				url: "DevengamientoV2.aspx/obtenerDatosCuenta",
				type: "post",
				data: JSON.stringify(ajaxData),
				contentType: "application/json",
				async: false,
				success: function (data) {

					if (data.d != null && data.d.length > 0) {

						for (i = 0; i < data.d.length; i++) {

							if (data.d[i].ID_TRIB_CONTRIB != null) {
								G_ID_TRIBUTO_CONTRIBUYENTE = data.d[i].ID_TRIB_CONTRIB;
							}
							else {
								G_ID_TRIBUTO_CONTRIBUYENTE = data.d[i].ID_INMUEBLE;

							}


							var modalidadCuenta = "";//string

							if (data.d[i].MODALIDAD == null) {
								G_MODALIDAD = -1;
								//return alert("La cuenta no tiene una modalidad");
							}
							else {
								G_MODALIDAD = data.d[i].MODALIDAD;

							}

							var fecha = mostrarBaja(data.d[i].FECHA_ALTA);
							$("#txtFechaAlta").val(fecha);

							if (tipoTributo == 'OBSA') {
								if ($("#ddlAnioConsulta").val() != 0 && idJurisdiccion == 2455) { //SERMAS
									cargarComboMesesSermas($("#ddlMeses"), $("#ddlAnioConsulta").val());
								}
								modalidadCuenta = obtenerModalidadAgua(data.d[i].MODALIDAD);
								$("#txtModalidad").val(modalidadCuenta);
								mostrar("#divModalidad");

							}
							else if (tipoTributo == 'CECE') {
								$("#txtTipo").val(data.d[i].TIPO);
								$("#txtCategoria").val(data.d[i].CATEGORIA);

								mostrar("#divCategoria");
								mostrar("#divTipo");
							}

						}
					}
					else {
						Alerta('No se encontraron datos para este tributo.');
					}
				},
				error: function (xhr, ajaxOptions, thrownError) {
					CerrarLoading();
					Alerta('No se encontraron datos para este tributo.');

				}
			});

		}

		function mostrarObligaciones(id) {
			var ajaxData = {
				idTributoContribuyente: id
			}

			$.ajax({
				url: "DevengamientoV2.aspx/mostrarObligaciones",
				type: "post",
				data: JSON.stringify(ajaxData),
				contentType: "application/json",
				async: false,
				success: function (data) {

					mostrar('#DivTitular');
					mostrar('#divObligaciones');

					var arrayObligaciones = [];

					for (i = 0; i < data.d.length; i++) {

						if (data.d[i].ESTADO_DEUDA != "CA") {

							var fechaPrimerVencimiento = formatoFechaPrimerVencimiento(data.d[i].FECHA_PRIMER_VENCIMIENTO);

							arrayObligaciones.push([
								data.d[i].ANO_CUOTA,
								data.d[i].NRO_CUOTA,
								data.d[i].ESTADO_DEUDA,
								fechaPrimerVencimiento,
								data.d[i].CAPITAL_FACTURADO,
								data.d[i].INTERESES_FACTURADOS,
								data.d[i].TOTAL_DEUDA_DET,
								data.d[i].ID_TRIBUTO_CONTRIBUYENTE,
								data.d[i].ID_OBLIGACION,
								data.d[i].en_plandepago,
								data.d[i].en_extrajudicial,
								data.d[i].en_judicial,
								data.d[i].en_prelegal
							]);

						}
					}

					var tabla = formatear_tabla($('#tablaObligaciones'), arrayObligaciones);

					tabla.column(COL_IDT).visible(false);
					tabla.column(COL_IDO).visible(false);
					tabla.column(COL_en_plandepago).visible(false);
					tabla.column(COL_en_extrajudicial).visible(false);
					tabla.column(COL_en_judicial).visible(false);
					tabla.column(COL_en_prelegal).visible(false);

				},
				error: function (xhr, ajaxOptions, thrownError) {
					CerrarLoading();
				}
			});

		}

		//################################################# UTILS #################################################
		function AlertaError(data) {

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
			$(idElemento)
				.prop('disabled', false)
                .show();
		}

		function ocultar(idElemento) {
			$(idElemento).hide();
		}

		function mostrarModal(idModal) {
			$(idModal).modal("show");
		}

		function ocultarModal(idModal) {
			$(idModal).modal("hide");
		}

		function ocultarColumna(idTabla, col) {
			$(idTabla + ' tr > *:nth-child(' + col + ')').hide();
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
            AbrirLoading();
            habilitar(ddl);

            const currentYear = new Date().getFullYear();
            const maxYear = currentYear + 1; // ← siempre 1 año más

            $(ddl).empty()
                .append('<option selected="selected" value="">--Seleccione el año--</option>');

            for (let anio = maxYear; anio > 1999; anio--) {
                $(ddl).append(
                    $("<option></option>").val(anio).text(anio)
                );
            }

            CerrarLoading();
        }


		//Funcion obtner TributosxJuridiccion por ID
		var TributoxJurisdiccionID = function (ddl) {
			AbrirLoading();

			$.ajax({
				type: "POST",
				url: ruta + "/Bienvenida.aspx/getTipoTributosxJuri ",
				contentType: "application/json; charset=utf-8",
				dataType: "json",
				success: function (data, st) {
					if (st == 'success') {
						if (data.d.length > 0) {

							$(ddl).empty().append('<option selected="selected" value="">--Seleccione el Tributo--</option>');
							$.each(data.d, function () {

								$(ddl).append($("<option></option>").val(this['ID_TIPO_TIBUTO']).html(this['CONCEPTO']));
							});

						}
						else {
							$(ddl).empty().append('<option selected="selected" value="">No disponible<option>');
						}
					}

				},
				failure: function (data) {
					alert(data.d);
				}
			});

			CerrarLoading();
		}

		function formatoFechaPrimerVencimiento(fecha) {
			if (fecha != null) {
				var dateString = fecha.substr(6);
				var currentTime = new Date(parseInt(dateString));
				var month = ("0" + (currentTime.getMonth() + 1)).slice(-2);
				var day = ("0" + currentTime.getDate()).slice(-2);
				var year = currentTime.getFullYear();
				var datePV = day + '/' + month + '/' + year;
			}
			else
				datePV = '';

			return datePV;
		}

		function obtenerTipoTributo(id_tipo_tributo) {

			var tipo_tributo;

			switch (id_tipo_tributo.toString()) {

				case "18": tipo_tributo = "TASA"; break;
				case "2": tipo_tributo = "AUAU"; break;
				case "4": tipo_tributo = "CECE"; break;
				case "5": tipo_tributo = "CICI"; break;
				case "6": tipo_tributo = "ININ"; break;
				case "12": tipo_tributo = "OBSA"; break;
				case "123": tipo_tributo = "INTE"; break;
				case "124": tipo_tributo = "TELF"; break;
				case "46": tipo_tributo = "OBSC"; break;
				case "55": tipo_tributo = "SUEN"; break;

			}
			return tipo_tributo;
		}

		function obtenerIdTipoTributo(tipo_tributo) {

			var id_tipo_tributo;

			switch (tipo_tributo) {

				case "TASA": id_tipo_tributo = "18"; break;
				case "AUAU": id_tipo_tributo = "2"; break;
				case "CECE": id_tipo_tributo = "4"; break;
				case "CICI": id_tipo_tributo = "5"; break;
				case "ININ": id_tipo_tributo = "6"; break;
				case "INTE": id_tipo_tributo = "123"; break;
				case "TELF": id_tipo_tributo = "124"; break;
				case "OBSA": id_tipo_tributo = "12"; break;
				case "OBSC": id_tipo_tributo = "46"; break;
				case "SUEN": id_tipo_tributo = "55"; break;

			}
			return id_tipo_tributo;
		}

		function obtenerModalidadAgua(idTipoModalidad) {
			var modalidad;

			switch (idTipoModalidad) {
				case "1": modalidad = "CUOTA FIJA"; break;
				case "2": modalidad = "MEDIDOR"; break;
				case "3": modalidad = "CUOTA FIJA"; break;
			}
			return modalidad;
		}

		function cargarCuotas(ddl, anioConsulta, tipoTributo) {

			var tributoElegido = $('#ddlTributo').val();
			var modalidadElegida = obtenerModalidadAgua($('#ddlModalidadAgua').val());
			var modalidad = '';

			var ajaxData = {
				anioConsulta: anioConsulta,
				tipoTributo: tipoTributo
			}

			$.ajax({
				url: "DevengamientoV2.aspx/traerVencimientos",
				type: "post",
				data: JSON.stringify(ajaxData),
				beforeSend: function () {
					AbrirLoading();
				},
				contentType: "application/json",
				async: false,
				success: function (data) {
					if (data.d != null) {
						console.log(data.d);
						habilitar(ddl);

						$(ddl).empty().append('<option selected="selected" value="">--Seleccione el mes--</option>');

						for (var i = 0; i < data.d.length; i++) {

							if (tributoElegido == 'OBSA') {//si es agua tengo que ver si es para medidor o fijo
								modalidad = data.d[i].DESCRIPCION;

								if (modalidad == modalidadElegida)
									ddl.append($("<option></option>").val(data.d[i].NRO_CUOTA).html(data.d[i].NRO_CUOTA));
							}
							else {
								ddl.append($("<option></option>").val(data.d[i].NRO_CUOTA).html(data.d[i].NRO_CUOTA));
							}
						}
					}
					mostrar('#divDdlCuotasDevengamiento');
					CerrarLoading();
				},
				error: function (xhr, ajaxOptions, thrownError) {
					CerrarLoading();
				}
			});
		}

		function cargarCuotasMultiselect(ddl, anioConsulta, tipoTributo) {
			var tributoElegido = $('#ddlTributo').val();
			var modalidadElegida = obtenerModalidadAgua($('#ddlModalidadAgua').val());
			var modalidad = '';

			AbrirLoading();
			ddl.multiselect('destroy');
			ddl.find('option')
				.remove()
				.end()
				;

			if ((idJurisdiccion == 2455 && (modalidadCuenta == null || modalidadCuenta == "null" || modalidadCuenta == "undefined")) && $('#radioMasivoNo').is(':checked')) {
				swal("Alerta", "Consulte una cuenta antes de seleccionar el periodo", "warning");
				CerrarLoading();
				return;
			}

			if ($('#radioMasivoSi').is(':checked')) {
				if ($('#ddlFijoMed').val() != 0) {
					modalidadCuenta = $('#ddlFijoMed').val();
				}
				else {
					swal("Alerta", "Seleccione una modalidad antes de seleccionar el periodo", "warning");
					CerrarLoading();
					return;
				}
			}

			var ajaxData = {
				anioConsulta: anioConsulta,
				tipoTributo: tipoTributo
			}

			$.ajax({
				url: "DevengamientoV2.aspx/traerVencimientos",
				type: "post",
				data: JSON.stringify(ajaxData),
				contentType: "application/json",
				async: false,
				success: function (data) {
					if (data.d != null) {
						habilitar(ddl);
						cantidad_cuotas = data.d.length;

						for (var i = 0; i < data.d.length; i++) {

							if (tributoElegido == 'OBSA') {//si es agua tengo que ver si es para medidor o fijo
								modalidad = data.d[i].DESCRIPCION;

								if (modalidad == modalidadElegida)
									ddl.append($("<option></option>").val(data.d[i].NRO_CUOTA).html(data.d[i].NRO_CUOTA));
							}
							else {
								ddl.append($("<option></option>").val(data.d[i].NRO_CUOTA).html(data.d[i].NRO_CUOTA));
							}
						}

						$(ddl).multiselect({
							nonSelectedText: '--Seleccione Cuota(s)--',
							includeSelectAllOption: true,
							selectAllText: 'TODAS',
							allSelectedText: 'TODAS',
							selectAllValue: 'all',
							filterPlaceholder: 'Buscar...',
							nSelectedText: 'seleccionadas'
						});
					}
					CerrarLoading();
				},
				error: function (xhr, ajaxOptions, thrownError) {
					CerrarLoading();
				}
			});

			ocultar(ddl);

		}

		function limpiarTablasObligaciones() {
			return;
		}

		function mostrarParametrosJurisdiccion(idJurisdiccion, tipoTributo) {

			if (tipoTributo == 0) {
				limpiarPantalla();
			}
			else {
				mostrarParametros(tipoTributo);
			}

			const column1Width = $("#colTipoTributo").width() - 30;
			$("#colTituloCuenta").width(column1Width);

		}

		function mostrarParametros(tipoTributo) {
			ResetInputs();
			switch (tipoTributo) {
				case "AUAU"://AUTOMOTORES

					mostrar('#divMasivo');
					mostrar('#divCuenta');
					mostrar('#divTipoDevengamiento');
					mostrar('#divAnioConsulta');
					ocultar('#ddlMeses');
					//if ($('#radioCuotas').is(':checked')) {
					//    mostrar('#ddlMeses');
					//}
					//ocultar('#rowModalidad');
					//ocultar('#rowCategoria');
					//ocultar('#rowTipo');

					break;

				case "ININ"://INMUEBLES
					mostrar('#divMasivo');
					mostrar('#divCuenta');
					mostrar('#divTipoDevengamiento');
					mostrar('#divAnioConsulta'); 
                    mostrar('#divMesesMultiselect');
					ocultar('#ddlMeses');
					//if ($('#radioCuotas').is(':checked')) {
					//    mostrar('#ddlMeses');
					//}

					break;
				case "CECE"://CEMENTERIO
					mostrar('#divMasivo');
					mostrar('#divCuenta');
					mostrar('#divTipoDevengamiento');
					mostrar('#divAnioConsulta');
					if ($('#radioCuotas').is(':checked')) {
						mostrar('#ddlMeses');
					}
					break;

				case "OBSC"://CLOACA

					mostrar('#divMasivo');
					mostrar('#divCuenta');
					//mostrar('#divModalidad');
					mostrar('#divTipoDevengamiento');
					if ($('#radioCuotas').is(':checked')) {
						mostrar('#ddlMeses');
					}
					mostrar('#divAnioConsulta');
					break;
				case "OBSA"://AGUA

					mostrar('#divMasivo');
					mostrar('#divCuenta');
					mostrar('#divModalidad');
					mostrar('#divTipoDevengamiento');
					mostrar('#divAnioConsulta');
					ocultar('#ddlMeses');
					if ($('#ddlModalidadAgua').val() === "3") {
						mostrar('#divMonto');
					}
					break;
				case "INTE":

					mostrar('#divMasivo');
					mostrar('#divAnioConsulta');
					mostrar('#divCuenta');
					mostrar('#divTipoDevengamiento');
					if ($('#radioCuotas').is(':checked')) {
						mostrar('#ddlMeses');
					}
					DisabledInternetInpus();
					//mostrar('#divCuenta');
					//mostrar('#divInternet');
					break;
				case "TELF":

					mostrar('#divMasivo');
					mostrar('#divAnioConsulta');
					mostrar('#divCuenta');
					mostrar('#divTipoDevengamiento');
					if ($('#radioCuotas').is(':checked')) {
						mostrar('#ddlMeses');
					}
					DisabledInternetInpus();
					//mostrar('#divCuenta');
					//mostrar('#divInternet');
					break;

				case "SUEN"://SUMINISTRO ENERGIA ELECTRICA
					mostrar('#divCuenta');
					mostrar('#divMonto');
					mostrar('#divTipoDevengamiento');
					mostrar('#divAnioConsulta');
					if ($('#radioCuotas').is(':checked')) {
						mostrar('#ddlMeses');
					}
					break;
				default:
					break;
			}
		}

		function DisabledInternetInpus() {
			$('#radioAnual').prop('checked', false);
			$('#radioAnual').prop('disabled', true);
			$('#radioCuotas').prop('checked', true);
			mostrarParametrosTipoDevengamiento($('#radioCuotas').val(), $('#ddlTributo').val());
		}

		function ResetInputs() {
			$('#radioAnual').prop('checked', true);
			$('#radioAnual').prop('disabled', false);
			$('#radioCuotas').prop('checked', false);
			ocultar('#ddlMeses');
			mostrarParametrosTipoDevengamiento($('#radioCuotas').val(), $('#ddlTributo').val());
		}
		function mostrarParametrosRadioMasivo(masivo) {
			if (masivo == 'SI') {
				ocultar('#divCuenta');
			}
			else {
				mostrar('#divCuenta');
			}
		}

		function mostrarParametrosTipoDevengamiento(tipoDevengamiento, tipoTributo) {
			if (tipoDevengamiento == '1') {//anual
				ocultar('#ddlMeses');
				ocultar('#divMesesMultiselect');
				ocultar('#ddlMesesMultiselect');
			}
			else {//dependiendo el tributo y la jurisdiccion puedo mostrar meses o cuotas
				mostrarMesesCuotas(tipoTributo);
			}
		}

		function mostrarMesesCuotas(tipoTributo) {

			switch (tipoTributo) {
				case "ININ"://PROPIEDAD
                    mostrar('#divMesesMultiselect');
					break;
				case "INTE"://PROPIEDAD
					mostrar('#ddlMeses');
					break;
				case "TELF"://PROPIEDAD
					mostrar('#ddlMeses');
					break;
				case "OBSA"://AGUA
					mostrar('#ddlMeses');
					break;
				case "CICI"://COMERCIO
					mostrar('#ddlMeses');
					break;
				case "CECE"://COMERCIO
					mostrar('#ddlMeses');
					break;
				case "AUAU"://AUTOMOTORES
					mostrar('#ddlMeses');
					break;
				case "OBSC"://SERVICIO CLOACA
					mostrar('#ddlMeses');
					break;
				case "SUEN"://SUMINISTRO ELECTRICO
					mostrar('#divMesesMultiselect');
					mostrar('#ddlMesesMultiselect');
					break;

				default:
					break;
			}
		}

		function limpiarPantalla() {
			ocultar('#divMasivo');
			ocultar('#divCuenta');
			ocultar('#divModalidad');
			ocultar('#divTipoDevengamiento');
			ocultar('#divAnioConsulta');
			ocultar('#divCuenta');
			ocultar('#DivTitular');
			ocultar('#divObligaciones');
			ocultar('#divObligacionesDet');

		}

        exportToCsv = function (Results) {
            var CsvString = "";
            var anio = $('#ddlAnioConsulta').val();
            var tributo = $('#ddlTributo').val();
            var nombreArchivo = "simulacion_" + tributo + "_" + anio + ".csv";

            Results.forEach(function (RowItem) {
                RowItem.forEach(function (ColItem) {

                    // FORZAR TEXTO SI TIENE COMA
                    if (typeof ColItem === "string" && ColItem.includes(',')) {
                        CsvString += "'" + ColItem + ";";   // 👈 ESTA ES LA CLAVE
                    } else {
                        CsvString += ColItem + ";";
                    }

                });
                CsvString += "\r\n";
            });

            CsvString = "data:text/csv;charset=utf-8," + encodeURIComponent(CsvString);

            var x = document.createElement("a");
            x.href = CsvString;
            x.download = nombreArchivo;
            document.body.appendChild(x);
            x.click();
            document.body.removeChild(x);
        }



		function deshabilitarBotonDevengar() {
			var btnPrueba = document.getElementById("btnPrueba");
			var btnDevengar = document.getElementById("btnDevengar");
			var btnSimular = document.getElementById("btnSimular");

			btnPrueba.disabled = true;
			btnDevengar.disabled = true;
			btnSimular.disabled = true;
			btnDevengar.innerText = "Devengando...";
		}

		function habilitarBotonDevengar() {
			var btnPrueba = document.getElementById("btnPrueba");
			var btnDevengar = document.getElementById("btnDevengar");
			var btnSimular = document.getElementById("btnSimular");

			btnPrueba.disabled = false;
			btnDevengar.disabled = false;
			btnSimular.disabled = false;
			btnDevengar.innerText = "Devengar";
		}
		//################################################# VALIDACIONES #################################################

		function validarDdl(ddl, mensaje) {
			if ($(ddl).val() == "" || $(ddl).val() == null ) {
				Alerta(mensaje);
				return false;
			}
			return true;
		}

		function validarVacio(elem, mensaje) {
			if ($(elem).val() == "" || $(elem).val() == null) {
				Alerta(mensaje);
				return false;
			}
			return true;
		}

		function validarConsulta() {
			var resultado = true;

			resultado = resultado && validarDdl('#ddlTributo', 'Seleccione un tipo de tributo.')
				&& validarVacio('#txtNroCuenta', 'Ingrese una cuenta para consultar.');

			return resultado;
		}

		function validarDevengamiento() {
			var resultado = true;

			resultado = resultado && validarDdl('#ddlTributo', 'Seleccione un tipo de tributo.');

			if ($("#ddlTributo").val() == 'OBSA') {
				resultado = resultado && validarDdl('#ddlModalidadAgua', 'Seleccione una modalidad.');
			}

			resultado = resultado && validarDdl('#ddlAnioConsulta', 'Seleccione un año a devengar.');

			if ($('#radioCuotas').is(':checked') && $("#ddlMeses").is(":visible")) {
				resultado = resultado && validarDdl('#ddlMeses', 'Seleccione la cuota a devengar.');
			}
			else if ($('#radioCuotas').is(':checked') && $("#divMesesMultiselect").is(":visible")) {
				resultado = resultado && validarDdl('#ddlMesesMultiselect', 'Seleccione las cuotas a devengar.');
			}

			if ($('#radioMasivoNo').is(':checked')) {
				resultado = resultado && validarVacio('#txtNroCuenta', 'Ingrese una cuenta a devengar.');
			}
			if ($("#txtMonto").val() == 'SUEN') {
				resultado = resultado && validarDdl('#txtMonto', 'Ingrese un Importe.');
			}

			return resultado;
		}

		function validarSimulacion() {
			var resultado = true;

			resultado = resultado && validarDdl('#ddlTributo', 'Seleccione un tipo de tributo.');

			if ($("#ddlTributo").val() == 'OBSA') {
				resultado = resultado && validarDdl('#ddlModalidadAgua', 'Seleccione una modalidad.');
			}

			resultado = resultado && validarDdl('#ddlAnioConsulta', 'Seleccione un año a simular.');

			if ($('#radioCuotas').is(':checked') && $("#ddlMeses").is(":visible")) {
				resultado = resultado && validarDdl('#ddlMeses', 'Seleccione la cuota a simular.');
			}
			else if ($('#radioCuotas').is(':checked') && $("#divMesesMultiselect").is(":visible")) {
				resultado = resultado && validarDdl('#ddlMesesMultiselect', 'Seleccione las cuotas a simular.');
			}

			if ($('#radioMasivoNo').is(':checked')) {
				resultado = resultado && validarVacio('#txtNroCuenta', 'Ingrese una cuenta a simular.');
			}

			return resultado;
		}

		function validarAnioConsulta() {
			if ($('#ddlTributo').val() == 'OBSA') {
				if ($('#ddlModalidadAgua').val() == null || $('#ddlModalidadAgua').val() == 0) {
					Alerta('Seleccione un tipo de modalidad.');
					$('#ddlAnioConsulta').val("");
					return false
				}
			}

			return true;
		}
		//############################################### END VALIDACIONES ###########################################

		function pruebaBarraCarga() {

			mostrar('#loading-barra');
			mostrar('#mensaje-devengamiento');

			deshabilitarBotonDevengar();


			G_TIPO_TRIBUTO = 'OBSA';
			G_ESTADO_DEVENGAMIENTO = 'P';
			G_PROGRESO_DEVENGAMIENTO = 0;
			G_PROGRESO_DEVENGAMIENTO_AUX = 0;

			intervaloConsulta = setInterval(CONSULTAR_PORCENTAJE_CARGA, 2000);

			var P_ID_TRIBUTO_CONTRIBUYENTE = 'P_ID_TRIBUTO_CONTRIBUYENTE=' + 'prueba';
			var P_TIPO_TRIBUTO = '&P_TIPO_TRIBUTO=' + 'prueba';
			var P_EJERCICIO_LIQ = '&P_EJERCICIO_LIQ=' + 'prueba';
			var P_NRO_CUOTA = '&P_NRO_CUOTA=' + 'prueba';
			var P_MODALIDAD = '&P_MODALIDAD=' + 'prueba';
			var P_MODO = '&P_MODO=' + 'prueba';
			var P_MONTO = '&P_MONTO=' + 0;
			var urlInicial = ruta + '/Devengamiento/PantallaAuxiliar.aspx?';
			var url = urlInicial.concat(P_ID_TRIBUTO_CONTRIBUYENTE);
			url = url.concat(P_TIPO_TRIBUTO);
			url = url.concat(P_EJERCICIO_LIQ);
			url = url.concat(P_NRO_CUOTA);
			url = url.concat(P_MODALIDAD);
			url = url.concat(P_MODO);
			url = url.concat(P_MONTO);
			return url;
		}

		function abrirVentanaAuxiliar() {
			CerrarLoading();
			mostrar('#loading-barra');
			mostrar('#mensaje-devengamiento');

			deshabilitarBotonDevengar();

			G_ESTADO_DEVENGAMIENTO = 'P'
			G_PROGRESO_DEVENGAMIENTO = 0;
			G_PROGRESO_DEVENGAMIENTO_AUX = 0;

			intervaloConsulta = setInterval(CONSULTAR_PORCENTAJE_CARGA, 2000);

			var P_ID_TRIBUTO_CONTRIBUYENTE = 'P_ID_TRIBUTO_CONTRIBUYENTE=' + G_ID_TRIBUTO_CONTRIBUYENTE;
			var P_TIPO_TRIBUTO = '&P_TIPO_TRIBUTO=' + G_TIPO_TRIBUTO;
			var P_EJERCICIO_LIQ = '&P_EJERCICIO_LIQ=' + G_EJERCICIO_LIQ;
			var P_NRO_CUOTA = '&P_NRO_CUOTA=' + G_NRO_CUOTA;
			var P_MODALIDAD = '&P_MODALIDAD=' + G_MODALIDAD;
			var P_MODO = '&P_MODO=' + G_MODO;
			var P_MONTO = '&P_MONTO=' + 0;
			if (G_TIPO_TRIBUTO == "OBSA") {
				if (G_MODALIDAD == -1)
					return;
				if (G_MODALIDAD === "3") {
					P_MONTO = '&P_MONTO=' + G_MONTO;
				}

			}
			if (G_TIPO_TRIBUTO == 'SUEN') {

				var P_MONTO = '&P_MONTO=' + G_MONTO;
				var P_CANTIDADSELECCIONADA = '&P_CANTIDADSELECCIONADA=' + G_CANTIDADSELECCIONADA;

			}
			var urlInicial = ruta + '/Devengamiento/PantallaAuxiliar.aspx?';
			var url = urlInicial.concat(P_ID_TRIBUTO_CONTRIBUYENTE);
			url = url.concat(P_TIPO_TRIBUTO);
			url = url.concat(P_EJERCICIO_LIQ);
			url = url.concat(P_NRO_CUOTA);
			url = url.concat(P_MODALIDAD);
			url = url.concat(P_MODO);
			url = url.concat(P_MONTO);

			if (G_TIPO_TRIBUTO == 'SUEN') {
				url = url.concat(P_CANTIDADSELECCIONADA);
			}

			window.open(url, '', 'width=500,height=400,left=100,top=100,toolbar=yes');
		}

		function CONSULTAR_PORCENTAJE_CARGA() {

			var idTipoTributo = obtenerIdTipoTributo(G_TIPO_TRIBUTO);

			var ajaxData = {
				P_ID_TIPO_TRIBUTO: idTipoTributo
			}

			$.ajax({
				url: "DevengamientoV2.aspx/CONSULTAR_PORCENTAJE_CARGA",
				type: "post",
				data: JSON.stringify(ajaxData),
				contentType: "application/json",
				async: true,
				success: function (data) {
					if (data.d != null && data.d.length > 0) {
						var PORCENTAJE = data.d[0].PORCENTAJE;
						var ESTADO = data.d[0].ESTADO;
						var PROCESADAS = data.d[0].PROCESADAS;
						var TOTAL = data.d[0].TOTAL;
						var MENSAJE_ERROR = data.d[0].MENSAJE_ERROR;

						//console.log('(' + PROCESADAS + '/' + TOTAL + ')');

						G_PROGRESO_DEVENGAMIENTO = PORCENTAJE;
						G_ESTADO_DEVENGAMIENTO = ESTADO;
						G_MENSAJE_ERROR = MENSAJE_ERROR;

						if (ESTADO == "E") {
							clearInterval(intervaloConsulta);
							AlertaError(MENSAJE_ERROR);
							ocultar('#loading-barra');
							ocultar('#mensaje-devengamiento');
							habilitarBotonDevengar();
						}
					}
					else {
						CerrarLoading();
						console.log('ERROR CONSULTAR PORCENTAJE CARGA');
					}
				},
				error: function (xhr, ajaxOptions, thrownError) {
					console.log('ERROR CONSULTAR PORCENTAJE CARGA' + thrownError);

				}
			});

			var progressBar = document.getElementById("loading-progress");
			var progressText = document.getElementById("loading-text");
			progressText.style.color = '#555';

			if (G_PROGRESO_DEVENGAMIENTO == 0) {//cargo la barra con numeros hasta que el back responda

				const random = Math.floor(Math.random() * 2);

				G_PROGRESO_DEVENGAMIENTO_AUX += random;
				if (G_PROGRESO_DEVENGAMIENTO_AUX >= 100) G_PROGRESO_DEVENGAMIENTO_AUX = 100;

				progressBar.style.width = Math.trunc(G_PROGRESO_DEVENGAMIENTO_AUX) + '%';
				progressText.innerHTML = Math.trunc(G_PROGRESO_DEVENGAMIENTO_AUX) + '%';
			}
			else {
				if (G_ESTADO_DEVENGAMIENTO == 'T') { //DEVENGAMIENTO TERMINADO
					clearInterval(intervaloConsulta);

					if (G_MODO == 'G') {
						Exito("Se ha devengado con éxito.", "success");

					}

					if (G_MASIVO == "02") {
						mostrarObligaciones(G_ID_TRIBUTO_CONTRIBUYENTE);
					}

					if (G_MODO == 'S') {
						obtenerSimulacion();//trae la simulación generada como un excel
					}

					progressBar.style.width = 100 + '%';
					progressText.innerHTML = 'Finalizado.';
					progressText.style.color = 'white';

					ocultar('#mensaje-devengamiento');

					G_MASIVO = null;
					G_MODO = null;
					G_TIPO_TRIBUTO = null;
					G_EJERCICIO_LIQ = null;
					G_NRO_CUOTA = null;
					G_MODALIDAD = null;

					habilitarBotonDevengar();
				}
				else if (G_ESTADO_DEVENGAMIENTO == 'E') {//ERROR EN DEVENGAMIENTO
					clearInterval(intervaloConsulta);

					AlertaError("Hubo un problema al devengar. Error al Liquidar la cuenta " + G_MENSAJE_ERROR);

					progressBar.style.width = 100 + '%';
					progressBar.style.backgroundColor = '#eb0000';
					progressText.innerHTML = 'Error.';
					progressText.style.color = 'white';

					ocultar('#mensaje-devengamiento');

					G_MASIVO = null;
					G_MODO = null;
					G_TIPO_TRIBUTO = null;
					G_EJERCICIO_LIQ = null;
					G_NRO_CUOTA = null;
					G_MODALIDAD = null;

					habilitarBotonDevengar();
				}
				else {//DEVENGAMIENTO EN PROCESO
					if (G_PROGRESO_DEVENGAMIENTO > 50) {
						progressText.style.color = 'white';
						progressBar.style.width = Math.trunc(G_PROGRESO_DEVENGAMIENTO) + '%';
						progressText.innerHTML = Math.trunc(G_PROGRESO_DEVENGAMIENTO) + '%';
					}
					else {
						progressBar.style.width = Math.trunc(G_PROGRESO_DEVENGAMIENTO) + '%';
						progressText.innerHTML = Math.trunc(G_PROGRESO_DEVENGAMIENTO) + '%';
					}
				}

			}
		}

		function ConsultarEstadoDevengamiento() {
			AbrirLoading();

			$.ajax({
				url: ruta + "/Devengamiento/DevengamientoV2.aspx/CONSULTAR_ESTADO_DEVENGAMIENTO",
				type: "post",
				contentType: "application/json",
				async: true,
				success: function (data) {
					if (data.d != null && data.d.length > 0) {
						var PORCENTAJE = data.d[0].PORCENTAJE;
						var ESTADO = data.d[0].ESTADO;
						var PROCESADAS = data.d[0].PROCESADAS;
						var TOTAL = data.d[0].TOTAL;
						var TIEMPO_UNITARIO = data.d[0].TIEMPO_UNITARIO;
						var MENSAJE_ERROR = data.d[0].MENSAJE_ERROR;

						//console.log('RESULTADO ConsultarEstadoDevengamiento: (Estado ' + ESTADO + ')' + '(Porcentaje ' + PORCENTAJE + ')');

						G_ESTADO_DEVENGAMIENTO = ESTADO;
						G_PROGRESO_DEVENGAMIENTO = PORCENTAJE;
						G_PROGRESO_DEVENGAMIENTO_AUX = PORCENTAJE;
						G_MENSAJE_ERROR = MENSAJE_ERROR;
						G_TIPO_TRIBUTO = obtenerTipoTributo(data.d[0].ID_TIPO_TRIBUTO);

						if (ESTADO == "E") {
							clearInterval(intervaloConsulta);
							AlertaError(MENSAJE_ERROR);
							ocultar('#loading-barra');
							ocultar('#mensaje-devengamiento');
							habilitarBotonDevengar();
						}
					}
					else {
						//console.log('RESULTADO ConsultarEstadoDevengamiento: Terminado.');

						G_ESTADO_DEVENGAMIENTO = 'T';//Terminado
						G_PROGRESO_DEVENGAMIENTO = 0;
						G_PROGRESO_DEVENGAMIENTO_AUX = 0;
					}

					if (G_ESTADO_DEVENGAMIENTO == 'P') {//Procesando
						mostrar('#loading-barra');
						deshabilitarBotonDevengar();
						CONSULTAR_PORCENTAJE_CARGA();
						intervaloConsulta = setInterval(CONSULTAR_PORCENTAJE_CARGA, 2000);
					}
					else {
						habilitarBotonDevengar();
					}
				},
				error: function (xhr, ajaxOptions, thrownError) {
					console.log('ERROR CONSULTAR PORCENTAJE CARGA: ' + thrownError);

				}
			});

			CerrarLoading();
		}

		function TributosConDevengamiento(ddl) {
			$.ajax({
				type: "POST",
				url: "DevengamientoV2.aspx/TRIBUTOS_CON_DEVENGAMIENTO",
				contentType: "application/json; charset=utf-8",
				dataType: "json",
				success: function (data, st) {
					if (st == 'success') {
						if (data.d.length > 0) {

							$(ddl).empty().append('<option selected="selected" value="">-- Seleccione un Tributo --</option>');
							$.each(data.d, function () {

								$(ddl).append($("<option></option>").val(this['TIPO_TRIBUTO']).html(this['CONCEPTO']));
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

		function obtenerCuota(tipoTributo) {
			obtenerCuotaAnual(tipoTributo);
		}

		function obtenerCuotaAnual(tipoTributo) {
			switch (tipoTributo) {
				case "ININ":
					return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
				case "OBSA":
                    return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
				case "INTE":
                    return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
				case "TELF":
                    return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
				case "CECE":
					return [0, 1];
				case "AUAU":
					return [0, 1, 2, 3, 4, 5, 6];
				case "SUEN":
                    return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
				default:
                    return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
					break;
			}
		}

		function iniciarMultiselect(ddl) {
			habilitar(ddl);

			$(ddl).multiselect({
				nonSelectedText: '--No disponible--',

				filterPlaceholder: 'Buscar...',
				nSelectedText: 'seleccionadas'
			});

			ocultar('#divMesesMultiselect');

		}

    </script>
</asp:Content>
