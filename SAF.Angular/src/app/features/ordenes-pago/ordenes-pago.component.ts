import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, FormsModule } from '@angular/forms';
import { CurrencyPipe, DatePipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatDialog, MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { FinancieroService, OrdenPago, Proveedor, CuentaErogacion } from '../../core/services/financiero.service';

// ── Dialog: Nueva OP ──────────────────────────────────────────────────────────
@Component({
  selector: 'app-nueva-op-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, FormsModule, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule],
  template: `
<div class="dlg-header"><mat-icon>payments</mat-icon><h2>Nueva Orden de Pago</h2></div>
<mat-dialog-content>
  <mat-form-field appearance="outline" style="width:100%;margin-bottom:8px">
    <mat-label>Buscar proveedor</mat-label>
    <input matInput [(ngModel)]="busqueda" (keyup.enter)="buscarProv()" />
    <button mat-icon-button matSuffix (click)="buscarProv()" type="button"><mat-icon>search</mat-icon></button>
  </mat-form-field>
  @if (proveedores.length) {
    <div class="prov-list">
      @for (p of proveedores; track p.identificador) {
        <div class="prov-item" [class.selected]="provSelId === p.identificador" (click)="selProv(p)">
          <strong>{{ p.apellido }}, {{ p.nombre }}</strong> &nbsp;<span class="cuit">{{ p.cuitCuil }}</span>
        </div>
      }
    </div>
  }
  @if (provSelId) {
    <form [formGroup]="form" class="op-form">
      <mat-form-field appearance="outline" style="width:100%">
        <mat-label>Cuenta de erogación (NRO_CTA)</mat-label>
        <input matInput formControlName="nroCta" placeholder="Ej: 1-1-1-01" />
      </mat-form-field>
      <mat-form-field appearance="outline" style="width:100%">
        <mat-label>Año erogación</mat-label>
        <input matInput formControlName="anoEro" maxlength="4" />
      </mat-form-field>
      <mat-form-field appearance="outline" style="width:100%">
        <mat-label>Monto a Pagar ($)</mat-label>
        <input matInput type="number" step="100" formControlName="montoAPagar" />
      </mat-form-field>
      <mat-form-field appearance="outline" style="width:100%">
        <mat-label>Observaciones</mat-label>
        <input matInput formControlName="observaciones" />
      </mat-form-field>
    </form>
  }
  @if (error()) { <div class="msg-err">{{ error() }}</div> }
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="!provSelId || form.invalid || loading()">
    {{ loading() ? 'Guardando…' : 'Crear OP' }}
  </button>
</mat-dialog-actions>`,
  styles: [`.dlg-header{display:flex;align-items:center;gap:10px;padding:20px 24px 0;h2{margin:0;font-size:18px;color:#1e293b}}
    mat-dialog-content{min-width:440px;padding-top:12px!important}
    .prov-list{border:1px solid var(--color-border);border-radius:6px;max-height:130px;overflow-y:auto;margin-bottom:12px}
    .prov-item{padding:8px 12px;cursor:pointer;font-size:13px;&:hover{background:#f0f4f8}&.selected{background:#e0f2fe}}
    .cuit{color:#64748b;font-size:12px} .op-form{margin-top:8px}
    .msg-err{background:#fef2f2;color:#b91c1c;padding:8px 12px;border-radius:4px;font-size:13px}
    .btn-ok{height:36px;padding:0 20px;background:var(--color-primary);color:#fff;border:none;border-radius:4px;font-size:14px;cursor:pointer;&:disabled{opacity:.55;cursor:not-allowed}}`]
})
export class NuevaOPDialogComponent {
  private svc = inject(FinancieroService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<NuevaOPDialogComponent>);
  data: { ano: string } = inject(MAT_DIALOG_DATA);

  busqueda   = '';
  proveedores: Proveedor[] = [];
  provSelId  = '';
  loading    = signal(false);
  error      = signal('');

  form = this.fb.nonNullable.group({
    nroCta:       [''],
    anoEro:       [this.data.ano],
    montoAPagar:  [0],
    observaciones: [''],
  });

  buscarProv() {
    if (this.busqueda.length < 2) return;
    this.svc.buscarProveedores(this.busqueda).subscribe(d => this.proveedores = d);
  }
  selProv(p: Proveedor) { this.provSelId = p.identificador; }

  guardar() {
    if (!this.provSelId || this.form.invalid) return;
    this.loading.set(true);
    const v = this.form.getRawValue();
    this.svc.crearOrdenPago(this.data.ano, {
      identificador: this.provSelId,
      nroCta:        v.nroCta,
      anoEro:        v.anoEro,
      montoAPagar:   v.montoAPagar,
      observaciones: v.observaciones || null,
    }).subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set(e.error?.title ?? 'Error'); this.loading.set(false); },
    });
  }
}

// ── Componente principal ──────────────────────────────────────────────────────
@Component({
  selector: 'app-ordenes-pago',
  standalone: true,
  imports: [
    ReactiveFormsModule, FormsModule, CurrencyPipe, DatePipe,
    MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule,
    MatTableModule, MatProgressSpinnerModule, MatDialogModule, MatTooltipModule,
    NuevaOPDialogComponent,
  ],
  template: `
<div class="page-container">
  <div class="eyebrow">Administración Financiera</div>
  <div class="page-header">
    <h1 class="page-title" style="margin:0">Órdenes de Pago</h1>
    <button class="btn-header" (click)="nuevaOP()"><mat-icon>add</mat-icon> Nueva OP</button>
  </div>

  <div class="card filter-card">
    <form [formGroup]="form" (ngSubmit)="cargar()" class="filter-row">
      <mat-form-field appearance="outline">
        <mat-label>Año</mat-label>
        <input matInput formControlName="ano" maxlength="4" style="width:80px" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Estado</mat-label>
        <select matNativeControl formControlName="estado">
          <option value="">Todos</option>
          <option value="P">Pendiente</option>
          <option value="A">Aprobado</option>
          <option value="E">Emitido</option>
          <option value="C">Cancelado</option>
        </select>
      </mat-form-field>
      <button class="btn-action" type="submit" [disabled]="loading()">
        {{ loading() ? 'Cargando…' : 'Buscar' }}
      </button>
    </form>
  </div>

  @if (ordenes().length) {
    <div class="card" style="padding:0;overflow:hidden;margin-top:var(--spacing-md)">
      <div class="card-header"><mat-icon>payments</mat-icon><span>{{ ordenes().length }} órdenes</span></div>
      <table mat-table [dataSource]="ordenes()">
        <ng-container matColumnDef="nro">
          <th mat-header-cell *matHeaderCellDef>N°</th>
          <td mat-cell *matCellDef="let o"><strong>{{ o.nroOpago }}</strong></td>
        </ng-container>
        <ng-container matColumnDef="proveedor">
          <th mat-header-cell *matHeaderCellDef>Proveedor</th>
          <td mat-cell *matCellDef="let o">{{ o.nombreProveedor || o.identificador }}</td>
        </ng-container>
        <ng-container matColumnDef="nroCta">
          <th mat-header-cell *matHeaderCellDef>Cuenta</th>
          <td mat-cell *matCellDef="let o">{{ o.nroCta }}</td>
        </ng-container>
        <ng-container matColumnDef="monto">
          <th mat-header-cell *matHeaderCellDef>Monto</th>
          <td mat-cell *matCellDef="let o"><strong>{{ o.montoAPagar | currency:'ARS':'symbol':'1.0-0' }}</strong></td>
        </ng-container>
        <ng-container matColumnDef="fechaMandato">
          <th mat-header-cell *matHeaderCellDef>Mandato</th>
          <td mat-cell *matCellDef="let o">{{ o.fechaMandato ? (o.fechaMandato | date:'dd/MM/yyyy') : '—' }}</td>
        </ng-container>
        <ng-container matColumnDef="estado">
          <th mat-header-cell *matHeaderCellDef>Estado</th>
          <td mat-cell *matCellDef="let o">
            <span [class]="'badge badge--' + estadoClass(o.estado)">{{ estadoLabel(o.estado) }}</span>
          </td>
        </ng-container>
        <ng-container matColumnDef="accion">
          <th mat-header-cell *matHeaderCellDef></th>
          <td mat-cell *matCellDef="let o">
            <div class="accion-cell">
              @if (o.estado === 'P') {
                <button class="icon-btn ok" (click)="cambiarEstado(o,'A')" matTooltip="Aprobar"><mat-icon>check_circle</mat-icon></button>
                <button class="icon-btn danger" (click)="cambiarEstado(o,'C')" matTooltip="Cancelar"><mat-icon>cancel</mat-icon></button>
              }
              @if (o.estado === 'A') {
                <button class="icon-btn pay" (click)="cambiarEstado(o,'E')" matTooltip="Emitir"><mat-icon>paid</mat-icon></button>
                <button class="icon-btn danger" (click)="cambiarEstado(o,'C')" matTooltip="Cancelar"><mat-icon>cancel</mat-icon></button>
              }
            </div>
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
    .accion-cell { display:flex; gap:4px; justify-content:flex-end; }
    .icon-btn { background:none; border:none; cursor:pointer; border-radius:4px; padding:4px; display:flex; align-items:center; mat-icon{font-size:18px;color:#64748b;}
      &.ok mat-icon{color:#16a34a;} &.pay mat-icon{color:#0369a1;} &.danger mat-icon{color:#dc2626;} }
  `]
})
export class OrdenesPagoComponent {
  private svc    = inject(FinancieroService);
  private fb     = inject(FormBuilder);
  private dialog = inject(MatDialog);

  anoActual = new Date().getFullYear().toString();
  form      = this.fb.nonNullable.group({ ano: [this.anoActual], estado: [''] });
  loading   = signal(false);
  ordenes   = signal<OrdenPago[]>([]);

  cols = ['nro','proveedor','nroCta','monto','fechaMandato','estado','accion'];

  cargar() {
    this.loading.set(true);
    const { ano, estado } = this.form.value;
    this.svc.ordenesPago(ano!, estado || undefined).subscribe({
      next: d => { this.ordenes.set(d); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  nuevaOP() {
    this.dialog.open(NuevaOPDialogComponent, {
      data: { ano: this.form.value.ano }, width: '480px', maxWidth: '95vw'
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  cambiarEstado(o: OrdenPago, estado: string) {
    this.svc.cambiarEstadoOP(o.tipoOpago, o.anoOpago, o.nroOpago, estado)
      .subscribe(() => this.cargar());
  }

  estadoLabel(e: string) { return { P:'Pendiente', A:'Aprobado', E:'Emitido', C:'Cancelado' }[e] ?? e; }
  estadoClass(e: string) { return { P:'warning', A:'info', E:'success', C:'muted' }[e] ?? 'muted'; }
}
