import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { TributariaService } from '../../../../core/services/tributaria.service';

@Component({
  selector: 'app-portal-web-dialog',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    MatDialogModule, MatFormFieldModule, MatInputModule,
    MatButtonModule, MatIconModule,
  ],
  template: `
<h2 mat-dialog-title><mat-icon>language</mat-icon> Alta Portal Web</h2>

<mat-dialog-content>
  <p class="info-text">
    Contribuyente: <strong>{{ data.nombre }}</strong><br>
    ID: <strong>{{ data.identificador }}</strong>
  </p>
  <p style="font-size:13px;color:#64748b;margin-bottom:16px">
    Se creará o actualizará el acceso al portal web ciudadano.
    La contraseña se almacenará como hash MD5.
  </p>

  <form [formGroup]="form">
    <mat-form-field appearance="outline" class="full">
      <mat-label>Contraseña</mat-label>
      <input matInput [type]="mostrarPass() ? 'text' : 'password'" formControlName="password" />
      <button mat-icon-button matSuffix type="button" (click)="mostrarPass.set(!mostrarPass())">
        <mat-icon>{{ mostrarPass() ? 'visibility_off' : 'visibility' }}</mat-icon>
      </button>
    </mat-form-field>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Habilitado</mat-label>
      <select matNativeControl formControlName="habilitado">
        <option [value]="true">Sí</option>
        <option [value]="false">No</option>
      </select>
    </mat-form-field>
  </form>

  @if (error()) {
    <div class="msg-err">{{ error() }}</div>
  }
  @if (ok()) {
    <div class="msg-ok"><mat-icon>check_circle</mat-icon> Acceso configurado exitosamente.</div>
  }
</mat-dialog-content>

<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-action" (click)="guardar()" [disabled]="form.invalid || loading() || ok()">
    {{ loading() ? 'Guardando…' : 'Guardar' }}
  </button>
</mat-dialog-actions>
`,
  styles: [`
    mat-dialog-content { min-width: 380px; }
    .info-text { font-size: 14px; color: #475569; background: #f8fafc;
                 border-radius: 6px; padding: 10px 14px; margin-bottom: 16px; line-height: 1.7; }
    .full { width: 100%; }
    .msg-ok { background: #f0fdf4; color: #166534; padding: 10px 14px; border-radius: 6px;
              display: flex; align-items: center; gap: 8px; }
    .msg-err { background: #fef2f2; color: #b91c1c; padding: 8px 12px; border-radius: 4px;
               font-size: 13px; }
    .btn-action { height: 36px; padding: 0 20px; background: var(--color-primary); color: #fff;
                  border: none; border-radius: 4px; font-size: 14px; cursor: pointer;
                  &:disabled { opacity: .55; cursor: not-allowed; } }
  `],
})
export class PortalWebDialogComponent {
  private svc = inject(TributariaService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<PortalWebDialogComponent>);
  data: { identificador: string; nombre: string } = inject(MAT_DIALOG_DATA);

  loading    = signal(false);
  error      = signal('');
  ok         = signal(false);
  mostrarPass = signal(false);

  form = this.fb.nonNullable.group({
    password:   ['', [Validators.required, Validators.minLength(6)]],
    habilitado: [true],
  });

  guardar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.error.set('');
    const { password, habilitado } = this.form.getRawValue();
    this.svc.altaPortalWeb(this.data.identificador, password, habilitado).subscribe({
      next: () => { this.ok.set(true); this.loading.set(false); setTimeout(() => this.ref.close(true), 1200); },
      error: e => { this.error.set('Error: ' + (e.error?.title ?? e.message)); this.loading.set(false); },
    });
  }
}
