import { Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { HttpClient } from '@angular/common/http';
import { signal } from '@angular/core';
import { environment } from '../../../../../environments/environment';
import { Persona } from '../../../../core/services/tributaria.service';

@Component({
  selector: 'app-persona-dialog',
  standalone: true,
  imports: [
    ReactiveFormsModule, MatDialogModule, MatFormFieldModule,
    MatInputModule, MatButtonModule, MatIconModule,
  ],
  template: `
    <h2 mat-dialog-title>
      <mat-icon>{{ data ? 'edit' : 'person_add' }}</mat-icon>
      {{ data ? 'Editar' : 'Nueva' }} Persona
    </h2>

    <mat-dialog-content [formGroup]="form">
      <div class="form-grid">
        <mat-form-field appearance="outline">
          <mat-label>Apellido</mat-label>
          <input matInput formControlName="apellido" />
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Nombre</mat-label>
          <input matInput formControlName="nombre" />
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Tipo Documento</mat-label>
          <select matNativeControl formControlName="tipoDocumento">
            <option value="DNI">DNI</option>
            <option value="LC">LC</option>
            <option value="LE">LE</option>
            <option value="PAS">Pasaporte</option>
            <option value="CI">CI</option>
          </select>
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Documento</mat-label>
          <input matInput formControlName="documento" />
        </mat-form-field>
        <mat-form-field appearance="outline" class="full-width">
          <mat-label>CUIT / CUIL</mat-label>
          <input matInput formControlName="cuitCuil" placeholder="20123456789" />
        </mat-form-field>
        <mat-form-field appearance="outline" class="full-width">
          <mat-label>Domicilio</mat-label>
          <input matInput formControlName="domicilio" />
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Localidad</mat-label>
          <input matInput formControlName="localidad" />
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Código Postal</mat-label>
          <input matInput formControlName="codigoPostal" />
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Teléfono</mat-label>
          <input matInput formControlName="telefono" />
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Email</mat-label>
          <input matInput formControlName="email" type="email" />
        </mat-form-field>
      </div>

      @if (error()) {
        <div class="dialog-error">{{ error() }}</div>
      }
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>Cancelar</button>
      <button class="save-btn" (click)="guardar()" [disabled]="loading() || form.invalid">
        {{ loading() ? 'Guardando…' : 'Guardar' }}
      </button>
    </mat-dialog-actions>
  `,
  styles: [`
    h2[mat-dialog-title] { display:flex; align-items:center; gap:8px; }
    mat-dialog-content { min-width: 540px; padding-top: 8px !important; }
    .form-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 4px 16px;
      .full-width { grid-column: 1 / -1; }
    }
    .dialog-error {
      background:#FFEBEE; color:#E74C3C; border-radius:4px;
      padding:8px 12px; font-size:13px; margin-top:4px;
    }
    .save-btn { height:36px; padding:0 20px; background:var(--color-primary); color:#fff;
                border:none; border-radius:4px; font-size:14px; font-weight:500; cursor:pointer;
                &:disabled { opacity:.55; cursor:not-allowed; } }
  `],
})
export class PersonaDialogComponent {
  private fb     = inject(FormBuilder);
  private http   = inject(HttpClient);
  private ref    = inject(MatDialogRef<PersonaDialogComponent>);
  data: Persona | null = inject(MAT_DIALOG_DATA);

  loading = signal(false);
  error   = signal('');

  form = this.fb.nonNullable.group({
    apellido:      [this.data?.apellido      ?? '', Validators.required],
    nombre:        [this.data?.nombre        ?? '', Validators.required],
    tipoDocumento: [this.data?.tipoDocumento ?? 'DNI', Validators.required],
    documento:     [this.data?.documento     ?? '', Validators.required],
    cuitCuil:      [this.data?.cuitCuil      ?? ''],
    domicilio:     [this.data?.domicilio     ?? ''],
    localidad:     [this.data?.localidad     ?? ''],
    codigoPostal:  [(this.data as any)?.codigoPostal ?? ''],
    telefono:      [this.data?.telefono      ?? ''],
    email:         [this.data?.email         ?? ''],
  });

  guardar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.error.set('');
    const base = `${environment.apiUrl}/personas`;
    const body = { ...this.form.getRawValue(), identificador: this.data?.identificador };

    const req$ = this.data
      ? this.http.put(`${base}/${this.data.identificador}`, body)
      : this.http.post<{ identificador: string }>(base, body);

    req$.subscribe({
      next: (res) => this.ref.close(res ?? true),
      error: () => { this.error.set('Error al guardar. Verificá los datos.'); this.loading.set(false); },
    });
  }
}
