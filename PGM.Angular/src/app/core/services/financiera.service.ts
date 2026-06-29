import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

export interface CuentaIngreso {
  anoIng: string;
  nroCtaIng: string;
  tipoCtaIng: string;
  designacion: string;
  presupuestoAutorizado: number;
  montoCobrado: number;
  montoDevengado: number;
}

export interface CuentaErogacion {
  anoEro: string;
  nroCtaEro: string;
  designacion: string;
  tipoCtaEro: string;
  presupuestoAutorizado: number;
  montoAfectado: number;
  montoComprometido: number;
  montoAPagar: number;
  montoPagado: number;
  disponible?: number;
}

export interface OrdenPago {
  tipoOpago: string;
  anoOpago: string;
  nroOpago: string;
  identificador: string;
  proveedor: string;
  cuitCuil: string;
  estadoOpago: string;
  montoAPagar: number;
  montoPagado: number;
  observaciones: string;
  fechaAprobacion: string;
}

export interface FacturaCompra {
  identificador: string;
  proveedor: string;
  cuitCuil: string;
  nroFactura: string;
  tipoComprobante: string;
  letraComprobante: string;
  fecha: string;
  totalFactura: number;
  netoGravado: number;
  iva: number;
  estado: string;
  ordenPago: string;
}

@Injectable({ providedIn: 'root' })
export class FinancieraService {
  private http = inject(HttpClient);
  private base = `${environment.apiUrl}/financiera`;

  presupuesto(ano: string) {
    return this.http.get<CuentaErogacion[]>(`${this.base}/presupuesto/${ano}`);
  }

  ordenesPago(ano: string, estado?: string, page = 0, pageSize = 100) {
    const params: any = { page, pageSize };
    if (estado) params['estado'] = estado;
    return this.http.get<{items: OrdenPago[], total: number}>(`${this.base}/ordenes-pago/${ano}`, { params });
  }

  facturasPorProveedor(identificador: string) {
    return this.http.get<FacturaCompra[]>(`${this.base}/proveedores/${identificador}/facturas`);
  }

  crearOrdenPago(ano: string, body: any) {
    return this.http.post<{nroOpago: string}>(`${this.base}/ordenes-pago/${ano}`, body);
  }

  cambiarEstadoOP(tipo: string, ano: string, nro: string, estado: string) {
    return this.http.put(`${this.base}/ordenes-pago/${tipo}/${ano}/${nro}/estado`, { estado });
  }

  crearFactura(identificador: string, body: any) {
    return this.http.post(`${this.base}/proveedores/${identificador}/facturas`, body);
  }

  ajustarPresupuesto(ano: string, nroCta: string, nuevoMonto: number) {
    return this.http.put(`${this.base}/presupuesto/${ano}/${nroCta}`, { nuevoMonto });
  }

  presupuestoIngresos(ano: string) {
    return this.http.get<CuentaIngreso[]>(`${this.base}/presupuesto-ingresos/${ano}`);
  }

  ordenPago(tipo: string, ano: string, nro: string) {
    return this.http.get<OrdenPago>(`${this.base}/ordenes-pago/${tipo}/${ano}/${nro}`);
  }

  facturasPorOrden(tipo: string, ano: string, nro: string) {
    return this.http.get<FacturaCompra[]>(`${this.base}/ordenes-pago/${tipo}/${ano}/${nro}/facturas`);
  }
}
