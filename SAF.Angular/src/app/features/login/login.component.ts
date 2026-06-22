import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    MatFormFieldModule, MatInputModule, MatButtonModule,
    MatIconModule, MatProgressSpinnerModule,
  ],
  template: `
    <div class="login-page">
      <div class="login-card">
        <div class="login-card__logo">
          <span class="logo-primary">SAF</span><span class="logo-accent">·FIN</span>
        </div>
        <p class="login-card__subtitle">Sistema de Administración Financiera</p>

        <form [formGroup]="form" (ngSubmit)="submit()" class="login-form">
          <mat-form-field appearance="outline">
            <mat-label>Usuario</mat-label>
            <mat-icon matPrefix>person</mat-icon>
            <input matInput formControlName="usuario" autocomplete="username" />
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>Contraseña</mat-label>
            <mat-icon matPrefix>lock</mat-icon>
            <input matInput formControlName="password"
                   [type]="showPwd() ? 'text' : 'password'"
                   autocomplete="current-password" />
            <button mat-icon-button matSuffix type="button"
                    (click)="showPwd.set(!showPwd())">
              <mat-icon>{{ showPwd() ? 'visibility_off' : 'visibility' }}</mat-icon>
            </button>
          </mat-form-field>

          @if (error()) {
            <div class="login-error">{{ error() }}</div>
          }

          <button mat-flat-button class="login-btn" type="submit"
                  [disabled]="loading() || form.invalid">
            @if (loading()) { <mat-spinner diameter="20" /> } @else { Ingresar }
          </button>
        </form>
      </div>
      <div class="login-credit">
        <span class="logo-credit-innova">Innova</span><span class="logo-credit-now">now</span>
      </div>
    </div>
  `,
  styles: [`
    .login-page {
      min-height: 100vh;
      background: var(--color-bg);
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 24px;
    }
    .login-card {
      background: var(--color-surface);
      border-radius: var(--radius-lg);
      border: 1px solid var(--color-border);
      box-shadow: var(--shadow-elevated);
      padding: 40px 48px;
      width: 100%;
      max-width: 400px;
      &__logo {
        font-size: 32px;
        font-weight: 900;
        text-align: center;
        margin-bottom: 4px;
        .logo-primary { color: var(--color-primary); }
        .logo-accent  { color: var(--color-accent); }
      }
      &__subtitle {
        text-align: center;
        color: var(--color-text-muted);
        font-size: 13px;
        margin: 0 0 28px 0;
      }
    }
    .login-form {
      display: flex;
      flex-direction: column;
      gap: 4px;
      mat-form-field { width: 100%; }
    }
    .login-error {
      background: #fef2f2;
      color: #b91c1c;
      padding: 8px 12px;
      border-radius: 4px;
      font-size: 13px;
      text-align: center;
    }
    .login-btn {
      height: 44px;
      background: var(--color-primary) !important;
      color: #fff !important;
      font-weight: 600;
      font-size: 15px;
      margin-top: 8px;
    }
    .login-credit {
      font-size: 12px;
      font-weight: 700;
      .logo-credit-innova { color: var(--color-primary); }
      .logo-credit-now    { color: var(--color-accent); }
    }
  `]
})
export class LoginComponent {
  private fb     = inject(FormBuilder);
  private auth   = inject(AuthService);
  private router = inject(Router);

  showPwd = signal(false);
  loading = signal(false);
  error   = signal('');

  form = this.fb.nonNullable.group({
    usuario:  ['', Validators.required],
    password: ['', Validators.required],
  });

  submit() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.error.set('');
    this.auth.login(this.form.getRawValue()).subscribe({
      next: () => this.router.navigate(['/dashboard']),
      error: () => {
        this.error.set('Usuario o contraseña incorrectos.');
        this.loading.set(false);
      }
    });
  }
}
