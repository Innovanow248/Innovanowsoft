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
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { FinancieroSAFService, CompromisoSAF, ProveedorSAF } from '../../../core/services/financiero-saf.service';

// ── Dialog: Detalle Compromiso ────────────────────────────────────────────────
@Component({
  selector: 'app-detalle-compromiso-dialog',
  standalone: true,
  imports: [CurrencyPipe, DatePipe, MatDialogModule, MatButtonModule, MatIconModule],
  template: `
<div class="dlg-header"><mat-icon>handshake</mat-icon><h2>Compromiso {{ data.tipoCompromiso }}-{{ data.anoCompromiso }}-{{ data.nroCompromiso }}</h2></div>
<mat-dialog-content>
  <div class="det-grid">
    <div class="det-section">
      <div class="det-label">Proveedor</div>
      <div class="det-value strong">{{ data.nombreProveedor || data.identificador }}</div>
      <div class="det-sub">ID: {{ data.identificador }}</div>
    </div>
    <div class="det-section">
      <div class="det-label">Fecha</div>
      <div class="det-value">{{ data.fechaCompromiso ? (data.fechaCompromiso | date:'dd/MM/yyyy') : '—' }}</div>
    </div>
    <div class="det-section full">
      <div class="det-label">Concepto</div>
      <div class="det-value">{{ data.concepto || '—' }}</div>
    </div>
    <div class="det-section">
      <div class="det-label">Estado</div>
      <div class="det-value">
        <span [class]="estadoClass()">{{ estadoLabel() }}</span>
      </div>
    </div>
  </div>

  <div class="montos-grid">
    <div class="monto-card">
      <div class="monto-label">Comprometido</div>
      <div class="monto-value">{{ data.montoComprometido | currency:'ARS':'symbol':'1.2-2' }}</div>
    </div>
    <div class="monto-card">
      <div class="monto-label">A pagar</div>
      <div class="monto-value">{{ data.montoAPagar | currency:'ARS':'symbol':'1.2-2' }}</div>
    </div>
    <div class="monto-card">
      <div class="monto-label">Pagado</div>
      <div class="monto-value success">{{ data.montoPagado | currency:'ARS':'symbol':'1.2-2' }}</div>
    </div>
    <div class="monto-card">
      <div class="monto-label">Saldo pendiente</div>
      <div class="monto-value" [class.danger]="saldo() > 0">{{ saldo() | currency:'ARS':'symbol':'1.2-2' }}</div>
    </div>
  </div>
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cerrar</button>
</mat-dialog-actions>`,
  styles: [`
    .dlg-header { display:flex; align-items:center; gap:10px; padding:20px 24px 0; h2 { margin:0; font-size:16px; color:#1e293b; } }
    mat-dialog-content { min-width:480px; padding-top:16px!important; }
    .det-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:16px; }
    .det-section { background:#f8fafc; border-radius:6px; padding:10px 14px; &.full { grid-column:1/-1; } }
    .det-label { font-size:11px; font-weight:700; text-transform:uppercase; color:#94a3b8; letter-spacing:.04em; margin-bottom:4px; }
    .det-value { font-size:14px; color:#1e293b; &.strong { font-weight:600; } }
    .det-sub { font-size:12px; color:#64748b; margin-top:2px; }
    .montos-grid { display:grid; grid-template-columns:1fr 1fr 1fr 1fr; gap:8px; }
    .monto-card { background:#f1f5f9; border-radius:6px; padding:10px 12px; text-align:center; }
    .monto-label { font-size:11px; color:#64748b; font-weight:600; margin-bottom:4px; }
    .monto-value { font-size:13px; font-weight:700; color:#1e293b; &.success { color:#16a34a; } &.danger { color:#dc2626; } }
    .badge { display:inline-flex; align-items:center; padding:2px 10px; border-radius:12px; font-size:12px; font-weight:600; }
    .badge--warning { background:#fef9c3; color:#854d0e; }
    .badge--info    { background:#dbeafe; color:#1d4ed8; }
    .badge--success { background:#dcfce7; color:#166534; }
    .badge--muted   { background:#f1f5f9; color:#64748b; }
  `]
})
export class DetalleCompromisoDialogComponent {
  data: CompromisoSAF = inject(MAT_DIALOG_DATA);
  saldo()      { return (this.data.montoAPagar ?? 0) - (this.data.montoPagado ?? 0); }
  estadoLabel(){ return { P:'Pendiente', A:'Autorizado', E:'Ejecutado', C:'Cancelado' }[this.data.estadoCompromiso] ?? this.data.estadoCompromiso; }
  estadoClass(){ return 'badge badge--' + ({ P:'warning', A:'info', E:'success', C:'muted' }[this.data.estadoCompromiso] ?? 'muted'); }
}

// ── Dialog: Nuevo Compromiso ──────────────────────────────────────────────────
@Component({
  selector: 'app-nuevo-compromiso-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, FormsModule, CurrencyPipe, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule],
  template: `
<div class="dlg-header"><mat-icon>handshake</mat-icon><h2>Nuevo Compromiso</h2></div>
<mat-dialog-content>
  <mat-form-field appearance="outline" style="width:100%;margin-bottom:8px">
    <mat-label>Buscar proveedor (apellido, CUIT o DNI)</mat-label>
    <input matInput [(ngModel)]="busqueda" (keyup.enter)="buscarProv()" [disabled]="loadingProv()" />
    <button mat-icon-button matSuffix (click)="buscarProv()" type="button" [disabled]="loadingProv()">
      <mat-icon>{{ loadingProv() ? 'hourglass_empty' : 'search' }}</mat-icon>
    </button>
  </mat-form-field>
  @if (errorProv()) {
    <div class="msg-err" style="margin-bottom:8px">{{ errorProv() }}</div>
  }
  @if (!loadingProv() && busqueda.length >= 2 && !proveedores.length) {
    <div style="font-size:13px;color:#64748b;margin-bottom:8px">Sin resultados para "{{ busqueda }}"</div>
  }
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
    <form [formGroup]="form" class="comp-form">
      <mat-form-field appearance="outline" style="width:100%">
        <mat-label>Concepto</mat-label>
        <input matInput formControlName="concepto" />
      </mat-form-field>
      <div style="display:flex;gap:8px">
        <mat-form-field appearance="outline" style="flex:1">
          <mat-label>Monto Comprometido ($)</mat-label>
          <input matInput type="number" step="1" formControlName="montoComprometido" />
        </mat-form-field>
        <mat-form-field appearance="outline" style="flex:1">
          <mat-label>N° Cta Erogación</mat-label>
          <input matInput formControlName="nroCta" />
        </mat-form-field>
      </div>
      <mat-form-field appearance="outline" style="width:100%">
        <mat-label>Año Erogación</mat-label>
        <input matInput formControlName="anoEro" maxlength="4" />
      </mat-form-field>
    </form>
  }
  @if (error()) { <div class="msg-err">{{ error() }}</div> }
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="!provSelId || form.invalid || loading()">
    {{ loading() ? 'Guardando…' : 'Crear compromiso' }}
  </button>
</mat-dialog-actions>`,
  styles: [`.dlg-header{display:flex;align-items:center;gap:10px;padding:20px 24px 0;h2{margin:0;font-size:18px;color:#1e293b}}
    mat-dialog-content{min-width:440px;padding-top:12px!important}
    .prov-list{border:1px solid var(--color-border);border-radius:6px;max-height:120px;overflow-y:auto;margin-bottom:12px}
    .prov-item{padding:8px 12px;cursor:pointer;font-size:13px;&:hover{background:#f0f4f8}&.selected{background:#e0f2fe}}
    .cuit{color:#64748b;font-size:12px} .comp-form{margin-top:8px}
    .msg-err{background:#fef2f2;color:#b91c1c;padding:8px 12px;border-radius:4px;font-size:13px}
    .btn-ok{height:36px;padding:0 20px;background:var(--color-primary);color:#fff;border:none;border-radius:4px;font-size:14px;cursor:pointer;&:disabled{opacity:.55;cursor:not-allowed}}`]
})
export class NuevoCompromisoDialogComponent {
  private svc = inject(FinancieroSAFService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<NuevoCompromisoDialogComponent>);
  data: { ano: string } = inject(MAT_DIALOG_DATA);

  busqueda      = '';
  proveedores: ProveedorSAF[] = [];
  provSelId     = '';
  loadingProv   = signal(false);
  errorProv     = signal('');
  loading       = signal(false);
  error         = signal('');

  form = this.fb.nonNullable.group({
    concepto:          ['', Validators.required],
    montoComprometido: [0, [Validators.required, Validators.min(0.01)]],
    nroCta:            ['', Validators.required],
    anoEro:            [this.data.ano, Validators.required],
  });

  buscarProv() {
    if (this.busqueda.length < 2) return;
    this.loadingProv.set(true);
    this.errorProv.set('');
    this.svc.buscarProveedores(this.busqueda).subscribe({
      next: d => { this.proveedores = d; this.loadingProv.set(false); },
      error: e => { this.errorProv.set(e.error?.title ?? 'Error al buscar proveedores'); this.loadingProv.set(false); },
    });
  }

  guardar() {
    if (!this.provSelId || this.form.invalid) return;
    this.loading.set(true);
    const v = this.form.getRawValue();
    this.svc.crearCompromiso(this.data.ano, {
      identificador:     this.provSelId,
      concepto:          v.concepto,
      montoComprometido: v.montoComprometido,
      nroCta:            v.nroCta,
      anoEro:            v.anoEro,
    }).subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set(e.error?.title ?? 'Error al guardar'); this.loading.set(false); },
    });
  }
}

// ── Componente principal ──────────────────────────────────────────────────────
@Component({
  selector: 'app-compromisos',
  standalone: true,
  imports: [
    ReactiveFormsModule, FormsModule, CurrencyPipe, DatePipe,
    MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule,
    MatTableModule, MatProgressSpinnerModule, MatDialogModule, MatTooltipModule,
    MatPaginatorModule,
    NuevoCompromisoDialogComponent,
    DetalleCompromisoDialogComponent,
  ],
  template: `
<div class="page-container">
  <div class="eyebrow">Administración Financiera</div>
  <div class="page-header">
    <h1 class="page-title" style="margin:0">Compromisos</h1>
    <button class="btn-header" (click)="nuevoCompromiso()"><mat-icon>add</mat-icon> Nuevo compromiso</button>
  </div>

  <div class="card filter-card">
    <form [formGroup]="form" (ngSubmit)="cargar()" class="filter-row">
      <mat-form-field appearance="outline" style="width:100px">
        <mat-label>Año</mat-label>
        <mat-icon matPrefix>calendar_today</mat-icon>
        <input matInput formControlName="ano" maxlength="4" />
      </mat-form-field>
      <mat-form-field appearance="outline" style="width:150px">
        <mat-label>Estado</mat-label>
        <select matNativeControl formControlName="estado">
          <option value="">Todos</option>
          <option value="P">Pendiente</option>
          <option value="A">Autorizado</option>
          <option value="E">Ejecutado</option>
          <option value="C">Cancelado</option>
        </select>
      </mat-form-field>
      <mat-form-field appearance="outline" style="flex:1;min-width:180px">
        <mat-label>Proveedor</mat-label>
        <mat-icon matPrefix>business</mat-icon>
        <input matInput formControlName="proveedor" placeholder="Nombre o CUIT" />
      </mat-form-field>
      <mat-form-field appearance="outline" style="width:160px">
        <mat-label>N° Compromiso</mat-label>
        <mat-icon matPrefix>tag</mat-icon>
        <input matInput formControlName="nroCompromiso" placeholder="Ej: 123" />
      </mat-form-field>
      <button class="btn-action" type="submit" [disabled]="loading()">
        {{ loading() ? 'Cargando…' : 'Buscar' }}
      </button>
    </form>
  </div>

  @if (compromisos().length || loading()) {
    <div class="card" style="padding:0;overflow:hidden;margin-top:var(--spacing-md)">
      <div class="card-header">
        <mat-icon>handshake</mat-icon>
        <span>{{ totalItems() }} compromisos</span>
        @if (loading()) { <mat-spinner diameter="18" style="margin-left:8px" /> }
      </div>

      <table mat-table [dataSource]="compromisos()">
        <ng-container matColumnDef="nro">
          <th mat-header-cell *matHeaderCellDef>N°</th>
          <td mat-cell *matCellDef="let c"><strong>{{ c.nroCompromiso }}</strong></td>
        </ng-container>
        <ng-container matColumnDef="fecha">
          <th mat-header-cell *matHeaderCellDef>Fecha</th>
          <td mat-cell *matCellDef="let c">{{ c.fechaCompromiso ? (c.fechaCompromiso | date:'dd/MM/yyyy') : '—' }}</td>
        </ng-container>
        <ng-container matColumnDef="proveedor">
          <th mat-header-cell *matHeaderCellDef>Proveedor</th>
          <td mat-cell *matCellDef="let c">{{ c.nombreProveedor || c.identificador }}</td>
        </ng-container>
        <ng-container matColumnDef="concepto">
          <th mat-header-cell *matHeaderCellDef>Concepto</th>
          <td mat-cell *matCellDef="let c">{{ c.concepto }}</td>
        </ng-container>
        <ng-container matColumnDef="monto">
          <th mat-header-cell *matHeaderCellDef>Monto</th>
          <td mat-cell *matCellDef="let c"><strong>{{ c.montoComprometido | currency:'ARS':'symbol':'1.2-2' }}</strong></td>
        </ng-container>
        <ng-container matColumnDef="estado">
          <th mat-header-cell *matHeaderCellDef>Estado</th>
          <td mat-cell *matCellDef="let c">
            <span [class]="'badge badge--' + estadoClass(c.estadoCompromiso)">{{ estadoLabel(c.estadoCompromiso) }}</span>
          </td>
        </ng-container>
        <ng-container matColumnDef="accion">
          <th mat-header-cell *matHeaderCellDef></th>
          <td mat-cell *matCellDef="let c">
            <div class="accion-cell">
              <button class="icon-btn" (click)="verDetalle(c)" matTooltip="Ver detalle"><mat-icon>visibility</mat-icon></button>
              @if (c.estadoCompromiso === 'P') {
                <button class="icon-btn ok" (click)="cambiarEstado(c,'A')" matTooltip="Autorizar"><mat-icon>check_circle</mat-icon></button>
                <button class="icon-btn danger" (click)="cambiarEstado(c,'C')" matTooltip="Cancelar"><mat-icon>cancel</mat-icon></button>
              }
              @if (c.estadoCompromiso === 'A') {
                <button class="icon-btn ok" (click)="cambiarEstado(c,'E')" matTooltip="Marcar ejecutado"><mat-icon>done_all</mat-icon></button>
              }
            </div>
          </td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="cols"></tr>
        <tr mat-row *matRowDef="let row; columns: cols;"></tr>
      </table>

      <mat-paginator
        [length]="totalItems()"
        [pageSize]="pageSize"
        [pageIndex]="page"
        [pageSizeOptions]="[10, 20, 50, 100]"
        (page)="onPageChange($event)"
        showFirstLastButtons>
      </mat-paginator>
    </div>
  }
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
export class CompromisosComponent {
  private svc    = inject(FinancieroSAFService);
  private fb     = inject(FormBuilder);
  private dialog = inject(MatDialog);

  anoActual  = new Date().getFullYear().toString();
  form       = this.fb.nonNullable.group({
    ano:          [this.anoActual],
    estado:       [''],
    proveedor:    [''],
    nroCompromiso:[''],
  });
  loading     = signal(false);
  compromisos = signal<CompromisoSAF[]>([]);
  totalItems  = signal(0);
  page        = 0;
  pageSize    = 20;

  cols = ['nro','fecha','proveedor','concepto','monto','estado','accion'];

  cargar(resetPage = true) {
    if (resetPage) this.page = 0;
    this.loading.set(true);
    const { ano, estado, proveedor, nroCompromiso } = this.form.value;
    this.svc.compromisos(
      ano!, estado || undefined, undefined,
      this.page, this.pageSize,
      proveedor      || undefined,
      nroCompromiso  || undefined,
    ).subscribe({
      next: d => { this.compromisos.set(d.items); this.totalItems.set(d.total); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  onPageChange(e: PageEvent) {
    this.page     = e.pageIndex;
    this.pageSize = e.pageSize;
    this.cargar(false);
  }

  verDetalle(c: CompromisoSAF) {
    this.dialog.open(DetalleCompromisoDialogComponent, {
      data: c, width: '560px', maxWidth: '95vw',
    });
  }

  nuevoCompromiso() {
    this.dialog.open(NuevoCompromisoDialogComponent, {
      data: { ano: this.form.value.ano }, width: '500px', maxWidth: '95vw'
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  cambiarEstado(c: CompromisoSAF, estado: string) {
    this.svc.cambiarEstadoCompromiso(c.tipoCompromiso, c.anoCompromiso, c.nroCompromiso, estado)
      .subscribe(() => this.cargar());
  }

  estadoLabel(e: string) { return { P:'Pendiente', A:'Autorizado', E:'Ejecutado', C:'Cancelado' }[e] ?? e; }
  estadoClass(e: string) { return { P:'warning', A:'info', E:'success', C:'muted' }[e] ?? 'muted'; }
}
