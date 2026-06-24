import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { AuthService } from '../services/auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  // Portal usa su propio token; no sobreescribir si ya viene Authorization
  if (req.headers.has('Authorization')) return next(req);
  const auth  = inject(AuthService);
  const token = auth.getToken();
  if (token) {
    req = req.clone({ setHeaders: { Authorization: `Bearer ${token}` } });
  }
  return next(req).pipe(
    catchError(err => {
      // Solo cerrar sesión si había token activo (sesión expirada), no en el request de login
      if (err.status === 401 && token) {
        auth.logout(); // logout() ya navega a /login internamente
      }
      return throwError(() => err);
    })
  );
};
