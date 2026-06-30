import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

export interface SesionCajero {
  cajero: string;
  fechaCaja: string;
  nroSession: string;
  cerrado: boolean;
  transferido: boolean;
}

export interface FormaPagoItem {
  tipoMoneda: 'EF' | 'CH' | 'TJ';
  importe: number;
  nroCheque?: string;
  banco?: string;
  fechaAcred?: string;
  tipoTarjeta?: string;
  nroTarjeta?: string;
  autorizacion?: string;
  nroCupon?: string;
  planTarjeta?: string;
}

export interface CobroVentanillaRequest {
  cajero: string;
  fechaCaja: string;
  nroSession: string;
  nrosInternos: string[];
  fechaPago: string;
  formasPago: FormaPagoItem[];
  impVuelto: number;
}

export interface CajeroUsuario {
  cajero: string;
  descripcion: string;
  habilitado: boolean;
  nivel: number;
  esEncargado: boolean;
}

export interface ResumenSesion {
  cajero: string;
  fechaCaja: string;
  nroSession: string;
  cerrado: boolean;
  cantOperaciones: number;
  totalEfectivo: number;
  totalCheque: number;
  totalTarjeta: number;
  totalGeneral: number;
}

@Injectable({ providedIn: 'root' })
export class CajaService {
  private http = inject(HttpClient);
  private base = `${environment.apiUrl}/caja`;

  abrirSesion(cajero: string, fechaCaja: string) {
    return this.http.post<SesionCajero>(`${this.base}/sesion/abrir`, { cajero, fechaCaja });
  }

  obtenerSesionActiva() {
    return this.http.get<SesionCajero>(`${this.base}/sesion/activa`);
  }

  registrarCobro(req: CobroVentanillaRequest) {
    return this.http.post<{ exitoso: boolean; mensaje: string; nroOperacion: string }>(`${this.base}/cobro`, req);
  }

  resumenSesion(cajero: string, fecha: string, nroSession: string) {
    return this.http.get<ResumenSesion>(`${this.base}/sesion/${cajero}/${fecha}/${nroSession}/resumen`);
  }

  cerrarSesion(cajero: string, fechaCaja: string, nroSession: string, diferenciaCierre: number) {
    return this.http.post(`${this.base}/sesion/cerrar`, { cajero, fechaCaja, nroSession, diferenciaCierre });
  }

  listarCajeros() {
    return this.http.get<CajeroUsuario[]>(`${this.base}/cajeros`);
  }

  crearCajero(cajero: string, descripcion: string, nivel: number) {
    return this.http.post<{ mensaje: string }>(`${this.base}/cajeros`, { cajero, descripcion, nivel });
  }

  toggleHabilitado(cajero: string, habilitado: boolean) {
    return this.http.put(`${this.base}/cajeros/${cajero}/habilitado`, habilitado);
  }
}
