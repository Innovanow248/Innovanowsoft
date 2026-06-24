import { Component, inject, signal, OnInit } from '@angular/core';
import { NgClass } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
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
import {
  DevengamientoService, ConceptoVencimiento, TipoTributo,
  ConceptoDevengamiento, Vencimiento
} from '../../../core/services/devengamiento.service';
import { AuthService } from '../../../core/services/auth.service';

// ── Dialog: Nueva vinculación ─────────────────────────────────────────────────
@Component({
  selector: 'app-vinculacion-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule,
            MatSelectModule, MatButtonModule, MatIconModule, MatProgressSpinnerModule],
  template: `
<h2 mat-dialog-title>
  <mat-icon>link</mat-icon> Nueva vinculación concepto-vencimiento
</h2>
<mat-dialog-content>
  <form [formGroup]="form" class="dlg-form">
    <mat-form-field appearance="outline" class="full">
      <mat-label>Vencimiento</mat-label>
      <mat-select formControlName="idVencimiento">
        @for (v of data.vencimientos; track v.idVencimientos) {
          <mat-option [value]="v.idVencimientos">
            Cuota {{ v.nroCuota }} — Ej. {{ v.ejercicio }} {{ v.nZona ? '· ' + v.nZona : '' }}
          </mat-option>
        }
      </mat-select>
    </mat-form-field>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Concepto padre</mat-label>
      <mat-select formControlName="conceptoPadre">
        <mat-option [value]="null">— Sin padre —</mat-option>
        @for (c of data.conceptos; track c.idTipoConcepto) {
          <mat-option [value]="c.idTipoConcepto">{{ c.concepto }} — {{ c.descripcion }}</mat-option>
        }
      </mat-select>
    </mat-form-field>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Concepto vinculado</mat-label>
      <mat-select formControlName="idTipoConcepto">
        @for (c of data.conceptos; track c.idTipoConcepto) {
          <mat-option [value]="c.idTipoConcepto">{{ c.concepto }} — {{ c.descripcion }}</mat-option>
        }
      </mat-select>
    </mat-form-field>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Cumplidor</mat-label>
      <mat-select formControlName="cumplidor">
        <mat-option value="C">C — Cumplidor</mat-option>
        <mat-option value="NC">NC — No cumplidor</mat-option>
        <mat-option value="T">T — Todos</mat-option>
      </mat-select>
    </mat-form-field>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Observación</mat-label>
      <input matInput formControlName="observacion" />
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
  styles: [`.dlg-form { display:flex; flex-direction:column; gap:12px; min-width:480px; padding-top:8px; }
            .full { width:100%; }`]
})
export class VinculacionDialogComponent {
  ref      = inject(MatDialogRef<VinculacionDialogComponent>);
  data     = inject<{ vencimientos: Vencimiento[]; conceptos: ConceptoDevengamiento[] }>(MAT_DIALOG_DATA);
  svc      = inject(DevengamientoService);
  auth     = inject(AuthService);
  guardando = signal(false);

  form = inject(FormBuilder).group({
    idVencimiento:  [null as number | null, Validators.required],
    idTipoConcepto: [null as number | null, Validators.required],
    conceptoPadre:  [null as number | null],
    cumplidor:      ['T'],
    observacion:    [null as string | null],
  });

  guardar() {
    if (this.form.invalid) return;
    this.guardando.set(true);
    const usuario = this.auth.currentUser()?.usuario ?? 'SISTEMA';
    const v = this.form.value;
    this.svc.crearConceptoVencimiento({
      idVencimiento:  v.idVencimiento,
      idTipoConcepto: v.idTipoConcepto,
      conceptoPadre:  v.conceptoPadre,
      cumplidor:      v.cumplidor,
      observacion:    v.observacion,
      usuario,
    }).subscribe({
      next: () => { this.guardando.set(false); this.ref.close(true); },
      error: () => this.guardando.set(false),
    });
  }
}

// ── Componente principal ───────────────────────────────────────────────────────
@Component({
  selector: 'app-vinculacion-dev',
  standalone: true,
  imports: [NgClass, ReactiveFormsModule, MatFormFieldModule, MatSelectModule,
            MatInputModule, MatButtonModule, MatIconModule, MatTableModule,
            MatProgressSpinnerModule, MatTooltipModule, MatChipsModule],
  template: `
<div class="page-container">
  <div class="page-header">
    <div>
      <h1 class="page-title">Vinculación de Conceptos</h1>
      <p class="page-subtitle">Asignación de conceptos a vencimientos por tributo y ejercicio</p>
    </div>
    <button mat-flat-button color="primary" (click)="abrir()" [disabled]="!tributoSel || !ejercicioSel">
      <mat-icon>add_link</mat-icon> Nueva vinculación
    </button>
  </div>

  <!-- Filtros -->
  <div class="filters-row">
    <mat-form-field appearance="outline" class="filter-field">
      <mat-label>Tributo</mat-label>
      <mat-select [(value)]="tributoSel" (selectionChange)="cargar()">
        <mat-option [value]="null">— Todos —</mat-option>
        @for (t of tributos(); track t.idTipoTributo) {
          <mat-option [value]="t.idTipoTributo">{{ t.tipoTributo_ }} — {{ t.concepto }}</mat-option>
        }
      </mat-select>
    </mat-form-field>
    <mat-form-field appearance="outline" class="filter-field">
      <mat-label>Ejercicio</mat-label>
      <mat-select [(value)]="ejercicioSel" (selectionChange)="cargar()">
        <mat-option [value]="null">— Todos —</mat-option>
        @for (e of ejercicios; track e) {
          <mat-option [value]="e">{{ e }}</mat-option>
        }
      </mat-select>
    </mat-form-field>
  </div>

  @if (cargando()) {
    <div class="spinner-row"><mat-spinner diameter="40" /></div>
  } @else {
    <div class="table-card">
      <table mat-table [dataSource]="vinculaciones()" class="w-full">

        <ng-container matColumnDef="ejercicio">
          <th mat-header-cell *matHeaderCellDef>Ejercicio</th>
          <td mat-cell *matCellDef="let r">{{ r.ejercicio || '—' }}</td>
        </ng-container>

        <ng-container matColumnDef="cuota">
          <th mat-header-cell *matHeaderCellDef>Cuota</th>
          <td mat-cell *matCellDef="let r">
            @if (r.nroCuota) { <mat-chip>{{ r.nroCuota }}</mat-chip> }
          </td>
        </ng-container>

        <ng-container matColumnDef="conceptoPadre">
          <th mat-header-cell *matHeaderCellDef>Concepto padre</th>
          <td mat-cell *matCellDef="let r">{{ r.conceptoPadreNombre || '—' }}</td>
        </ng-container>

        <ng-container matColumnDef="concepto">
          <th mat-header-cell *matHeaderCellDef>Concepto vinculado</th>
          <td mat-cell *matCellDef="let r">
            <strong>{{ r.conceptoNombre || ('ID ' + r.idTipoConcepto) }}</strong>
          </td>
        </ng-container>

        <ng-container matColumnDef="cumplidor">
          <th mat-header-cell *matHeaderCellDef>Cumplidor</th>
          <td mat-cell *matCellDef="let r">
            <mat-chip [color]="cumColor(r.cumplidor)">{{ r.cumplidor || '—' }}</mat-chip>
          </td>
        </ng-container>

        <ng-container matColumnDef="zona">
          <th mat-header-cell *matHeaderCellDef>Zona</th>
          <td mat-cell *matCellDef="let r">{{ r.nZona || '—' }}</td>
        </ng-container>

        <ng-container matColumnDef="acciones">
          <th mat-header-cell *matHeaderCellDef></th>
          <td mat-cell *matCellDef="let r">
            <button mat-icon-button color="warn" (click)="eliminar(r)" matTooltip="Quitar vinculación">
              <mat-icon>link_off</mat-icon>
            </button>
          </td>
        </ng-container>

        <tr mat-header-row *matHeaderRowDef="cols"></tr>
        <tr mat-row *matRowDef="let r; columns: cols;"
            [ngClass]="{ 'row-baja': r.fecBaja }"></tr>
      </table>
      @if (!vinculaciones().length) {
        <p class="empty-msg">Sin vinculaciones{{ tributoSel || ejercicioSel ? ' para los filtros seleccionados' : '' }}.</p>
      }
    </div>
  }
</div>
`,
  styles: [`
    .filters-row { display:flex; gap:16px; margin-bottom:16px; flex-wrap:wrap; }
    .filter-field { min-width:240px; }
    .spinner-row { display:flex; justify-content:center; padding:40px; }
    .table-card { background:#fff; border-radius:8px; overflow:hidden;
                  box-shadow:0 1px 4px rgba(0,0,0,.08); }
    .row-baja td { opacity:.45; text-decoration:line-through; }
    .empty-msg { text-align:center; padding:32px; color:#888; }
    .w-full { width:100%; }
  `]
})
export class VinculacionDevComponent implements OnInit {
  private svc    = inject(DevengamientoService);
  private dialog = inject(MatDialog);
  private auth   = inject(AuthService);

  tributos     = signal<TipoTributo[]>([]);
  conceptos    = signal<ConceptoDevengamiento[]>([]);
  vencimientos = signal<Vencimiento[]>([]);
  vinculaciones = signal<ConceptoVencimiento[]>([]);
  cargando     = signal(false);

  tributoSel:  number | null = null;
  ejercicioSel: string | null = null;

  cols = ['ejercicio', 'cuota', 'conceptoPadre', 'concepto', 'cumplidor', 'zona', 'acciones'];
  ejercicios = Array.from({ length: 6 }, (_, i) => String(new Date().getFullYear() - i));

  ngOnInit() {
    this.svc.tributos().subscribe(t => this.tributos.set(t));
    this.svc.conceptos().subscribe(c => this.conceptos.set(c));
    this.cargar();
  }

  cargar() {
    this.cargando.set(true);
    if (this.tributoSel) {
      this.svc.vencimientos(this.tributoSel, this.ejercicioSel ?? undefined)
             .subscribe(v => this.vencimientos.set(v));
    }
    this.svc.conceptosVencimientos(
      this.tributoSel ?? undefined,
      this.ejercicioSel ?? undefined
    ).subscribe({
      next: data => { this.vinculaciones.set(data); this.cargando.set(false); },
      error: ()   => this.cargando.set(false),
    });
  }

  abrir() {
    const vencsFiltrados = this.vencimientos().filter(v =>
      (!this.tributoSel || v.idTipoTributo === this.tributoSel) &&
      (!this.ejercicioSel || v.ejercicio === this.ejercicioSel)
    );
    this.dialog.open(VinculacionDialogComponent, {
      data: { vencimientos: vencsFiltrados, conceptos: this.conceptos() },
      width: '560px',
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  eliminar(v: ConceptoVencimiento) {
    if (!confirm('¿Quitar esta vinculación?')) return;
    const usuario = this.auth.currentUser()?.usuario ?? 'SISTEMA';
    this.svc.eliminarConceptoVencimiento(v.idConceptoVencimiento, usuario)
           .subscribe(() => this.cargar());
  }

  cumColor(c: string | null) {
    if (c === 'C')  return 'primary';
    if (c === 'NC') return 'warn';
    return '';
  }
}
