import { Component, inject, signal, OnInit } from '@angular/core';
import { NgClass } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatChipsModule } from '@angular/material/chips';
import { MatDialogModule, MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { DevengamientoService, ParametricaTributo, TipoTributo } from '../../../core/services/devengamiento.service';
import { AuthService } from '../../../core/services/auth.service';

// ── Dialog: Agregar tributo ───────────────────────────────────────────────────
@Component({
  selector: 'app-parametrica-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatSelectModule,
            MatButtonModule, MatIconModule, MatProgressSpinnerModule, MatCheckboxModule],
  template: `
<h2 mat-dialog-title>
  <mat-icon>add_circle</mat-icon> Agregar tributo a parametrización
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
    <div class="check-row">
      <mat-checkbox formControlName="masivo">Masivo</mat-checkbox>
      <mat-checkbox formControlName="declarativo">Declarativo</mat-checkbox>
    </div>
  </form>
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button (click)="ref.close()">Cancelar</button>
  <button mat-flat-button color="primary" (click)="guardar()" [disabled]="form.invalid || guardando()">
    @if (guardando()) { <mat-spinner diameter="18" /> } @else { Agregar }
  </button>
</mat-dialog-actions>
`,
  styles: [`.dlg-form { display:flex; flex-direction:column; gap:12px; min-width:400px; padding-top:8px; }
            .full { width:100%; }
            .check-row { display:flex; gap:24px; }`]
})
export class ParametricaDialogComponent {
  ref      = inject(MatDialogRef<ParametricaDialogComponent>);
  data     = inject<{ tributos: TipoTributo[] }>(MAT_DIALOG_DATA);
  svc      = inject(DevengamientoService);
  auth     = inject(AuthService);
  guardando = signal(false);

  form = inject(FormBuilder).group({
    idTipoTributo: [null as number | null, Validators.required],
    masivo:        [false],
    declarativo:   [false],
  });

  guardar() {
    if (this.form.invalid) return;
    this.guardando.set(true);
    const v = this.form.value;
    const usuario = this.auth.currentUser()?.usuario ?? 'SISTEMA';
    this.svc.crearParametrica({
      idTipoTributo:  v.idTipoTributo,
      idJurisdiccion: 1,
      masivo:         v.masivo ? 'S' : 'N',
      declarativo:    v.declarativo ? 'S' : 'N',
      usuario,
    }).subscribe({
      next: () => { this.guardando.set(false); this.ref.close(true); },
      error: () => this.guardando.set(false),
    });
  }
}

// ── Componente principal ───────────────────────────────────────────────────────
@Component({
  selector: 'app-parametrizar-tributos',
  standalone: true,
  imports: [NgClass, ReactiveFormsModule, MatButtonModule, MatIconModule, MatTableModule,
            MatProgressSpinnerModule, MatTooltipModule, MatChipsModule,
            MatFormFieldModule, MatSelectModule],
  template: `
<div class="page-container">
  <div class="page-header">
    <div>
      <h1 class="page-title">Parametrizar Tributos</h1>
      <p class="page-subtitle">Tributos habilitados para devengamiento en esta jurisdicción</p>
    </div>
    <button mat-flat-button color="primary" (click)="abrir()">
      <mat-icon>add</mat-icon> Agregar tributo
    </button>
  </div>

  @if (cargando()) {
    <div class="spinner-row"><mat-spinner diameter="40" /></div>
  } @else {
    <div class="table-card">
      <table mat-table [dataSource]="parametricas()" class="w-full">

        <ng-container matColumnDef="tipo">
          <th mat-header-cell *matHeaderCellDef>Código</th>
          <td mat-cell *matCellDef="let r">
            <mat-chip>{{ r.tipoTributo_ }}</mat-chip>
          </td>
        </ng-container>

        <ng-container matColumnDef="concepto">
          <th mat-header-cell *matHeaderCellDef>Tributo</th>
          <td mat-cell *matCellDef="let r">{{ r.concepto }}</td>
        </ng-container>

        <ng-container matColumnDef="masivo">
          <th mat-header-cell *matHeaderCellDef>Masivo</th>
          <td mat-cell *matCellDef="let r">
            <mat-chip [color]="r.masivo === 'S' ? 'primary' : ''">
              {{ r.masivo === 'S' ? 'Sí' : 'No' }}
            </mat-chip>
          </td>
        </ng-container>

        <ng-container matColumnDef="declarativo">
          <th mat-header-cell *matHeaderCellDef>Declarativo</th>
          <td mat-cell *matCellDef="let r">
            <mat-chip [color]="r.declarativo === 'S' ? 'accent' : ''">
              {{ r.declarativo === 'S' ? 'Sí' : 'No' }}
            </mat-chip>
          </td>
        </ng-container>

        <ng-container matColumnDef="acciones">
          <th mat-header-cell *matHeaderCellDef></th>
          <td mat-cell *matCellDef="let r">
            <button mat-icon-button color="warn" (click)="eliminar(r)" matTooltip="Quitar tributo">
              <mat-icon>remove_circle</mat-icon>
            </button>
          </td>
        </ng-container>

        <tr mat-header-row *matHeaderRowDef="cols"></tr>
        <tr mat-row *matRowDef="let r; columns: cols;"></tr>
      </table>
      @if (!parametricas().length) {
        <p class="empty-msg">No hay tributos parametrizados para devengamiento.</p>
      }
    </div>
  }
</div>
`,
  styles: [`
    .spinner-row { display:flex; justify-content:center; padding:40px; }
    .table-card { background:#fff; border-radius:8px; overflow:hidden;
                  box-shadow:0 1px 4px rgba(0,0,0,.08); }
    .empty-msg { text-align:center; padding:32px; color:#888; }
    .w-full { width:100%; }
  `]
})
export class ParametrizarTributosComponent implements OnInit {
  private svc    = inject(DevengamientoService);
  private dialog = inject(MatDialog);
  private auth   = inject(AuthService);

  tributos    = signal<TipoTributo[]>([]);
  parametricas = signal<ParametricaTributo[]>([]);
  cargando    = signal(false);

  cols = ['tipo', 'concepto', 'masivo', 'declarativo', 'acciones'];

  ngOnInit() {
    this.svc.tributos().subscribe(t => this.tributos.set(t));
    this.cargar();
  }

  cargar() {
    this.cargando.set(true);
    this.svc.parametricaTributos().subscribe({
      next: data => { this.parametricas.set(data); this.cargando.set(false); },
      error: ()   => this.cargando.set(false),
    });
  }

  abrir() {
    const yaAgregados = this.parametricas().map(p => p.idTipoTributo);
    const disponibles = this.tributos().filter(t => !yaAgregados.includes(t.idTipoTributo));
    this.dialog.open(ParametricaDialogComponent, {
      data: { tributos: disponibles },
      width: '480px',
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  eliminar(p: ParametricaTributo) {
    if (!confirm(`¿Quitar "${p.concepto}" de la parametrización?`)) return;
    const usuario = this.auth.currentUser()?.usuario ?? 'SISTEMA';
    this.svc.eliminarParametrica(p.idParamTrib, usuario).subscribe(() => this.cargar());
  }
}
