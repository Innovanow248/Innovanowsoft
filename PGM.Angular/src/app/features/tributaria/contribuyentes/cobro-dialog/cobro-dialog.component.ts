import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { CurrencyPipe, DatePipe } from '@angular/common';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { TributariaService, DeudaContribuyente } from '../../../../core/services/tributaria.service';

@Component({
  selector: 'app-cobro-dialog',
  standalone: true,
  imports: [
    ReactiveFormsModule, CurrencyPipe, DatePipe,
    MatDialogModule, MatFormFieldModule, MatInputModule,
    MatButtonModule, MatIconModule,
  ],
  template: `
<h2 mat-dialog-title><mat-icon>payments</mat-icon> Registrar Cobro</h2>

<mat-dialog-content>
  <!-- Detalle de la cuota -->
  <div class="cuota-card">
    <div class="cuota-row"><span>Período</span><strong>{{ data.cuota.periodo }}</strong></div>
    <div class="cuota-row"><span>Tipo bien</span><strong>{{ data.cuota.tipoBien }}</strong></div>
    <div class="cuota-row"><span>Clave</span><strong>{{ data.cuota.claveBien }}</strong></div>
    <div class="cuota-row"><span>Capital</span><strong>{{ data.cuota.capitalFacturado | currency:'ARS':'symbol':'1.2-2' }}</strong></div>
    <div class="cuota-row highlight"><span>Total actualizado</span><strong>{{ data.cuota.deudaTotalActualizada | currency:'ARS':'symbol':'1.2-2' }}</strong></div>
    <div class="cuota-row"><span>1° vencimiento</span><strong>{{ data.cuota.imp1Vence | currency:'ARS':'symbol':'1.2-2' }}</strong></div>
  </div>

  <form [formGroup]="form" style="margin-top:16px">
    <mat-form-field appearance="outline" class="full">
      <mat-label>Fecha de pago</mat-label>
      <input matInput type="date" formControlName="fechaPago" />
    </mat-form-field>
  </form>

  @if (resultado()) {
    <div [class]="resultado()!.exitoso ? 'msg-ok' : 'msg-err'">
      <mat-icon>{{ resultado()!.exitoso ? 'check_circle' : 'error' }}</mat-icon>
      {{ resultado()!.mensaje || (resultado()!.exitoso ? 'Cobro registrado exitosamente.' : 'Error al registrar cobro.') }}
    </div>
  }
</mat-dialog-content>

<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-action" (click)="cobrar()"
          [disabled]="form.invalid || loading() || resultado()?.exitoso">
    {{ loading() ? 'Procesando…' : 'Confirmar cobro' }}
  </button>
</mat-dialog-actions>
`,
  styles: [`
    mat-dialog-content { min-width: 420px; }
    .cuota-card { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px 16px; }
    .cuota-row { display: flex; justify-content: space-between; padding: 4px 0; font-size: 14px; }
    .cuota-row.highlight { margin-top: 4px; padding-top: 8px; border-top: 1px solid #e2e8f0;
                           font-size: 15px; }
    .full { width: 100%; }
    .msg-ok { background: #f0fdf4; color: #166534; padding: 10px 14px; border-radius: 6px;
              margin-top: 12px; display: flex; align-items: center; gap: 8px; }
    .msg-err { background: #fef2f2; color: #b91c1c; padding: 10px 14px; border-radius: 6px;
               margin-top: 12px; display: flex; align-items: center; gap: 8px; }
    .btn-action { height: 36px; padding: 0 20px; background: var(--color-primary); color: #fff;
                  border: none; border-radius: 4px; font-size: 14px; cursor: pointer;
                  &:disabled { opacity: .55; cursor: not-allowed; } }
  `],
})
export class CobroDialogComponent {
  private svc = inject(TributariaService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<CobroDialogComponent>);
  data: { cuota: DeudaContribuyente } = inject(MAT_DIALOG_DATA);

  loading  = signal(false);
  resultado = signal<{ exitoso: boolean; mensaje: string } | null>(null);

  form = this.fb.nonNullable.group({
    fechaPago: [new Date().toISOString().substring(0, 10), Validators.required],
  });

  cobrar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.svc.registrarCobro(this.data.cuota.nroInterno, this.form.value.fechaPago!).subscribe({
      next: r => {
        this.resultado.set({ exitoso: r.exitoso, mensaje: r.mensaje });
        this.loading.set(false);
        if (r.exitoso) setTimeout(() => this.ref.close(true), 1500);
      },
      error: e => {
        this.resultado.set({ exitoso: false, mensaje: e.error?.mensaje ?? 'Error al procesar cobro.' });
        this.loading.set(false);
      },
    });
  }
}
