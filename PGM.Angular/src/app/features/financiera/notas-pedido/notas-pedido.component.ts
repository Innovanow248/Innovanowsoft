import { Component, inject, signal, OnInit } from '@angular/core';
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
import { FinancieroSAFService, NotaPedidoSAF, AreaSAF } from '../../../core/services/financiero-saf.service';

// ── Dialog: Nueva Nota de Pedido ──────────────────────────────────────────────
@Component({
  selector: 'app-nueva-np-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, FormsModule, CurrencyPipe, DecimalPipe, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule],
  template: `
<div class="dlg-header"><mat-icon>assignment</mat-icon><h2>Nueva Nota de Pedido</h2></div>
<mat-dialog-content>
  <form [formGroup]="form" class="np-form">
    <mat-form-field appearance="outline" style="width:100%">
      <mat-label>Área Solicitante</mat-label>
      <select matNativeControl formControlName="idAreaSolicitante">
        <option [value]="0">— Seleccione un área —</option>
        @for (a of areas(); track a.idArea) {
          <option [value]="a.idArea">{{ a.descripcion }}</option>
        }
      </select>
    </mat-form-field>
    <mat-form-field appearance="outline" style="width:100%">
      <mat-label>Concepto</mat-label>
      <input matInput formControlName="concepto" />
    </mat-form-field>
    <mat-form-field appearance="outline" style="width:100%">
      <mat-label>Lugar de Entrega</mat-label>
      <input matInput formControlName="lugarEntrega" />
    </mat-form-field>
  </form>

  <div class="items-header">
    <span>Items del pedido</span>
    <button class="btn-add-item" (click)="addItem()" type="button"><mat-icon>add</mat-icon> Agregar item</button>
  </div>

  @for (item of items; track $index) {
    <div class="item-row">
      <mat-form-field appearance="outline" class="item-des">
        <mat-label>Descripción</mat-label>
        <input matInput [(ngModel)]="item.designacion" [ngModelOptions]="{standalone:true}" />
      </mat-form-field>
      <mat-form-field appearance="outline" class="item-qty">
        <mat-label>Cantidad</mat-label>
        <input matInput type="number" [(ngModel)]="item.cantidad" [ngModelOptions]="{standalone:true}" />
      </mat-form-field>
      <mat-form-field appearance="outline" class="item-unit">
        <mat-label>Unidad</mat-label>
        <input matInput [(ngModel)]="item.unidad" [ngModelOptions]="{standalone:true}" />
      </mat-form-field>
      <mat-form-field appearance="outline" class="item-price">
        <mat-label>Precio U.</mat-label>
        <input matInput type="number" [(ngModel)]="item.precioUnitario" [ngModelOptions]="{standalone:true}" />
      </mat-form-field>
      <button class="btn-rm" (click)="removeItem($index)" type="button"><mat-icon>delete</mat-icon></button>
    </div>
  }

  <div class="total-row">Total estimado: <strong>{{ totalItems() | currency:'ARS':'symbol':'1.0-0' }}</strong></div>
  @if (error()) { <div class="msg-err">{{ error() }}</div> }
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="form.invalid || loading()">
    {{ loading() ? 'Guardando…' : 'Crear nota de pedido' }}
  </button>
</mat-dialog-actions>`,
  styles: [`.dlg-header{display:flex;align-items:center;gap:10px;padding:20px 24px 0;h2{margin:0;font-size:18px;color:#1e293b}}
    mat-dialog-content{min-width:560px;max-height:70vh;padding-top:12px!important}
    .np-form{margin-bottom:8px}
    .items-header{display:flex;align-items:center;justify-content:space-between;font-weight:700;font-size:13px;margin-bottom:8px;color:#1e293b}
    .btn-add-item{display:flex;align-items:center;gap:4px;background:var(--color-primary);color:#fff;border:none;border-radius:4px;padding:0 10px;height:30px;font-size:12px;cursor:pointer;mat-icon{font-size:16px;width:16px;height:16px}}
    .item-row{display:flex;gap:6px;align-items:flex-start;margin-bottom:4px}
    .item-des{flex:3} .item-qty{flex:1} .item-unit{flex:1} .item-price{flex:1.5}
    .btn-rm{background:none;border:none;cursor:pointer;padding:12px 4px;mat-icon{color:#dc2626;font-size:18px;width:18px;height:18px}}
    .total-row{text-align:right;font-size:13px;color:#64748b;margin:8px 0}
    .msg-err{background:#fef2f2;color:#b91c1c;padding:8px 12px;border-radius:4px;font-size:13px}
    .btn-ok{height:36px;padding:0 20px;background:var(--color-primary);color:#fff;border:none;border-radius:4px;font-size:14px;cursor:pointer;&:disabled{opacity:.55;cursor:not-allowed}}`]
})
export class NuevaNPDialogComponent {
  private svc = inject(FinancieroSAFService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<NuevaNPDialogComponent>);
  data: { ano: string } = inject(MAT_DIALOG_DATA);

  loading = signal(false);
  error   = signal('');
  areas   = signal<AreaSAF[]>([]);

  form = this.fb.nonNullable.group({
    idAreaSolicitante: [0, [Validators.required, Validators.min(1)]],
    concepto:          ['', Validators.required],
    lugarEntrega:      [''],
  });

  constructor() {
    this.svc.getAreas().subscribe({ next: a => this.areas.set(a) });
  }

  items: { designacion: string; cantidad: number; unidad: string; precioUnitario: number }[] = [
    { designacion: '', cantidad: 1, unidad: 'UN', precioUnitario: 0 }
  ];

  addItem()             { this.items.push({ designacion: '', cantidad: 1, unidad: 'UN', precioUnitario: 0 }); }
  removeItem(i: number) { this.items.splice(i, 1); }
  totalItems()          { return this.items.reduce((a, i) => a + i.cantidad * i.precioUnitario, 0); }

  guardar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    const v = this.form.getRawValue();
    this.svc.crearNotaPedido(this.data.ano, {
      idAreaSolicitante: v.idAreaSolicitante,
      concepto:          v.concepto,
      lugarEntrega:      v.lugarEntrega,
      items:             this.items.filter(i => i.designacion),
    }).subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set(e.error?.title ?? 'Error al guardar'); this.loading.set(false); },
    });
  }
}

// ── Componente principal ──────────────────────────────────────────────────────
@Component({
  selector: 'app-notas-pedido',
  standalone: true,
  imports: [
    ReactiveFormsModule, FormsModule, CurrencyPipe, DatePipe, DecimalPipe,
    MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule,
    MatTableModule, MatProgressSpinnerModule, MatDialogModule, MatTooltipModule,
    NuevaNPDialogComponent,
  ],
  template: `
<div class="page-container">
  <div class="eyebrow">Administración Financiera</div>
  <div class="page-header">
    <h1 class="page-title" style="margin:0">Notas de Pedido</h1>
    <button class="btn-header" (click)="nuevaNP()"><mat-icon>add</mat-icon> Nueva nota</button>
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
          <option value="C">Cancelado</option>
          <option value="R">Rechazado</option>
        </select>
      </mat-form-field>
      <button class="btn-action" type="submit" [disabled]="loading()">
        {{ loading() ? 'Cargando…' : 'Buscar' }}
      </button>
    </form>
  </div>

  @if (error()) {
    <div class="amber-banner" style="margin-top:var(--spacing-md)">{{ error() }}</div>
  }

  @if (buscado() && !loading() && !notas().length && !error()) {
    <div class="card" style="margin-top:var(--spacing-md);text-align:center;padding:40px;color:#94a3b8">
      <mat-icon style="font-size:40px;width:40px;height:40px;display:block;margin:0 auto 8px">assignment</mat-icon>
      Sin notas de pedido para el período seleccionado.
    </div>
  }

  @if (notas().length) {
    <div class="card" style="padding:0;overflow:hidden;margin-top:var(--spacing-md)">
      <div class="card-header"><mat-icon>assignment</mat-icon><span>{{ notas().length }} notas de pedido</span></div>
      <table mat-table [dataSource]="notas()">
        <ng-container matColumnDef="nro">
          <th mat-header-cell *matHeaderCellDef>N°</th>
          <td mat-cell *matCellDef="let n"><strong>{{ n.nroComprobante }}</strong></td>
        </ng-container>
        <ng-container matColumnDef="fecha">
          <th mat-header-cell *matHeaderCellDef>Fecha</th>
          <td mat-cell *matCellDef="let n">{{ n.fechaPedido ? (n.fechaPedido | date:'dd/MM/yyyy') : '—' }}</td>
        </ng-container>
        <ng-container matColumnDef="area">
          <th mat-header-cell *matHeaderCellDef>Área</th>
          <td mat-cell *matCellDef="let n">{{ n.areaSolicitante }}</td>
        </ng-container>
        <ng-container matColumnDef="concepto">
          <th mat-header-cell *matHeaderCellDef>Concepto</th>
          <td mat-cell *matCellDef="let n">{{ n.concepto }}</td>
        </ng-container>
        <ng-container matColumnDef="estado">
          <th mat-header-cell *matHeaderCellDef>Estado</th>
          <td mat-cell *matCellDef="let n">
            <span [class]="'badge badge--' + estadoClass(n.estado)">{{ estadoLabel(n.estado) }}</span>
          </td>
        </ng-container>
        <ng-container matColumnDef="accion">
          <th mat-header-cell *matHeaderCellDef></th>
          <td mat-cell *matCellDef="let n">
            <div class="accion-cell">
              @if (n.estado === 'P') {
                <button class="icon-btn ok" (click)="cambiarEstado(n,'A')" matTooltip="Aprobar"><mat-icon>check_circle</mat-icon></button>
                <button class="icon-btn danger" (click)="cambiarEstado(n,'R')" matTooltip="Rechazar"><mat-icon>cancel</mat-icon></button>
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
      &.ok mat-icon{color:#16a34a;} &.danger mat-icon{color:#dc2626;} }
  `]
})
export class NotasPedidoFinancieraComponent implements OnInit {
  private svc    = inject(FinancieroSAFService);
  private fb     = inject(FormBuilder);
  private dialog = inject(MatDialog);

  anoActual = new Date().getFullYear().toString();
  form      = this.fb.nonNullable.group({ ano: [this.anoActual], estado: [''] });
  loading   = signal(false);
  error     = signal('');
  notas     = signal<NotaPedidoSAF[]>([]);
  buscado   = signal(false);

  cols = ['nro','fecha','area','concepto','estado','accion'];

  ngOnInit() { this.cargar(); }

  cargar() {
    this.loading.set(true);
    this.error.set('');
    const { ano, estado } = this.form.getRawValue();
    this.svc.notasPedido(ano, estado || undefined).subscribe({
      next: d => { this.notas.set(d); this.loading.set(false); this.buscado.set(true); },
      error: e => {
        this.error.set('Error al cargar notas de pedido: ' + (e.error?.title ?? e.message ?? 'Error de conexión'));
        this.loading.set(false);
        this.buscado.set(true);
      },
    });
  }

  nuevaNP() {
    this.dialog.open(NuevaNPDialogComponent, {
      data: { ano: this.form.value.ano }, width: '620px', maxWidth: '95vw'
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  cambiarEstado(n: NotaPedidoSAF, estado: string) {
    this.svc.cambiarEstadoNP(n.tipoComprobante, n.anoComprobante, n.nroComprobante, estado)
      .subscribe(() => this.cargar());
  }

  estadoLabel(e: string) { return { P:'Pendiente', A:'Aprobado', C:'Cancelado', R:'Rechazado' }[e] ?? e; }
  estadoClass(e: string) { return { P:'warning', A:'success', C:'muted', R:'danger' }[e] ?? 'muted'; }
}
