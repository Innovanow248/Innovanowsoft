import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { environment } from '../../../environments/environment';

export interface TipoTributo {
  idTipoTributo: number;
  tipoTributo_: string;
  concepto: string;
  conceptoAbreviado: string | null;
}

export interface ZonaInmueble {
  idZonas: number;
  concepto: string;
  conceptoAbreviado: string;
}

export interface ConceptoAnio {
  idTipoconAnio: number;
  idTipoConcepto: number;
  anioEjercicio: number;
  porcentaje: number | null;
  valor: number | null;
  usrIng: string;
  fecIng: string;
  usrBaja: string | null;
  fecBaja: string | null;
}

export interface ConceptoDevengamiento {
  idTipoConcepto: number;
  idTipoTributo: number | null;
  concepto: string;
  descripcion: string | null;
  impacto: string | null;
  porcentaje: number | null;
  valor: number | null;
  objetoRef: string | null;
  orden: number | null;
  tipoCuota: string | null;
  masivo: string | null;
  idTipoTributoAux: number | null;
  usrIng: string;
  fecIng: string;
  usrBaja: string | null;
  fecBaja: string | null;
  anios: ConceptoAnio[];
}

export interface Vencimiento {
  idVencimientos: number;
  idTipoTributo: number;
  nroCuota: number;
  ejercicio: string | null;
  nTipo: string | null;
  nZona: string | null;
  fechaPrimerVto: string;
  fechaSegundoVto: string | null;
  fechaTercerVto: string | null;
  descPrimerVto: number | null;
  descSegundoVto: number | null;
  descTercerVto: number | null;
  usrBaja: string | null;
  fecBaja: string | null;
}

export interface TipoPlanPago {
  idTipoPlanespago: number;
  codigoPlan: string;
  designacionPlan: string;
  decretoResolucion: string | null;
  soloUsoDevengamiento: string | null;
  observaciones: string | null;
  cantidadCuotas: number | null;
  diaPrimerVencimiento: number | null;
  actualizable: string | null;
  periodo: string | null;
  usrBaja: string | null;
  fecBaja: string | null;
  detalles: TipoPlanPagoDetalle[];
}

export interface TipoPlanPagoDetalle {
  idPlanesagoDet: number;
  idTipoPlanespago: number;
  cantidadCuotas: number | null;
  fechaVigenteDesde: string | null;
  fechaVigenteHasta: string | null;
  montoMinDeuda: number | null;
  montoMaxDeuda: number | null;
  cantMinCuotas: number | null;
  cantMaxCuotas: number | null;
  montoMinCuota: number | null;
  interesFinanciacion: number | null;
  cantCuotasSinInteres: number | null;
}

export interface ObsaModalidad {
  idObsaModalidad: number;
  descripcion: string | null;
}

export interface ConfigInteres {
  idConfiguracion: number;
  idTipoTributo: number;
  porcentual: number;
  observacion: string | null;
  fechaDesde: string;
  fechaHasta: string | null;
  idJurisdiccion: number | null;
  usrIng: string;
  fecIng: string;
  usrBaja: string | null;
  fecBaja: string | null;
}

export interface ParametricaTributo {
  idParamTrib: number;
  idTipoTributo: number;
  concepto: string;
  tipoTributo_: string | null;
  idJurisdiccion: number;
  activo: number;
  masivo: string | null;
  declarativo: string | null;
  usrIng: string | null;
  fecIng: string | null;
  usrBaja: string | null;
  fecBaja: string | null;
}

export interface EstadoDevengamiento {
  idPorcentajeCarga: number;
  idJurisdiccion: number;
  idTipoTributo: number | null;
  porcentaje: number;
  estado: string;
  mensaje: string | null;
  fecInicio: string | null;
  fecFin: string | null;
  usrOperador: string | null;
  ejercicio: string | null;
}

export interface LogDevengamiento {
  idLog: number;
  idJurisdiccion: number;
  idTipoTributo: number | null;
  tipoTributo: string | null;
  ejercicio: string | null;
  resultado: string;
  mensaje: string | null;
  fecEjecucion: string;
  usrOperador: string | null;
  cuentasProcesadas: number | null;
  cuentasDevengadas: number | null;
  cuentasError: number | null;
  duracionSegundos: number | null;
}

export interface ConceptoVencimiento {
  idConceptoVencimiento: number;
  idTipoConcepto: number | null;
  idVencimiento: number | null;
  cumplidor: string | null;
  observacion: string | null;
  conceptoPadre: number | null;
  usrIng: string | null;
  fecIng: string | null;
  usrBaja: string | null;
  fecBaja: string | null;
  conceptoNombre: string | null;
  conceptoPadreNombre: string | null;
  ejercicio: string | null;
  nroCuota: number | null;
  nZona: string | null;
  idTipoTributo: number | null;
}

@Injectable({ providedIn: 'root' })
export class DevengamientoService {
  private http = inject(HttpClient);
  private base = `${environment.apiUrl}/devengamiento`;

  tributos() {
    return this.http.get<TipoTributo[]>(`${this.base}/tributos`);
  }

  zonas() {
    return this.http.get<ZonaInmueble[]>(`${this.base}/zonas`);
  }

  // Conceptos
  conceptos(idTipoTributo?: number, busqueda?: string) {
    let params = new HttpParams();
    if (idTipoTributo) params = params.set('idTipoTributo', idTipoTributo);
    if (busqueda)      params = params.set('busqueda', busqueda);
    return this.http.get<ConceptoDevengamiento[]>(`${this.base}/conceptos`, { params });
  }

  concepto(id: number) {
    return this.http.get<ConceptoDevengamiento>(`${this.base}/conceptos/${id}`);
  }

  crearConcepto(req: object) {
    return this.http.post<{ id: number }>(`${this.base}/conceptos`, req);
  }

  actualizarConcepto(id: number, req: object) {
    return this.http.put(`${this.base}/conceptos/${id}`, req);
  }

  eliminarConcepto(id: number, usuario = 'SISTEMA') {
    return this.http.delete(`${this.base}/conceptos/${id}?usuario=${encodeURIComponent(usuario)}`);
  }

  // Conceptos por año
  conceptoAnios(idConcepto: number) {
    return this.http.get<ConceptoAnio[]>(`${this.base}/conceptos/${idConcepto}/anios`);
  }

  crearConceptoAnio(idConcepto: number, req: object) {
    return this.http.post<{ id: number }>(`${this.base}/conceptos/${idConcepto}/anios`, req);
  }

  actualizarConceptoAnio(id: number, req: object) {
    return this.http.put(`${this.base}/conceptos-anio/${id}`, req);
  }

  eliminarConceptoAnio(id: number, usuario = 'SISTEMA') {
    return this.http.delete(`${this.base}/conceptos-anio/${id}?usuario=${encodeURIComponent(usuario)}`);
  }

  // Vencimientos
  vencimientos(idTipoTributo?: number, ejercicio?: string) {
    let params = new HttpParams();
    if (idTipoTributo) params = params.set('idTipoTributo', idTipoTributo);
    if (ejercicio)     params = params.set('ejercicio', ejercicio);
    return this.http.get<Vencimiento[]>(`${this.base}/vencimientos`, { params });
  }

  crearVencimiento(req: object) {
    return this.http.post<{ id: number }>(`${this.base}/vencimientos`, req);
  }

  actualizarVencimiento(id: number, req: object) {
    return this.http.put(`${this.base}/vencimientos/${id}`, req);
  }

  eliminarVencimiento(id: number, usuario = 'SISTEMA') {
    return this.http.delete(`${this.base}/vencimientos/${id}?usuario=${encodeURIComponent(usuario)}`);
  }

  // Planes
  planes(busqueda?: string) {
    const params = busqueda ? new HttpParams().set('busqueda', busqueda) : {};
    return this.http.get<TipoPlanPago[]>(`${this.base}/planes-pago`, { params });
  }

  plan(id: number) {
    return this.http.get<TipoPlanPago>(`${this.base}/planes-pago/${id}`);
  }

  crearPlan(req: object) {
    return this.http.post<{ id: number }>(`${this.base}/planes-pago`, req);
  }

  actualizarPlan(id: number, req: object) {
    return this.http.put(`${this.base}/planes-pago/${id}`, req);
  }

  eliminarPlan(id: number, usuario = 'SISTEMA') {
    return this.http.delete(`${this.base}/planes-pago/${id}?usuario=${encodeURIComponent(usuario)}`);
  }

  detallesPlan(idPlan: number) {
    return this.http.get<TipoPlanPagoDetalle[]>(`${this.base}/planes-pago/${idPlan}/detalles`);
  }

  crearDetallePlan(idPlan: number, req: object) {
    return this.http.post<{ id: number }>(`${this.base}/planes-pago/${idPlan}/detalles`, req);
  }

  eliminarDetallePlan(id: number, usuario = 'SISTEMA') {
    return this.http.delete(`${this.base}/planes-pago/detalles/${id}?usuario=${encodeURIComponent(usuario)}`);
  }

  // OBSA Modalidades
  obsaModalidades() {
    return this.http.get<ObsaModalidad[]>(`${this.base}/obsa-modalidades`);
  }

  // Intereses
  intereses(idTipoTributo?: number) {
    const params = idTipoTributo ? new HttpParams().set('idTipoTributo', idTipoTributo) : {};
    return this.http.get<ConfigInteres[]>(`${this.base}/intereses`, { params });
  }

  interes(id: number) {
    return this.http.get<ConfigInteres>(`${this.base}/intereses/${id}`);
  }

  crearInteres(req: object) {
    return this.http.post<{ id: number }>(`${this.base}/intereses`, req);
  }

  actualizarInteres(id: number, req: object) {
    return this.http.put(`${this.base}/intereses/${id}`, req);
  }

  eliminarInteres(id: number, usuario = 'SISTEMA') {
    return this.http.delete(`${this.base}/intereses/${id}?usuario=${encodeURIComponent(usuario)}`);
  }

  // Parametrica Tributos
  parametricaTributos() {
    return this.http.get<ParametricaTributo[]>(`${this.base}/parametrica-tributos`);
  }

  crearParametrica(req: object) {
    return this.http.post<{ id: number }>(`${this.base}/parametrica-tributos`, req);
  }

  eliminarParametrica(id: number, usuario = 'SISTEMA') {
    return this.http.delete(`${this.base}/parametrica-tributos/${id}?usuario=${encodeURIComponent(usuario)}`);
  }

  // Vinculación Conceptos
  conceptosVencimientos(idTipoTributo?: number, ejercicio?: string) {
    let params = new HttpParams();
    if (idTipoTributo) params = params.set('idTipoTributo', idTipoTributo);
    if (ejercicio)     params = params.set('ejercicio', ejercicio);
    return this.http.get<ConceptoVencimiento[]>(`${this.base}/conceptos-vencimientos`, { params });
  }

  crearConceptoVencimiento(req: object) {
    return this.http.post<{ id: number }>(`${this.base}/conceptos-vencimientos`, req);
  }

  eliminarConceptoVencimiento(id: number, usuario = 'SISTEMA') {
    return this.http.delete(`${this.base}/conceptos-vencimientos/${id}?usuario=${encodeURIComponent(usuario)}`);
  }

  // Clone por año
  clonarVencimientos(ejercicioOrigen: string, ejercicioDestino: string, idTipoTributo?: number) {
    return this.http.post<{ insertados: number }>(`${this.base}/vencimientos/clonar`,
      { ejercicioOrigen, ejercicioDestino, idTipoTributo: idTipoTributo ?? null });
  }

  clonarConceptosAnio(ejercicioOrigen: string, ejercicioDestino: string, idTipoTributo?: number) {
    return this.http.post<{ insertados: number }>(`${this.base}/conceptos-anio/clonar`,
      { ejercicioOrigen, ejercicioDestino, idTipoTributo: idTipoTributo ?? null });
  }

  // DevengamientoV2
  v2Estado(idJurisdiccion = 1, idTipoTributo?: number) {
    let params = new HttpParams().set('idJurisdiccion', idJurisdiccion);
    if (idTipoTributo) params = params.set('idTipoTributo', idTipoTributo);
    return this.http.get<EstadoDevengamiento | null>(`${this.base}/v2/estado`, { params });
  }

  v2Log(idJurisdiccion = 1, take = 20) {
    return this.http.get<LogDevengamiento[]>(`${this.base}/v2/log?idJurisdiccion=${idJurisdiccion}&take=${take}`);
  }

  v2Ejecutar(req: { idJurisdiccion: number; idTipoTributo: number; ejercicio: string; usuario: string }) {
    return this.http.post<{ ok: boolean; mensaje: string }>(`${this.base}/v2/ejecutar`, req);
  }
}
