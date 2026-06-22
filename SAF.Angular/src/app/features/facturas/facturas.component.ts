import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, FormsModule, Validators } from '@angular/forms';
import { CurrencyPipe, DatePipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatDialog, MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { FinancieroService, Factura, Proveedor } from '../../core/services/financiero.service';

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
  private svc = inject(FinancieroService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<AltaFacturaDialogComponent>);

  busqueda   = '';
  proveedores: Proveedor[] = [];
  provSelId  = '';
  loading    = signal(false);
  error      = signal('');

  today = new Date().toISOString().slice(0,10);

  form = this.fb.nonNullable.group({
    tipoComprobante:  ['FAC', Validators.required],
    letraComprobante: ['A',   Validators.required],
    nroFactura:       ['',    Validators.required],
    fecha:            [this.today, Validators.required],
    totalFactura:     [0,     [Validators.required, Validators.min(0.01)]],
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
      error: e => { this.error.set(e.error?.title ?? 'Error'); this.loading.set(false); },
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
  `]
})
export class FacturasComponent {
  private svc    = inject(FinancieroService);
  private fb     = inject(FormBuilder);
  private dialog = inject(MatDialog);

  anoActual = new Date().getFullYear().toString();
  form      = this.fb.nonNullable.group({ year: [this.anoActual], estado: [''] });
  loading   = signal(false);
  facturas  = signal<Factura[]>([]);

  cols = ['fecha','nroFactura','proveedor','total','neto','iva','op','estado'];

  cargar() {
    this.loading.set(true);
    const { year, estado } = this.form.value;
    this.svc.facturas(parseInt(year!), undefined, estado || undefined).subscribe({
      next: d => { this.facturas.set(d); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  nuevaFactura() {
    this.dialog.open(AltaFacturaDialogComponent, { width: '500px', maxWidth: '95vw' })
      .afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  estadoLabel(e: string) { return { A:'Alta', E:'Ejecutado', N:'Anulado' }[e] ?? e; }
  estadoClass(e: string) { return { A:'info', E:'success', N:'muted' }[e] ?? 'muted'; }
}
