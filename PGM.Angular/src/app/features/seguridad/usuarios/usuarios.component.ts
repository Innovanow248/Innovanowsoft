import { Component, inject, signal, computed } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators, FormControl } from '@angular/forms';
import { NgClass, SlicePipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatChipsModule } from '@angular/material/chips';
import { MatDialogModule, MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatTabsModule } from '@angular/material/tabs';
import { SeguridadService, UsuarioAdmin, GrupoItem } from '../../../core/services/seguridad.service';

// ── Grupos de permisos para mostrar en el checklist ──────────────────────────
const GRUPOS_PERMISOS: { titulo: string; icon: string; codigos: string[] }[] = [
  {
    titulo: 'Tributaria',
    icon: 'account_balance_wallet',
    codigos: ['ADMINISTRA_EXECIONES','ADMINISTRAR_DEUDA','ADMINISTRAR_PAGOS',
              'CAJERO','CATASTRO','CERTIFICADO_FISCAL','COMERCIO_CATEGORIAS',
              'DECLARACION_JURADA','GESTION_DEUDA','LIQUIDACION','PERSONAS',
              'SUBTASAS_CALCULADAS','OBSERVACIONES_PADRON'],
  },
  {
    titulo: 'Financiera / Contabilidad',
    icon: 'savings',
    codigos: ['CONTABILIDAD','CUENTAS_BANCARIAS','DEVENGAMIENTO','PERMISOS_OPAGO',
              'REC_INGRESO','VALES_ADELANTO'],
  },
  {
    titulo: 'Expedientes / Legal',
    icon: 'gavel',
    codigos: ['EXPEDIENTE','Juzgado_Faltas','LEGALES','OBRAS_PRIVADAS','PROCURACION',
              'PRESCRIPCION'],
  },
  {
    titulo: 'Recursos Humanos',
    icon: 'badge',
    codigos: ['SLD_FICHA_SUELDO','SLD_HISTORIAL','SLD_OBSERVACIONES',
              'IMPUESTO_GANANCIAS','SUBSIDIOS_BORRAR'],
  },
  {
    titulo: 'Administración / Sistema',
    icon: 'settings',
    codigos: ['AREAS','USUARIOS'],
  },
  {
    titulo: 'Adjuntos de archivos',
    icon: 'attach_file',
    codigos: ['ADJ_ARCHIVOS_ARTI','ADJ_ARCHIVOS_CACA','ADJ_ARCHIVOS_FACT',
              'ADJ_ARCHIVOS_ININ','ADJ_ARCHIVOS_PERS','ADJ_ARCHIVOS_RECO',
              'ADJ_ARCHIVOS_REIN','ADJ_ARCHIVOS_REMU','ADJ_ARCHIVOS_RURU',
              'ADJ_ARCHIVOS_SUBS','ADJ_ARCHIVOS_OB05','ADJ_ARCHIVOS_OBCA',
              'ADJ_ARCHIVOS_OBCL','ADJ_ARCHIVOS_OBCU','ADJ_ARCHIVOS_OBDE',
              'ADJ_ARCHIVOS_OBEA','ADJ_ARCHIVOS_OBFI','ADJ_ARCHIVOS_OBGA',
              'ADJ_ARCHIVOS_OBIN','ADJ_ARCHIVOS_OBME','ADJ_ARCHIVOS_OBNI',
              'ADJ_ARCHIVOS_OBPA','ADJ_ARCHIVOS_OBPV','ADJ_ARCHIVOS_OBSA',
              'ADJ_ARCHIVOS_OBSC','ADJ_ARCHIVOS_OBSI','ADJ_ARCHIVOS_OBTE',
              'ADJ_ARCHIVOS_OBVI'],
  },
];

// ── Dialog: Crear / Editar usuario ───────────────────────────────────────────
@Component({
  selector: 'app-usuario-dialog',
  standalone: true,
  imports: [
    ReactiveFormsModule, NgClass,
    MatDialogModule, MatFormFieldModule, MatInputModule,
    MatButtonModule, MatIconModule, MatCheckboxModule,
    MatTabsModule, MatProgressSpinnerModule,
  ],
  template: `
<h2 mat-dialog-title>
  <mat-icon>{{ esNuevo ? 'person_add' : 'manage_accounts' }}</mat-icon>
  {{ esNuevo ? 'Nuevo usuario' : 'Editar: ' + data.usuario?.codigoUsuario }}
</h2>

<mat-dialog-content>
  <mat-tab-group>

    <!-- TAB: Datos generales -->
    <mat-tab label="Datos generales">
      <form [formGroup]="form" class="tab-form">
        @if (esNuevo) {
          <mat-form-field appearance="outline" class="full">
            <mat-label>Código de usuario</mat-label>
            <input matInput formControlName="codigoUsuario" style="text-transform:uppercase"
                   placeholder="ej: JPEREZ" maxlength="15" />
            <mat-hint>Máx. 15 caracteres, sin espacios</mat-hint>
          </mat-form-field>
        }
        <mat-form-field appearance="outline" class="full">
          <mat-label>Descripción / Nombre completo</mat-label>
          <input matInput formControlName="descripcion" />
        </mat-form-field>
        <mat-form-field appearance="outline" class="full">
          <mat-label>Grupo / Rol</mat-label>
          <select matNativeControl formControlName="codigoGrupo">
            <option value="">— Sin grupo —</option>
            @for (g of grupos(); track g.codigo) {
              <option [value]="g.codigo">{{ g.codigo }} ({{ g.totalUsuarios }})</option>
            }
          </select>
        </mat-form-field>
        <mat-form-field appearance="outline" class="full">
          <mat-label>Fecha de caducidad (opcional)</mat-label>
          <input matInput type="date" formControlName="fechaCaducacion" />
          <mat-hint>Dejar vacío = sin vencimiento</mat-hint>
        </mat-form-field>
        @if (esNuevo) {
          <mat-form-field appearance="outline" class="full">
            <mat-label>Contraseña inicial</mat-label>
            <input matInput [type]="verPass ? 'text' : 'password'" formControlName="password" />
            <button mat-icon-button matSuffix type="button" (click)="verPass=!verPass">
              <mat-icon>{{ verPass ? 'visibility_off' : 'visibility' }}</mat-icon>
            </button>
          </mat-form-field>
        }
        @if (error()) {
          <div class="dlg-error">{{ error() }}</div>
        }
      </form>
    </mat-tab>

    <!-- TAB: Permisos -->
    <mat-tab label="Permisos ({{ conteoPermisos() }})">
      <div class="permisos-container">
        @for (grupo of gruposPermisos; track grupo.titulo) {
          <div class="permiso-grupo">
            <div class="permiso-grupo-header">
              <mat-icon>{{ grupo.icon }}</mat-icon>
              <strong>{{ grupo.titulo }}</strong>
              <span class="permiso-count">
                {{ contarActivos(grupo.codigos) }}/{{ grupo.codigos.length }}
              </span>
            </div>
            <div class="permiso-checks">
              @for (cod of grupo.codigos; track cod) {
                <mat-checkbox
                  [checked]="permisoActivo(cod)"
                  (change)="togglePermiso(cod, $event.checked)">
                  {{ cod }}
                </mat-checkbox>
              }
            </div>
          </div>
        }
        @if (otrosPermisos().length) {
          <div class="permiso-grupo">
            <div class="permiso-grupo-header">
              <mat-icon>more_horiz</mat-icon>
              <strong>Otros</strong>
            </div>
            <div class="permiso-checks">
              @for (cod of otrosPermisos(); track cod) {
                <mat-checkbox
                  [checked]="permisoActivo(cod)"
                  (change)="togglePermiso(cod, $event.checked)">
                  {{ cod }}
                </mat-checkbox>
              }
            </div>
          </div>
        }
      </div>
    </mat-tab>

  </mat-tab-group>
</mat-dialog-content>

<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="form.invalid || loading()">
    @if (loading()) { <mat-spinner diameter="18" /> } @else { Guardar }
  </button>
</mat-dialog-actions>
`,
  styles: [`
    h2[mat-dialog-title] { display:flex; align-items:center; gap:10px; mat-icon{color:var(--color-primary);} }
    mat-dialog-content { min-width: 580px; max-width: 700px; padding-top: 8px !important; }
    .tab-form { padding: 20px 4px 8px; display: flex; flex-direction: column; gap: 4px; }
    .full { width: 100%; }
    .dlg-error { background:#fef2f2; color:#b91c1c; padding:8px 12px; border-radius:4px; font-size:13px; margin-top:4px; }
    .permisos-container { padding: 16px 4px; display: flex; flex-direction: column; gap: 16px; max-height: 380px; overflow-y: auto; }
    .permiso-grupo { border: 1px solid var(--color-border,#e2e8f0); border-radius: 8px; overflow: hidden; }
    .permiso-grupo-header { display:flex; align-items:center; gap:8px; padding:8px 14px;
      background:var(--color-surface-alt,#f8fafc); font-size:13px;
      mat-icon { font-size:16px; height:16px; width:16px; color:var(--color-primary); }
      .permiso-count { margin-left:auto; font-size:11px; color:var(--color-text-muted); } }
    .permiso-checks { display: flex; flex-wrap: wrap; gap: 2px 0; padding: 10px 14px;
      mat-checkbox { width: 50%; font-size: 12px; } }
    .btn-ok { height:36px; padding:0 20px; background:var(--color-primary); color:#fff;
      border:none; border-radius:4px; font-size:14px; cursor:pointer; display:inline-flex; align-items:center; gap:6px;
      &:disabled { opacity:.55; cursor:not-allowed; } }
  `],
})
export class UsuarioDialogComponent {
  private svc  = inject(SeguridadService);
  private fb   = inject(FormBuilder);
  private ref  = inject(MatDialogRef<UsuarioDialogComponent>);
  data: { usuario: UsuarioAdmin | null; grupos: GrupoItem[]; todosProcesos: string[] } = inject(MAT_DIALOG_DATA);

  esNuevo      = !this.data.usuario;
  grupos       = signal(this.data.grupos);
  loading      = signal(false);
  error        = signal('');
  verPass      = false;
  gruposPermisos = GRUPOS_PERMISOS;

  permisosActivos = signal<Set<string>>(
    new Set(this.data.usuario?.permisos ?? [])
  );

  form = this.fb.nonNullable.group({
    codigoUsuario:   [this.data.usuario?.codigoUsuario ?? '', this.esNuevo ? [Validators.required, Validators.pattern(/^\S{1,15}$/)] : []],
    descripcion:     [this.data.usuario?.descripcion ?? '', Validators.required],
    codigoGrupo:     [this.data.usuario?.codigoGrupo ?? ''],
    fechaCaducacion: [this.data.usuario?.fechaCaducacion ? this.data.usuario.fechaCaducacion.substring(0,10) : ''],
    password:        ['', this.esNuevo ? Validators.required : []],
  });

  conteoPermisos  = computed(() => this.permisosActivos().size);
  permisoActivo   = (cod: string) => this.permisosActivos().has(cod);
  contarActivos   = (codigos: string[]) => codigos.filter(c => this.permisosActivos().has(c)).length;

  otrosPermisos = computed(() => {
    const conocidos = new Set(GRUPOS_PERMISOS.flatMap(g => g.codigos));
    return this.data.todosProcesos.filter(p => !conocidos.has(p));
  });

  togglePermiso(cod: string, activo: boolean) {
    const set = new Set(this.permisosActivos());
    activo ? set.add(cod) : set.delete(cod);
    this.permisosActivos.set(set);
  }

  guardar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.error.set('');
    const v = this.form.getRawValue();
    const permisos = [...this.permisosActivos()];
    const caducacion = v.fechaCaducacion || null;

    const obs = this.esNuevo
      ? this.svc.crearUsuario({
          codigoUsuario: v.codigoUsuario.toUpperCase(),
          password:      v.password,
          codigoGrupo:   v.codigoGrupo,
          descripcion:   v.descripcion,
          fechaCaducacion: caducacion,
          permisos,
        })
      : this.svc.actualizarUsuario(this.data.usuario!.codigoUsuario, {
          codigoGrupo:   v.codigoGrupo,
          descripcion:   v.descripcion,
          fechaCaducacion: caducacion,
          permisos,
        });

    obs.subscribe({
      next: () => this.ref.close(true),
      error: e => {
        this.error.set(e.error?.title ?? e.error?.detail ?? 'Error al guardar');
        this.loading.set(false);
      },
    });
  }
}

// ── Dialog: Cambiar contraseña ────────────────────────────────────────────────
@Component({
  selector: 'app-cambiar-password-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule,
            MatButtonModule, MatIconModule, MatProgressSpinnerModule],
  template: `
<h2 mat-dialog-title><mat-icon>lock_reset</mat-icon> Cambiar contraseña — {{ data }}</h2>
<mat-dialog-content style="min-width:360px;padding-top:12px!important">
  <mat-form-field appearance="outline" style="width:100%">
    <mat-label>Nueva contraseña</mat-label>
    <input matInput [type]="ver ? 'text' : 'password'" [formControl]="passCtrl" />
    <button mat-icon-button matSuffix type="button" (click)="ver=!ver">
      <mat-icon>{{ ver ? 'visibility_off' : 'visibility' }}</mat-icon>
    </button>
  </mat-form-field>
  @if (error()) { <div class="dlg-error">{{ error() }}</div> }
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="passCtrl.invalid || loading()">
    @if (loading()) { <mat-spinner diameter="18" /> } @else { Cambiar }
  </button>
</mat-dialog-actions>`,
  styles: [`.btn-ok{height:36px;padding:0 20px;background:var(--color-primary);color:#fff;border:none;border-radius:4px;font-size:14px;cursor:pointer;display:inline-flex;align-items:center;gap:6px;&:disabled{opacity:.55;cursor:not-allowed}}
    .dlg-error{background:#fef2f2;color:#b91c1c;padding:8px 12px;border-radius:4px;font-size:13px;margin-top:4px}
    h2[mat-dialog-title]{display:flex;align-items:center;gap:10px;mat-icon{color:var(--color-primary)}}`],
})
export class CambiarPasswordDialogComponent {
  private svc = inject(SeguridadService);
  private ref = inject(MatDialogRef<CambiarPasswordDialogComponent>);
  data: string = inject(MAT_DIALOG_DATA); // código de usuario

  ver      = false;
  loading  = signal(false);
  error    = signal('');
  passCtrl = new FormControl('', [Validators.required, Validators.minLength(4)]);

  guardar() {
    if (this.passCtrl.invalid) return;
    this.loading.set(true);
    this.svc.cambiarPassword(this.data, this.passCtrl.value!).subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set(e.error?.title ?? 'Error'); this.loading.set(false); },
    });
  }
}

// ── Componente principal ──────────────────────────────────────────────────────
@Component({
  selector: 'app-usuarios',
  standalone: true,
  imports: [
    ReactiveFormsModule, NgClass, SlicePipe,
    MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule,
    MatTableModule, MatProgressSpinnerModule, MatTooltipModule,
    MatChipsModule, MatDialogModule,
  ],
  template: `
<div class="page-container">
  <div class="eyebrow">Seguridad</div>
  <div class="page-header">
    <h1 class="page-title">Usuarios del sistema</h1>
    <button class="btn-header" (click)="abrirNuevo()">
      <mat-icon>person_add</mat-icon> Nuevo usuario
    </button>
  </div>

  <!-- Buscador -->
  <div class="card filter-card">
    <mat-form-field appearance="outline" style="width:100%;max-width:440px">
      <mat-label>Buscar por usuario, descripción o grupo</mat-label>
      <input matInput [formControl]="busquedaCtrl" (keyup.enter)="cargar()"
             placeholder="ej: ADMIN ó Tesorería" />
      <button mat-icon-button matSuffix (click)="cargar()"><mat-icon>search</mat-icon></button>
    </mat-form-field>
  </div>

  <!-- Error de carga -->
  @if (errorCarga()) {
    <div class="error-carga">
      <mat-icon>warning</mat-icon>
      {{ errorCarga() }}
    </div>
  }

  <!-- Tabla -->
  @if (loading()) {
    <div style="text-align:center;padding:60px"><mat-spinner diameter="44" /></div>
  } @else if (!errorCarga() && usuarios().length === 0) {
    <div class="empty-state">
      <mat-icon>manage_accounts</mat-icon>
      <p>{{ buscado() ? 'Sin resultados para "' + buscado() + '"' : 'Sin usuarios registrados' }}</p>
    </div>
  } @else if (!errorCarga()) {
    <div class="card table-card">
      <div class="card-header">
        <mat-icon>manage_accounts</mat-icon>
        <span>{{ usuarios().length }} usuario{{ usuarios().length !== 1 ? 's' : '' }}</span>
      </div>
      <table mat-table [dataSource]="usuarios()">

        <ng-container matColumnDef="codigo">
          <th mat-header-cell *matHeaderCellDef>Usuario</th>
          <td mat-cell *matCellDef="let u">
            <strong class="codigo">{{ u.codigoUsuario }}</strong>
          </td>
        </ng-container>

        <ng-container matColumnDef="descripcion">
          <th mat-header-cell *matHeaderCellDef>Nombre / Descripción</th>
          <td mat-cell *matCellDef="let u">{{ u.descripcion || '—' }}</td>
        </ng-container>

        <ng-container matColumnDef="grupo">
          <th mat-header-cell *matHeaderCellDef>Grupo</th>
          <td mat-cell *matCellDef="let u">
            @if (u.codigoGrupo) {
              <span class="badge-grupo">{{ u.codigoGrupo }}</span>
            } @else { <span class="muted">Sin grupo</span> }
          </td>
        </ng-container>

        <ng-container matColumnDef="permisos">
          <th mat-header-cell *matHeaderCellDef>Permisos</th>
          <td mat-cell *matCellDef="let u">
            <span class="perm-count" [class.perm-none]="u.permisos.length === 0">
              {{ u.permisos.length }} permiso{{ u.permisos.length !== 1 ? 's' : '' }}
            </span>
          </td>
        </ng-container>

        <ng-container matColumnDef="caducacion">
          <th mat-header-cell *matHeaderCellDef>Caducidad</th>
          <td mat-cell *matCellDef="let u">
            @if (u.fechaCaducacion) {
              <span [class.vencido]="estaVencido(u.fechaCaducacion)">
                {{ u.fechaCaducacion | slice:0:10 }}
              </span>
            } @else {
              <span class="muted">Sin vencimiento</span>
            }
          </td>
        </ng-container>

        <ng-container matColumnDef="acciones">
          <th mat-header-cell *matHeaderCellDef></th>
          <td mat-cell *matCellDef="let u">
            <div class="accion-cell">
              <button class="icon-btn" (click)="abrirEditar(u)" matTooltip="Editar">
                <mat-icon>edit</mat-icon>
              </button>
              <button class="icon-btn" (click)="abrirPassword(u.codigoUsuario)" matTooltip="Cambiar contraseña">
                <mat-icon>lock_reset</mat-icon>
              </button>
              <button class="icon-btn danger" (click)="eliminar(u)" matTooltip="Eliminar usuario">
                <mat-icon>delete</mat-icon>
              </button>
            </div>
          </td>
        </ng-container>

        <tr mat-header-row *matHeaderRowDef="cols"></tr>
        <tr mat-row *matRowDef="let row; columns: cols;"></tr>
      </table>
    </div>
  }
</div>
`,
  styles: [`
    .page-header  { display:flex; align-items:center; justify-content:space-between; margin-bottom:var(--spacing-md); }
    .btn-header   { display:flex; align-items:center; gap:6px; background:var(--color-primary); color:#fff;
                    border:none; border-radius:6px; padding:0 16px; height:40px; font-size:14px; font-weight:600; cursor:pointer; }
    .filter-card  { padding:var(--spacing-md) var(--spacing-lg); margin-bottom:var(--spacing-md); }
    .table-card   { padding:0; overflow:hidden; }
    .card-header  { display:flex; align-items:center; gap:8px; padding:var(--spacing-sm) var(--spacing-lg);
                    border-bottom:1px solid var(--color-border); font-weight:700; font-size:14px; color:var(--color-text-heading);
                    mat-icon { color:var(--color-primary); font-size:20px; width:20px; height:20px; } }
    .empty-state  { text-align:center; padding:60px 20px; color:var(--color-text-muted);
                    mat-icon { font-size:48px; display:block; margin:0 auto 12px; opacity:.4; } }
    .error-carga  { display:flex; align-items:center; gap:10px; background:#fef2f2; color:#b91c1c;
                    border:1px solid #fecaca; border-radius:8px; padding:14px 18px; margin-bottom:16px;
                    mat-icon { flex-shrink:0; } }
    .codigo       { font-family:monospace; font-size:13px; color:var(--color-primary); }
    .badge-grupo  { background:var(--color-surface-alt,#f1f5f9); border:1px solid var(--color-border);
                    padding:2px 8px; border-radius:12px; font-size:11px; font-weight:600; color:#475569; }
    .muted        { color:var(--color-text-muted); font-size:12px; }
    .perm-count   { font-size:12px; font-weight:600; color:#0284c7; }
    .perm-none    { color:var(--color-text-muted); font-weight:400; }
    .vencido      { color:#dc2626; font-weight:600; font-size:12px; }
    .accion-cell  { display:flex; gap:2px; justify-content:flex-end; }
    .icon-btn     { background:none; border:none; cursor:pointer; border-radius:4px; padding:4px;
                    display:flex; align-items:center;
                    mat-icon { font-size:18px; color:#64748b; }
                    &:hover { background:var(--color-surface-alt,#f1f5f9); }
                    &.danger mat-icon { color:#dc2626; } }
  `],
})
export class UsuariosComponent {
  private svc    = inject(SeguridadService);
  private dialog = inject(MatDialog);

  busquedaCtrl = new FormControl('');
  loading      = signal(false);
  errorCarga   = signal('');
  buscado      = signal('');
  usuarios     = signal<UsuarioAdmin[]>([]);
  grupos       = signal<GrupoItem[]>([]);
  procesos     = signal<string[]>([]);

  cols = ['codigo','descripcion','grupo','permisos','caducacion','acciones'];

  constructor() {
    // Cargar catálogos al iniciar
    this.svc.grupos().subscribe(g => this.grupos.set(g));
    this.svc.procesos().subscribe(p => this.procesos.set(p));
    this.cargar();
  }

  cargar() {
    const b = this.busquedaCtrl.value?.trim() ?? '';
    this.buscado.set(b);
    this.loading.set(true);
    this.errorCarga.set('');
    this.svc.usuarios(b || undefined).subscribe({
      next: d => { this.usuarios.set(d); this.loading.set(false); },
      error: e => {
        this.loading.set(false);
        const status = e.status ?? 0;
        if (status === 0)        this.errorCarga.set('No se puede conectar con la API (puerto 5000). Verificá que el servidor esté corriendo.');
        else if (status === 401) this.errorCarga.set('Sin autorización (401). Volvé a iniciar sesión.');
        else if (status === 404) this.errorCarga.set('Endpoint no encontrado (404). Reiniciá la API para cargar el nuevo código.');
        else                     this.errorCarga.set(`Error ${status}: ${e.error?.title ?? e.message}`);
      },
    });
  }

  estaVencido(fecha: string): boolean {
    return new Date(fecha) < new Date();
  }

  abrirNuevo() {
    this.dialog.open(UsuarioDialogComponent, {
      data: { usuario: null, grupos: this.grupos(), todosProcesos: this.procesos() },
      width: '720px', maxWidth: '96vw',
    }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  abrirEditar(u: UsuarioAdmin) {
    // Carga datos frescos (con permisos actualizados) antes de abrir el diálogo
    this.svc.usuario(u.codigoUsuario).subscribe({
      next: usuarioFull => {
        this.dialog.open(UsuarioDialogComponent, {
          data: { usuario: usuarioFull, grupos: this.grupos(), todosProcesos: this.procesos() },
          width: '720px', maxWidth: '96vw',
        }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
      },
      error: () => {
        // Fallback: abre con los datos que ya tenemos
        this.dialog.open(UsuarioDialogComponent, {
          data: { usuario: u, grupos: this.grupos(), todosProcesos: this.procesos() },
          width: '720px', maxWidth: '96vw',
        }).afterClosed().subscribe(ok => { if (ok) this.cargar(); });
      },
    });
  }

  abrirPassword(codigo: string) {
    this.dialog.open(CambiarPasswordDialogComponent, {
      data: codigo, width: '400px', maxWidth: '96vw',
    });
  }

  eliminar(u: UsuarioAdmin) {
    if (!confirm(`¿Eliminar el usuario "${u.codigoUsuario}"?\nEsta acción no se puede deshacer.`)) return;
    this.svc.eliminarUsuario(u.codigoUsuario).subscribe({
      next: () => this.cargar(),
      error: e => alert('Error al eliminar: ' + (e.error?.title ?? e.message)),
    });
  }
}
