import { Component, inject, signal, computed } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { CurrencyPipe, DecimalPipe, NgClass } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatDialog, MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { FinancieroService, CuentaErogacion } from '../../core/services/financiero.service';
import { Validators } from '@angular/forms';

// ── Dialog ────────────────────────────────────────────────────────────────────
@Component({
  selector: 'app-ajuste-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, CurrencyPipe, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule],
  template: `
<div class="dlg-header"><mat-icon>tune</mat-icon><h2>Ajuste presupuestario</h2></div>
<mat-dialog-content>
  <div class="cuenta-info">
    <div class="cta-nro">{{ data.nroCtaEro }}</div>
    <div class="cta-des">{{ data.designacion }}</div>
  </div>
  <div class="monto-actual">Presupuesto actual: <strong>{{ data.presupuestoAutorizado | currency:'ARS':'symbol':'1.0-0' }}</strong></div>
  <form [formGroup]="form" style="margin-top:16px">
    <mat-form-field appearance="outline" style="width:100%">
      <mat-label>Nuevo monto autorizado ($)</mat-label>
      <input matInput type="number" step="1000" min="0" formControlName="nuevoMonto" />
    </mat-form-field>
  </form>
  @if (error()) { <div class="msg-err">{{ error() }}</div> }
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="form.invalid || loading()">
    {{ loading() ? 'Guardando…' : 'Confirmar ajuste' }}
  </button>
</mat-dialog-actions>`,
  styles: [`.dlg-header{display:flex;align-items:center;gap:10px;padding:20px 24px 0;color:#1e293b;h2{margin:0;font-size:18px}}
    mat-dialog-content{min-width:380px;padding-top:12px!important}
    .cuenta-info{background:#f8fafc;border-radius:6px;padding:10px 14px;margin-bottom:12px}
    .cta-nro{font-size:12px;font-weight:700;color:#0369a1}.cta-des{font-size:14px;color:#334155}
    .monto-actual{font-size:13px;color:#64748b;margin-bottom:4px}
    .msg-err{background:#fef2f2;color:#b91c1c;padding:8px 12px;border-radius:4px;font-size:13px}
    .btn-ok{height:36px;padding:0 20px;background:var(--color-primary);color:#fff;border:none;border-radius:4px;font-size:14px;cursor:pointer;
      &:disabled{opacity:.55;cursor:not-allowed}}`],
})
export class AjusteDialogComponent {
  private svc = inject(FinancieroService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<AjusteDialogComponent>);
  data: CuentaErogacion = inject(MAT_DIALOG_DATA);

  loading = signal(false);
  error   = signal('');

  form = this.fb.nonNullable.group({
    nuevoMonto: [this.data.presupuestoAutorizado, [Validators.required, Validators.min(0)]],
  });

  guardar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.svc.ajustarPresupuesto(this.data.anoEro, this.data.nroCtaEro, this.form.getRawValue().nuevoMonto)
      .subscribe({
        next: () => this.ref.close(true),
        error: e => { this.error.set(e.error?.title ?? 'Error'); this.loading.set(false); },
      });
  }
}

// ── Componente principal ──────────────────────────────────────────────────────
@Component({
  selector: 'app-presupuesto',
  standalone: true,
  imports: [
    ReactiveFormsModule, CurrencyPipe, DecimalPipe, NgClass,
    MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule,
    MatTableModule, MatProgressSpinnerModule, MatProgressBarModule,
    MatDialogModule, MatTooltipModule, AjusteDialogComponent,
  ],
  templateUrl: './presupuesto.component.html',
  styleUrl: './presupuesto.component.scss',
})
export class PresupuestoComponent {
  private svc    = inject(FinancieroService);
  private fb     = inject(FormBuilder);
  private dialog = inject(MatDialog);

  anoActual = new Date().getFullYear().toString();
  form      = this.fb.nonNullable.group({ ano: [this.anoActual] });

  loading = signal(false);
  cuentas = signal<CuentaErogacion[]>([]);

  cols = ['nroCtaEro','designacion','presupuestoAutorizado','montoAfectado','montoPagado','disponible','ejecucion','accion'];

  totalAutorizado = computed(() => this.cuentas().reduce((a, c) => a + c.presupuestoAutorizado, 0));
  totalPagado     = computed(() => this.cuentas().reduce((a, c) => a + c.montoPagado, 0));
  totalDisponible = computed(() => this.cuentas().reduce((a, c) => a + (c.presupuestoAutorizado - c.montoAfectado), 0));
  pctEjecucion    = computed(() => this.totalAutorizado() ? (this.totalPagado() / this.totalAutorizado()) * 100 : 0);

  cargar() {
    this.loading.set(true);
    this.svc.presupuesto(this.form.value.ano!).subscribe({
      next: d => { this.cuentas.set(d); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  ajustar(c: CuentaErogacion) {
    this.dialog.open(AjusteDialogComponent, { data: c, width: '420px', maxWidth: '95vw' })
      .afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  ejecucionPct(c: CuentaErogacion) { return c.presupuestoAutorizado ? (c.montoPagado / c.presupuestoAutorizado) * 100 : 0; }
  disponible(c: CuentaErogacion)   { return c.presupuestoAutorizado - c.montoAfectado; }
  colorEjecucion(pct: number)       { return pct >= 90 ? 'danger' : pct >= 70 ? 'warning' : 'success'; }
}
