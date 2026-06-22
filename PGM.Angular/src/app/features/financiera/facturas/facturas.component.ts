import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, FormsModule, Validators } from '@angular/forms';
import { CurrencyPipe, DatePipe, DecimalPipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatDialog, MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { FinancieroSAFService, FacturaSAF, ProveedorSAF } from '../../../core/services/financiero-saf.service';

// ── Dialog: Detalle Factura ───────────────────────────────────────────────────
@Component({
  selector: 'app-detalle-factura-dialog',
  standalone: true,
  imports: [CurrencyPipe, DatePipe, DecimalPipe, MatDialogModule, MatButtonModule, MatIconModule, MatTableModule, MatProgressSpinnerModule],
  template: `
<div class="dlg-header"><mat-icon>receipt_long</mat-icon><h2>Detalle de Factura</h2></div>
<mat-dialog-content>
  <!-- Cabecera -->
  <div class="det-grid">
    <div class="det-section">
      <div class="det-label">Proveedor</div>
      <div class="det-value strong">{{ data.nombreProveedor || data.identificador }}</div>
      <div class="det-sub">ID: {{ data.identificador }}</div>
    </div>
    <div class="det-section">
      <div class="det-label">Comprobante</div>
      <div class="det-value strong">{{ data.tipoComprobante }} {{ data.letraComprobante }}-{{ data.nroFactura }}</div>
    </div>
    <div class="det-section">
      <div class="det-label">Fecha</div>
      <div class="det-value">{{ data.fecha | date:'dd/MM/yyyy' }}</div>
    </div>
    <div class="det-section">
      <div class="det-label">Estado</div>
      <div class="det-value"><span [class]="estadoClass()">{{ estadoLabel() }}</span></div>
    </div>
    @if (data.nroOpago) {
      <div class="det-section full">
        <div class="det-label">Orden de Pago asociada</div>
        <div class="det-value">{{ data.nroOpago }}</div>
      </div>
    }
  </div>

  <!-- Montos -->
  <div class="montos-grid">
    <div class="monto-card">
      <div class="monto-label">Total Factura</div>
      <div class="monto-value primary">{{ data.totalFactura | currency:'ARS':'symbol':'1.2-2' }}</div>
    </div>
    <div class="monto-card">
      <div class="monto-label">Neto Gravado</div>
      <div class="monto-value">{{ (data.netoGravado ?? 0) | currency:'ARS':'symbol':'1.2-2' }}</div>
    </div>
    <div class="monto-card">
      <div class="monto-label">IVA</div>
      <div class="monto-value">{{ (data.iva ?? 0) | currency:'ARS':'symbol':'1.2-2' }}</div>
    </div>
  </div>

  <!-- Ítems -->
  <div class="items-section">
    <div class="items-title">
      <mat-icon>list</mat-icon>
      <span>Ítems</span>
    </div>
    @if (loadingItems()) {
      <div style="text-align:center;padding:20px"><mat-spinner diameter="28" /></div>
    } @else if (errorItems()) {
      <div style="padding:12px;background:#fef2f2;color:#b91c1c;border-radius:4px;font-size:12px">{{ errorItems() }}</div>
    } @else if (items().length) {
      <table mat-table [dataSource]="items()" class="items-table">
        <ng-container matColumnDef="designacion">
          <th mat-header-cell *matHeaderCellDef>Descripción</th>
          <td mat-cell *matCellDef="let i">{{ i.designacion || '—' }}</td>
        </ng-container>
        <ng-container matColumnDef="codigo">
          <th mat-header-cell *matHeaderCellDef>Código</th>
          <td mat-cell *matCellDef="let i"><code>{{ i.codigoArticulo || '—' }}</code></td>
        </ng-container>
        <ng-container matColumnDef="cantidad">
          <th mat-header-cell *matHeaderCellDef class="col-r">Cant.</th>
          <td mat-cell *matCellDef="let i" class="col-r">{{ i.cantidad | number:'1.0-2' }}</td>
        </ng-container>
        <ng-container matColumnDef="precio">
          <th mat-header-cell *matHeaderCellDef class="col-r">P. Unit.</th>
          <td mat-cell *matCellDef="let i" class="col-r">{{ i.precioUnitario | currency:'ARS':'symbol':'1.2-2' }}</td>
        </ng-container>
        <ng-container matColumnDef="subtotal">
          <th mat-header-cell *matHeaderCellDef class="col-r">Subtotal</th>
          <td mat-cell *matCellDef="let i" class="col-r"><strong>{{ i.subtotal | currency:'ARS':'symbol':'1.2-2' }}</strong></td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="colsItems"></tr>
        <tr mat-row *matRowDef="let row; columns: colsItems;"></tr>
      </table>
    } @else {
      <div class="items-empty">Sin ítems registrados para esta factura</div>
    }
  </div>
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cerrar</button>
</mat-dialog-actions>`,
  styles: [`
    .dlg-header { display:flex; align-items:center; gap:10px; padding:20px 24px 0; h2 { margin:0; font-size:16px; color:#1e293b; } }
    mat-dialog-content { min-width:560px; max-width:700px; padding-top:16px!important; }
    .det-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:16px; }
    .det-section { background:#f8fafc; border-radius:6px; padding:10px 14px; &.full { grid-column:1/-1; } }
    .det-label { font-size:11px; font-weight:700; text-transform:uppercase; color:#94a3b8; letter-spacing:.04em; margin-bottom:4px; }
    .det-value { font-size:14px; color:#1e293b; &.strong { font-weight:600; } }
    .det-sub { font-size:12px; color:#64748b; margin-top:2px; }
    .montos-grid { display:grid; grid-template-columns:1fr 1fr 1fr; gap:8px; margin-bottom:16px; }
    .monto-card { background:#f1f5f9; border-radius:6px; padding:10px 12px; text-align:center; }
    .monto-label { font-size:11px; color:#64748b; font-weight:600; margin-bottom:4px; }
    .monto-value { font-size:14px; font-weight:700; color:#1e293b; &.primary { color:var(--color-primary); } }
    .badge { display:inline-flex; align-items:center; padding:2px 10px; border-radius:12px; font-size:12px; font-weight:600; }
    .badge--info    { background:#dbeafe; color:#1d4ed8; }
    .badge--success { background:#dcfce7; color:#166534; }
    .badge--muted   { background:#f1f5f9; color:#64748b; }
    .items-section { border:1px solid var(--color-border, #e2e8f0); border-radius:6px; overflow:hidden; }
    .items-title { display:flex; align-items:center; gap:6px; padding:8px 14px; background:#f8fafc; border-bottom:1px solid var(--color-border, #e2e8f0); font-size:13px; font-weight:700; color:#334155;
      mat-icon { font-size:16px; width:16px; height:16px; color:#64748b; } }
    .items-table { width:100%; }
    .items-empty { padding:16px; text-align:center; font-size:13px; color:#94a3b8; }
    .col-r { text-align:right !important; }
    table { font-size:13px; }
    th.mat-mdc-header-cell { font-size:11px; color:#94a3b8; font-weight:700; padding:6px 8px !important; }
    td.mat-mdc-cell { padding:5px 8px !important; }
  `]
})
export class DetalleFacturaDialogComponent {
  private svc  = inject(FinancieroSAFService);
  data: FacturaSAF = inject(MAT_DIALOG_DATA);

  items        = signal<any[]>([]);
  loadingItems = signal(true);
  errorItems   = signal('');
  colsItems    = ['designacion','codigo','cantidad','precio','subtotal'];

  constructor() {
    console.log('[DetalleFactura] cargando items', this.data.identificador, this.data.nroFactura);
    this.svc.facturasItems(this.data.identificador, this.data.nroFactura).subscribe({
      next: d => {
        console.log('[DetalleFactura] items recibidos:', d.length, d);
        this.items.set(d);
        this.loadingItems.set(false);
      },
      error: (e) => {
        console.error('[DetalleFactura] error:', e);
        this.errorItems.set(`Error ${e.status ?? ''}: ${e.message ?? 'desconocido'}`);
        this.loadingItems.set(false);
      },
    });
  }

  estadoLabel() { return { A:'Alta', E:'Ejecutado', N:'Anulado' }[this.data.estado ?? ''] ?? this.data.estado ?? '—'; }
  estadoClass() { return 'badge badge--' + ({ A:'info', E:'success', N:'muted' }[this.data.estado ?? ''] ?? 'muted'); }
}

// ── Dialog: Alta Factura ──────────────────────────────────────────────────────
@Component({
  selector: 'app-alta-factura-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, FormsModule, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule],
  template: `
<div class="dlg-header"><mat-icon>receipt_long</mat-icon><h2>Registrar Factura</h2></div>
<mat-dialog-content>
  <mat-form-field appearance="outline" style="width:100%;margin-bottom:8px">
    <mat-label>Buscar proveedor</mat-label>
    <input matInput [(ngModel)]="busqueda" (keyup.enter)="buscarProv()" />
    <button mat-icon-button matSuffix (click)="buscarProv()" type="button"><mat-icon>search</mat-icon></button>
  </mat-form-field>
  @if (proveedores.length) {
    <div class="prov-list">
      @for (p of proveedores; track p.identificador) {
        <div class="prov-item" [class.selected]="provSelId===p.identificador" (click)="provSelId=p.identificador">
          <strong>{{ p.apellido }}, {{ p.nombre }}</strong> &nbsp;<span class="cuit">{{ p.cuitCuil }}</span>
        </div>
      }
    </div>
  }
  @if (provSelId) {
    <form [formGroup]="form" class="fac-form">
      <div style="display:flex;gap:8px">
        <mat-form-field appearance="outline" style="flex:1">
          <mat-label>Tipo</mat-label>
          <select matNativeControl formControlName="tipoComprobante">
            <option value="FAC">Factura</option>
            <option value="REC">Recibo</option>
            <option value="NOT">Nota de Crédito</option>
          </select>
        </mat-form-field>
        <mat-form-field appearance="outline" style="width:80px">
          <mat-label>Letra</mat-label>
          <select matNativeControl formControlName="letraComprobante">
            <option value="A">A</option>
            <option value="B">B</option>
            <option value="C">C</option>
            <option value="E">E</option>
          </select>
        </mat-form-field>
      </div>
      <mat-form-field appearance="outline" style="width:100%">
        <mat-label>N° Factura</mat-label>
        <input matInput formControlName="nroFactura" placeholder="0001-00012345" />
      </mat-form-field>
      <mat-form-field appearance="outline" style="width:100%">
        <mat-label>Fecha</mat-label>
        <input matInput type="date" formControlName="fecha" />
      </mat-form-field>
      <mat-form-field appearance="outline" style="width:100%">
        <mat-label>Total Factura ($)</mat-label>
        <input matInput type="number" step="1" formControlName="totalFactura" />
      </mat-form-field>
      <div style="display:flex;gap:8px">
        <mat-form-field appearance="outline" style="flex:1">
          <mat-label>Neto Gravado ($)</mat-label>
          <input matInput type="number" step="1" formControlName="netoGravado" />
        </mat-form-field>
        <mat-form-field appearance="outline" style="flex:1">
          <mat-label>IVA ($)</mat-label>
          <input matInput type="number" step="1" [value]="ivaCalc()" readonly />
        </mat-form-field>
      </div>
    </form>
  }
  @if (error()) { <div class="msg-err">{{ error() }}</div> }
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="!provSelId || form.invalid || loading()">
    {{ loading() ? 'Guardando…' : 'Registrar' }}
  </button>
</mat-dialog-actions>`,
  styles: [`.dlg-header{display:flex;align-items:center;gap:10px;padding:20px 24px 0;h2{margin:0;font-size:18px;color:#1e293b}}
    mat-dialog-content{min-width:440px;padding-top:12px!important}
    .prov-list{border:1px solid var(--color-border);border-radius:6px;max-height:120px;overflow-y:auto;margin-bottom:12px}
    .prov-item{padding:8px 12px;cursor:pointer;font-size:13px;&:hover{background:#f0f4f8}&.selected{background:#e0f2fe}}
    .cuit{color:#64748b;font-size:12px} .fac-form{margin-top:8px}
    .msg-err{background:#fef2f2;color:#b91c1c;padding:8px 12px;border-radius:4px;font-size:13px}
    .btn-ok{height:36px;padding:0 20px;background:var(--color-primary);color:#fff;border:none;border-radius:4px;font-size:14px;cursor:pointer;&:disabled{opacity:.55;cursor:not-allowed}}`]
})
export class AltaFacturaDialogComponent {
  private svc = inject(FinancieroSAFService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<AltaFacturaDialogComponent>);

  busqueda   = '';
  proveedores: ProveedorSAF[] = [];
  provSelId  = '';
  loading    = signal(false);
  error      = signal('');

  today = new Date().toISOString().slice(0, 10);

  form = this.fb.nonNullable.group({
    tipoComprobante:  ['FAC', Validators.required],
    letraComprobante: ['A',   Validators.required],
    nroFactura:       ['',    Validators.required],
    fecha:            [this.today, Validators.required],
    totalFactura:     [0, [Validators.required, Validators.min(0.01)]],
    netoGravado:      [0],
  });

  ivaCalc() {
    const { totalFactura, netoGravado } = this.form.getRawValue();
    return Math.max(0, totalFactura - netoGravado);
  }

  buscarProv() {
    if (this.busqueda.length < 2) return;
    this.svc.buscarProveedores(this.busqueda).subscribe(d => this.proveedores = d);
  }

  guardar() {
    if (!this.provSelId || this.form.invalid) return;
    this.loading.set(true);
    const v = this.form.getRawValue();
    this.svc.crearFactura({
      identificador:    this.provSelId,
      nroFactura:       v.nroFactura,
      tipoComprobante:  v.tipoComprobante,
      letraComprobante: v.letraComprobante,
      fecha:            v.fecha,
      totalFactura:     v.totalFactura,
      netoGravado:      v.netoGravado,
      iva:              this.ivaCalc(),
      tipoOpago: null, anoOpago: null, nroOpago: null,
    }).subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set(e.error?.title ?? 'Error al guardar'); this.loading.set(false); },
    });
  }
}

// ── Componente principal ──────────────────────────────────────────────────────
@Component({
  selector: 'app-facturas',
  standalone: true,
  imports: [
    ReactiveFormsModule, FormsModule, CurrencyPipe, DatePipe,
    MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule,
    MatTableModule, MatProgressSpinnerModule, MatDialogModule, MatTooltipModule,
    AltaFacturaDialogComponent,
    DetalleFacturaDialogComponent,
  ],
  template: `
<div class="page-container">
  <div class="eyebrow">Administración Financiera</div>
  <div class="page-header">
    <h1 class="page-title" style="margin:0">Facturas de Compra</h1>
    <button class="btn-header" (click)="nuevaFactura()"><mat-icon>add</mat-icon> Registrar factura</button>
  </div>

  <div class="card filter-card">
    <form [formGroup]="form" (ngSubmit)="cargar()" class="filter-row">
      <mat-form-field appearance="outline">
        <mat-label>Año</mat-label>
        <input matInput formControlName="year" maxlength="4" style="width:80px" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Estado</mat-label>
        <select matNativeControl formControlName="estado">
          <option value="">Todos</option>
          <option value="A">Alta</option>
          <option value="E">Ejecutado</option>
          <option value="N">Anulado</option>
        </select>
      </mat-form-field>
      <button class="btn-action" type="submit" [disabled]="loading()">
        {{ loading() ? 'Cargando…' : 'Buscar' }}
      </button>
    </form>
  </div>

  @if (facturas().length) {
    <div class="card" style="padding:0;overflow:hidden;margin-top:var(--spacing-md)">
      <div class="card-header"><mat-icon>receipt_long</mat-icon><span>{{ facturas().length }} facturas</span></div>
      <table mat-table [dataSource]="facturas()">
        <ng-container matColumnDef="fecha">
          <th mat-header-cell *matHeaderCellDef>Fecha</th>
          <td mat-cell *matCellDef="let f">{{ f.fecha | date:'dd/MM/yyyy' }}</td>
        </ng-container>
        <ng-container matColumnDef="nroFactura">
          <th mat-header-cell *matHeaderCellDef>N° Factura</th>
          <td mat-cell *matCellDef="let f"><strong>{{ f.letraComprobante }}-{{ f.nroFactura }}</strong></td>
        </ng-container>
        <ng-container matColumnDef="proveedor">
          <th mat-header-cell *matHeaderCellDef>Proveedor</th>
          <td mat-cell *matCellDef="let f">{{ f.nombreProveedor || f.identificador }}</td>
        </ng-container>
        <ng-container matColumnDef="total">
          <th mat-header-cell *matHeaderCellDef>Total</th>
          <td mat-cell *matCellDef="let f"><strong>{{ f.totalFactura | currency:'ARS':'symbol':'1.2-2' }}</strong></td>
        </ng-container>
        <ng-container matColumnDef="neto">
          <th mat-header-cell *matHeaderCellDef>Neto Gravado</th>
          <td mat-cell *matCellDef="let f">{{ f.netoGravado | currency:'ARS':'symbol':'1.2-2' }}</td>
        </ng-container>
        <ng-container matColumnDef="iva">
          <th mat-header-cell *matHeaderCellDef>IVA</th>
          <td mat-cell *matCellDef="let f">{{ f.iva | currency:'ARS':'symbol':'1.2-2' }}</td>
        </ng-container>
        <ng-container matColumnDef="op">
          <th mat-header-cell *matHeaderCellDef>OP</th>
          <td mat-cell *matCellDef="let f">{{ f.nroOpago || '—' }}</td>
        </ng-container>
        <ng-container matColumnDef="estado">
          <th mat-header-cell *matHeaderCellDef>Estado</th>
          <td mat-cell *matCellDef="let f">
            <span [class]="'badge badge--' + estadoClass(f.estado)">{{ estadoLabel(f.estado) }}</span>
          </td>
        </ng-container>
        <ng-container matColumnDef="accion">
          <th mat-header-cell *matHeaderCellDef></th>
          <td mat-cell *matCellDef="let f">
            <button class="icon-btn" (click)="verDetalle(f)" matTooltip="Ver detalle"><mat-icon>visibility</mat-icon></button>
          </td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="cols"></tr>
        <tr mat-row *matRowDef="let row; columns: cols;"></tr>
      </table>
    </div>
  }
  @if (loading()) { <div style="text-align:center;padding:40px"><mat-spinner diameter="40" /></div> }
</div>`,
  styles: [`
    .page-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:var(--spacing-md); }
    .btn-header  { display:flex; align-items:center; gap:6px; background:var(--color-primary); color:#fff; border:none; border-radius:6px; padding:0 16px; height:40px; font-size:14px; font-weight:600; cursor:pointer; }
    .filter-card { padding:var(--spacing-md) var(--spacing-lg); }
    .filter-row  { display:flex; gap:var(--spacing-md); align-items:flex-start; flex-wrap:wrap; }
    .btn-action  { height:56px; padding:0 24px; margin-top:4px; background:var(--color-primary); color:#fff; border:none; border-radius:4px; font-size:14px; cursor:pointer; &:disabled{opacity:.55;cursor:not-allowed;} }
    .card-header { display:flex; align-items:center; gap:8px; padding:var(--spacing-md) var(--spacing-lg); border-bottom:1px solid var(--color-border); font-weight:700; color:var(--color-text-heading); font-size:14px; mat-icon{color:var(--color-primary);font-size:20px;width:20px;height:20px;} }
    .icon-btn { background:none; border:none; cursor:pointer; border-radius:4px; padding:4px; display:flex; align-items:center; mat-icon{font-size:18px;color:#64748b;} &:hover mat-icon{color:var(--color-primary);} }
  `]
})
export class FacturasFinancieraComponent {
  private svc    = inject(FinancieroSAFService);
  private fb     = inject(FormBuilder);
  private dialog = inject(MatDialog);

  anoActual = new Date().getFullYear().toString();
  form      = this.fb.nonNullable.group({ year: [this.anoActual], estado: [''] });
  loading   = signal(false);
  facturas  = signal<FacturaSAF[]>([]);

  cols = ['fecha','nroFactura','proveedor','total','neto','iva','op','estado','accion'];

  cargar() {
    this.loading.set(true);
    const { year, estado } = this.form.value;
    this.svc.facturas(parseInt(year!), undefined, estado || undefined).subscribe({
      next: d => { this.facturas.set(d); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  verDetalle(f: FacturaSAF) {
    this.dialog.open(DetalleFacturaDialogComponent, { data: f, width: '620px', maxWidth: '95vw', autoFocus: 'mat-dialog-close, button' });
  }

  nuevaFactura() {
    this.dialog.open(AltaFacturaDialogComponent, { width: '500px', maxWidth: '95vw' })
      .afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  estadoLabel(e: string) { return { A:'Alta', E:'Ejecutado', N:'Anulado' }[e] ?? e; }
  estadoClass(e: string) { return { A:'info', E:'success', N:'muted' }[e] ?? 'muted'; }
}
