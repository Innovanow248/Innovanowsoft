import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { environment } from '../../../environments/environment';

export interface UsuarioAdmin {
  codigoUsuario:   string;
  codigoGrupo:     string;
  descripcion:     string;
  identificador:   string;
  fechaCaducacion: string | null;
  idArea:          number | null;
  permisos:        string[];
}

export interface GrupoItem {
  codigo:        string;
  totalUsuarios: number;
}

@Injectable({ providedIn: 'root' })
export class SeguridadService {
  private http = inject(HttpClient);
  private base = `${environment.apiUrl}/seguridad`;

  usuarios(busqueda?: string) {
    const params = busqueda ? new HttpParams().set('busqueda', busqueda) : {};
    return this.http.get<UsuarioAdmin[]>(`${this.base}/usuarios`, { params });
  }

  usuario(codigo: string) {
    return this.http.get<UsuarioAdmin>(`${this.base}/usuarios/${codigo}`);
  }

  crearUsuario(req: {
    codigoUsuario: string; password: string; codigoGrupo: string;
    descripcion: string; identificador?: string;
    fechaCaducacion?: string | null; permisos: string[];
  }) {
    return this.http.post(`${this.base}/usuarios`, req);
  }

  actualizarUsuario(codigo: string, req: {
    codigoGrupo: string; descripcion: string; identificador?: string;
    fechaCaducacion?: string | null; permisos: string[];
  }) {
    return this.http.put(`${this.base}/usuarios/${codigo}`, req);
  }

  cambiarPassword(codigo: string, nuevoPassword: string) {
    return this.http.put(`${this.base}/usuarios/${codigo}/password`, { nuevoPassword });
  }

  eliminarUsuario(codigo: string) {
    return this.http.delete(`${this.base}/usuarios/${codigo}`);
  }

  grupos() {
    return this.http.get<GrupoItem[]>(`${this.base}/grupos`);
  }

  procesos() {
    return this.http.get<string[]>(`${this.base}/procesos`);
  }
}
