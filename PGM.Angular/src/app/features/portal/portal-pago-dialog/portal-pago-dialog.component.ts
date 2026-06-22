import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { CurrencyPipe } from '@angular/common';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatIconModule } from '@angular/material/icon';
import { PortalService } from '../../../core/services/portal.service';

@Component({
  selector: 'app-portal-pago-dialog',
  standalone: true,
  imports: [
    ReactiveFormsModule, CurrencyPipe,
    MatDialogModule, MatFormFieldModule, MatInputModule, MatIconModule,
  ],
  template: `
<div class="dialog-header">
  <mat-icon class="dialog-icon">payments</mat-icon>
  <h2>Pagar cuota</h2>
</div>

<mat-dialog-content>
  <div class="cuota-resumen">
    <div class="cr-row"><span>Período</span><strong>{{ data.cuota.periodo }}</strong></div>
    <div class="cr-row"><span>Tipo</span><strong>{{ data.cuota.tipoBien }} — {{ data.cuota.claveBien }}</strong></div>
    <div class="cr-row"><span>Capital</span><strong>{{ data.cuota.capitalFacturado | currency:'ARS':'symbol':'1.2-2' }}</strong></div>
    <div class="cr-row total"><span>Total actualizado</span><strong class="monto">{{ data.cuota.deudaTotalActualizada | currency:'ARS':'symbol':'1.2-2' }}</strong></div>
    <div class="cr-row"><span>1° vencimiento</span><strong>{{ data.cuota.imp1Vence | currency:'ARS':'symbol':'1.2-2' }}</strong></div>
  </div>

  <div class="aviso">
    <mat-icon>info</mat-icon>
    El pago registrado en línea genera un comprobante que podrá presentar en las oficinas municipales.
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
      {{ resultado()!.exitoso
          ? '¡Pago registrado exitosamente! Guardá tu comprobante.'
          : (resultado()!.mensaje || 'Error al procesar el pago.') }}
    </div>
  }
</mat-dialog-content>

<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-confirmar" (click)="confirmar()"
          [disabled]="form.invalid || loading() || resultado()?.exitoso">
    {{ loading() ? 'Procesando…' : 'Confirmar pago' }}
  </button>
</mat-dialog-actions>
`,
  styles: [`
    .dialog-header {
      display: flex; align-items: center; gap: 12px;
      padding: 20px 24px 0; color: #1a3a5c;
      h2 { margin: 0; font-size: 20px; font-weight: 700; }
    }
    .dialog-icon { font-size: 28px; color: #1a3a5c; }
    mat-dialog-content { min-width: 380px; padding-top: 16px !important; }
    .cuota-resumen {
      background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px;
      padding: 12px 16px;
    }
    .cr-row {
      display: flex; justify-content: space-between; padding: 5px 0;
      font-size: 14px; border-bottom: 1px solid #f1f5f9;
      &:last-child { border-bottom: none; }
      span { color: #64748b; }
    }
    .cr-row.total { padding-top: 10px; font-size: 15px; }
    .monto { color: #dc2626; font-size: 18px; }
    .aviso {
      display: flex; align-items: flex-start; gap: 8px;
      background: #fffbeb; border: 1px solid #fcd34d; border-radius: 8px;
      padding: 10px 14px; font-size: 13px; color: #92400e; margin-top: 14px;
      mat-icon { font-size: 18px; flex-shrink: 0; margin-top: 1px; }
    }
    .full { width: 100%; }
    .msg-ok {
      background: #f0fdf4; color: #166534; padding: 12px 16px; border-radius: 8px;
      margin-top: 12px; display: flex; align-items: center; gap: 8px; font-weight: 600;
    }
    .msg-err {
      background: #fef2f2; color: #b91c1c; padding: 12px 16px; border-radius: 8px;
      margin-top: 12px; display: flex; align-items: center; gap: 8px;
    }
    .btn-confirmar {
      height: 40px; padding: 0 24px;
      background: #1a3a5c; color: #fff; border: none; border-radius: 6px;
      font-size: 14px; font-weight: 600; cursor: pointer;
      &:disabled { opacity: .55; cursor: not-allowed; }
    }
  `],
})
export class PortalPagoDialogComponent {
  private svc = inject(PortalService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<PortalPagoDialogComponent>);
  data: { cuota: any } = inject(MAT_DIALOG_DATA);

  loading   = signal(false);
  resultado = signal<{ exitoso: boolean; mensaje: string } | null>(null);

  form = this.fb.nonNullable.group({
    fechaPago: [new Date().toISOString().substring(0, 10), Validators.required],
  });

  confirmar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.svc.pagar(this.data.cuota.nroInterno, this.form.value.fechaPago!).subscribe({
      next: r => {
        this.resultado.set({ exitoso: r.exitoso, mensaje: r.mensaje });
        this.loading.set(false);
        if (r.exitoso) setTimeout(() => this.ref.close(true), 2000);
      },
      error: e => {
        this.resultado.set({ exitoso: false, mensaje: e.error?.mensaje ?? 'Error al procesar.' });
        this.loading.set(false);
      },
    });
  }
}
