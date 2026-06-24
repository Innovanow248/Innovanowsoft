import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators, FormControl } from '@angular/forms';
import { NgClass, DecimalPipe, SlicePipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatChipsModule } from '@angular/material/chips';
import { MatDialogModule, MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { DevengamientoService, TipoPlanPago, TipoPlanPagoDetalle } from '../../../core/services/devengamiento.service';

// ── Dialog: Crear/Editar Plan ──────────────────────────────────────────────────
@Component({
  selector: 'app-plan-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule,
            MatSelectModule, MatButtonModule, MatIconModule, MatProgressSpinnerModule],
  template: `
<h2 mat-dialog-title>
  <mat-icon>{{ data ? 'edit' : 'add_circle' }}</mat-icon>
  {{ data ? 'Editar plan' : 'Nuevo plan de pago' }}
</h2>
<mat-dialog-content>
  <form [formGroup]="form" class="dlg-form">
    <div class="row-2">
      <mat-form-field appearance="outline">
        <mat-label>Código del plan</mat-label>
        <input matInput formControlName="codigoPlan" maxlength="10" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Período</mat-label>
        <input matInput formControlName="periodo" placeholder="ej: MENSUAL" />
      </mat-form-field>
    </div>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Designación / Nombre</mat-label>
      <input matInput formControlName="designacionPlan" />
    </mat-form-field>
    <div class="row-3">
      <mat-form-field appearance="outline">
        <mat-label>Cantidad de cuotas</mat-label>
        <input matInput type="number" formControlName="cantidadCuotas" min="1" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Día 1er vencimiento</mat-label>
        <input matInput type="number" formControlName="diaPrimerVencimiento" min="1" max="31" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Decreto / Resolución</mat-label>
        <input matInput formControlName="decretoResolucion" />
      </mat-form-field>
    </div>
    <div class="row-3">
      <mat-form-field appearance="outline">
        <mat-label>Solo uso devengamiento</mat-label>
        <mat-select formControlName="soloUsoDevengamiento">
          <mat-option [value]="null">—</mat-option>
          <mat-option value="S">Sí</mat-option>
          <mat-option value="N">No</mat-option>
        </mat-select>
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Actualizable</mat-label>
        <mat-select formControlName="actualizable">
          <mat-option [value]="null">—</mat-option>
          <mat-option value="S">Sí</mat-option>
          <mat-option value="N">No</mat-option>
        </mat-select>
      </mat-form-field>
    </div>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Observaciones</mat-label>
      <textarea matInput formControlName="observaciones" rows="2"></textarea>
    </mat-form-field>
    @if (error()) { <div class="dlg-error">{{ error() }}</div> }
  </form>
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="form.invalid || loading()">
    @if (loading()) { <mat-spinner diameter="18" /> } @else { Guardar }
  </button>
</mat-dialog-actions>`,
  styles: [`
    h2[mat-dialog-title] { display:flex; align-items:center; gap:10px; mat-icon { color:var(--color-primary); } }
    mat-dialog-content { min-width:560px; padding-top:8px!important; }
    .dlg-form { display:flex; flex-direction:column; gap:4px; padding:12px 0 4px; }
    .full  { width:100%; }
    .row-2 { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
    .row-3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:12px; }
    .dlg-error { background:#fef2f2; color:#b91c1c; padding:8px 12px; border-radius:4px; font-size:13px; }
    .btn-ok { height:36px; padding:0 20px; background:var(--color-primary); color:#fff;
      border:none; border-radius:4px; font-size:14px; cursor:pointer; display:inline-flex; align-items:center; gap:6px;
      &:disabled { opacity:.55; cursor:not-allowed; } }
  `],
})
export class PlanDialogComponent {
  private svc = inject(DevengamientoService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<PlanDialogComponent>);
  data: TipoPlanPago | null = inject(MAT_DIALOG_DATA);

  loading = signal(false);
  error   = signal('');

  form = this.fb.nonNullable.group({
    codigoPlan:           [this.data?.codigoPlan ?? '', Validators.required],
    designacionPlan:      [this.data?.designacionPlan ?? '', Validators.required],
    periodo:              [this.data?.periodo ?? ''],
    cantidadCuotas:       [this.data?.cantidadCuotas ?? null],
    diaPrimerVencimiento: [this.data?.diaPrimerVencimiento ?? null],
    decretoResolucion:    [this.data?.decretoResolucion ?? ''],
    soloUsoDevengamiento: [this.data?.soloUsoDevengamiento ?? null],
    actualizable:         [this.data?.actualizable ?? null],
    observaciones:        [this.data?.observaciones ?? ''],
  });

  guardar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.error.set('');
    const req = { ...this.form.getRawValue(), usuario: 'SISTEMA' };
    const obs = this.data
      ? this.svc.actualizarPlan(this.data.idTipoPlanespago, req)
      : this.svc.crearPlan(req);
    obs.subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set(e.error?.title ?? 'Error'); this.loading.set(false); },
    });
  }
}

// ── Dialog: Ver detalles del plan ──────────────────────────────────────────────
@Component({
  selector: 'app-plan-detalles-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, DecimalPipe, SlicePipe, MatDialogModule, MatFormFieldModule, MatInputModule,
            MatButtonModule, MatIconModule, MatTableModule, MatProgressSpinnerModule, MatTooltipModule],
  template: `
<h2 mat-dialog-title>
  <mat-icon>list_alt</mat-icon>
  Detalles — {{ data.codigoPlan }}: {{ data.designacionPlan }}
</h2>
<mat-dialog-content style="min-width:720px; max-width:900px">
  @if (detalles().length) {
    <table mat-table [dataSource]="detalles()" class="det-table">
      <ng-container matColumnDef="cuotas">
        <th mat-header-cell *matHeaderCellDef>Cuotas</th>
        <td mat-cell *matCellDef="let d">{{ d.cantMinCuotas }}—{{ d.cantMaxCuotas }}</td>
      </ng-container>
      <ng-container matColumnDef="deuda">
        <th mat-header-cell *matHeaderCellDef>Monto deuda</th>
        <td mat-cell *matCellDef="let d">
          @if (d.montoMinDeuda != null || d.montoMaxDeuda != null) {
            <span>&#36;{{ d.montoMinDeuda | number:'1.0-0' }} — &#36;{{ d.montoMaxDeuda | number:'1.0-0' }}</span>
          } @else { <span class="muted">—</span> }
        </td>
      </ng-container>
      <ng-container matColumnDef="interes">
        <th mat-header-cell *matHeaderCellDef>Interés</th>
        <td mat-cell *matCellDef="let d">
          {{ d.interesFinanciacion != null ? (d.interesFinanciacion + ' %') : '—' }}
        </td>
      </ng-container>
      <ng-container matColumnDef="vigencia">
        <th mat-header-cell *matHeaderCellDef>Vigencia</th>
        <td mat-cell *matCellDef="let d">
          <div class="fecha-cell">
            @if (d.fechaVigenteDesde) { <span>Desde: {{ d.fechaVigenteDesde | slice:0:10 }}</span> }
            @if (d.fechaVigenteHasta) { <span>Hasta: {{ d.fechaVigenteHasta | slice:0:10 }}</span> }
          </div>
        </td>
      </ng-container>
      <ng-container matColumnDef="acciones">
        <th mat-header-cell *matHeaderCellDef></th>
        <td mat-cell *matCellDef="let d">
          <button class="icon-btn danger" (click)="eliminarDetalle(d)" matTooltip="Eliminar">
            <mat-icon>delete</mat-icon>
          </button>
        </td>
      </ng-container>
      <tr mat-header-row *matHeaderRowDef="['cuotas','deuda','interes','vigencia','acciones']"></tr>
      <tr mat-row *matRowDef="let r; columns: ['cuotas','deuda','interes','vigencia','acciones'];"></tr>
    </table>
  } @else {
    <p class="empty-txt">Sin detalles cargados.</p>
  }

  <div class="add-section">
    <h3>Agregar detalle</h3>
    <form [formGroup]="detForm" class="det-form">
      <mat-form-field appearance="outline">
        <mat-label>Cuotas mín.</mat-label>
        <input matInput type="number" formControlName="cantMinCuotas" min="1" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Cuotas máx.</mat-label>
        <input matInput type="number" formControlName="cantMaxCuotas" min="1" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Interés financ. (%)</mat-label>
        <input matInput type="number" step="0.01" formControlName="interesFinanciacion" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Vigente desde</mat-label>
        <input matInput type="date" formControlName="fechaVigenteDesde" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Vigente hasta</mat-label>
        <input matInput type="date" formControlName="fechaVigenteHasta" />
      </mat-form-field>
      <button class="btn-add" (click)="agregarDetalle()" [disabled]="loadingAdd()">
        @if (loadingAdd()) { <mat-spinner diameter="16" /> } @else { <mat-icon>add</mat-icon> }
      </button>
    </form>
    @if (errorAdd()) { <div class="dlg-error">{{ errorAdd() }}</div> }
  </div>
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button (click)="ref.close(changed())">Cerrar</button>
</mat-dialog-actions>`,
  styles: [`
    h2[mat-dialog-title] { display:flex; align-items:center; gap:10px; mat-icon { color:var(--color-primary); } }
    .det-table { width:100%; }
    .empty-txt { color:var(--color-text-muted); text-align:center; padding:20px 0; }
    .fecha-cell { display:flex; flex-direction:column; gap:1px; font-size:12px; }
    .muted { color:var(--color-text-muted); font-size:12px; }
    .add-section { border-top:1px solid var(--color-border); margin-top:12px; padding-top:12px; }
    h3 { font-size:14px; font-weight:600; margin:0 0 8px; }
    .det-form { display:flex; gap:10px; flex-wrap:wrap; align-items:flex-start;
      mat-form-field { flex:1; min-width:110px; } }
    .btn-add { height:56px; padding:0 16px; background:var(--color-primary); color:#fff;
      border:none; border-radius:4px; cursor:pointer; display:inline-flex; align-items:center; gap:6px;
      &:disabled { opacity:.55; } mat-icon { font-size:20px; } }
    .dlg-error { background:#fef2f2; color:#b91c1c; padding:8px 12px; border-radius:4px; font-size:13px; margin-top:6px; }
    .icon-btn { background:none; border:none; cursor:pointer; border-radius:4px; padding:4px;
      display:inline-flex; align-items:center;
      &.danger mat-icon { font-size:18px; color:#dc2626; }
      &:hover { background:#fef2f2; } }
  `],
})
export class PlanDetallesDialogComponent {
  private svc = inject(DevengamientoService);
  private fb  = inject(FormBuilder);
  ref = inject(MatDialogRef<PlanDetallesDialogComponent>);
  data: TipoPlanPago = inject(MAT_DIALOG_DATA);

  detalles   = signal<TipoPlanPagoDetalle[]>(this.data.detalles ?? []);
  loadingAdd = signal(false);
  errorAdd   = signal('');
  changed    = signal(false);

  detForm = this.fb.nonNullable.group({
    cantMinCuotas:       [null as number | null],
    cantMaxCuotas:       [null as number | null],
    interesFinanciacion: [null as number | null],
    fechaVigenteDesde:   [''],
    fechaVigenteHasta:   [''],
  });

  agregarDetalle() {
    this.loadingAdd.set(true);
    this.errorAdd.set('');
    const v = this.detForm.getRawValue();
    this.svc.crearDetallePlan(this.data.idTipoPlanespago, { ...v, usuario: 'SISTEMA' }).subscribe({
      next: () => {
        this.changed.set(true);
        this.svc.detallesPlan(this.data.idTipoPlanespago).subscribe(d => this.detalles.set(d));
        this.detForm.reset();
        this.loadingAdd.set(false);
      },
      error: e => { this.errorAdd.set(e.error?.title ?? 'Error'); this.loadingAdd.set(false); },
    });
  }

  eliminarDetalle(d: TipoPlanPagoDetalle) {
    if (!confirm('¿Eliminar este detalle?')) return;
    this.svc.eliminarDetallePlan(d.idPlanesagoDet).subscribe({
      next: () => {
        this.changed.set(true);
        this.detalles.update(list => list.filter(x => x.idPlanesagoDet !== d.idPlanesagoDet));
      },
    });
  }
}

// ── Componente principal: Planes de Pago ──────────────────────────────────────
@Component({
  selector: 'app-planes-pago-dev',
  standalone: true,
  imports: [
    ReactiveFormsModule, NgClass, DecimalPipe,
    MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule,
    MatTableModule, MatProgressSpinnerModule, MatTooltipModule, MatChipsModule,
    MatDialogModule,
  ],
  template: `
<div class="page-container">
  <div class="eyebrow">Devengamiento</div>
  <div class="page-header">
    <h1 class="page-title">Tipos de Planes de Pago</h1>
    <button class="btn-header" (click)="abrirNuevo()">
      <mat-icon>add_circle</mat-icon> Nuevo plan
    </button>
  </div>

  <div class="card filter-card">
    <mat-form-field appearance="outline" style="width:360px">
      <mat-label>Buscar por código o nombre</mat-label>
      <input matInput [formControl]="busquedaCtrl" (keyup.enter)="cargar()" />
      <button mat-icon-button matSuffix (click)="cargar()"><mat-icon>search</mat-icon></button>
    </mat-form-field>
  </div>

  @if (errorCarga()) {
    <div class="error-carga"><mat-icon>warning</mat-icon>{{ errorCarga() }}</div>
  }

  @if (loading()) {
    <div class="center-spinner"><mat-spinner diameter="44" /></div>
  } @else if (!errorCarga()) {
    <div class="card table-card">
      <div class="card-header">
        <mat-icon>event_repeat</mat-icon>
        <span>{{ planes().length }} plan{{ planes().length !== 1 ? 'es' : '' }}</span>
      </div>
      @if (planes().length === 0) {
        <div class="empty-state"><mat-icon>inbox</mat-icon><p>Sin planes de pago</p></div>
      } @else {
        <table mat-table [dataSource]="planes()">
          <ng-container matColumnDef="codigo">
            <th mat-header-cell *matHeaderCellDef>Código</th>
            <td mat-cell *matCellDef="let p"><strong class="mono">{{ p.codigoPlan }}</strong></td>
          </ng-container>
          <ng-container matColumnDef="nombre">
            <th mat-header-cell *matHeaderCellDef>Designación</th>
            <td mat-cell *matCellDef="let p">{{ p.designacionPlan }}</td>
          </ng-container>
          <ng-container matColumnDef="cuotas">
            <th mat-header-cell *matHeaderCellDef>Cuotas</th>
            <td mat-cell *matCellDef="let p">{{ p.cantidadCuotas ?? '—' }}</td>
          </ng-container>
          <ng-container matColumnDef="periodo">
            <th mat-header-cell *matHeaderCellDef>Período</th>
            <td mat-cell *matCellDef="let p">{{ p.periodo || '—' }}</td>
          </ng-container>
          <ng-container matColumnDef="deveng">
            <th mat-header-cell *matHeaderCellDef>Dev.</th>
            <td mat-cell *matCellDef="let p">
              @if (p.soloUsoDevengamiento === 'S') {
                <span class="chip-dev">DEV</span>
              } @else { <span class="muted">—</span> }
            </td>
          </ng-container>
          <ng-container matColumnDef="decreto">
            <th mat-header-cell *matHeaderCellDef>Decreto</th>
            <td mat-cell *matCellDef="let p">{{ p.decretoResolucion || '—' }}</td>
          </ng-container>
          <ng-container matColumnDef="acciones">
            <th mat-header-cell *matHeaderCellDef></th>
            <td mat-cell *matCellDef="let p">
              <div class="accion-cell">
                <button class="icon-btn" (click)="abrirDetalles(p)" matTooltip="Ver detalles">
                  <mat-icon>list_alt</mat-icon>
                </button>
                <button class="icon-btn" (click)="abrirEditar(p)" matTooltip="Editar">
                  <mat-icon>edit</mat-icon>
                </button>
                <button class="icon-btn danger" (click)="eliminar(p)" matTooltip="Eliminar">
                  <mat-icon>delete</mat-icon>
                </button>
              </div>
            </td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="cols"></tr>
          <tr mat-row *matRowDef="let r; columns: cols;"></tr>
        </table>
      }
    </div>
  }
</div>`,
  styles: [`
    .page-header  { display:flex; align-items:center; justify-content:space-between; margin-bottom:var(--spacing-md); }
    .btn-header   { display:flex; align-items:center; gap:6px; background:var(--color-primary); color:#fff;
                    border:none; border-radius:6px; padding:0 16px; height:40px; font-size:14px; font-weight:600; cursor:pointer; }
    .filter-card  { padding:var(--spacing-md) var(--spacing-lg); margin-bottom:var(--spacing-md); }
    .table-card   { padding:0; overflow:hidden; }
    .card-header  { display:flex; align-items:center; gap:8px; padding:var(--spacing-sm) var(--spacing-lg);
                    border-bottom:1px solid var(--color-border); font-weight:700; font-size:14px;
                    mat-icon { color:var(--color-primary); font-size:20px; width:20px; height:20px; } }
    .empty-state  { text-align:center; padding:48px; color:var(--color-text-muted);
                    mat-icon { font-size:40px; display:block; margin:0 auto 8px; opacity:.4; } }
    .error-carga  { display:flex; align-items:center; gap:10px; background:#fef2f2; color:#b91c1c;
                    border:1px solid #fecaca; border-radius:8px; padding:14px 18px; margin-bottom:16px; }
    .center-spinner { text-align:center; padding:60px; }
    .mono      { font-family:monospace; color:var(--color-primary); font-size:13px; }
    .muted     { color:var(--color-text-muted); font-size:12px; }
    .chip-dev  { background:#fef3c7; color:#92400e; padding:2px 8px; border-radius:12px; font-size:11px; font-weight:700; }
    .accion-cell { display:flex; gap:2px; justify-content:flex-end; }
    .icon-btn { background:none; border:none; cursor:pointer; border-radius:4px; padding:4px;
                display:flex; align-items:center;
                mat-icon { font-size:18px; color:#64748b; }
                &:hover { background:var(--color-surface-alt,#f1f5f9); }
                &.danger mat-icon { color:#dc2626; } }
  `],
})
export class PlanesPagoDevComponent {
  private svc    = inject(DevengamientoService);
  private dialog = inject(MatDialog);

  busquedaCtrl = new FormControl('');
  loading      = signal(false);
  errorCarga   = signal('');
  planes       = signal<TipoPlanPago[]>([]);

  cols = ['codigo', 'nombre', 'cuotas', 'periodo', 'deveng', 'decreto', 'acciones'];

  constructor() {
    this.cargar();
  }

  cargar() {
    this.loading.set(true);
    this.errorCarga.set('');
    this.svc.planes(this.busquedaCtrl.value?.trim() || undefined).subscribe({
      next: d => { this.planes.set(d); this.loading.set(false); },
      error: e => { this.loading.set(false); this.errorCarga.set(e.status === 0 ? 'Sin conexión.' : `Error ${e.status}`); },
    });
  }

  abrirNuevo() {
    this.dialog.open(PlanDialogComponent, {
      data: null, width: '640px', maxWidth: '96vw',
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  abrirEditar(p: TipoPlanPago) {
    this.dialog.open(PlanDialogComponent, {
      data: p, width: '640px', maxWidth: '96vw',
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  abrirDetalles(p: TipoPlanPago) {
    this.svc.plan(p.idTipoPlanespago).subscribe(full => {
      this.dialog.open(PlanDetallesDialogComponent, {
        data: full, width: '860px', maxWidth: '96vw',
      }).afterClosed().subscribe(changed => { if (changed) this.cargar(); });
    });
  }

  eliminar(p: TipoPlanPago) {
    if (!confirm(`¿Eliminar el plan "${p.codigoPlan} — ${p.designacionPlan}"?`)) return;
    this.svc.eliminarPlan(p.idTipoPlanespago).subscribe({
      next: () => this.cargar(),
      error: e => alert('Error: ' + (e.error?.title ?? e.message)),
    });
  }
}
