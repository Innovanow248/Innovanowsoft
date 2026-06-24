import { Component, inject, signal } from '@angular/core';
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
import { DevengamientoService, ConceptoDevengamiento, ConceptoAnio, TipoTributo } from '../../../core/services/devengamiento.service';

@Component({
  selector: 'app-clonar-conceptos-anio-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule,
            MatSelectModule, MatButtonModule, MatIconModule, MatProgressSpinnerModule],
  template: `
<h2 mat-dialog-title><mat-icon>content_copy</mat-icon> Clonar conceptos por año</h2>
<mat-dialog-content style="min-width:400px; padding-top:12px!important">
  <form [formGroup]="form" class="dlg-form">
    <mat-form-field appearance="outline" class="full">
      <mat-label>Tributo (opcional)</mat-label>
      <mat-select formControlName="idTipoTributo">
        <mat-option [value]="null">— Todos —</mat-option>
        @for (t of data.tributos; track t.idTipoTributo) {
          <mat-option [value]="t.idTipoTributo">{{ t.tipoTributo_ }} — {{ t.concepto }}</mat-option>
        }
      </mat-select>
    </mat-form-field>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Ejercicio origen</mat-label>
      <input matInput formControlName="ejercicioOrigen" placeholder="Ej: 2024" maxlength="4" />
    </mat-form-field>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Ejercicio destino</mat-label>
      <input matInput formControlName="ejercicioDestino" placeholder="Ej: 2025" maxlength="4" />
    </mat-form-field>
    @if (error()) { <div class="dlg-error">{{ error() }}</div> }
    @if (exito()) { <div class="dlg-ok">{{ exito() }}</div> }
  </form>
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button (click)="ref.close(!!exito())">{{ exito() ? 'Cerrar' : 'Cancelar' }}</button>
  @if (!exito()) {
    <button mat-flat-button color="primary" (click)="clonar()" [disabled]="form.invalid || loading()">
      @if (loading()) { <mat-spinner diameter="18" /> } @else { Clonar }
    </button>
  }
</mat-dialog-actions>`,
  styles: [`.dlg-form{display:flex;flex-direction:column;gap:12px;} .full{width:100%;}
            .dlg-error{background:#fef2f2;color:#b91c1c;padding:8px 12px;border-radius:4px;font-size:13px;}
            .dlg-ok{background:#f0fdf4;color:#166534;padding:8px 12px;border-radius:4px;font-size:13px;}`]
})
export class ClonarConceptosAnioDialogComponent {
  ref  = inject(MatDialogRef<ClonarConceptosAnioDialogComponent>);
  data = inject<{ tributos: TipoTributo[] }>(MAT_DIALOG_DATA);
  svc  = inject(DevengamientoService);

  loading = signal(false);
  error   = signal('');
  exito   = signal('');

  form = inject(FormBuilder).group({
    idTipoTributo:    [null as number | null],
    ejercicioOrigen:  ['', [Validators.required, Validators.pattern(/^\d{4}$/)]],
    ejercicioDestino: ['', [Validators.required, Validators.pattern(/^\d{4}$/)]],
  });

  clonar() {
    if (this.form.invalid) return;
    this.loading.set(true); this.error.set(''); this.exito.set('');
    const v = this.form.value;
    this.svc.clonarConceptosAnio(v.ejercicioOrigen!, v.ejercicioDestino!, v.idTipoTributo ?? undefined).subscribe({
      next: r => { this.loading.set(false); this.exito.set(`Se clonaron ${r.insertados} conceptos correctamente.`); },
      error: e => { this.loading.set(false); this.error.set(e.error?.mensaje ?? 'Error al clonar.'); },
    });
  }
}

// ── Dialog: Editar valor año ───────────────────────────────────────────────────
@Component({
  selector: 'app-editar-anio-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule,
            MatButtonModule, MatIconModule, MatProgressSpinnerModule],
  template: `
<h2 mat-dialog-title><mat-icon>edit_calendar</mat-icon> Editar año {{ data.anio.anioEjercicio }}</h2>
<mat-dialog-content style="min-width:360px; padding-top:12px!important">
  <form [formGroup]="form" class="dlg-form">
    <mat-form-field appearance="outline" class="full">
      <mat-label>Porcentaje</mat-label>
      <input matInput type="number" step="0.00001" formControlName="porcentaje" />
      <span matSuffix>%</span>
    </mat-form-field>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Valor</mat-label>
      <input matInput type="number" step="0.01" formControlName="valor" />
      <span matPrefix>$&nbsp;</span>
    </mat-form-field>
    @if (error()) { <div class="dlg-error">{{ error() }}</div> }
  </form>
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="loading()">
    @if (loading()) { <mat-spinner diameter="18" /> } @else { Guardar }
  </button>
</mat-dialog-actions>`,
  styles: [`
    h2[mat-dialog-title] { display:flex; align-items:center; gap:10px; mat-icon { color:var(--color-primary); } }
    .dlg-form { display:flex; flex-direction:column; gap:4px; }
    .full { width:100%; }
    .dlg-error { background:#fef2f2; color:#b91c1c; padding:8px 12px; border-radius:4px; font-size:13px; }
    .btn-ok { height:36px; padding:0 20px; background:var(--color-primary); color:#fff;
      border:none; border-radius:4px; font-size:14px; cursor:pointer; display:inline-flex; align-items:center; gap:6px;
      &:disabled { opacity:.55; cursor:not-allowed; } }
  `],
})
export class EditarAnioDialogComponent {
  private svc = inject(DevengamientoService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<EditarAnioDialogComponent>);
  data: { anio: ConceptoAnio } = inject(MAT_DIALOG_DATA);

  loading = signal(false);
  error   = signal('');

  form = this.fb.nonNullable.group({
    porcentaje: [this.data.anio.porcentaje ?? null],
    valor:      [this.data.anio.valor ?? null],
  });

  guardar() {
    this.loading.set(true);
    const v = this.form.getRawValue();
    this.svc.actualizarConceptoAnio(this.data.anio.idTipoconAnio, {
      anioEjercicio: this.data.anio.anioEjercicio,
      porcentaje: v.porcentaje,
      valor: v.valor,
      usuario: 'SISTEMA',
    }).subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set(e.error?.title ?? 'Error'); this.loading.set(false); },
    });
  }
}

// ── Componente principal: Vinculación Conceptos-Año ───────────────────────────
@Component({
  selector: 'app-conceptos-anio',
  standalone: true,
  imports: [
    ReactiveFormsModule, NgClass, DecimalPipe,
    MatFormFieldModule, MatInputModule, MatSelectModule,
    MatButtonModule, MatIconModule, MatTableModule,
    MatProgressSpinnerModule, MatTooltipModule, MatDialogModule,
    ClonarConceptosAnioDialogComponent,
  ],
  template: `
<div class="page-container">
  <div class="eyebrow">Devengamiento</div>
  <div class="page-header">
    <h1 class="page-title">Vinculación Conceptos — Año</h1>
    <button mat-stroked-button (click)="clonar()">
      <mat-icon>content_copy</mat-icon> Clonar año
    </button>
  </div>
  <p class="page-desc">
    Seleccioná un tipo de tributo y un año para ver y gestionar los valores de cada concepto.
  </p>

  <!-- Selector de tributo + año -->
  <div class="card filter-card">
    <mat-form-field appearance="outline" style="width:300px">
      <mat-label>Tipo de tributo</mat-label>
      <mat-select [formControl]="filtroTributo" (selectionChange)="onFiltroChange()">
        <mat-option [value]="null">— Seleccioná —</mat-option>
        @for (t of tributos(); track t.idTipoTributo) {
          <mat-option [value]="t.idTipoTributo">{{ t.tipoTributo_ }} — {{ t.concepto }}</mat-option>
        }
      </mat-select>
    </mat-form-field>
    <mat-form-field appearance="outline" style="width:150px">
      <mat-label>Año ejercicio</mat-label>
      <input matInput type="number" [formControl]="filtroAnio" (keyup.enter)="onFiltroChange()" />
      <button mat-icon-button matSuffix (click)="onFiltroChange()"><mat-icon>search</mat-icon></button>
    </mat-form-field>
  </div>

  @if (errorCarga()) {
    <div class="error-carga"><mat-icon>warning</mat-icon>{{ errorCarga() }}</div>
  }

  @if (!filtroTributo.value && !loading()) {
    <div class="hint-state">
      <mat-icon>tune</mat-icon>
      <p>Seleccioná un tributo para ver los conceptos del año.</p>
    </div>
  } @else if (loading()) {
    <div class="center-spinner"><mat-spinner diameter="44" /></div>
  } @else if (!errorCarga() && conceptos().length > 0) {

    <!-- Agregar año a concepto -->
    <div class="card add-card">
      <h3><mat-icon>add_circle_outline</mat-icon> Asignar año a un concepto</h3>
      <form [formGroup]="addForm" class="add-form">
        <mat-form-field appearance="outline" style="width:280px">
          <mat-label>Concepto</mat-label>
          <mat-select formControlName="idConcepto">
            @for (c of conceptos(); track c.idTipoConcepto) {
              <mat-option [value]="c.idTipoConcepto">{{ c.concepto }} — {{ c.descripcion }}</mat-option>
            }
          </mat-select>
        </mat-form-field>
        <mat-form-field appearance="outline" style="width:130px">
          <mat-label>Año</mat-label>
          <input matInput type="number" formControlName="anio" />
        </mat-form-field>
        <mat-form-field appearance="outline" style="width:140px">
          <mat-label>Porcentaje</mat-label>
          <input matInput type="number" step="0.01" formControlName="porcentaje" />
          <span matSuffix>%</span>
        </mat-form-field>
        <mat-form-field appearance="outline" style="width:140px">
          <mat-label>Valor</mat-label>
          <input matInput type="number" step="0.01" formControlName="valor" />
          <span matPrefix>$&nbsp;</span>
        </mat-form-field>
        <button class="btn-add" (click)="agregarAnio()" [disabled]="addForm.invalid || loadingAdd()">
          @if (loadingAdd()) { <mat-spinner diameter="16" /> } @else {
            <mat-icon>add</mat-icon> Asignar
          }
        </button>
      </form>
      @if (errorAdd()) { <div class="dlg-error">{{ errorAdd() }}</div> }
    </div>

    <!-- Tabla de conceptos con sus valores para el año seleccionado -->
    <div class="card table-card">
      <div class="card-header">
        <mat-icon>link</mat-icon>
        <span>Conceptos para tributo {{ nombreTributo(filtroTributo.value) }} — Año {{ filtroAnio.value }}</span>
        <span class="badge-count">{{ aniosDelAnio().length }} con valor</span>
      </div>

      @if (aniosDelAnio().length === 0) {
        <div class="empty-state"><mat-icon>link_off</mat-icon>
          <p>Sin conceptos con valor para el año {{ filtroAnio.value }}</p>
        </div>
      } @else {
        <table mat-table [dataSource]="aniosDelAnio()">
          <ng-container matColumnDef="concepto">
            <th mat-header-cell *matHeaderCellDef>Concepto</th>
            <td mat-cell *matCellDef="let a">
              <strong class="mono">{{ nombreConcepto(a.idTipoConcepto) }}</strong>
            </td>
          </ng-container>
          <ng-container matColumnDef="descripcion">
            <th mat-header-cell *matHeaderCellDef>Descripción</th>
            <td mat-cell *matCellDef="let a">{{ descripcionConcepto(a.idTipoConcepto) }}</td>
          </ng-container>
          <ng-container matColumnDef="porcentaje">
            <th mat-header-cell *matHeaderCellDef>Porcentaje</th>
            <td mat-cell *matCellDef="let a">
              @if (a.porcentaje != null) {
                <span class="chip chip-p">{{ a.porcentaje | number:'1.2-5' }} %</span>
              } @else { <span class="muted">—</span> }
            </td>
          </ng-container>
          <ng-container matColumnDef="valor">
            <th mat-header-cell *matHeaderCellDef>Valor</th>
            <td mat-cell *matCellDef="let a">
              @if (a.valor != null) {
                <span class="chip chip-v">$ {{ a.valor | number:'1.2-2' }}</span>
              } @else { <span class="muted">—</span> }
            </td>
          </ng-container>
          <ng-container matColumnDef="acciones">
            <th mat-header-cell *matHeaderCellDef></th>
            <td mat-cell *matCellDef="let a">
              <div class="accion-cell">
                <button class="icon-btn" (click)="editarAnio(a)" matTooltip="Editar valores">
                  <mat-icon>edit</mat-icon>
                </button>
                <button class="icon-btn danger" (click)="eliminarAnio(a)" matTooltip="Desvincular">
                  <mat-icon>link_off</mat-icon>
                </button>
              </div>
            </td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="cols"></tr>
          <tr mat-row *matRowDef="let r; columns: cols;"></tr>
        </table>
      }
    </div>
  } @else if (!errorCarga() && filtroTributo.value) {
    <div class="empty-state"><mat-icon>inbox</mat-icon><p>Sin conceptos para el tributo seleccionado</p></div>
  }
</div>`,
  styles: [`
    .page-header  { display:flex; align-items:center; justify-content:space-between; margin-bottom:4px; }
    .page-desc    { color:var(--color-text-muted); font-size:14px; margin:0 0 var(--spacing-md); }
    .filter-card  { padding:var(--spacing-md) var(--spacing-lg); margin-bottom:var(--spacing-md); display:flex; gap:16px; flex-wrap:wrap; }
    .add-card     { padding:var(--spacing-md) var(--spacing-lg); margin-bottom:var(--spacing-md);
                    h3 { display:flex; align-items:center; gap:8px; font-size:14px; font-weight:600; margin:0 0 12px;
                         mat-icon { font-size:18px; color:var(--color-primary); } } }
    .add-form     { display:flex; gap:12px; flex-wrap:wrap; align-items:flex-start; }
    .btn-add      { height:56px; padding:0 16px; background:var(--color-primary); color:#fff;
                    border:none; border-radius:4px; font-size:14px; cursor:pointer;
                    display:inline-flex; align-items:center; gap:6px;
                    &:disabled { opacity:.55; } mat-icon { font-size:18px; } }
    .table-card   { padding:0; overflow:hidden; }
    .card-header  { display:flex; align-items:center; gap:8px; padding:var(--spacing-sm) var(--spacing-lg);
                    border-bottom:1px solid var(--color-border); font-weight:700; font-size:14px;
                    mat-icon { color:var(--color-primary); font-size:20px; width:20px; height:20px; }
                    .badge-count { margin-left:auto; background:var(--color-primary); color:#fff;
                                   font-size:11px; padding:2px 8px; border-radius:10px; font-weight:600; } }
    .empty-state  { text-align:center; padding:48px; color:var(--color-text-muted);
                    mat-icon { font-size:40px; display:block; margin:0 auto 8px; opacity:.4; } }
    .hint-state   { text-align:center; padding:60px; color:var(--color-text-muted);
                    mat-icon { font-size:48px; display:block; margin:0 auto 12px; opacity:.3; } }
    .error-carga  { display:flex; align-items:center; gap:10px; background:#fef2f2; color:#b91c1c;
                    border:1px solid #fecaca; border-radius:8px; padding:14px 18px; margin-bottom:16px; }
    .dlg-error    { background:#fef2f2; color:#b91c1c; padding:8px 12px; border-radius:4px; font-size:13px; margin-top:6px; }
    .center-spinner { text-align:center; padding:60px; }
    .mono  { font-family:monospace; color:var(--color-primary); font-size:13px; }
    .muted { color:var(--color-text-muted); font-size:12px; }
    .chip    { padding:2px 8px; border-radius:12px; font-size:11px; font-weight:600; }
    .chip-p  { background:#dbeafe; color:#1d4ed8; }
    .chip-v  { background:#d1fae5; color:#065f46; }
    .accion-cell { display:flex; gap:2px; justify-content:flex-end; }
    .icon-btn { background:none; border:none; cursor:pointer; border-radius:4px; padding:4px;
                display:flex; align-items:center;
                mat-icon { font-size:18px; color:#64748b; }
                &:hover { background:var(--color-surface-alt,#f1f5f9); }
                &.danger mat-icon { color:#dc2626; } }
  `],
})
export class ConceptosAnioComponent {
  private svc    = inject(DevengamientoService);
  private dialog = inject(MatDialog);
  private fb     = inject(FormBuilder);

  clonar() {
    this.dialog.open(ClonarConceptosAnioDialogComponent, {
      data: { tributos: this.tributos() }, width: '480px',
    }).afterClosed().subscribe(ok => { if (ok) this.onFiltroChange(); });
  }

  filtroTributo = new FormControl<number | null>(null);
  filtroAnio    = new FormControl<number>(new Date().getFullYear());

  loading    = signal(false);
  errorCarga = signal('');
  loadingAdd = signal(false);
  errorAdd   = signal('');

  tributos  = signal<TipoTributo[]>([]);
  conceptos = signal<ConceptoDevengamiento[]>([]);

  // Todos los anios de los conceptos del tributo seleccionado, filtrados por año
  aniosDelAnio = signal<ConceptoAnio[]>([]);

  cols = ['concepto', 'descripcion', 'porcentaje', 'valor', 'acciones'];

  addForm = this.fb.nonNullable.group({
    idConcepto:  [null as number | null, Validators.required],
    anio:        [new Date().getFullYear(), [Validators.required, Validators.min(2000)]],
    porcentaje:  [null as number | null],
    valor:       [null as number | null],
  });

  constructor() {
    this.svc.tributos().subscribe(t => this.tributos.set(t));
  }

  onFiltroChange() {
    const tributo = this.filtroTributo.value;
    const anio    = this.filtroAnio.value;
    if (!tributo || !anio) return;
    this.cargar(tributo, anio);
  }

  cargar(tributo: number, anio: number) {
    this.loading.set(true);
    this.errorCarga.set('');
    this.svc.conceptos(tributo).subscribe({
      next: cs => {
        this.conceptos.set(cs);
        // Recopilar todos los anios de todos los conceptos para el año seleccionado
        const todos: ConceptoAnio[] = cs.flatMap(c => (c.anios ?? []).filter(a => a.anioEjercicio === anio));
        this.aniosDelAnio.set(todos);
        this.loading.set(false);
      },
      error: e => { this.loading.set(false); this.errorCarga.set(e.status === 0 ? 'Sin conexión.' : `Error ${e.status}`); },
    });
  }

  nombreTributo(id: number | null) {
    return this.tributos().find(t => t.idTipoTributo === id)?.tipoTributo_ ?? '';
  }

  nombreConcepto(id: number) {
    return this.conceptos().find(c => c.idTipoConcepto === id)?.concepto ?? String(id);
  }

  descripcionConcepto(id: number) {
    return this.conceptos().find(c => c.idTipoConcepto === id)?.descripcion ?? '';
  }

  agregarAnio() {
    if (this.addForm.invalid) return;
    this.loadingAdd.set(true);
    this.errorAdd.set('');
    const v = this.addForm.getRawValue();
    this.svc.crearConceptoAnio(v.idConcepto!, {
      anioEjercicio: v.anio,
      porcentaje: v.porcentaje,
      valor: v.valor,
      usuario: 'SISTEMA',
    }).subscribe({
      next: () => {
        this.addForm.patchValue({ idConcepto: null, porcentaje: null, valor: null });
        this.loadingAdd.set(false);
        this.cargar(this.filtroTributo.value!, this.filtroAnio.value!);
      },
      error: e => { this.errorAdd.set(e.error?.title ?? 'Error'); this.loadingAdd.set(false); },
    });
  }

  editarAnio(a: ConceptoAnio) {
    this.dialog.open(EditarAnioDialogComponent, {
      data: { anio: a }, width: '400px', maxWidth: '96vw',
    }).afterClosed().subscribe(ok => {
      if (ok) this.cargar(this.filtroTributo.value!, this.filtroAnio.value!);
    });
  }

  eliminarAnio(a: ConceptoAnio) {
    const nombre = this.nombreConcepto(a.idTipoConcepto);
    if (!confirm(`¿Desvincular el año ${a.anioEjercicio} del concepto "${nombre}"?`)) return;
    this.svc.eliminarConceptoAnio(a.idTipoconAnio).subscribe({
      next: () => {
        this.aniosDelAnio.update(list => list.filter(x => x.idTipoconAnio !== a.idTipoconAnio));
      },
    });
  }
}
