import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { environment } from '../../../environments/environment';

const API = environment.safApiUrl;

// ── Modelos ──────────────────────────────────────────────────────────────────
export interface CuentaErogacionSAF {
  anoEro: string;
  nroCtaEro: string;
  designacion: string;
  presupuestoAutorizado: number;
  montoAfectado: number;
  montoPagado: number;
}

export interface CompromisoSAF {
  tipoCompromiso: string;
  anoCompromiso: string;
  nroCompromiso: string;
  identificador: string;
  nombreProveedor: string;
  fechaCompromiso: string;
  concepto: string;
  montoComprometido: number;
  montoAPagar: number;
  montoPagado: number;
  estadoCompromiso: string;
}

export interface OrdenPagoSAF {
  tipoOpago: string;
  anoOpago: string;
  nroOpago: string;
  identificador: string;
  nombreProveedor: string;
  nroCta: string;
  anoEro: string;
  montoAPagar: number;
  montoPagado: number;
  estado: string;
  observaciones?: string;
  fechaMandato?: string;
}

export interface FacturaSAF {
  identificador: string;
  nombreProveedor: string;
  nroFactura: string;
  fecha: string;
  tipoComprobante: string;
  letraComprobante: string;
  totalFactura: number;
  netoGravado: number;
  iva: number;
  estado: string;
  tipoOpago?: string;
  anoOpago?: string;
  nroOpago?: string;
}

export interface ProveedorSAF {
  identificador: string;
  nombre: string;
  apellido: string;
  cuitCuil: string;
  email?: string;
  telefono?: string;
  tipoSociedad?: string;
  fechaAlta?: string;
  nroRegistro?: string;
}

export interface AreaSAF {
  idArea: number;
  codigo: string;
  descripcion: string;
  idAreaSuperior?: number;
}

export interface NotaPedidoSAF {
  tipoComprobante: string;
  anoComprobante: string;
  nroComprobante: string;
  fechaPedido?: string;
  areaSolicitante: string;
  concepto: string;
  estado: string;
  detalles: NotaPedidoDetalleSAF[];
}

export interface NotaPedidoDetalleSAF {
  cantidad: number;
  unidad: string;
  designacion: string;
  precioUnitario: number;
}

// ── Service ──────────────────────────────────────────────────────────────────
@Injectable({ providedIn: 'root' })
export class FinancieroSAFService {
  private http = inject(HttpClient);

  // Presupuesto
  presupuesto(ano: string) {
    return this.http.get<CuentaErogacionSAF[]>(`${API}/presupuesto/${ano}`);
  }
  ajustarPresupuesto(ano: string, nroCta: string, nuevoMonto: number) {
    return this.http.put(`${API}/presupuesto/${ano}/${nroCta}`, { nuevoMonto });
  }

  // Compromisos
  compromisos(ano: string, estado?: string, identificador?: string) {
    let p = new HttpParams();
    if (estado)        p = p.set('estado', estado);
    if (identificador) p = p.set('identificador', identificador);
    return this.http.get<CompromisoSAF[]>(`${API}/compromisos/${ano}`, { params: p });
  }
  crearCompromiso(ano: string, body: any) {
    return this.http.post<{ nro: string }>(`${API}/compromisos/${ano}`, body);
  }
  cambiarEstadoCompromiso(tipo: string, ano: string, nro: string, estado: string) {
    return this.http.put(`${API}/compromisos/${tipo}/${ano}/${nro}/estado`, { estado });
  }

  // Órdenes de Pago
  ordenesPago(ano: string, estado?: string, identificador?: string) {
    let p = new HttpParams();
    if (estado)        p = p.set('estado', estado);
    if (identificador) p = p.set('identificador', identificador);
    return this.http.get<OrdenPagoSAF[]>(`${API}/ordenes-pago/${ano}`, { params: p });
  }
  crearOrdenPago(ano: string, body: any) {
    return this.http.post<{ nro: string }>(`${API}/ordenes-pago/${ano}`, body);
  }
  cambiarEstadoOP(tipo: string, ano: string, nro: string, estado: string) {
    return this.http.put(`${API}/ordenes-pago/${tipo}/${ano}/${nro}/estado`, { estado });
  }

  // Facturas
  facturas(year?: number, identificador?: string, estado?: string) {
    let p = new HttpParams();
    if (year)          p = p.set('year', year.toString());
    if (identificador) p = p.set('identificador', identificador);
    if (estado)        p = p.set('estado', estado);
    return this.http.get<FacturaSAF[]>(`${API}/facturas`, { params: p });
  }
  crearFactura(body: any) {
    return this.http.post(`${API}/facturas`, body);
  }
  facturasItems(identificador: string, nroFactura: string) {
    return this.http.get<any[]>(`${API}/facturas/items`, { params: { identificador, nroFactura } });
  }

  // Proveedores
  buscarProveedores(termino: string) {
    return this.http.get<ProveedorSAF[]>(`${API}/proveedores`, { params: { termino } });
  }

  // Áreas municipales
  getAreas() {
    return this.http.get<AreaSAF[]>(`${API}/areas`);
  }

  // Notas de Pedido
  notasPedido(ano: string, estado?: string) {
    let p = new HttpParams();
    if (estado) p = p.set('estado', estado);
    return this.http.get<NotaPedidoSAF[]>(`${API}/notas-pedido/${ano}`, { params: p });
  }
  crearNotaPedido(ano: string, body: any) {
    return this.http.post<{ nro: string }>(`${API}/notas-pedido/${ano}`, body);
  }
  cambiarEstadoNP(tipo: string, ano: string, nro: string, estado: string) {
    return this.http.put(`${API}/notas-pedido/${tipo}/${ano}/${nro}/estado`, { estado });
  }
}
