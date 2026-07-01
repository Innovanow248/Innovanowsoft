import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { shareReplay } from 'rxjs/operators';
import { environment } from '../../../environments/environment';

export interface Persona {
  identificador: string;
  apellido: string;
  nombre: string;
  cuitCuil: string;
  documento: string;
  tipoDocumento: string;
  domicilio: string;
  localidad: string;
  telefono: string;
  email: string;
}

export interface BienPadron {
  idBien: string;
  tipoBien: string;
  claveBien: string;
  activo: string;
  situacionDeuda: string;
  montoDeudaActualizado: number;
  descripcion: string | null;
  nombreFantasia: string | null;
  clasificacion: string | null;
  rubro: string | null;
  fechaBaja: string | null;
}

export interface ComercioDetalle {
  idComercioIndustria: string;
  nombreFantasia: string;
  nombreSociedad: string;
  tipoSociedad: string;
  cuit: string;
  ingresosBrutos: string;
  calle: string;
  numeracionCalle: string;
  barrio: string;
  resolucionHabilitacion: string;
  alquilerDesde: string | null;
  alquilerHasta: string | null;
  telefono: string;
  telefonoMovil: string;
  email: string;
  legajo: string;
  nroLicencia: string;
  capitalDeclarado: number | null;
  personalOcupado: number | null;
}

export interface RubroComercio {
  anoRubros: string;
  codigoRubro: string;
  concepto: string;
  principal: string;
  fechaAlta: string | null;
  fechaCese: string | null;
}

export interface Sucursal {
  idComercioIndustria: string;
  nroSucursal: string;
  nombreFantasia: string;
  calle: string;
  numeracionCalle: string;
  barrio: string;
  resolucionHabilitacion: string;
  fechaHabilitacion: string | null;
  fechaAlta: string | null;
  fechaBaja: string | null;
  observaciones: string;
  otraJurisdiccion: string;
}

export interface DeudaResumen {
  tipoBien: string;
  montoHistorico: number;
  montoActualizado: number;
  fechaActualizacion: string;
}

export interface TipoBien {
  codigoTipoBien: string;
  concepto: string;
}

export interface PlanPago {
  tipoBien: string;
  tipoPlan: string;
  designacionPlan: string;
  cantidadCuotas: number;
}

export interface BienPadronDetalle {
  idBien: string;
  tipoBien: string;
  conceptoBien: string;
  claveBien: string;
  identificador: string;
  apellido: string;
  nombre: string;
  cuitCuil: string;
  activo: string;
  situacionDeuda: string;
  montoDeudaActualizado: number;
  tipoPlan: string;
  exencion: string;
}

export interface DeudaContribuyente {
  tipoBien: string;
  claveBien: string;
  nroInterno: string;
  periodo: string;
  estadoDeuda: string;
  capitalFacturado: number;
  deudaTotalActualizada: number;
  imp1Vence: number;
  fechaVencimiento1: string;
  imp2Vence: number;
  fechaVencimiento2: string;
  imp3Vence: number;
  fechaVencimiento3: string;
}

@Injectable({ providedIn: 'root' })
export class TributariaService {
  private http = inject(HttpClient);
  private base = `${environment.apiUrl}/tributaria`;

  buscar(p: { cuit?: string; documento?: string; apellido?: string; id?: string; tipoBienes?: string[] }) {
    let params = new HttpParams();
    if (p.cuit)       params = params.set('cuit',      p.cuit);
    if (p.documento)  params = params.set('documento', p.documento);
    if (p.apellido)   params = params.set('apellido',  p.apellido);
    if (p.id)         params = params.set('id',        p.id);
    p.tipoBienes?.forEach(t => params = params.append('tipoBienes', t));
    return this.http.get<any>(`${this.base}/buscar`, { params });
  }

  bienes(identificador: string) {
    return this.http.get<BienPadron[]>(`${this.base}/contribuyente/${identificador}/bienes`);
  }

  deuda(identificador: string) {
    return this.http.get<DeudaContribuyente[]>(`${this.base}/contribuyente/${identificador}/deuda`);
  }

  resumenDeuda(identificador: string) {
    return this.http.get<DeudaResumen[]>(`${this.base}/contribuyente/${identificador}/deuda/resumen`);
  }

  readonly tiposBien$ = this.http.get<TipoBien[]>(`${this.base}/tipos-bien`).pipe(shareReplay(1));

  tiposBien() {
    return this.tiposBien$;
  }

  planes(tipoBien: string) {
    return this.http.get<PlanPago[]>(`${this.base}/planes/${tipoBien}`);
  }

  padron(params: Record<string, string | number>) {
    return this.http.get<{ items: BienPadronDetalle[]; total: number }>(`${this.base}/padron`, { params: params as any });
  }

  // ── ALTAS ──────────────────────────────────────────────────────────────

  altaPadron(req: any) {
    return this.http.post<{ idBien: string }>(`${this.base}/padron`, req);
  }

  altaAutomotor(idBien: string, req: any) {
    return this.http.post(`${this.base}/padron/${idBien}/automotor`, req);
  }

  altaCatastro(idBien: string, req: any) {
    return this.http.post(`${this.base}/padron/${idBien}/catastro`, req);
  }

  altaComercio(idBien: string, req: any) {
    return this.http.post(`${this.base}/padron/${idBien}/comercio`, req);
  }

  // ── MODIFICACIONES ─────────────────────────────────────────────────────

  bajarBien(idBien: string, tipoBien: string) {
    return this.http.put(`${this.base}/padron/${idBien}/baja?tipoBien=${tipoBien}`, {});
  }

  cambiarTitular(idBien: string, tipoBien: string, nuevoIdentificador: string) {
    return this.http.put(`${this.base}/padron/${idBien}/titular?tipoBien=${tipoBien}`,
      { nuevoIdentificador });
  }

  // ── COBRO ──────────────────────────────────────────────────────────────

  registrarCobro(nroInterno: string, fechaPago: string) {
    return this.http.post<{ codErr: string; mensaje: string; exitoso: boolean }>(
      `${this.base}/cobro`, { nroInterno, fechaPago });
  }

  // ── PORTAL WEB ─────────────────────────────────────────────────────────

  altaPortalWeb(identificador: string, password: string, habilitado = true) {
    return this.http.post(
      `${environment.apiUrl}/personas/${identificador}/portal`,
      { password, habilitado });
  }

  // ── REFERENCIA ─────────────────────────────────────────────────────────

  tasas() {
    return this.http.get<any[]>(`${this.base}/referencia/tasas`);
  }

  crearTasa(body: any) {
    return this.http.post(`${this.base}/referencia/tasas`, body);
  }

  actualizarTasa(body: any) {
    return this.http.put(`${this.base}/referencia/tasas`, body);
  }

  eliminarTasa(interes: string, fecha: any) {
    const f = new Date(fecha).toISOString().substring(0, 10);
    return this.http.delete(`${this.base}/referencia/tasas?interes=${interes}&fecha=${f}`);
  }

  anosValuacion() {
    return this.http.get<string[]>(`${this.base}/referencia/valuacion-automotores/anos`);
  }

  valuacionAutomotores(ano?: string, marca?: string, modelo?: string) {
    const p = new URLSearchParams();
    if (ano)    p.set('ano', ano);
    if (marca)  p.set('marca', marca);
    if (modelo) p.set('modelo', modelo);
    const qs = p.toString() ? '?' + p.toString() : '';
    return this.http.get<any[]>(`${this.base}/referencia/valuacion-automotores${qs}`);
  }

  marcasAutomotores(ano: string) {
    return this.http.get<string[]>(`${this.base}/referencia/valuacion-automotores/marcas?ano=${encodeURIComponent(ano)}`);
  }

  modelosAutomotores(ano: string, marca: string) {
    return this.http.get<string[]>(
      `${this.base}/referencia/valuacion-automotores/modelos?ano=${encodeURIComponent(ano)}&marca=${encodeURIComponent(marca)}`);
  }

  crearValuacion(body: any) {
    return this.http.post(`${this.base}/referencia/valuacion-automotores`, body);
  }

  actualizarValuacion(body: any) {
    return this.http.put(`${this.base}/referencia/valuacion-automotores`, body);
  }

  eliminarValuacion(ano: string, cip: string, modelo: number) {
    return this.http.delete(
      `${this.base}/referencia/valuacion-automotores?ano=${ano}&cip=${encodeURIComponent(cip)}&modelo=${modelo}`);
  }

  // ── PROPIETARIOS INMUEBLE ──────────────────────────────────────────────
  propietarios(idBien: string) {
    return this.http.get<any[]>(`${this.base}/padron/${idBien}/propietarios`);
  }

  agregarPropietario(idBien: string, body: { identificador: string; porcentajeAcciones?: number }) {
    return this.http.post(`${this.base}/padron/${idBien}/propietarios`, body);
  }

  eliminarPropietario(idBien: string, identificador: string) {
    return this.http.delete(`${this.base}/padron/${idBien}/propietarios/${identificador}`);
  }

  // ── MEJORAS CATASTRO ───────────────────────────────────────────────────
  mejoras(idCatastro: string) {
    return this.http.get<any[]>(`${this.base}/catastro/${idCatastro}/mejoras`);
  }

  agregarMejora(idCatastro: string, body: any) {
    return this.http.post<{ clave: number }>(`${this.base}/catastro/${idCatastro}/mejoras`, body);
  }

  eliminarMejora(idCatastro: string, clave: number) {
    return this.http.delete(`${this.base}/catastro/${idCatastro}/mejoras/${clave}`);
  }

  // ── VARIABLES PARAMÉTRICAS ─────────────────────────────────────────────
  variables(idBien: string) {
    return this.http.get<any[]>(`${this.base}/padron/${idBien}/variables`);
  }

  catastroDetalle(idBien: string) {
    return this.http.get<any>(`${this.base}/catastro/${idBien}/detalle`);
  }

  // ── COMERCIO ───────────────────────────────────────────────────────────
  comercioDetalle(idBien: string) {
    return this.http.get<ComercioDetalle>(`${this.base}/comercio/${idBien}/detalle`);
  }

  rubrosComercio(idBien: string) {
    return this.http.get<RubroComercio[]>(`${this.base}/comercio/${idBien}/rubros`);
  }

  sucursales(idBien: string) {
    return this.http.get<Sucursal[]>(`${this.base}/comercio/${idBien}/sucursales`);
  }

  crearSucursal(idBien: string, body: any) {
    return this.http.post(`${this.base}/comercio/${idBien}/sucursales`, body);
  }

  bajarSucursal(idBien: string, nroSucursal: string) {
    return this.http.delete(`${this.base}/comercio/${idBien}/sucursales/${nroSucursal}`);
  }
}
