import { Component, inject, signal, computed } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { CurrencyPipe, DatePipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatChipsModule } from '@angular/material/chips';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialog, MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { FinancieroSAFService, ProveedorSAF, FacturaSAF } from '../../../core/services/financiero-saf.service';
import { DetalleFacturaDialogComponent } from '../facturas/facturas.component';

// ── Dialog: Alta factura de compra ────────────────────────────────────────────
@Component({
  selector: 'app-alta-factura-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, CurrencyPipe, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule],
  template: `
<div class="dlg-header">
  <mat-icon>receipt_long</mat-icon>
  <h2>Registrar factura</h2>
</div>
<mat-dialog-content>
  <div class="prov-chip">
    <mat-icon>storefront</mat-icon>
    <span>{{ data.proveedor }}</span>
  </div>
  <form [formGroup]="form" class="form-grid">
    <mat-form-field appearance="outline">
      <mat-label>Tipo comprobante</mat-label>
      <select matNativeControl formControlName="tipoComprobante">
        <option value="FAC">Factura</option>
        <option value="NCR">Nota de crédito</option>
        <option value="NDB">Nota de débito</option>
        <option value="REC">Recibo</option>
      </select>
    </mat-form-field>
    <mat-form-field appearance="outline">
      <mat-label>Letra</mat-label>
      <select matNativeControl formControlName="letraComprobante">
        <option value="A">A</option>
        <option value="B">B</option>
        <option value="C">C</option>
        <option value="E">E</option>
      </select>
    </mat-form-field>
    <mat-form-field appearance="outline" class="full">
      <mat-label>N° factura (Ej: 0001-00000001)</mat-label>
      <input matInput formControlName="nroFactura" placeholder="0001-00000001" />
    </mat-form-field>
    <mat-form-field appearance="outline">
      <mat-label>Fecha</mat-label>
      <input matInput type="date" formControlName="fecha" />
    </mat-form-field>
    <mat-form-field appearance="outline">
      <mat-label>Total ($)</mat-label>
      <input matInput type="number" step="100" min="0" formControlName="totalFactura" (change)="calcularIva()" />
    </mat-form-field>
    <mat-form-field appearance="outline">
      <mat-label>Neto gravado ($)</mat-label>
      <input matInput type="number" step="100" min="0" formControlName="netoGravado" (change)="calcularIva()" />
    </mat-form-field>
    <mat-form-field appearance="outline">
      <mat-label>IVA ($)</mat-label>
      <input matInput type="number" step="1" formControlName="iva" />
    </mat-form-field>
    <div class="sep-line full"><span>Orden de pago (opcional)</span></div>
    <mat-form-field appearance="outline">
      <mat-label>Tipo OP</mat-label>
      <input matInput formControlName="tipoOpago" placeholder="CO" maxlength="4" />
    </mat-form-field>
    <mat-form-field appearance="outline">
      <mat-label>Año OP</mat-label>
      <input matInput formControlName="anoOpago" maxlength="4" />
    </mat-form-field>
    <mat-form-field appearance="outline">
      <mat-label>N° OP</mat-label>
      <input matInput formControlName="nroOpago" />
    </mat-form-field>
  </form>
  @if (error()) { <div class="msg-err">{{ error() }}</div> }
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="form.invalid || loading()">
    {{ loading() ? 'Guardando…' : 'Registrar' }}
  </button>
</mat-dialog-actions>`,
  styles: [`.dlg-header{display:flex;align-items:center;gap:10px;padding:20px 24px 0;color:#1e293b;h2{margin:0;font-size:18px}}
    mat-dialog-content{min-width:480px}
    .prov-chip{display:flex;align-items:center;gap:6px;background:#eff6ff;border-radius:6px;padding:8px 12px;margin-bottom:12px;font-size:13px;color:#1e40af;
      mat-icon{font-size:16px}}
    .form-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;padding:8px 0} .full{grid-column:1/-1}
    .sep-line{font-size:11px;font-weight:700;letter-spacing:.08em;color:#94a3b8;text-transform:uppercase;
      display:flex;align-items:center;gap:8px;padding:4px 0;
      &::before,&::after{content:'';flex:1;height:1px;background:#e2e8f0}}
    .msg-err{background:#fef2f2;color:#b91c1c;padding:8px 12px;border-radius:4px;font-size:13px}
    .btn-ok{height:36px;padding:0 20px;background:var(--color-primary);color:#fff;border:none;border-radius:4px;font-size:14px;cursor:pointer;
      &:disabled{opacity:.55;cursor:not-allowed}}`],
})
export class AltaFacturaDialogComponent {
  private svc = inject(FinancieroSAFService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<AltaFacturaDialogComponent>);
  data: {identificador: string; proveedor: string} = inject(MAT_DIALOG_DATA);

  loading = signal(false);
  error   = signal('');
  today   = new Date().toISOString().substring(0, 10);

  form = this.fb.nonNullable.group({
    tipoComprobante:  ['FAC', Validators.required],
    letraComprobante: ['A',   Validators.required],
    nroFactura:       ['',    Validators.required],
    fecha:            [this.today, Validators.required],
    totalFactura:     [0, [Validators.required, Validators.min(0.01)]],
    netoGravado:      [0, [Validators.required, Validators.min(0)]],
    iva:              [0],
    tipoOpago:        [''],
    anoOpago:         [''],
    nroOpago:         [''],
  });

  calcularIva() {
    const total = this.form.getRawValue().totalFactura;
    const neto  = this.form.getRawValue().netoGravado;
    if (total > 0 && neto > 0) this.form.patchValue({ iva: Math.round((total - neto) * 100) / 100 });
  }

  guardar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    const v = this.form.getRawValue();
    this.svc.crearFactura({
      identificador:    this.data.identificador,
      tipoComprobante:  v.tipoComprobante,
      letraComprobante: v.letraComprobante,
      nroFactura:       v.nroFactura,
      fecha:            v.fecha,
      totalFactura:     v.totalFactura,
      netoGravado:      v.netoGravado,
      iva:              v.iva,
      tipoOpago:        v.tipoOpago || null,
      anoOpago:         v.anoOpago  || null,
      nroOpago:         v.nroOpago  || null,
    }).subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set(e.error?.title ?? 'Error al registrar'); this.loading.set(false); },
    });
  }
}

// ── Componente principal ──────────────────────────────────────────────────────
@Component({
  selector: 'app-proveedores',
  standalone: true,
  imports: [
    ReactiveFormsModule, CurrencyPipe, DatePipe,
    MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule,
    MatTableModule, MatProgressSpinnerModule, MatChipsModule,
    MatTooltipModule, MatDialogModule,
    AltaFacturaDialogComponent, DetalleFacturaDialogComponent,
  ],
  templateUrl: './proveedores.component.html',
  styleUrl: './proveedores.component.scss',
})
export class ProveedoresComponent {
  private saf    = inject(FinancieroSAFService);
  private fb     = inject(FormBuilder);
  private dialog = inject(MatDialog);

  form = this.fb.nonNullable.group({ busqueda: [''] });

  loading    = signal(false);
  error      = signal('');
  resultados = signal<ProveedorSAF[]>([]);
  proveedor  = signal<ProveedorSAF | null>(null);
  facturas   = signal<FacturaSAF[]>([]);

  colsResultados = ['nombre', 'cuit', 'tipo', 'accion'];
  cols           = ['fecha', 'nroFactura', 'tipo', 'totalFactura', 'netoGravado', 'iva', 'estado', 'ordenPago', 'detalle'];

  totalFacturado = computed(() => this.facturas().reduce((a, f) => a + f.totalFactura, 0));
  cantFacturas   = computed(() => this.facturas().length);

  buscar() {
    const val = this.form.value.busqueda?.trim() ?? '';
    if (!val) return;
    this.loading.set(true);
    this.error.set('');
    this.resultados.set([]);
    this.proveedor.set(null);
    this.facturas.set([]);

    this.saf.buscarProveedores(val).subscribe({
      next: r => {
        if (r.length === 0) {
          this.error.set('Sin resultados para ese proveedor.');
        } else if (r.length === 1) {
          this.seleccionar(r[0]);
        } else {
          this.resultados.set(r);
        }
        this.loading.set(false);
      },
      error: () => { this.error.set('Error al buscar.'); this.loading.set(false); },
    });
  }

  seleccionar(p: ProveedorSAF) {
    this.proveedor.set(p);
    this.resultados.set([]);
    this.loading.set(true);
    this.saf.facturas(undefined, p.identificador).subscribe({
      next: f => { this.facturas.set(f); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  verDetalle(f: FacturaSAF) {
    this.dialog.open(DetalleFacturaDialogComponent, { data: f, width: '620px', maxWidth: '95vw', autoFocus: 'mat-dialog-close, button' });
  }

  nuevaFactura() {
    const p = this.proveedor();
    if (!p) return;
    this.dialog.open(AltaFacturaDialogComponent, {
      data: { identificador: p.identificador, proveedor: `${p.apellido}, ${p.nombre}` },
      width: '560px', maxWidth: '95vw',
    }).afterClosed().subscribe(ok => {
      if (ok) this.saf.facturas(undefined, p.identificador).subscribe({
        next: f => this.facturas.set(f),
      });
    });
  }

  ordenPago(f: FacturaSAF): string {
    if (!f.nroOpago) return '—';
    return `${f.tipoOpago || ''}-${f.anoOpago || ''}-${f.nroOpago}`;
  }

  estadoClass(e: string): string {
    const m: Record<string, string> = { A: 'success', P: 'warning', R: 'danger', C: 'muted' };
    return `badge badge--${m[e?.trim()] ?? 'muted'}`;
  }

  estadoLabel(e: string): string {
    const m: Record<string, string> = { A: 'Activa', P: 'Pendiente', R: 'Rechazada', C: 'Cancelada' };
    return m[e?.trim()] ?? e;
  }
}
