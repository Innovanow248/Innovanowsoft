import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
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
        <!-- Logo -->
        <div class="login-card__logo">
          <span class="logo-primary">PGM</span><span class="logo-accent">·GOB</span>
        </div>
        <p class="login-card__subtitle">Sistema de Gestión Municipal</p>

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
            @if (loading()) {
              <mat-spinner diameter="20" />
            } @else {
              Ingresar
            }
          </button>
        </form>
      </div>

      <!-- Crédito -->
      <div class="login-credit">
        <span class="logo-credit-innova">Innova</span><span class="logo-credit-now">now</span>
      </div>
    </div>
  `,
  styleUrl: './login.component.scss'
})
export class LoginComponent {
  private fb     = inject(FormBuilder);
  private auth   = inject(AuthService);
  private router = inject(Router);
  private route  = inject(ActivatedRoute);

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
      next: () => {
        const returnUrl = this.route.snapshot.queryParamMap.get('returnUrl') ?? '/dashboard';
        this.router.navigateByUrl(returnUrl);
      },
      error: () => {
        this.error.set('Usuario o contraseña incorrectos.');
        this.loading.set(false);
      }
    });
  }
}
