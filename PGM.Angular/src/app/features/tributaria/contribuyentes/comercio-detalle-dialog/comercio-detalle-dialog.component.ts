import { Component, inject, signal, OnInit } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { DatePipe, CurrencyPipe } from '@angular/common';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatTabsModule } from '@angular/material/tabs';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { TributariaService, ComercioDetalle, Sucursal, RubroComercio } from '../../../../core/services/tributaria.service';

@Component({
  selector: 'app-comercio-detalle-dialog',
  standalone: true,
  imports: [
    ReactiveFormsModule, DatePipe, CurrencyPipe,
    MatDialogModule, MatFormFieldModule, MatInputModule,
    MatButtonModule, MatIconModule, MatTableModule,
    MatTabsModule, MatProgressSpinnerModule, MatTooltipModule,
  ],
  template: `
<h2 mat-dialog-title>
  <mat-icon>storefront</mat-icon> Comercio {{ data.claveBien }}
</h2>
<mat-dialog-content>
  <mat-tab-group>

    <!-- ── TAB: Datos del negocio ─────────────────────────────────────── -->
    <mat-tab label="Datos del negocio">
      <div class="tab-content">
        @if (loadingDatos()) { <mat-spinner diameter="32" style="margin:24px auto;display:block" /> }
        @if (datos()) {
          <!-- Identificación -->
          <p class="section-title">Identificación</p>
          <div class="datos-grid">
            <div class="dato-item dato-full">
              <span class="dato-label">Nombre de fantasía</span>
              <span class="dato-valor strong">{{ datos()!.nombreFantasia || '—' }}</span>
            </div>
            <div class="dato-item dato-full">
              <span class="dato-label">Razón social</span>
              <span class="dato-valor">{{ datos()!.nombreSociedad || '—' }}</span>
            </div>
            <div class="dato-item">
              <span class="dato-label">Tipo de sociedad</span>
              <span class="dato-valor">{{ datos()!.tipoSociedad || '—' }}</span>
            </div>
            <div class="dato-item">
              <span class="dato-label">CUIT</span>
              <span class="dato-valor">{{ datos()!.cuit || '—' }}</span>
            </div>
            <div class="dato-item">
              <span class="dato-label">Ingresos brutos</span>
              <span class="dato-valor">{{ datos()!.ingresosBrutos || '—' }}</span>
            </div>
            <div class="dato-item">
              <span class="dato-label">N° licencia</span>
              <span class="dato-valor">{{ datos()!.nroLicencia || '—' }}</span>
            </div>
            <div class="dato-item">
              <span class="dato-label">Legajo</span>
              <span class="dato-valor">{{ datos()!.legajo || '—' }}</span>
            </div>
            <div class="dato-item dato-full">
              <span class="dato-label">Resolución habilitación</span>
              <span class="dato-valor">{{ datos()!.resolucionHabilitacion || '—' }}</span>
            </div>
          </div>

          <!-- Dirección y contacto -->
          <p class="section-title" style="margin-top:12px">Dirección y contacto</p>
          <div class="datos-grid">
            <div class="dato-item dato-full">
              <span class="dato-label">Dirección</span>
              <span class="dato-valor">
                {{ datos()!.calle || '—' }}
                {{ datos()!.numeracionCalle ? 'N° ' + datos()!.numeracionCalle : '' }}
                {{ datos()!.barrio ? '· ' + datos()!.barrio : '' }}
              </span>
            </div>
            <div class="dato-item">
              <span class="dato-label">Teléfono</span>
              <span class="dato-valor">{{ datos()!.telefono || datos()!.telefonoMovil || '—' }}</span>
            </div>
            <div class="dato-item">
              <span class="dato-label">Email</span>
              <span class="dato-valor">{{ datos()!.email || '—' }}</span>
            </div>
          </div>

          <!-- Fechas y datos económicos -->
          <p class="section-title" style="margin-top:12px">Datos económicos</p>
          <div class="datos-grid">
            <div class="dato-item">
              <span class="dato-label">Fecha inicio actividades</span>
              <span class="dato-valor">{{ datos()!.alquilerDesde ? (datos()!.alquilerDesde | date:'dd/MM/yyyy') : '—' }}</span>
            </div>
            <div class="dato-item">
              <span class="dato-label">Fecha fin actividades</span>
              <span class="dato-valor" [style.color]="datos()!.alquilerHasta ? '#b91c1c' : ''">
                {{ datos()!.alquilerHasta ? (datos()!.alquilerHasta | date:'dd/MM/yyyy') : '—' }}
              </span>
            </div>
            <div class="dato-item">
              <span class="dato-label">Capital declarado</span>
              <span class="dato-valor monto">{{ datos()!.capitalDeclarado != null ? (datos()!.capitalDeclarado | currency:'ARS':'symbol':'1.0-0') : '—' }}</span>
            </div>
            <div class="dato-item">
              <span class="dato-label">Personal ocupado</span>
              <span class="dato-valor">{{ datos()!.personalOcupado ?? '—' }}</span>
            </div>
          </div>

          <!-- Rubros -->
          <p class="section-title" style="margin-top:12px">
            Rubros
            @if (rubros().length) { <span class="section-badge">{{ rubros()[0].anoRubros }}</span> }
          </p>
          @if (loadingRubros()) { <mat-spinner diameter="24" style="margin:8px 0;display:block" /> }
          @if (!loadingRubros() && !rubros().length) {
            <p class="empty-small">Sin rubros registrados.</p>
          }
          @if (rubros().length) {
            <div class="rubros-list">
              @for (r of rubros(); track r.codigoRubro) {
                <div class="rubro-row" [class.rubro-principal]="r.principal === '1'">
                  <div class="rubro-left">
                    @if (r.principal === '1') {
                      <span class="badge-principal">Principal</span>
                    }
                    <span class="rubro-concepto">{{ r.concepto || r.codigoRubro }}</span>
                  </div>
                  <span class="rubro-cod">{{ r.codigoRubro }}</span>
                </div>
              }
            </div>
          }
        }
      </div>
    </mat-tab>

    <!-- ── TAB: Sucursales ───────────────────────────────────────────── -->
    <mat-tab [label]="'Sucursales (' + sucursales_().length + ')'">
      <div class="tab-content">
        @if (loadingSuc()) { <mat-spinner diameter="32" style="margin:24px auto;display:block" /> }

        @if (sucursales_().length) {
          <table mat-table [dataSource]="sucursales_()" class="inner-table">
            <ng-container matColumnDef="nro">
              <th mat-header-cell *matHeaderCellDef>N°</th>
              <td mat-cell *matCellDef="let s">{{ s.nroSucursal }}</td>
            </ng-container>
            <ng-container matColumnDef="nombre">
              <th mat-header-cell *matHeaderCellDef>Nombre de fantasía</th>
              <td mat-cell *matCellDef="let s"><strong>{{ s.nombreFantasia || '—' }}</strong></td>
            </ng-container>
            <ng-container matColumnDef="direccion">
              <th mat-header-cell *matHeaderCellDef>Dirección</th>
              <td mat-cell *matCellDef="let s">
                {{ s.calle || '' }}{{ s.numeracionCalle ? ' N° ' + s.numeracionCalle : '' }}
                @if (s.barrio) { <span class="barrio-chip">{{ s.barrio }}</span> }
              </td>
            </ng-container>
            <ng-container matColumnDef="resolucion">
              <th mat-header-cell *matHeaderCellDef>Resolución</th>
              <td mat-cell *matCellDef="let s">{{ s.resolucionHabilitacion || '—' }}</td>
            </ng-container>
            <ng-container matColumnDef="fechaHab">
              <th mat-header-cell *matHeaderCellDef>Habilitación</th>
              <td mat-cell *matCellDef="let s">{{ s.fechaHabilitacion ? (s.fechaHabilitacion | date:'dd/MM/yyyy') : '—' }}</td>
            </ng-container>
            <ng-container matColumnDef="estado">
              <th mat-header-cell *matHeaderCellDef>Estado</th>
              <td mat-cell *matCellDef="let s">
                @if (s.fechaBaja) {
                  <span class="badge badge--muted">Baja {{ s.fechaBaja | date:'dd/MM/yy' }}</span>
                } @else {
                  <span class="badge badge--success">Activa</span>
                }
              </td>
            </ng-container>
            <ng-container matColumnDef="accion">
              <th mat-header-cell *matHeaderCellDef></th>
              <td mat-cell *matCellDef="let s">
                @if (!s.fechaBaja) {
                  <button mat-icon-button color="warn"
                          matTooltip="Dar de baja la sucursal"
                          (click)="bajarSucursal(s.nroSucursal)">
                    <mat-icon>remove_circle_outline</mat-icon>
                  </button>
                }
              </td>
            </ng-container>
            <tr mat-header-row *matHeaderRowDef="colsSuc"></tr>
            <tr mat-row *matRowDef="let row; columns: colsSuc;"></tr>
          </table>
        } @else if (!loadingSuc()) {
          <p class="empty">Sin sucursales registradas.</p>
        }

        <!-- Nueva sucursal -->
        <div class="add-section">
          <p class="add-title"><mat-icon>add_business</mat-icon> Nueva sucursal</p>
          <form [formGroup]="fSuc" (ngSubmit)="crearSucursal()" class="add-form">
            <mat-form-field appearance="outline" style="flex:1 1 200px">
              <mat-label>Nombre de fantasía</mat-label>
              <input matInput formControlName="nombreFantasia" maxlength="60" />
            </mat-form-field>
            <mat-form-field appearance="outline" style="flex:1 1 180px">
              <mat-label>Calle</mat-label>
              <input matInput formControlName="calle" maxlength="40" />
            </mat-form-field>
            <mat-form-field appearance="outline" style="width:90px">
              <mat-label>N° puerta</mat-label>
              <input matInput formControlName="numeracionCalle" maxlength="10" />
            </mat-form-field>
            <mat-form-field appearance="outline" style="width:130px">
              <mat-label>Barrio</mat-label>
              <input matInput formControlName="barrio" maxlength="30" />
            </mat-form-field>
            <mat-form-field appearance="outline" style="width:150px">
              <mat-label>N° Resolución</mat-label>
              <input matInput formControlName="resolucionHabilitacion" maxlength="20" />
            </mat-form-field>
            <mat-form-field appearance="outline" style="width:155px">
              <mat-label>Fecha habilitación</mat-label>
              <input matInput type="date" formControlName="fechaHabilitacion" />
            </mat-form-field>
            <mat-form-field appearance="outline" style="flex:1 1 180px">
              <mat-label>Observaciones</mat-label>
              <input matInput formControlName="observaciones" maxlength="200" />
            </mat-form-field>
            <button class="btn-add" type="submit" [disabled]="savingSuc()">
              <mat-icon>save</mat-icon> Guardar
            </button>
          </form>
          @if (errSuc()) { <div class="msg-err">{{ errSuc() }}</div> }
          @if (msgSuc()) { <div class="msg-ok">{{ msgSuc() }}</div> }
        </div>
      </div>
    </mat-tab>

  </mat-tab-group>
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cerrar</button>
</mat-dialog-actions>`,
  styles: [`
    h2[mat-dialog-title] { display:flex; align-items:center; gap:8px; font-size:18px;
      mat-icon { color:var(--color-primary); } }
    mat-dialog-content { min-width:720px; max-width:1020px; max-height:78vh; }
    .tab-content { padding:16px 0; }
    .section-title { font-size:11px; font-weight:700; color:#64748b; text-transform:uppercase;
      letter-spacing:.5px; margin:0 0 2px; display:flex; align-items:center; gap:8px; }
    .section-badge { font-size:11px; font-weight:600; background:#e0f2fe; color:#0369a1;
      border-radius:10px; padding:1px 8px; }
    .inner-table { width:100%; }
    .empty { color:#94a3b8; font-size:13px; text-align:center; padding:20px 0; }
    .empty-small { color:#94a3b8; font-size:13px; padding:4px 0; margin:0; }
    .msg-err { background:#fef2f2; color:#b91c1c; padding:8px 12px; border-radius:4px; font-size:13px; margin-top:8px; }
    .msg-ok  { background:#f0fdf4; color:#166534; padding:8px 12px; border-radius:4px; font-size:13px; margin-top:8px; }
    .datos-grid { display:grid; grid-template-columns:1fr 1fr; gap:0; border:1px solid #f1f5f9; border-radius:6px; overflow:hidden; margin-bottom:4px; }
    .dato-item { display:flex; flex-direction:column; padding:8px 12px; border-bottom:1px solid #f1f5f9;
      &:last-child { border-bottom:none; } }
    .dato-item.dato-full { grid-column:1/-1; }
    .dato-label { font-size:10px; color:#94a3b8; text-transform:uppercase; letter-spacing:.4px; margin-bottom:1px; }
    .dato-valor { font-size:13px; color:#1e293b; font-weight:500; }
    .dato-valor.strong { font-weight:700; font-size:14px; }
    .dato-valor.monto { color:var(--color-primary); font-weight:600; }
    .rubros-list { display:flex; flex-direction:column; gap:4px; }
    .rubro-row { display:flex; align-items:center; justify-content:space-between; padding:7px 12px;
      background:#f8fafc; border-radius:6px; border:1px solid #e2e8f0; gap:8px; }
    .rubro-row.rubro-principal { background:#eff6ff; border-color:#bfdbfe; }
    .rubro-left { display:flex; align-items:center; gap:8px; flex:1; min-width:0; }
    .badge-principal { font-size:10px; font-weight:700; background:#1d4ed8; color:#fff;
      border-radius:10px; padding:1px 8px; white-space:nowrap; }
    .rubro-concepto { font-size:12px; color:#1e293b; font-weight:500; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .rubro-cod { font-size:10px; color:#94a3b8; white-space:nowrap; }
    .barrio-chip { font-size:11px; background:#f1f5f9; border-radius:10px; padding:1px 7px; margin-left:6px; color:#475569; }
    .badge { display:inline-block; border-radius:10px; padding:2px 10px; font-size:11px; font-weight:600; }
    .badge--success { background:#dcfce7; color:#166534; }
    .badge--muted { background:#f1f5f9; color:#64748b; }
    .add-section { margin-top:20px; border-top:1px solid #e2e8f0; padding-top:16px; }
    .add-title { display:flex; align-items:center; gap:6px; font-size:12px; font-weight:700;
      color:#475569; text-transform:uppercase; letter-spacing:.4px; margin:0 0 10px; }
    .add-form { display:flex; gap:8px; flex-wrap:wrap; align-items:flex-start; }
    .btn-add { height:56px; padding:0 16px; background:var(--color-primary); color:#fff; border:none;
      border-radius:4px; font-size:14px; cursor:pointer; display:flex; align-items:center; gap:4px;
      white-space:nowrap;
      &:disabled { opacity:.55; cursor:not-allowed; } }
  `],
})
export class ComercioDetalleDialogComponent implements OnInit {
  private svc = inject(TributariaService);
  private fb  = inject(FormBuilder);
  data: { idBien: string; claveBien: string } = inject(MAT_DIALOG_DATA);

  datos         = signal<ComercioDetalle | null>(null);
  loadingDatos  = signal(false);

  rubros_       = signal<RubroComercio[]>([]);
  loadingRubros = signal(false);

  sucursales_   = signal<Sucursal[]>([]);
  loadingSuc    = signal(false);
  savingSuc     = signal(false);
  errSuc        = signal('');
  msgSuc        = signal('');
  colsSuc       = ['nro', 'nombre', 'direccion', 'resolucion', 'fechaHab', 'estado', 'accion'];

  rubros()     { return this.rubros_(); }

  fSuc = this.fb.nonNullable.group({
    nombreFantasia:         [''],
    calle:                  ['', Validators.required],
    numeracionCalle:        [''],
    barrio:                 [''],
    resolucionHabilitacion: [''],
    fechaHabilitacion:      ['' as string],
    observaciones:          [''],
  });

  ngOnInit() {
    this.cargarDatos();
    this.cargarRubros();
    this.cargarSucursales();
  }

  cargarDatos() {
    this.loadingDatos.set(true);
    this.svc.comercioDetalle(this.data.idBien).subscribe({
      next: d => { this.datos.set(d); this.loadingDatos.set(false); },
      error: () => this.loadingDatos.set(false),
    });
  }

  cargarRubros() {
    this.loadingRubros.set(true);
    this.svc.rubrosComercio(this.data.idBien).subscribe({
      next: r => { this.rubros_.set(r); this.loadingRubros.set(false); },
      error: () => this.loadingRubros.set(false),
    });
  }

  cargarSucursales() {
    this.loadingSuc.set(true);
    this.svc.sucursales(this.data.idBien).subscribe({
      next: s => { this.sucursales_.set(s); this.loadingSuc.set(false); },
      error: () => this.loadingSuc.set(false),
    });
  }

  crearSucursal() {
    if (this.fSuc.invalid) return;
    this.savingSuc.set(true);
    this.errSuc.set('');
    this.msgSuc.set('');
    const v = this.fSuc.getRawValue();
    this.svc.crearSucursal(this.data.idBien, { ...v, fechaHabilitacion: v.fechaHabilitacion || null }).subscribe({
      next: () => {
        this.fSuc.reset();
        this.msgSuc.set('Sucursal registrada correctamente.');
        this.cargarSucursales();
        this.savingSuc.set(false);
        setTimeout(() => this.msgSuc.set(''), 3000);
      },
      error: e => { this.errSuc.set(e.error?.title ?? 'Error al crear sucursal'); this.savingSuc.set(false); },
    });
  }

  bajarSucursal(nroSucursal: string) {
    if (!confirm(`¿Dar de baja la sucursal N° ${nroSucursal}?`)) return;
    this.svc.bajarSucursal(this.data.idBien, nroSucursal).subscribe({
      next: () => this.cargarSucursales(),
      error: e => alert('Error: ' + (e.error?.title ?? e.message)),
    });
  }
}
