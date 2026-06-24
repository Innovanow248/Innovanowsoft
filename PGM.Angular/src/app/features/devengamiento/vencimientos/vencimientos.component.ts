import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators, FormControl } from '@angular/forms';
import { NgClass, SlicePipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialogModule, MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { DevengamientoService, Vencimiento, TipoTributo } from '../../../core/services/devengamiento.service';

// ── Dialog: Clonar por año ────────────────────────────────────────────────────
@Component({
  selector: 'app-clonar-vencimientos-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule,
            MatSelectModule, MatButtonModule, MatIconModule, MatProgressSpinnerModule],
  template: `
<h2 mat-dialog-title><mat-icon>content_copy</mat-icon> Clonar vencimientos por año</h2>
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
export class ClonarVencimientosDialogComponent {
  ref  = inject(MatDialogRef<ClonarVencimientosDialogComponent>);
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
    this.svc.clonarVencimientos(v.ejercicioOrigen!, v.ejercicioDestino!, v.idTipoTributo ?? undefined).subscribe({
      next: r => { this.loading.set(false); this.exito.set(`Se clonaron ${r.insertados} vencimientos correctamente.`); },
      error: e => { this.loading.set(false); this.error.set(e.error?.mensaje ?? 'Error al clonar.'); },
    });
  }
}

function toDateInput(iso: string | null): string {
  return iso ? iso.substring(0, 10) : '';
}

// ── Dialog Vencimiento ─────────────────────────────────────────────────────────
@Component({
  selector: 'app-vencimiento-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule,
            MatSelectModule, MatButtonModule, MatIconModule, MatProgressSpinnerModule],
  template: `
<h2 mat-dialog-title>
  <mat-icon>{{ data.vencimiento ? 'edit' : 'add_circle' }}</mat-icon>
  {{ data.vencimiento ? 'Editar vencimiento' : 'Nuevo vencimiento' }}
</h2>
<mat-dialog-content>
  <form [formGroup]="form" class="dlg-form">
    <div class="row-2">
      <mat-form-field appearance="outline">
        <mat-label>Tipo de tributo</mat-label>
        <mat-select formControlName="idTipoTributo">
          @for (t of data.tributos; track t.idTipoTributo) {
            <mat-option [value]="t.idTipoTributo">{{ t.tipoTributo_ }} — {{ t.concepto }}</mat-option>
          }
        </mat-select>
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Ejercicio (año)</mat-label>
        <input matInput formControlName="ejercicio" placeholder="2025" maxlength="4" />
      </mat-form-field>
    </div>
    <div class="row-2">
      <mat-form-field appearance="outline">
        <mat-label>Nro. de cuota</mat-label>
        <input matInput type="number" formControlName="nroCuota" min="1" max="99" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Tipo</mat-label>
        <input matInput formControlName="nTipo" placeholder="ej: ORDINARIA" />
      </mat-form-field>
    </div>

    <div class="section-title">Fechas y descuentos</div>
    <div class="row-vto">
      <mat-form-field appearance="outline">
        <mat-label>1er vencimiento</mat-label>
        <input matInput type="date" formControlName="fechaPrimerVto" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Descuento 1er vto (%)</mat-label>
        <input matInput type="number" step="0.01" formControlName="descPrimerVto" />
      </mat-form-field>
    </div>
    <div class="row-vto">
      <mat-form-field appearance="outline">
        <mat-label>2do vencimiento</mat-label>
        <input matInput type="date" formControlName="fechaSegundoVto" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Descuento 2do vto (%)</mat-label>
        <input matInput type="number" step="0.01" formControlName="descSegundoVto" />
      </mat-form-field>
    </div>
    <div class="row-vto">
      <mat-form-field appearance="outline">
        <mat-label>3er vencimiento</mat-label>
        <input matInput type="date" formControlName="fechaTercerVto" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Descuento 3er vto (%)</mat-label>
        <input matInput type="number" step="0.01" formControlName="descTercerVto" />
      </mat-form-field>
    </div>

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
    .row-2   { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
    .row-vto { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
    .section-title { font-size:12px; font-weight:700; color:var(--color-text-muted); text-transform:uppercase;
                     letter-spacing:.06em; margin:4px 0 0; padding-bottom:4px; border-bottom:1px solid var(--color-border); }
    .dlg-error { background:#fef2f2; color:#b91c1c; padding:8px 12px; border-radius:4px; font-size:13px; }
    .btn-ok { height:36px; padding:0 20px; background:var(--color-primary); color:#fff;
      border:none; border-radius:4px; font-size:14px; cursor:pointer; display:inline-flex; align-items:center; gap:6px;
      &:disabled { opacity:.55; cursor:not-allowed; } }
  `],
})
export class VencimientoDialogComponent {
  private svc = inject(DevengamientoService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<VencimientoDialogComponent>);
  data: { vencimiento: Vencimiento | null; tributos: TipoTributo[] } = inject(MAT_DIALOG_DATA);

  loading = signal(false);
  error   = signal('');
  v       = this.data.vencimiento;

  form = this.fb.nonNullable.group({
    idTipoTributo:   [this.v?.idTipoTributo ?? (this.data.tributos[0]?.idTipoTributo ?? null), Validators.required],
    ejercicio:       [this.v?.ejercicio ?? String(new Date().getFullYear())],
    nroCuota:        [this.v?.nroCuota ?? 1, [Validators.required, Validators.min(1)]],
    nTipo:           [this.v?.nTipo ?? ''],
    nZona:           [this.v?.nZona ?? ''],
    fechaPrimerVto:  [toDateInput(this.v?.fechaPrimerVto ?? null), Validators.required],
    fechaSegundoVto: [toDateInput(this.v?.fechaSegundoVto ?? null)],
    fechaTercerVto:  [toDateInput(this.v?.fechaTercerVto ?? null)],
    descPrimerVto:   [this.v?.descPrimerVto ?? null],
    descSegundoVto:  [this.v?.descSegundoVto ?? null],
    descTercerVto:   [this.v?.descTercerVto ?? null],
  });

  guardar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.error.set('');
    const v = this.form.getRawValue();
    const req = { ...v, usuario: 'SISTEMA' };
    const obs = this.v
      ? this.svc.actualizarVencimiento(this.v.idVencimientos, req)
      : this.svc.crearVencimiento(req);
    obs.subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set(e.error?.title ?? 'Error al guardar'); this.loading.set(false); },
    });
  }
}

// ── Componente principal: Vencimientos ────────────────────────────────────────
@Component({
  selector: 'app-vencimientos-dev',
  standalone: true,
  imports: [
    ReactiveFormsModule, NgClass, SlicePipe,
    MatFormFieldModule, MatInputModule, MatSelectModule,
    MatButtonModule, MatIconModule, MatTableModule,
    MatProgressSpinnerModule, MatTooltipModule, MatDialogModule,
    ClonarVencimientosDialogComponent,
  ],
  template: `
<div class="page-container">
  <div class="eyebrow">Devengamiento</div>
  <div class="page-header">
    <h1 class="page-title">Vencimientos</h1>
    <button mat-stroked-button (click)="clonar()" style="margin-right:8px">
      <mat-icon>content_copy</mat-icon> Clonar año
    </button>
    <button class="btn-header" (click)="abrirNuevo()">
      <mat-icon>add_circle</mat-icon> Nuevo vencimiento
    </button>
  </div>

  <div class="card filter-card">
    <mat-form-field appearance="outline" style="width:280px">
      <mat-label>Tipo de tributo</mat-label>
      <mat-select [formControl]="filtroTributo" (selectionChange)="cargar()">
        <mat-option [value]="null">Todos</mat-option>
        @for (t of tributos(); track t.idTipoTributo) {
          <mat-option [value]="t.idTipoTributo">{{ t.tipoTributo_ }} — {{ t.concepto }}</mat-option>
        }
      </mat-select>
    </mat-form-field>
    <mat-form-field appearance="outline" style="width:130px">
      <mat-label>Ejercicio</mat-label>
      <input matInput [formControl]="filtroEjercicio" placeholder="2025" maxlength="4" (keyup.enter)="cargar()" />
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
        <mat-icon>event</mat-icon>
        <span>{{ vencimientos().length }} vencimiento{{ vencimientos().length !== 1 ? 's' : '' }}</span>
      </div>
      @if (vencimientos().length === 0) {
        <div class="empty-state"><mat-icon>event_busy</mat-icon><p>Sin vencimientos para los filtros aplicados</p></div>
      } @else {
        <table mat-table [dataSource]="vencimientos()">
          <ng-container matColumnDef="ejercicio">
            <th mat-header-cell *matHeaderCellDef>Ejercicio</th>
            <td mat-cell *matCellDef="let v"><strong>{{ v.ejercicio || '—' }}</strong></td>
          </ng-container>
          <ng-container matColumnDef="tributo">
            <th mat-header-cell *matHeaderCellDef>Tributo</th>
            <td mat-cell *matCellDef="let v">
              <span class="badge">{{ nombreTributo(v.idTipoTributo) }}</span>
            </td>
          </ng-container>
          <ng-container matColumnDef="cuota">
            <th mat-header-cell *matHeaderCellDef>Cuota</th>
            <td mat-cell *matCellDef="let v"><span class="cuota-num">{{ v.nroCuota }}</span></td>
          </ng-container>
          <ng-container matColumnDef="tipo">
            <th mat-header-cell *matHeaderCellDef>Tipo</th>
            <td mat-cell *matCellDef="let v">{{ v.nTipo || '—' }}</td>
          </ng-container>
          <ng-container matColumnDef="primerVto">
            <th mat-header-cell *matHeaderCellDef>1er Vto.</th>
            <td mat-cell *matCellDef="let v">
              <div class="fecha-cell">
                <span>{{ v.fechaPrimerVto | slice:0:10 }}</span>
                @if (v.descPrimerVto) { <span class="desc">{{ v.descPrimerVto }}%</span> }
              </div>
            </td>
          </ng-container>
          <ng-container matColumnDef="segundoVto">
            <th mat-header-cell *matHeaderCellDef>2do Vto.</th>
            <td mat-cell *matCellDef="let v">
              @if (v.fechaSegundoVto) {
                <div class="fecha-cell">
                  <span>{{ v.fechaSegundoVto | slice:0:10 }}</span>
                  @if (v.descSegundoVto) { <span class="desc">{{ v.descSegundoVto }}%</span> }
                </div>
              } @else { <span class="muted">—</span> }
            </td>
          </ng-container>
          <ng-container matColumnDef="tercerVto">
            <th mat-header-cell *matHeaderCellDef>3er Vto.</th>
            <td mat-cell *matCellDef="let v">
              @if (v.fechaTercerVto) {
                <div class="fecha-cell">
                  <span>{{ v.fechaTercerVto | slice:0:10 }}</span>
                  @if (v.descTercerVto) { <span class="desc">{{ v.descTercerVto }}%</span> }
                </div>
              } @else { <span class="muted">—</span> }
            </td>
          </ng-container>
          <ng-container matColumnDef="acciones">
            <th mat-header-cell *matHeaderCellDef></th>
            <td mat-cell *matCellDef="let v">
              <div class="accion-cell">
                <button class="icon-btn" (click)="abrirEditar(v)" matTooltip="Editar">
                  <mat-icon>edit</mat-icon>
                </button>
                <button class="icon-btn danger" (click)="eliminar(v)" matTooltip="Eliminar">
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
    .filter-card  { padding:var(--spacing-md) var(--spacing-lg); margin-bottom:var(--spacing-md); display:flex; gap:16px; flex-wrap:wrap; }
    .table-card   { padding:0; overflow:hidden; }
    .card-header  { display:flex; align-items:center; gap:8px; padding:var(--spacing-sm) var(--spacing-lg);
                    border-bottom:1px solid var(--color-border); font-weight:700; font-size:14px;
                    mat-icon { color:var(--color-primary); font-size:20px; width:20px; height:20px; } }
    .empty-state  { text-align:center; padding:48px; color:var(--color-text-muted);
                    mat-icon { font-size:40px; display:block; margin:0 auto 8px; opacity:.4; } }
    .error-carga  { display:flex; align-items:center; gap:10px; background:#fef2f2; color:#b91c1c;
                    border:1px solid #fecaca; border-radius:8px; padding:14px 18px; margin-bottom:16px; }
    .center-spinner { text-align:center; padding:60px; }
    .badge     { background:var(--color-surface-alt,#f1f5f9); border:1px solid var(--color-border);
                 padding:2px 8px; border-radius:12px; font-size:11px; font-weight:600; color:#475569; }
    .cuota-num { display:inline-flex; align-items:center; justify-content:center;
                 width:24px; height:24px; background:var(--color-primary); color:#fff;
                 border-radius:50%; font-size:12px; font-weight:700; }
    .fecha-cell { display:flex; flex-direction:column; gap:1px; font-size:12px; }
    .desc       { color:#059669; font-weight:600; font-size:11px; }
    .muted      { color:var(--color-text-muted); font-size:12px; }
    .accion-cell { display:flex; gap:2px; justify-content:flex-end; }
    .icon-btn { background:none; border:none; cursor:pointer; border-radius:4px; padding:4px;
                display:flex; align-items:center;
                mat-icon { font-size:18px; color:#64748b; }
                &:hover { background:var(--color-surface-alt,#f1f5f9); }
                &.danger mat-icon { color:#dc2626; } }
  `],
})
export class VencimientosDevComponent {
  private svc    = inject(DevengamientoService);
  private dialog = inject(MatDialog);

  filtroTributo  = new FormControl<number | null>(null);
  filtroEjercicio = new FormControl(String(new Date().getFullYear()));

  loading      = signal(false);
  errorCarga   = signal('');
  tributos     = signal<TipoTributo[]>([]);
  vencimientos = signal<Vencimiento[]>([]);

  cols = ['ejercicio', 'tributo', 'cuota', 'tipo', 'primerVto', 'segundoVto', 'tercerVto', 'acciones'];

  constructor() {
    this.svc.tributos().subscribe(t => this.tributos.set(t));
    this.cargar();
  }

  cargar() {
    this.loading.set(true);
    this.errorCarga.set('');
    this.svc.vencimientos(
      this.filtroTributo.value ?? undefined,
      this.filtroEjercicio.value?.trim() || undefined,
    ).subscribe({
      next: d => { this.vencimientos.set(d); this.loading.set(false); },
      error: e => { this.loading.set(false); this.errorCarga.set(e.status === 0 ? 'Sin conexión.' : `Error ${e.status}`); },
    });
  }

  nombreTributo(id: number) {
    return this.tributos().find(t => t.idTipoTributo === id)?.tipoTributo_ ?? String(id);
  }

  clonar() {
    this.dialog.open(ClonarVencimientosDialogComponent, {
      data: { tributos: this.tributos() }, width: '480px',
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  abrirNuevo() {
    this.dialog.open(VencimientoDialogComponent, {
      data: { vencimiento: null, tributos: this.tributos() }, width: '600px', maxWidth: '96vw',
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  abrirEditar(v: Vencimiento) {
    this.dialog.open(VencimientoDialogComponent, {
      data: { vencimiento: v, tributos: this.tributos() }, width: '600px', maxWidth: '96vw',
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  eliminar(v: Vencimiento) {
    if (!confirm(`¿Eliminar el vencimiento cuota ${v.nroCuota} del ejercicio ${v.ejercicio}?`)) return;
    this.svc.eliminarVencimiento(v.idVencimientos).subscribe({
      next: () => this.cargar(),
      error: e => alert('Error: ' + (e.error?.title ?? e.message)),
    });
  }
}
