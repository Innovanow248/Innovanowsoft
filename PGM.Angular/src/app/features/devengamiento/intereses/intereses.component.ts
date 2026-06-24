import { Component, inject, signal, OnInit } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { NgClass, DatePipe, DecimalPipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialogModule, MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { MatChipsModule } from '@angular/material/chips';
import { DevengamientoService, ConfigInteres, TipoTributo } from '../../../core/services/devengamiento.service';
import { AuthService } from '../../../core/services/auth.service';

// ── Dialog ─────────────────────────────────────────────────────────────────────
@Component({
  selector: 'app-interes-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule,
            MatSelectModule, MatButtonModule, MatIconModule, MatProgressSpinnerModule,
            MatDatepickerModule, MatNativeDateModule],
  template: `
<h2 mat-dialog-title>
  <mat-icon>{{ data.interes ? 'edit' : 'add_circle' }}</mat-icon>
  {{ data.interes ? 'Editar interés' : 'Nuevo interés' }}
</h2>
<mat-dialog-content>
  <form [formGroup]="form" class="dlg-form">
    <mat-form-field appearance="outline" class="full">
      <mat-label>Tipo de tributo</mat-label>
      <mat-select formControlName="idTipoTributo">
        @for (t of data.tributos; track t.idTipoTributo) {
          <mat-option [value]="t.idTipoTributo">{{ t.tipoTributo_ }} — {{ t.concepto }}</mat-option>
        }
      </mat-select>
    </mat-form-field>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Porcentual (%)</mat-label>
      <input matInput type="number" formControlName="porcentual" step="0.00001" />
      <mat-hint>Tasa de interés en porcentaje</mat-hint>
    </mat-form-field>
    <div class="row-2">
      <mat-form-field appearance="outline">
        <mat-label>Fecha desde</mat-label>
        <input matInput [matDatepicker]="dpDesde" formControlName="fechaDesde" />
        <mat-datepicker-toggle matIconSuffix [for]="dpDesde" />
        <mat-datepicker #dpDesde />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Fecha hasta</mat-label>
        <input matInput [matDatepicker]="dpHasta" formControlName="fechaHasta" />
        <mat-datepicker-toggle matIconSuffix [for]="dpHasta" />
        <mat-datepicker #dpHasta />
      </mat-form-field>
    </div>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Observación</mat-label>
      <textarea matInput formControlName="observacion" rows="2"></textarea>
    </mat-form-field>
  </form>
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button (click)="ref.close()">Cancelar</button>
  <button mat-flat-button color="primary" (click)="guardar()" [disabled]="form.invalid || guardando()">
    @if (guardando()) { <mat-spinner diameter="18" /> } @else { Guardar }
  </button>
</mat-dialog-actions>
`,
  styles: [`.dlg-form { display:flex; flex-direction:column; gap:12px; min-width:460px; padding-top:8px; }
            .row-2 { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
            .full { width:100%; }`]
})
export class InteresDialogComponent {
  ref      = inject(MatDialogRef<InteresDialogComponent>);
  data     = inject<{ interes: ConfigInteres | null; tributos: TipoTributo[] }>(MAT_DIALOG_DATA);
  svc      = inject(DevengamientoService);
  auth     = inject(AuthService);
  guardando = signal(false);

  form = inject(FormBuilder).group({
    idTipoTributo: [this.data.interes?.idTipoTributo ?? null, Validators.required],
    porcentual:    [this.data.interes?.porcentual    ?? null, [Validators.required, Validators.min(0)]],
    fechaDesde:    [this.data.interes?.fechaDesde ? new Date(this.data.interes.fechaDesde) : null, Validators.required],
    fechaHasta:    [this.data.interes?.fechaHasta ? new Date(this.data.interes.fechaHasta) : null],
    observacion:   [this.data.interes?.observacion ?? null],
  });

  guardar() {
    if (this.form.invalid) return;
    this.guardando.set(true);
    const usuario = this.auth.currentUser()?.usuario ?? 'SISTEMA';
    const v = this.form.value;
    const payload = {
      idTipoTributo: v.idTipoTributo,
      porcentual:    v.porcentual,
      fechaDesde:    v.fechaDesde,
      fechaHasta:    v.fechaHasta,
      observacion:   v.observacion,
      idJurisdiccion: null,
      usuario,
    };
    const op = this.data.interes
      ? this.svc.actualizarInteres(this.data.interes.idConfiguracion, payload)
      : this.svc.crearInteres(payload);

    op.subscribe({
      next: () => { this.guardando.set(false); this.ref.close(true); },
      error: () => this.guardando.set(false),
    });
  }
}

// ── Componente principal ───────────────────────────────────────────────────────
@Component({
  selector: 'app-intereses-dev',
  standalone: true,
  imports: [NgClass, DatePipe, DecimalPipe, ReactiveFormsModule, MatFormFieldModule, MatSelectModule,
            MatButtonModule, MatIconModule, MatTableModule, MatProgressSpinnerModule,
            MatTooltipModule, MatChipsModule, MatInputModule],
  template: `
<div class="page-container">
  <div class="page-header">
    <div>
      <h1 class="page-title">Intereses</h1>
      <p class="page-subtitle">Configuración de tasas de interés por tributo</p>
    </div>
    <button mat-flat-button color="primary" (click)="abrir(null)">
      <mat-icon>add</mat-icon> Nuevo interés
    </button>
  </div>

  <!-- Filtro -->
  <div class="filters-row">
    <mat-form-field appearance="outline" class="filter-field">
      <mat-label>Filtrar por tributo</mat-label>
      <mat-select [(value)]="filtroTributo" (selectionChange)="cargar()">
        <mat-option [value]="null">— Todos —</mat-option>
        @for (t of tributos(); track t.idTipoTributo) {
          <mat-option [value]="t.idTipoTributo">{{ t.tipoTributo_ }} — {{ t.concepto }}</mat-option>
        }
      </mat-select>
    </mat-form-field>
  </div>

  @if (cargando()) {
    <div class="spinner-row"><mat-spinner diameter="40" /></div>
  } @else {
    <div class="table-card">
      <table mat-table [dataSource]="intereses()" class="w-full">

        <ng-container matColumnDef="tributo">
          <th mat-header-cell *matHeaderCellDef>Tributo</th>
          <td mat-cell *matCellDef="let r">
            {{ nombreTributo(r.idTipoTributo) }}
          </td>
        </ng-container>

        <ng-container matColumnDef="porcentual">
          <th mat-header-cell *matHeaderCellDef>Porcentual</th>
          <td mat-cell *matCellDef="let r">
            <mat-chip>{{ r.porcentual | number:'1.2-5' }}%</mat-chip>
          </td>
        </ng-container>

        <ng-container matColumnDef="vigencia">
          <th mat-header-cell *matHeaderCellDef>Vigencia</th>
          <td mat-cell *matCellDef="let r">
            {{ r.fechaDesde | date:'dd/MM/yyyy' }}
            @if (r.fechaHasta) { → {{ r.fechaHasta | date:'dd/MM/yyyy' }} }
            @else { → vigente }
          </td>
        </ng-container>

        <ng-container matColumnDef="observacion">
          <th mat-header-cell *matHeaderCellDef>Observación</th>
          <td mat-cell *matCellDef="let r">{{ r.observacion || '—' }}</td>
        </ng-container>

        <ng-container matColumnDef="acciones">
          <th mat-header-cell *matHeaderCellDef></th>
          <td mat-cell *matCellDef="let r">
            <button mat-icon-button (click)="abrir(r)" matTooltip="Editar">
              <mat-icon>edit</mat-icon>
            </button>
            <button mat-icon-button color="warn" (click)="eliminar(r)" matTooltip="Eliminar">
              <mat-icon>delete</mat-icon>
            </button>
          </td>
        </ng-container>

        <tr mat-header-row *matHeaderRowDef="cols"></tr>
        <tr mat-row *matRowDef="let r; columns: cols;"
            [ngClass]="{ 'row-baja': r.fecBaja }"></tr>
      </table>
      @if (!intereses().length) {
        <p class="empty-msg">Sin registros de intereses{{ filtroTributo ? ' para este tributo' : '' }}.</p>
      }
    </div>
  }
</div>
`,
  styles: [`
    .filters-row { display:flex; gap:16px; margin-bottom:16px; flex-wrap:wrap; }
    .filter-field { min-width:260px; }
    .spinner-row { display:flex; justify-content:center; padding:40px; }
    .table-card { background:#fff; border-radius:8px; overflow:hidden;
                  box-shadow:0 1px 4px rgba(0,0,0,.08); }
    .row-baja td { opacity:.45; text-decoration:line-through; }
    .empty-msg { text-align:center; padding:32px; color:#888; }
    .w-full { width:100%; }
  `]
})
export class InteresesDevComponent implements OnInit {
  private svc    = inject(DevengamientoService);
  private dialog = inject(MatDialog);
  private auth   = inject(AuthService);

  tributos   = signal<TipoTributo[]>([]);
  intereses  = signal<ConfigInteres[]>([]);
  cargando   = signal(false);
  filtroTributo: number | null = null;

  cols = ['tributo', 'porcentual', 'vigencia', 'observacion', 'acciones'];

  ngOnInit() {
    this.svc.tributos().subscribe(t => this.tributos.set(t));
    this.cargar();
  }

  cargar() {
    this.cargando.set(true);
    this.svc.intereses(this.filtroTributo ?? undefined).subscribe({
      next: data => { this.intereses.set(data); this.cargando.set(false); },
      error: ()   => this.cargando.set(false),
    });
  }

  nombreTributo(id: number) {
    const t = this.tributos().find(x => x.idTipoTributo === id);
    return t ? `${t.tipoTributo_} — ${t.concepto}` : String(id);
  }

  abrir(interes: ConfigInteres | null) {
    this.dialog.open(InteresDialogComponent, {
      data: { interes, tributos: this.tributos() },
      width: '520px',
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  eliminar(interes: ConfigInteres) {
    if (!confirm('¿Eliminar esta configuración de interés?')) return;
    const usuario = this.auth.currentUser()?.usuario ?? 'SISTEMA';
    this.svc.eliminarInteres(interes.idConfiguracion, usuario).subscribe(() => this.cargar());
  }
}
