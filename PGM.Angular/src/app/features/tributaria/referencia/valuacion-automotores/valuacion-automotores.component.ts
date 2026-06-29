import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { CurrencyPipe, DecimalPipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog, MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { TributariaService } from '../../../../core/services/tributaria.service';

// ── Dialog edición/alta ───────────────────────────────────────────────────────
@Component({
  selector: 'app-valuacion-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule],
  template: `
<div class="dlg-header">
  <mat-icon>{{ data ? 'edit' : 'add_circle' }}</mat-icon>
  <h2>{{ data ? 'Editar valuación' : 'Nueva valuación' }}</h2>
</div>
<mat-dialog-content>
  <form [formGroup]="form" class="form-grid">
    <mat-form-field appearance="outline">
      <mat-label>Año valuación</mat-label>
      <input matInput formControlName="anoValuacion" maxlength="4" [readonly]="!!data" />
    </mat-form-field>
    <mat-form-field appearance="outline">
      <mat-label>CIP</mat-label>
      <input matInput formControlName="cip" [readonly]="!!data" />
    </mat-form-field>
    <mat-form-field appearance="outline">
      <mat-label>Año modelo vehículo</mat-label>
      <input matInput type="number" formControlName="modeloValuacion" [readonly]="!!data" />
    </mat-form-field>
    <mat-form-field appearance="outline">
      <mat-label>Base imponible ($)</mat-label>
      <input matInput type="number" step="100" formControlName="baseImponible" />
    </mat-form-field>
  </form>
  @if (error()) { <div class="msg-err">{{ error() }}</div> }
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="form.invalid || loading()">
    {{ loading() ? 'Guardando…' : 'Guardar' }}
  </button>
</mat-dialog-actions>`,
  styles: [`.dlg-header{display:flex;align-items:center;gap:10px;padding:20px 24px 0;color:#1e293b;h2{margin:0;font-size:18px}}
    mat-dialog-content{min-width:380px} .form-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;padding:16px 0}
    .msg-err{background:#fef2f2;color:#b91c1c;padding:8px 12px;border-radius:4px;font-size:13px;grid-column:1/-1}
    .btn-ok{height:36px;padding:0 20px;background:var(--color-primary);color:#fff;border:none;border-radius:4px;font-size:14px;cursor:pointer;
    &:disabled{opacity:.55;cursor:not-allowed}}`],
})
export class ValuacionDialogComponent {
  private svc = inject(TributariaService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<ValuacionDialogComponent>);
  data: any = inject(MAT_DIALOG_DATA);

  loading = signal(false);
  error   = signal('');

  form = this.fb.nonNullable.group({
    anoValuacion:   [this.data?.anoValuacion ?? '', Validators.required],
    cip:            [this.data?.cip ?? '', Validators.required],
    modeloValuacion:[this.data?.modeloValuacion ?? new Date().getFullYear(), Validators.required],
    baseImponible:  [this.data?.baseImponible ?? 0, [Validators.required, Validators.min(0)]],
  });

  guardar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    const body = this.form.getRawValue();
    const obs = this.data
      ? this.svc.actualizarValuacion(body)
      : this.svc.crearValuacion(body);
    obs.subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set(e.error?.title ?? 'Error al guardar'); this.loading.set(false); },
    });
  }
}

// ── Componente principal ──────────────────────────────────────────────────────
@Component({
  selector: 'app-valuacion-automotores',
  standalone: true,
  imports: [ReactiveFormsModule, FormsModule, CurrencyPipe, DecimalPipe, MatIconModule, MatTableModule, MatButtonModule, MatFormFieldModule, MatInputModule, MatDialogModule],
  template: `
<div class="page-container">
  <div class="eyebrow">Administración Tributaria · Referencia</div>
  <div class="page-header">
    <h1 class="page-title">Valuación Automotores</h1>
    <button class="btn-header" (click)="nueva()">
      <mat-icon>add</mat-icon> Nueva
    </button>
  </div>

  <!-- Filtros -->
  <div class="card filter-card">
    <div class="filter-row">
      <mat-form-field appearance="outline" class="field-ano">
        <mat-label>Año valuación</mat-label>
        <select matNativeControl [ngModel]="anoSel" (ngModelChange)="cambiarAno($event)">
          <option value="">— Año —</option>
          @for (a of anos; track a) {
            <option [value]="a">{{ a }}</option>
          }
        </select>
      </mat-form-field>

      <mat-form-field appearance="outline" class="field-marca">
        <mat-label>Marca</mat-label>
        <select matNativeControl [ngModel]="filtroMarca" (ngModelChange)="cambiarMarca($event)"
                [disabled]="!anoSel || loadingMarcas()">
          <option value="">— Todas las marcas —</option>
          @for (m of marcas; track m) {
            <option [value]="m">{{ m }}</option>
          }
        </select>
      </mat-form-field>

      <mat-form-field appearance="outline" class="field-modelo">
        <mat-label>Modelo</mat-label>
        <select matNativeControl [(ngModel)]="filtroModelo" (ngModelChange)="buscar()"
                [disabled]="!filtroMarca || loadingModelos()">
          <option value="">— Todos los modelos —</option>
          @for (m of modelos; track m) {
            <option [value]="m">{{ m }}</option>
          }
        </select>
      </mat-form-field>

      <mat-form-field appearance="outline" class="field-cip">
        <mat-label>CIP</mat-label>
        <mat-icon matPrefix>search</mat-icon>
        <input matInput [(ngModel)]="filtroCip" (ngModelChange)="filtrarCip()" placeholder="Ej: 0010103" />
      </mat-form-field>
    </div>

    <div class="filter-footer">
      @if (loadingMarcas() || loadingModelos()) {
        <span class="hint"><mat-icon class="spin-sm">sync</mat-icon> Cargando…</span>
      }
      @if (todos.length) {
        <span class="filter-info">{{ filasFiltradas.length | number }} de {{ todos.length | number }} registros</span>
      }
      @if (filtroMarca || filtroModelo || filtroCip) {
        <button class="btn-limpiar" (click)="limpiarFiltros()">
          <mat-icon>filter_alt_off</mat-icon> Limpiar
        </button>
      }
    </div>
  </div>

  @if (!todos.length && !loading() && anoSel && !filtroMarca) {
    <div class="hint-seleccionar">
      <mat-icon>arrow_upward</mat-icon> Seleccioná una marca para ver los registros
    </div>
  }

  @if (loading()) {
    <div class="loading-msg"><mat-icon class="spin">sync</mat-icon> Cargando datos…</div>
  }

  @if (!loading() && filasFiltradas.length) {
    <div class="card table-card">
      <table mat-table [dataSource]="pagina">
        <ng-container matColumnDef="anoValuacion">
          <th mat-header-cell *matHeaderCellDef>Año</th>
          <td mat-cell *matCellDef="let v"><span class="chip">{{ v.anoValuacion }}</span></td>
        </ng-container>
        <ng-container matColumnDef="cip">
          <th mat-header-cell *matHeaderCellDef>CIP</th>
          <td mat-cell *matCellDef="let v"><code>{{ v.cip }}</code></td>
        </ng-container>
        <ng-container matColumnDef="marcaVehiculo">
          <th mat-header-cell *matHeaderCellDef>Marca / Tipo</th>
          <td mat-cell *matCellDef="let v"><span class="marca-chip">{{ v.marcaVehiculo || '—' }}</span></td>
        </ng-container>
        <ng-container matColumnDef="modeloValuacion">
          <th mat-header-cell *matHeaderCellDef>Año modelo</th>
          <td mat-cell *matCellDef="let v"><strong>{{ v.modeloValuacion }}</strong></td>
        </ng-container>
        <ng-container matColumnDef="baseImponible">
          <th mat-header-cell *matHeaderCellDef>Base imponible</th>
          <td mat-cell *matCellDef="let v"><strong>{{ v.baseImponible | currency:'ARS':'symbol':'1.0-0' }}</strong></td>
        </ng-container>
        <ng-container matColumnDef="alicuota">
          <th mat-header-cell *matHeaderCellDef>Alícuota</th>
          <td mat-cell *matCellDef="let v">{{ v.alicuota }}%</td>
        </ng-container>
        <ng-container matColumnDef="accion">
          <th mat-header-cell *matHeaderCellDef></th>
          <td mat-cell *matCellDef="let v" class="accion-cell">
            <button class="icon-btn" (click)="editar(v)" title="Editar"><mat-icon>edit</mat-icon></button>
            <button class="icon-btn danger" (click)="eliminar(v)" title="Eliminar"><mat-icon>delete</mat-icon></button>
          </td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="cols"></tr>
        <tr mat-row *matRowDef="let row; columns: cols;"></tr>
      </table>
    </div>

    <!-- Paginación simple -->
    @if (filasFiltradas.length > pageSize) {
      <div class="pagination">
        <button class="icon-btn" [disabled]="page === 0" (click)="setPage(page - 1)">
          <mat-icon>chevron_left</mat-icon>
        </button>
        <span>Página {{ page + 1 }} de {{ totalPages }}</span>
        <button class="icon-btn" [disabled]="page >= totalPages - 1" (click)="setPage(page + 1)">
          <mat-icon>chevron_right</mat-icon>
        </button>
      </div>
    }
  }

  @if (!loading() && !filasFiltradas.length && anoSel) {
    <div class="empty-state">Sin registros para el año {{ anoSel }}.</div>

  }
</div>`,
  styles: [`
    .page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:20px}
    .btn-header{display:flex;align-items:center;gap:6px;background:var(--color-primary);color:#fff;
      border:none;border-radius:6px;padding:0 16px;height:40px;font-size:14px;font-weight:600;cursor:pointer}
    .filter-card{padding:16px 20px;margin-bottom:16px}
    .filter-row{display:flex;gap:12px;flex-wrap:wrap;align-items:flex-start}
    .filter-footer{display:flex;align-items:center;gap:12px;margin-top:2px;flex-wrap:wrap}
    .field-ano{width:140px;flex-shrink:0}
    .field-marca{flex:2;min-width:220px}
    .field-modelo{flex:2;min-width:220px}
    .field-cip{width:180px;flex-shrink:0}
    .filter-info{font-size:13px;color:#64748b;white-space:nowrap}
    .hint{display:flex;align-items:center;gap:4px;font-size:12px;color:#94a3b8}
    .spin-sm{font-size:14px;animation:spin 1s linear infinite}
    .btn-limpiar{display:flex;align-items:center;gap:4px;background:none;border:1px solid #e2e8f0;
      border-radius:6px;padding:4px 12px;font-size:12px;color:#64748b;cursor:pointer;
      mat-icon{font-size:16px} &:hover{background:#f8fafc;color:#334155}}
    .hint-seleccionar{display:flex;align-items:center;gap:8px;color:#94a3b8;padding:32px 0;
      font-size:15px;justify-content:center; mat-icon{color:#cbd5e1}}
    .table-card{padding:0;overflow:hidden;overflow-x:auto}
    .chip{background:#e0f2fe;color:#0369a1;border-radius:6px;padding:2px 10px;font-size:12px;font-weight:700}
    .marca-chip{display:inline-block;background:#fef3c7;color:#92400e;border:1px solid #fcd34d;border-radius:6px;
      padding:3px 10px;font-size:13px;font-weight:700;letter-spacing:.2px;max-width:260px;white-space:nowrap;
      overflow:hidden;text-overflow:ellipsis}
    code{font-size:12px;background:#f1f5f9;padding:2px 6px;border-radius:4px}
    .accion-cell{display:flex;gap:4px;justify-content:flex-end}
    .icon-btn{background:none;border:none;cursor:pointer;border-radius:4px;padding:4px;display:flex;align-items:center;
      mat-icon{font-size:18px;color:#64748b} &:hover mat-icon{color:var(--color-primary)}
      &:disabled{opacity:.4;cursor:not-allowed}}
    .icon-btn.danger:hover mat-icon{color:#dc2626}
    .loading-msg{display:flex;align-items:center;gap:8px;color:#64748b;padding:20px 0}
    .spin{animation:spin 1s linear infinite} @keyframes spin{from{transform:rotate(0)}to{transform:rotate(360deg)}}
    .pagination{display:flex;align-items:center;gap:12px;justify-content:center;padding:16px;font-size:14px;color:#475569}
    .empty-state{text-align:center;color:#94a3b8;padding:40px;font-size:15px}
  `],
})
export class ValuacionAutomotoresComponent {
  private svc    = inject(TributariaService);
  private dialog = inject(MatDialog);

  loading        = signal(false);
  loadingMarcas  = signal(false);
  loadingModelos = signal(false);
  anos:    string[] = [];
  marcas:  string[] = [];
  modelos: string[] = [];
  anoSel       = '';
  filtroMarca  = '';
  filtroModelo = '';
  filtroCip    = '';
  todos:          any[] = [];
  filasFiltradas: any[] = [];
  page     = 0;
  pageSize = 100;
  cols = ['anoValuacion','cip','marcaVehiculo','modeloValuacion','baseImponible','alicuota','accion'];

  get pagina() { return this.filasFiltradas.slice(this.page * this.pageSize, (this.page + 1) * this.pageSize); }
  get totalPages() { return Math.ceil(this.filasFiltradas.length / this.pageSize); }

  constructor() {
    this.svc.anosValuacion().subscribe({
      next: d => { this.anos = d; if (d.length) { this.anoSel = d[0]; this.cargarMarcas(); } },
    });
  }

  cambiarAno(ano: string) {
    this.anoSel = ano;
    this.filtroMarca  = '';
    this.filtroModelo = '';
    this.filtroCip    = '';
    this.modelos = [];
    this.todos   = [];
    this.filasFiltradas = [];
    if (ano) this.cargarMarcas();
    else     this.marcas = [];
  }

  cargarMarcas() {
    this.loadingMarcas.set(true);
    this.svc.marcasAutomotores(this.anoSel).subscribe({
      next: d => { this.marcas = d; this.loadingMarcas.set(false); },
      error: () => this.loadingMarcas.set(false),
    });
  }

  cambiarMarca(marca: string) {
    this.filtroMarca  = marca;
    this.filtroModelo = '';
    this.filtroCip    = '';
    this.modelos = [];
    this.todos   = [];
    this.filasFiltradas = [];
    if (!marca) return;
    this.loadingModelos.set(true);
    this.svc.modelosAutomotores(this.anoSel, marca).subscribe({
      next: d => {
        this.modelos = d;
        this.loadingModelos.set(false);
        this.buscar();
      },
      error: () => this.loadingModelos.set(false),
    });
  }

  buscar() {
    this.loading.set(true);
    this.page = 0;
    this.svc.valuacionAutomotores(this.anoSel, this.filtroMarca, this.filtroModelo).subscribe({
      next: d => { this.todos = d; this.filtrarCip(); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  filtrarCip() {
    const f = this.filtroCip.trim().toLowerCase();
    this.filasFiltradas = f
      ? this.todos.filter(v => v.cip.toLowerCase().includes(f))
      : [...this.todos];
    this.page = 0;
  }

  limpiarFiltros() {
    this.filtroMarca  = '';
    this.filtroModelo = '';
    this.filtroCip    = '';
    this.modelos = [];
    this.todos   = [];
    this.filasFiltradas = [];
    this.page = 0;
  }

  setPage(p: number) { this.page = p; }

  nueva() {
    this.dialog.open(ValuacionDialogComponent, { data: null, width: '480px', maxWidth: '95vw' })
      .afterClosed().subscribe(ok => { if (ok) this.buscar(); });
  }

  editar(v: any) {
    this.dialog.open(ValuacionDialogComponent, { data: v, width: '480px', maxWidth: '95vw' })
      .afterClosed().subscribe(ok => { if (ok) this.buscar(); });
  }

  eliminar(v: any) {
    if (!confirm(`¿Eliminar valuación ${v.cip} modelo ${v.modeloValuacion} del año ${v.anoValuacion}?`)) return;
    this.svc.eliminarValuacion(v.anoValuacion, v.cip, v.modeloValuacion)
      .subscribe({ next: () => this.buscar() });
  }
}
