import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { NgIf } from '@angular/common';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { TributariaService, Persona } from '../../../../core/services/tributaria.service';

@Component({
  selector: 'app-cambio-titular-dialog',
  standalone: true,
  imports: [
    ReactiveFormsModule, NgIf,
    MatDialogModule, MatFormFieldModule, MatInputModule,
    MatButtonModule, MatIconModule,
  ],
  template: `
<h2 mat-dialog-title><mat-icon>swap_horiz</mat-icon> Cambio de Titularidad</h2>

<mat-dialog-content>
  <p class="info-text">
    Bien: <strong>{{ data.tipoBien }}</strong> — <strong>{{ data.claveBien }}</strong><br>
    Titular actual: <strong>{{ data.identificadorActual }}</strong>
  </p>

  <form [formGroup]="form" class="buscar-row">
    <mat-form-field appearance="outline" style="flex:1">
      <mat-label>ID del nuevo titular</mat-label>
      <input matInput formControlName="nuevoId"
             placeholder="CUIT, DNI o ID"
             (keyup.enter)="buscarPersona()" />
    </mat-form-field>
    <button type="button" class="btn-search" (click)="buscarPersona()" [disabled]="buscando()">
      <mat-icon>search</mat-icon>
    </button>
  </form>

  @if (personaEncontrada()) {
    <div class="persona-card">
      <mat-icon>person</mat-icon>
      <div>
        <div><strong>{{ personaEncontrada()!.apellido }}, {{ personaEncontrada()!.nombre }}</strong></div>
        <div style="font-size:12px;color:#64748b">ID: {{ personaEncontrada()!.identificador }} — CUIT: {{ personaEncontrada()!.cuitCuil }}</div>
      </div>
    </div>
  }

  @if (error()) {
    <div class="msg-err">{{ error() }}</div>
  }
</mat-dialog-content>

<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-action" (click)="confirmar()"
          [disabled]="!personaEncontrada() || loading()">
    {{ loading() ? 'Guardando…' : 'Confirmar cambio' }}
  </button>
</mat-dialog-actions>
`,
  styles: [`
    mat-dialog-content { min-width: 420px; }
    .info-text { font-size: 14px; color: #475569; background: #f8fafc;
                 border-radius: 6px; padding: 10px 14px; margin-bottom: 16px; line-height: 1.7; }
    .buscar-row { display: flex; gap: 8px; align-items: flex-start; }
    .btn-search { height: 56px; width: 56px; flex-shrink: 0; background: #e2e8f0;
                  border: none; border-radius: 4px; cursor: pointer; display: flex;
                  align-items: center; justify-content: center;
                  &:hover { background: #cbd5e1; }
                  &:disabled { opacity: .55; cursor: not-allowed; } }
    .persona-card { display: flex; align-items: center; gap: 12px; background: #f0fdf4;
                    border: 1px solid #bbf7d0; border-radius: 6px; padding: 10px 14px; }
    .msg-err { background: #fef2f2; color: #b91c1c; padding: 8px 12px; border-radius: 4px;
               font-size: 13px; margin-top: 8px; }
    .btn-action { height: 36px; padding: 0 20px; background: var(--color-primary); color: #fff;
                  border: none; border-radius: 4px; font-size: 14px; cursor: pointer;
                  &:disabled { opacity: .55; cursor: not-allowed; } }
  `],
})
export class CambioTitularDialogComponent {
  private svc = inject(TributariaService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<CambioTitularDialogComponent>);
  data: { idBien: string; tipoBien: string; claveBien: string; identificadorActual: string } = inject(MAT_DIALOG_DATA);

  loading           = signal(false);
  buscando          = signal(false);
  error             = signal('');
  personaEncontrada = signal<Persona | null>(null);

  form = this.fb.nonNullable.group({
    nuevoId: ['', Validators.required],
  });

  buscarPersona() {
    const val = this.form.value.nuevoId?.trim();
    if (!val) return;
    this.buscando.set(true);
    this.error.set('');
    this.personaEncontrada.set(null);

    const params = val.length === 11 ? { cuit: val } : { documento: val };

    this.svc.buscar(params).subscribe({
      next: (r: any) => {
        const p: Persona = r.persona ?? r;
        this.personaEncontrada.set(p);
        this.buscando.set(false);
      },
      error: () => { this.error.set('No se encontró persona con ese dato.'); this.buscando.set(false); },
    });
  }

  confirmar() {
    const p = this.personaEncontrada();
    if (!p) return;
    this.loading.set(true);
    this.svc.cambiarTitular(this.data.idBien, this.data.tipoBien, p.identificador).subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set('Error: ' + (e.error?.title ?? e.message)); this.loading.set(false); },
    });
  }
}
