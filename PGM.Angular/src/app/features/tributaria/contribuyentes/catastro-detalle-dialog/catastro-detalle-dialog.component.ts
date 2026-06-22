import { Component, inject, signal, OnInit } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { CurrencyPipe, DecimalPipe } from '@angular/common';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatTabsModule } from '@angular/material/tabs';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { TributariaService } from '../../../../core/services/tributaria.service';

@Component({
  selector: 'app-catastro-detalle-dialog',
  standalone: true,
  imports: [
    ReactiveFormsModule, CurrencyPipe, DecimalPipe,
    MatDialogModule, MatFormFieldModule, MatInputModule,
    MatButtonModule, MatIconModule, MatTableModule,
    MatTabsModule, MatProgressSpinnerModule,
  ],
  template: `
<h2 mat-dialog-title>
  <mat-icon>home</mat-icon> Inmueble {{ data.claveBien }}
</h2>
<mat-dialog-content>
  <mat-tab-group>

    <!-- ── TAB: Propietarios ──────────────────────────────────────────── -->
    <mat-tab label="Propietarios">
      <div class="tab-content">
        @if (loadingProp()) { <mat-spinner diameter="32" style="margin:24px auto;display:block" /> }

        @if (propietarios().length) {
          <table mat-table [dataSource]="propietarios()" class="inner-table">
            <ng-container matColumnDef="ident">
              <th mat-header-cell *matHeaderCellDef>ID</th>
              <td mat-cell *matCellDef="let p">{{ p.identificador }}</td>
            </ng-container>
            <ng-container matColumnDef="nombre">
              <th mat-header-cell *matHeaderCellDef>Apellido y Nombre</th>
              <td mat-cell *matCellDef="let p"><strong>{{ p.apellido }}, {{ p.nombre }}</strong></td>
            </ng-container>
            <ng-container matColumnDef="pct">
              <th mat-header-cell *matHeaderCellDef>% Acciones</th>
              <td mat-cell *matCellDef="let p">{{ p.porcentajeAcciones != null ? (p.porcentajeAcciones | number:'1.2-2') + '%' : '—' }}</td>
            </ng-container>
            <ng-container matColumnDef="borrar">
              <th mat-header-cell *matHeaderCellDef></th>
              <td mat-cell *matCellDef="let p">
                <button mat-icon-button color="warn"
                        (click)="eliminarPropietario(p.identificador)"
                        title="Eliminar propietario">
                  <mat-icon>delete</mat-icon>
                </button>
              </td>
            </ng-container>
            <tr mat-header-row *matHeaderRowDef="colsProp"></tr>
            <tr mat-row *matRowDef="let row; columns: colsProp;"></tr>
          </table>
        } @else if (!loadingProp()) {
          <p class="empty">Sin propietarios registrados.</p>
        }

        <!-- Agregar propietario -->
        <form [formGroup]="fProp" (ngSubmit)="agregarPropietario()" class="add-row">
          <mat-form-field appearance="outline" style="flex:1">
            <mat-label>Identificador</mat-label>
            <input matInput formControlName="identificador" maxlength="5" />
          </mat-form-field>
          <mat-form-field appearance="outline" style="width:140px">
            <mat-label>% Acciones</mat-label>
            <input matInput type="number" step="0.01" min="0" max="100" formControlName="porcentajeAcciones" />
          </mat-form-field>
          <button class="btn-add" type="submit" [disabled]="fProp.invalid || savingProp()">
            <mat-icon>add</mat-icon> Agregar
          </button>
        </form>
        @if (errProp()) { <div class="msg-err">{{ errProp() }}</div> }
      </div>
    </mat-tab>

    <!-- ── TAB: Mejoras ───────────────────────────────────────────────── -->
    <mat-tab label="Mejoras constructivas">
      <div class="tab-content">
        @if (loadingMej()) { <mat-spinner diameter="32" style="margin:24px auto;display:block" /> }

        @if (mejoras().length) {
          <table mat-table [dataSource]="mejoras()" class="inner-table">
            <ng-container matColumnDef="ano">
              <th mat-header-cell *matHeaderCellDef>Año</th>
              <td mat-cell *matCellDef="let m">{{ m.anoConstruction }}</td>
            </ng-container>
            <ng-container matColumnDef="estado">
              <th mat-header-cell *matHeaderCellDef>Estado</th>
              <td mat-cell *matCellDef="let m">{{ m.estadoConstruccion }}</td>
            </ng-container>
            <ng-container matColumnDef="superficie">
              <th mat-header-cell *matHeaderCellDef>Sup. cubierta (m²)</th>
              <td mat-cell *matCellDef="let m">{{ m.superficieCubierta | number:'1.2-2' }}</td>
            </ng-container>
            <ng-container matColumnDef="valor">
              <th mat-header-cell *matHeaderCellDef>Valor edificado</th>
              <td mat-cell *matCellDef="let m">{{ m.valorEdificado | currency:'ARS':'symbol':'1.2-2' }}</td>
            </ng-container>
            <ng-container matColumnDef="tipo">
              <th mat-header-cell *matHeaderCellDef>Tipo construcción</th>
              <td mat-cell *matCellDef="let m">{{ m.tipoConstruccion || '—' }}</td>
            </ng-container>
            <ng-container matColumnDef="borrar">
              <th mat-header-cell *matHeaderCellDef></th>
              <td mat-cell *matCellDef="let m">
                <button mat-icon-button color="warn"
                        (click)="eliminarMejora(m.clave)"
                        title="Eliminar mejora">
                  <mat-icon>delete</mat-icon>
                </button>
              </td>
            </ng-container>
            <tr mat-header-row *matHeaderRowDef="colsMej"></tr>
            <tr mat-row *matRowDef="let row; columns: colsMej;"></tr>
          </table>
        } @else if (!loadingMej()) {
          <p class="empty">Sin mejoras registradas.</p>
        }

        <!-- Agregar mejora -->
        <form [formGroup]="fMej" (ngSubmit)="agregarMejora()" class="add-row">
          <mat-form-field appearance="outline" style="width:100px">
            <mat-label>Año</mat-label>
            <input matInput formControlName="anoConstruction" maxlength="4" placeholder="{{ anoActual }}" />
          </mat-form-field>
          <mat-form-field appearance="outline" style="width:80px">
            <mat-label>Estado</mat-label>
            <select matNativeControl formControlName="estadoConstruccion">
              <option value="T">T</option>
              <option value="P">P</option>
              <option value="R">R</option>
            </select>
          </mat-form-field>
          <mat-form-field appearance="outline" style="width:150px">
            <mat-label>Sup. cubierta (m²)</mat-label>
            <input matInput type="number" step="0.01" min="0" formControlName="superficieCubierta" />
          </mat-form-field>
          <mat-form-field appearance="outline" style="flex:1">
            <mat-label>Valor edificado ($)</mat-label>
            <input matInput type="number" step="1000" min="0" formControlName="valorEdificado" />
          </mat-form-field>
          <button class="btn-add" type="submit" [disabled]="fMej.invalid || savingMej()">
            <mat-icon>add</mat-icon> Agregar
          </button>
        </form>
        @if (errMej()) { <div class="msg-err">{{ errMej() }}</div> }
      </div>
    </mat-tab>

  </mat-tab-group>
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cerrar</button>
</mat-dialog-actions>`,
  styles: [`
    h2[mat-dialog-title] { display:flex; align-items:center; gap:8px; font-size:18px; mat-icon { color:var(--color-primary); } }
    mat-dialog-content { min-width:680px; max-width:900px; max-height:75vh; }
    .tab-content { padding:16px 0; }
    .inner-table { width:100%; }
    .empty { color:#94a3b8; font-size:13px; text-align:center; padding:20px 0; }
    .add-row { display:flex; gap:8px; align-items:flex-start; margin-top:16px; flex-wrap:wrap; }
    .btn-add { height:56px; padding:0 16px; background:var(--color-primary); color:#fff; border:none;
               border-radius:4px; font-size:14px; cursor:pointer; display:flex; align-items:center; gap:4px;
               &:disabled { opacity:.55; cursor:not-allowed; } }
    .msg-err { background:#fef2f2; color:#b91c1c; padding:8px 12px; border-radius:4px; font-size:13px; margin-top:8px; }
  `],
})
export class CatastroDetalleDialogComponent implements OnInit {
  private svc = inject(TributariaService);
  private fb  = inject(FormBuilder);
  data: { idBien: string; claveBien: string } = inject(MAT_DIALOG_DATA);

  anoActual = new Date().getFullYear().toString();

  // ── Propietarios ──────────────────────────────────────────────────────
  propietarios = signal<any[]>([]);
  loadingProp  = signal(false);
  savingProp   = signal(false);
  errProp      = signal('');
  colsProp     = ['ident', 'nombre', 'pct', 'borrar'];

  fProp = this.fb.nonNullable.group({
    identificador:      ['', Validators.required],
    porcentajeAcciones: [null as number | null],
  });

  // ── Mejoras ───────────────────────────────────────────────────────────
  mejoras     = signal<any[]>([]);
  loadingMej  = signal(false);
  savingMej   = signal(false);
  errMej      = signal('');
  colsMej     = ['ano', 'estado', 'superficie', 'valor', 'tipo', 'borrar'];

  fMej = this.fb.nonNullable.group({
    anoConstruction:    [this.anoActual, Validators.required],
    estadoConstruccion: ['T'],
    superficieCubierta: [0, Validators.min(0)],
    valorEdificado:     [0, [Validators.required, Validators.min(0.01)]],
  });

  ngOnInit() {
    this.cargarPropietarios();
    this.cargarMejoras();
  }

  cargarPropietarios() {
    this.loadingProp.set(true);
    this.svc.propietarios(this.data.idBien).subscribe({
      next: p => { this.propietarios.set(p); this.loadingProp.set(false); },
      error: () => this.loadingProp.set(false),
    });
  }

  agregarPropietario() {
    if (this.fProp.invalid) return;
    this.savingProp.set(true);
    this.errProp.set('');
    const v = this.fProp.getRawValue();
    this.svc.agregarPropietario(this.data.idBien, {
      identificador: v.identificador,
      porcentajeAcciones: v.porcentajeAcciones ?? undefined,
    }).subscribe({
      next: () => { this.fProp.reset({ identificador: '', porcentajeAcciones: null }); this.cargarPropietarios(); this.savingProp.set(false); },
      error: e => { this.errProp.set(e.error?.title ?? 'Error al agregar'); this.savingProp.set(false); },
    });
  }

  eliminarPropietario(identificador: string) {
    if (!confirm(`¿Eliminar propietario ${identificador}?`)) return;
    this.svc.eliminarPropietario(this.data.idBien, identificador).subscribe({
      next: () => this.cargarPropietarios(),
      error: e => alert('Error: ' + (e.error?.title ?? e.message)),
    });
  }

  cargarMejoras() {
    this.loadingMej.set(true);
    this.svc.mejoras(this.data.idBien).subscribe({
      next: m => { this.mejoras.set(m); this.loadingMej.set(false); },
      error: () => this.loadingMej.set(false),
    });
  }

  agregarMejora() {
    if (this.fMej.invalid) return;
    this.savingMej.set(true);
    this.errMej.set('');
    this.svc.agregarMejora(this.data.idBien, this.fMej.getRawValue()).subscribe({
      next: () => { this.fMej.reset({ anoConstruction: this.anoActual, estadoConstruccion: 'T', superficieCubierta: 0, valorEdificado: 0 }); this.cargarMejoras(); this.savingMej.set(false); },
      error: e => { this.errMej.set(e.error?.title ?? 'Error al agregar'); this.savingMej.set(false); },
    });
  }

  eliminarMejora(clave: number) {
    if (!confirm(`¿Eliminar mejora #${clave}?`)) return;
    this.svc.eliminarMejora(this.data.idBien, clave).subscribe({
      next: () => this.cargarMejoras(),
      error: e => alert('Error: ' + (e.error?.title ?? e.message)),
    });
  }
}
