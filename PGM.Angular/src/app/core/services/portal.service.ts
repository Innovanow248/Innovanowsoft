import { Injectable, inject, signal } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Router } from '@angular/router';
import { tap } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface CiudadanoSession {
  token:         string;
  identificador: string;
  nombre:        string;
  apellido:      string;
}

const CITIZEN_TOKEN_KEY = 'pgm_citizen_token';
const CITIZEN_USER_KEY  = 'pgm_citizen_user';

@Injectable({ providedIn: 'root' })
export class PortalService {
  private http   = inject(HttpClient);
  private router = inject(Router);
  private base   = `${environment.apiUrl}/portal`;

  ciudadano = signal<CiudadanoSession | null>(this.loadSession());

  // ── Auth ─────────────────────────────────────────────────────────────────

  login(identificador: string, password: string) {
    return this.http.post<CiudadanoSession>(`${this.base}/login`, { identificador, password }).pipe(
      tap(res => {
        localStorage.setItem(CITIZEN_TOKEN_KEY, res.token);
        localStorage.setItem(CITIZEN_USER_KEY, JSON.stringify(res));
        this.ciudadano.set(res);
      })
    );
  }

  logout() {
    localStorage.removeItem(CITIZEN_TOKEN_KEY);
    localStorage.removeItem(CITIZEN_USER_KEY);
    this.ciudadano.set(null);
    this.router.navigate(['/portal']);
  }

  isLoggedIn() { return !!localStorage.getItem(CITIZEN_TOKEN_KEY); }

  // ── API calls — usa token ciudadano directamente (no el interceptor admin) ─

  private authHeaders() {
    const token = localStorage.getItem(CITIZEN_TOKEN_KEY) ?? '';
    return new HttpHeaders({ Authorization: `Bearer ${token}` });
  }

  perfil() {
    return this.http.get<any>(`${this.base}/perfil`, { headers: this.authHeaders() });
  }

  deuda() {
    return this.http.get<{ resumen: any[]; cuotas: any[] }>(
      `${this.base}/deuda`, { headers: this.authHeaders() });
  }

  pagar(nroInterno: string, fechaPago: string) {
    return this.http.post<{ codErr: string; mensaje: string; exitoso: boolean }>(
      `${this.base}/pagar`, { nroInterno, fechaPago },
      { headers: this.authHeaders() });
  }

  private loadSession(): CiudadanoSession | null {
    try { return JSON.parse(localStorage.getItem(CITIZEN_USER_KEY) ?? 'null'); }
    catch { return null; }
  }
}
