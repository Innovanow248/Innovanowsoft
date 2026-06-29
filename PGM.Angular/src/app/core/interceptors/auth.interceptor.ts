import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { AuthService } from '../services/auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  // Portal usa su propio token; no sobreescribir si ya viene Authorization
  if (req.headers.has('Authorization')) return next(req);
  const auth   = inject(AuthService);
  const router = inject(Router);
  const token  = auth.getToken();
  if (token) {
    req = req.clone({ setHeaders: { Authorization: `Bearer ${token}` } });
  }
  return next(req).pipe(
    catchError(err => {
      // Token expirado: logout preservando la URL actual para volver después del login
      if (err.status === 401 && token) {
        auth.logout(router.url);
      }
      return throwError(() => err);
    })
  );
};
