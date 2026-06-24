import { Component, inject, signal, computed } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators, FormControl } from '@angular/forms';
import { NgClass, DecimalPipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialogModule, MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatChipsModule } from '@angular/material/chips';
import { DevengamientoService, ConceptoDevengamiento, TipoTributo, ConceptoAnio } from '../../../core/services/devengamiento.service';

// ── Dialog: Crear/Editar Concepto ─────────────────────────────────────────────
@Component({
  selector: 'app-concepto-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule,
            MatSelectModule, MatButtonModule, MatIconModule, MatProgressSpinnerModule],
  template: `
<h2 mat-dialog-title>
  <mat-icon>{{ data.concepto ? 'edit' : 'add_circle' }}</mat-icon>
  {{ data.concepto ? 'Editar concepto' : 'Nuevo concepto' }}
</h2>
<mat-dialog-content>
  <form [formGroup]="form" class="dlg-form">
    <div class="row-2">
      <mat-form-field appearance="outline">
        <mat-label>Código concepto</mat-label>
        <input matInput formControlName="concepto" style="text-transform:uppercase" maxlength="15" />
        <mat-hint>Máx. 15 caracteres</mat-hint>
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Tipo de tributo</mat-label>
        <mat-select formControlName="idTipoTributo">
          <mat-option [value]="null">— Sin asignar —</mat-option>
          @for (t of data.tributos; track t.idTipoTributo) {
            <mat-option [value]="t.idTipoTributo">{{ t.tipoTributo_ }} — {{ t.concepto }}</mat-option>
          }
        </mat-select>
      </mat-form-field>
    </div>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Descripción</mat-label>
      <input matInput formControlName="descripcion" />
    </mat-form-field>
    <div class="row-3">
      <mat-form-field appearance="outline">
        <mat-label>Impacto</mat-label>
        <mat-select formControlName="impacto">
          <mat-option [value]="null">—</mat-option>
          <mat-option value="P">P — Porcentaje</mat-option>
          <mat-option value="V">V — Valor fijo</mat-option>
        </mat-select>
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Porcentaje</mat-label>
        <input matInput type="number" formControlName="porcentaje" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Valor</mat-label>
        <input matInput type="number" formControlName="valor" />
      </mat-form-field>
    </div>
    <div class="row-2">
      <mat-form-field appearance="outline">
        <mat-label>Tipo cuota</mat-label>
        <input matInput formControlName="tipoCuota" maxlength="2" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Orden</mat-label>
        <input matInput type="number" formControlName="orden" />
      </mat-form-field>
    </div>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Objeto de referencia</mat-label>
      <input matInput formControlName="objetoRef" />
    </mat-form-field>
    @if (error()) {
      <div class="dlg-error">{{ error() }}</div>
    }
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
    .full { width:100%; }
    .row-2 { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
    .row-3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:12px; }
    .dlg-error { background:#fef2f2; color:#b91c1c; padding:8px 12px; border-radius:4px; font-size:13px; }
    .btn-ok { height:36px; padding:0 20px; background:var(--color-primary); color:#fff;
      border:none; border-radius:4px; font-size:14px; cursor:pointer; display:inline-flex; align-items:center; gap:6px;
      &:disabled { opacity:.55; cursor:not-allowed; } }
  `],
})
export class ConceptoDialogComponent {
  private svc = inject(DevengamientoService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<ConceptoDialogComponent>);
  data: { concepto: ConceptoDevengamiento | null; tributos: TipoTributo[] } = inject(MAT_DIALOG_DATA);

  loading = signal(false);
  error   = signal('');

  form = this.fb.nonNullable.group({
    concepto:        [this.data.concepto?.concepto ?? '', [Validators.required, Validators.maxLength(15)]],
    idTipoTributo:   [this.data.concepto?.idTipoTributo ?? null],
    descripcion:     [this.data.concepto?.descripcion ?? ''],
    impacto:         [this.data.concepto?.impacto ?? null],
    porcentaje:      [this.data.concepto?.porcentaje ?? null],
    valor:           [this.data.concepto?.valor ?? null],
    tipoCuota:       [this.data.concepto?.tipoCuota ?? ''],
    orden:           [this.data.concepto?.orden ?? null],
    objetoRef:       [this.data.concepto?.objetoRef ?? ''],
  });

  guardar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.error.set('');
    const v = this.form.getRawValue();
    const req = { ...v, concepto: (v.concepto as string).toUpperCase(), usuario: 'SISTEMA' };
    const obs = this.data.concepto
      ? this.svc.actualizarConcepto(this.data.concepto.idTipoConcepto, req)
      : this.svc.crearConcepto(req);
    obs.subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set(e.error?.title ?? 'Error al guardar'); this.loading.set(false); },
    });
  }
}

// ── Dialog: Gestionar años de un concepto ─────────────────────────────────────
@Component({
  selector: 'app-concepto-anios-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, DecimalPipe, MatDialogModule, MatFormFieldModule, MatInputModule,
            MatButtonModule, MatIconModule, MatTableModule, MatProgressSpinnerModule, MatTooltipModule],
  template: `
<h2 mat-dialog-title>
  <mat-icon>calendar_today</mat-icon>
  Valores por año — {{ data.concepto.concepto }}
</h2>
<mat-dialog-content style="min-width:600px">
  <!-- Tabla de años -->
  @if (anios().length) {
    <table mat-table [dataSource]="anios()" class="anios-table">
      <ng-container matColumnDef="anio">
        <th mat-header-cell *matHeaderCellDef>Año</th>
        <td mat-cell *matCellDef="let a"><strong>{{ a.anioEjercicio }}</strong></td>
      </ng-container>
      <ng-container matColumnDef="porcentaje">
        <th mat-header-cell *matHeaderCellDef>Porcentaje</th>
        <td mat-cell *matCellDef="let a">{{ a.porcentaje != null ? (a.porcentaje | number:'1.2-5') + ' %' : '—' }}</td>
      </ng-container>
      <ng-container matColumnDef="valor">
        <th mat-header-cell *matHeaderCellDef>Valor</th>
        <td mat-cell *matCellDef="let a">{{ a.valor != null ? ('$' + (a.valor | number:'1.2-2')) : '—' }}</td>
      </ng-container>
      <ng-container matColumnDef="acciones">
        <th mat-header-cell *matHeaderCellDef></th>
        <td mat-cell *matCellDef="let a">
          <button class="icon-btn danger" (click)="eliminarAnio(a)" matTooltip="Eliminar año">
            <mat-icon>delete</mat-icon>
          </button>
        </td>
      </ng-container>
      <tr mat-header-row *matHeaderRowDef="['anio','porcentaje','valor','acciones']"></tr>
      <tr mat-row *matRowDef="let r; columns: ['anio','porcentaje','valor','acciones'];"></tr>
    </table>
  } @else {
    <p class="empty-txt">Sin años registrados para este concepto.</p>
  }

  <!-- Formulario agregar año -->
  <div class="add-section">
    <h3>Agregar año</h3>
    <form [formGroup]="anioForm" class="anio-form">
      <mat-form-field appearance="outline">
        <mat-label>Año ejercicio</mat-label>
        <input matInput type="number" formControlName="anioEjercicio" placeholder="2025" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Porcentaje</mat-label>
        <input matInput type="number" step="0.01" formControlName="porcentaje" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Valor</mat-label>
        <input matInput type="number" step="0.01" formControlName="valor" />
      </mat-form-field>
      <button class="btn-add" (click)="agregarAnio()" [disabled]="anioForm.invalid || loadingAdd()">
        @if (loadingAdd()) { <mat-spinner diameter="16" /> } @else { <mat-icon>add</mat-icon> Agregar }
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
    .anios-table { width:100%; margin:8px 0; }
    .empty-txt { color:var(--color-text-muted); padding:16px 0; text-align:center; }
    .add-section { border-top:1px solid var(--color-border); margin-top:12px; padding-top:12px; }
    h3 { font-size:14px; font-weight:600; margin:0 0 8px; color:var(--color-text-heading); }
    .anio-form { display:flex; gap:12px; align-items:flex-start; flex-wrap:wrap;
      mat-form-field { flex:1; min-width:120px; } }
    .btn-add { height:56px; padding:0 16px; background:var(--color-primary); color:#fff;
      border:none; border-radius:4px; font-size:14px; cursor:pointer; display:inline-flex; align-items:center; gap:6px;
      &:disabled { opacity:.55; cursor:not-allowed; }
      mat-icon { font-size:18px; width:18px; height:18px; } }
    .dlg-error { background:#fef2f2; color:#b91c1c; padding:8px 12px; border-radius:4px; font-size:13px; margin-top:6px; }
    .icon-btn { background:none; border:none; cursor:pointer; border-radius:4px; padding:4px;
      display:inline-flex; align-items:center;
      &.danger mat-icon { font-size:18px; color:#dc2626; }
      &:hover { background:#fef2f2; } }
  `],
})
export class ConceptoAniosDialogComponent {
  private svc = inject(DevengamientoService);
  private fb  = inject(FormBuilder);
  ref = inject(MatDialogRef<ConceptoAniosDialogComponent>);
  data: { concepto: ConceptoDevengamiento } = inject(MAT_DIALOG_DATA);

  anios      = signal<ConceptoAnio[]>(this.data.concepto.anios ?? []);
  loadingAdd = signal(false);
  errorAdd   = signal('');
  changed    = signal(false);

  anioForm = this.fb.nonNullable.group({
    anioEjercicio: [new Date().getFullYear(), [Validators.required, Validators.min(2000), Validators.max(2100)]],
    porcentaje:    [null as number | null],
    valor:         [null as number | null],
  });

  agregarAnio() {
    if (this.anioForm.invalid) return;
    this.loadingAdd.set(true);
    this.errorAdd.set('');
    const v = this.anioForm.getRawValue();
    this.svc.crearConceptoAnio(this.data.concepto.idTipoConcepto, { ...v, usuario: 'SISTEMA' }).subscribe({
      next: () => {
        this.changed.set(true);
        this.svc.conceptoAnios(this.data.concepto.idTipoConcepto).subscribe(a => this.anios.set(a));
        this.anioForm.reset({ anioEjercicio: new Date().getFullYear(), porcentaje: null, valor: null });
        this.loadingAdd.set(false);
      },
      error: e => { this.errorAdd.set(e.error?.title ?? 'Error'); this.loadingAdd.set(false); },
    });
  }

  eliminarAnio(a: ConceptoAnio) {
    if (!confirm(`¿Eliminar el año ${a.anioEjercicio}?`)) return;
    this.svc.eliminarConceptoAnio(a.idTipoconAnio).subscribe({
      next: () => {
        this.changed.set(true);
        this.anios.update(list => list.filter(x => x.idTipoconAnio !== a.idTipoconAnio));
      },
    });
  }
}

// ── Componente principal: Conceptos de Devengamiento ─────────────────────────
@Component({
  selector: 'app-conceptos-dev',
  standalone: true,
  imports: [
    ReactiveFormsModule, NgClass, DecimalPipe,
    MatFormFieldModule, MatInputModule, MatSelectModule,
    MatButtonModule, MatIconModule, MatTableModule,
    MatProgressSpinnerModule, MatTooltipModule, MatChipsModule,
    MatDialogModule,
  ],
  template: `
<div class="page-container">
  <div class="eyebrow">Devengamiento</div>
  <div class="page-header">
    <h1 class="page-title">Conceptos de Devengamiento</h1>
    <button class="btn-header" (click)="abrirNuevo()">
      <mat-icon>add_circle</mat-icon> Nuevo concepto
    </button>
  </div>

  <!-- Filtros -->
  <div class="card filter-card">
    <mat-form-field appearance="outline" style="width:260px">
      <mat-label>Tipo de tributo</mat-label>
      <mat-select [formControl]="filtroTributo" (selectionChange)="cargar()">
        <mat-option [value]="null">Todos</mat-option>
        @for (t of tributos(); track t.idTipoTributo) {
          <mat-option [value]="t.idTipoTributo">{{ t.tipoTributo_ }} — {{ t.concepto }}</mat-option>
        }
      </mat-select>
    </mat-form-field>
    <mat-form-field appearance="outline" style="width:300px">
      <mat-label>Buscar por código o descripción</mat-label>
      <input matInput [formControl]="filtroBusqueda" (keyup.enter)="cargar()" />
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
        <mat-icon>receipt_long</mat-icon>
        <span>{{ conceptos().length }} concepto{{ conceptos().length !== 1 ? 's' : '' }}</span>
      </div>
      @if (conceptos().length === 0) {
        <div class="empty-state"><mat-icon>inbox</mat-icon><p>Sin conceptos para los filtros aplicados</p></div>
      } @else {
        <table mat-table [dataSource]="conceptos()">
          <ng-container matColumnDef="concepto">
            <th mat-header-cell *matHeaderCellDef>Código</th>
            <td mat-cell *matCellDef="let c"><strong class="mono">{{ c.concepto }}</strong></td>
          </ng-container>
          <ng-container matColumnDef="descripcion">
            <th mat-header-cell *matHeaderCellDef>Descripción</th>
            <td mat-cell *matCellDef="let c">{{ c.descripcion || '—' }}</td>
          </ng-container>
          <ng-container matColumnDef="tributo">
            <th mat-header-cell *matHeaderCellDef>Tributo</th>
            <td mat-cell *matCellDef="let c">
              @if (c.idTipoTributo) {
                <span class="badge">{{ nombreTributo(c.idTipoTributo) }}</span>
              } @else { <span class="muted">—</span> }
            </td>
          </ng-container>
          <ng-container matColumnDef="impacto">
            <th mat-header-cell *matHeaderCellDef>Impacto</th>
            <td mat-cell *matCellDef="let c">
              @if (c.impacto === 'P') { <span class="chip chip-p">% {{ c.porcentaje }}</span> }
              @else if (c.impacto === 'V') { <span class="chip chip-v">$ {{ c.valor }}</span> }
              @else { <span class="muted">—</span> }
            </td>
          </ng-container>
          <ng-container matColumnDef="anios">
            <th mat-header-cell *matHeaderCellDef>Años</th>
            <td mat-cell *matCellDef="let c">
              <span class="anio-count">{{ c.anios?.length ?? 0 }}</span>
            </td>
          </ng-container>
          <ng-container matColumnDef="acciones">
            <th mat-header-cell *matHeaderCellDef></th>
            <td mat-cell *matCellDef="let c">
              <div class="accion-cell">
                <button class="icon-btn" (click)="abrirAnios(c)" matTooltip="Gestionar años">
                  <mat-icon>calendar_today</mat-icon>
                </button>
                <button class="icon-btn" (click)="abrirEditar(c)" matTooltip="Editar">
                  <mat-icon>edit</mat-icon>
                </button>
                <button class="icon-btn danger" (click)="eliminar(c)" matTooltip="Eliminar">
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
    .page-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:var(--spacing-md); }
    .btn-header  { display:flex; align-items:center; gap:6px; background:var(--color-primary); color:#fff;
                   border:none; border-radius:6px; padding:0 16px; height:40px; font-size:14px; font-weight:600; cursor:pointer; }
    .filter-card { padding:var(--spacing-md) var(--spacing-lg); margin-bottom:var(--spacing-md); display:flex; gap:16px; flex-wrap:wrap; }
    .table-card  { padding:0; overflow:hidden; }
    .card-header { display:flex; align-items:center; gap:8px; padding:var(--spacing-sm) var(--spacing-lg);
                   border-bottom:1px solid var(--color-border); font-weight:700; font-size:14px;
                   mat-icon { color:var(--color-primary); font-size:20px; width:20px; height:20px; } }
    .empty-state { text-align:center; padding:48px; color:var(--color-text-muted);
                   mat-icon { font-size:40px; display:block; margin:0 auto 8px; opacity:.4; } }
    .error-carga { display:flex; align-items:center; gap:10px; background:#fef2f2; color:#b91c1c;
                   border:1px solid #fecaca; border-radius:8px; padding:14px 18px; margin-bottom:16px;
                   mat-icon { flex-shrink:0; } }
    .center-spinner { text-align:center; padding:60px; }
    .mono  { font-family:monospace; color:var(--color-primary); font-size:13px; }
    .muted { color:var(--color-text-muted); font-size:12px; }
    .badge { background:var(--color-surface-alt,#f1f5f9); border:1px solid var(--color-border);
             padding:2px 8px; border-radius:12px; font-size:11px; font-weight:600; color:#475569; }
    .chip      { padding:2px 8px; border-radius:12px; font-size:11px; font-weight:600; }
    .chip-p    { background:#dbeafe; color:#1d4ed8; }
    .chip-v    { background:#d1fae5; color:#065f46; }
    .anio-count { font-size:12px; font-weight:600; color:#7c3aed; }
    .accion-cell { display:flex; gap:2px; justify-content:flex-end; }
    .icon-btn { background:none; border:none; cursor:pointer; border-radius:4px; padding:4px;
                display:flex; align-items:center;
                mat-icon { font-size:18px; color:#64748b; }
                &:hover { background:var(--color-surface-alt,#f1f5f9); }
                &.danger mat-icon { color:#dc2626; } }
  `],
})
export class ConceptosDevComponent {
  private svc    = inject(DevengamientoService);
  private dialog = inject(MatDialog);

  filtroTributo  = new FormControl<number | null>(null);
  filtroBusqueda = new FormControl('');

  loading    = signal(false);
  errorCarga = signal('');
  tributos   = signal<TipoTributo[]>([]);
  conceptos  = signal<ConceptoDevengamiento[]>([]);

  cols = ['concepto', 'descripcion', 'tributo', 'impacto', 'anios', 'acciones'];

  constructor() {
    this.svc.tributos().subscribe(t => this.tributos.set(t));
    this.cargar();
  }

  cargar() {
    this.loading.set(true);
    this.errorCarga.set('');
    this.svc.conceptos(this.filtroTributo.value ?? undefined, this.filtroBusqueda.value?.trim() || undefined).subscribe({
      next: d => { this.conceptos.set(d); this.loading.set(false); },
      error: e => {
        this.loading.set(false);
        this.errorCarga.set(e.status === 0 ? 'Sin conexión con la API.' : `Error ${e.status}`);
      },
    });
  }

  nombreTributo(id: number) {
    return this.tributos().find(t => t.idTipoTributo === id)?.tipoTributo_ ?? String(id);
  }

  abrirNuevo() {
    this.dialog.open(ConceptoDialogComponent, {
      data: { concepto: null, tributos: this.tributos() }, width: '640px', maxWidth: '96vw',
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  abrirEditar(c: ConceptoDevengamiento) {
    this.dialog.open(ConceptoDialogComponent, {
      data: { concepto: c, tributos: this.tributos() }, width: '640px', maxWidth: '96vw',
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  abrirAnios(c: ConceptoDevengamiento) {
    this.svc.concepto(c.idTipoConcepto).subscribe(full => {
      this.dialog.open(ConceptoAniosDialogComponent, {
        data: { concepto: full }, width: '680px', maxWidth: '96vw',
      }).afterClosed().subscribe(changed => { if (changed) this.cargar(); });
    });
  }

  eliminar(c: ConceptoDevengamiento) {
    if (!confirm(`¿Eliminar el concepto "${c.concepto}"?`)) return;
    this.svc.eliminarConcepto(c.idTipoConcepto).subscribe({
      next: () => this.cargar(),
      error: e => alert('Error: ' + (e.error?.title ?? e.message)),
    });
  }
}
