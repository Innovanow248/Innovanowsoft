import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { tap } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface LoginRequest  { usuario: string; password: string; }
export interface LoginResponse {
  token: string;
  usuario: string;
  grupo: string;
  identificador: string;
  permisos: string[];
}

const TOKEN_KEY = 'saf_token';
const USER_KEY  = 'saf_user';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private http   = inject(HttpClient);
  private router = inject(Router);

  currentUser = signal<LoginResponse | null>(this.loadUser());

  login(req: LoginRequest) {
    return this.http.post<LoginResponse>(`${environment.apiUrl}/auth/login`, req).pipe(
      tap(res => {
        localStorage.setItem(TOKEN_KEY, res.token);
        localStorage.setItem(USER_KEY, JSON.stringify(res));
        this.currentUser.set(res);
      })
    );
  }

  logout() {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    this.currentUser.set(null);
    this.router.navigate(['/login']);
  }

  getToken()   { return localStorage.getItem(TOKEN_KEY); }
  isLoggedIn() { return !!this.getToken(); }

  private loadUser(): LoginResponse | null {
    try { return JSON.parse(localStorage.getItem(USER_KEY) ?? 'null'); }
    catch { return null; }
  }
}
