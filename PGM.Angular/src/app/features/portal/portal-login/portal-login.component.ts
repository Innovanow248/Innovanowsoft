import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatIconModule } from '@angular/material/icon';
import { PortalService } from '../../../core/services/portal.service';

@Component({
  selector: 'app-portal-login',
  standalone: true,
  imports: [ReactiveFormsModule, MatFormFieldModule, MatInputModule, MatIconModule],
  template: `
<div class="portal-login">
  <div class="login-card">
    <div class="login-header">
      <div class="login-logo">
        <mat-icon class="logo-icon">location_city</mat-icon>
      </div>
      <h1>Portal Ciudadano</h1>
      <p>Municipalidad · Administración Tributaria</p>
    </div>

    <form [formGroup]="form" (ngSubmit)="ingresar()">
      <mat-form-field appearance="outline" class="full">
        <mat-label>CUIT / DNI</mat-label>
        <mat-icon matPrefix>badge</mat-icon>
        <input matInput formControlName="identificador" placeholder="Ej: 20236835015" autocomplete="username" />
      </mat-form-field>

      <mat-form-field appearance="outline" class="full">
        <mat-label>Contraseña</mat-label>
        <mat-icon matPrefix>lock</mat-icon>
        <input matInput [type]="showPass() ? 'text' : 'password'"
               formControlName="password" autocomplete="current-password" />
        <button mat-icon-button matSuffix type="button" (click)="showPass.set(!showPass())">
          <mat-icon>{{ showPass() ? 'visibility_off' : 'visibility' }}</mat-icon>
        </button>
      </mat-form-field>

      @if (error()) {
        <div class="login-error">
          <mat-icon>error_outline</mat-icon>
          {{ error() }}
        </div>
      }

      <button class="btn-ingresar" type="submit" [disabled]="form.invalid || loading()">
        {{ loading() ? 'Ingresando…' : 'Ingresar' }}
      </button>
    </form>

    <div class="login-footer">
      <mat-icon>info</mat-icon>
      Tu código de acceso fue asignado por la municipalidad.
    </div>
  </div>
</div>
`,
  styles: [`
    .portal-login {
      min-height: 100vh;
      background: linear-gradient(135deg, #1a3a5c 0%, #0f2235 60%, #1a3a5c 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px;
    }
    .login-card {
      background: #fff;
      border-radius: 16px;
      padding: 40px;
      width: 100%;
      max-width: 420px;
      box-shadow: 0 24px 64px rgba(0,0,0,0.3);
    }
    .login-header {
      text-align: center;
      margin-bottom: 32px;
    }
    .login-logo {
      width: 72px;
      height: 72px;
      border-radius: 50%;
      background: #1a3a5c;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 16px;
    }
    .logo-icon { color: #f5a623; font-size: 36px; width: 36px; height: 36px; }
    h1 { font-size: 22px; font-weight: 700; color: #1a3a5c; margin: 0 0 4px; }
    p  { font-size: 13px; color: #64748b; margin: 0; }
    .full { width: 100%; margin-bottom: 8px; }
    .login-error {
      display: flex; align-items: center; gap: 8px;
      background: #fef2f2; color: #b91c1c; border-radius: 8px;
      padding: 10px 14px; margin-bottom: 16px; font-size: 14px;
      mat-icon { font-size: 18px; }
    }
    .btn-ingresar {
      width: 100%; height: 48px;
      background: #1a3a5c; color: #fff;
      border: none; border-radius: 8px;
      font-size: 16px; font-weight: 600; cursor: pointer;
      transition: background .2s;
      &:hover:not(:disabled) { background: #243f5e; }
      &:disabled { opacity: .55; cursor: not-allowed; }
    }
    .login-footer {
      display: flex; align-items: center; gap: 6px;
      font-size: 12px; color: #94a3b8; margin-top: 24px;
      text-align: center; justify-content: center;
      mat-icon { font-size: 14px; }
    }
  `],
})
export class PortalLoginComponent {
  private svc    = inject(PortalService);
  private fb     = inject(FormBuilder);
  private router = inject(Router);

  loading  = signal(false);
  error    = signal('');
  showPass = signal(false);

  form = this.fb.nonNullable.group({
    identificador: ['', Validators.required],
    password:      ['', Validators.required],
  });

  constructor() {
    if (this.svc.isLoggedIn()) this.router.navigate(['/portal/dashboard']);
  }

  ingresar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.error.set('');
    const { identificador, password } = this.form.getRawValue();
    this.svc.login(identificador.trim(), password).subscribe({
      next: () => this.router.navigate(['/portal/dashboard']),
      error: e => {
        this.error.set(e.status === 401 ? 'Credenciales inválidas.' : 'Error al conectar con el servidor.');
        this.loading.set(false);
      },
    });
  }
}
