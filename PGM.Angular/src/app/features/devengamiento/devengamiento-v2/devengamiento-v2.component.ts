import { Component, inject, signal, OnInit, OnDestroy } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { DatePipe, NgClass, DecimalPipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatChipsModule } from '@angular/material/chips';
import { MatTooltipModule } from '@angular/material/tooltip';
import { DevengamientoService, TipoTributo, EstadoDevengamiento, LogDevengamiento, ParametricaTributo } from '../../../core/services/devengamiento.service';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-devengamiento-v2',
  standalone: true,
  imports: [
    DatePipe, NgClass, DecimalPipe, ReactiveFormsModule,
    MatFormFieldModule, MatInputModule, MatSelectModule,
    MatButtonModule, MatIconModule, MatTableModule,
    MatProgressSpinnerModule, MatProgressBarModule,
    MatChipsModule, MatTooltipModule,
  ],
  template: `
<div class="page-container">
  <div class="page-header">
    <div>
      <div class="eyebrow">Devengamiento</div>
      <h1 class="page-title">Motor de Ejecución V2</h1>
    </div>
  </div>

  <!-- Panel de ejecución -->
  <div class="card" style="padding:var(--spacing-lg); margin-bottom:16px">
    <div class="card-section-title"><mat-icon>play_circle</mat-icon> Nueva ejecución</div>
    <form [formGroup]="form" class="exec-row">
      <mat-form-field appearance="outline">
        <mat-label>Tributo</mat-label>
        <mat-select formControlName="idTipoTributo">
          @for (p of parametrica(); track p.idParamTrib) {
            <mat-option [value]="p.idTipoTributo">{{ p.tipoTributo_ ?? p.idTipoTributo }} — {{ p.concepto }}</mat-option>
          }
        </mat-select>
      </mat-form-field>
      <mat-form-field appearance="outline" style="width:120px">
        <mat-label>Ejercicio</mat-label>
        <input matInput formControlName="ejercicio" placeholder="2025" maxlength="4" />
      </mat-form-field>
      <button mat-flat-button color="primary"
              (click)="ejecutar()"
              [disabled]="form.invalid || ejecutando()">
        @if (ejecutando()) { <mat-spinner diameter="20" /> Ejecutando… }
        @else { <mat-icon>play_arrow</mat-icon> Ejecutar }
      </button>
    </form>
    @if (mensajeEjecucion()) {
      <div [class]="'exec-msg exec-msg--' + (errorEjecucion() ? 'error' : 'ok')">
        {{ mensajeEjecucion() }}
      </div>
    }
  </div>

  <!-- Estado actual -->
  <div class="card" style="padding:var(--spacing-lg); margin-bottom:16px">
    <div class="card-section-title">
      <mat-icon>monitor</mat-icon> Estado del devengamiento
      <button mat-icon-button (click)="cargarEstado()" matTooltip="Actualizar" style="margin-left:auto">
        <mat-icon>refresh</mat-icon>
      </button>
    </div>
    @if (cargandoEstado()) {
      <mat-spinner diameter="32" style="margin:16px auto" />
    } @else if (estado()) {
      <div class="estado-grid">
        <div class="estado-item">
          <span>Tributo</span>
          <strong>{{ nombreTributo(estado()!.idTipoTributo) }}</strong>
        </div>
        <div class="estado-item">
          <span>Ejercicio</span>
          <strong>{{ estado()!.ejercicio ?? '—' }}</strong>
        </div>
        <div class="estado-item">
          <span>Operador</span>
          <strong>{{ estado()!.usrOperador ?? '—' }}</strong>
        </div>
        <div class="estado-item">
          <span>Inicio</span>
          <strong>{{ estado()!.fecInicio ? (estado()!.fecInicio | date:'dd/MM/yyyy HH:mm') : '—' }}</strong>
        </div>
      </div>
      <div class="progress-row">
        <mat-progress-bar mode="determinate" [value]="estado()!.porcentaje"
                          [color]="estado()!.estado === 'ERROR' ? 'warn' : 'primary'" />
        <span class="progress-pct">{{ estado()!.porcentaje | number:'1.0-0' }}%</span>
        <span [class]="'badge badge--' + estadoBadge(estado()!.estado)">{{ estado()!.estado }}</span>
      </div>
      @if (estado()!.mensaje) {
        <div class="estado-msg">{{ estado()!.mensaje }}</div>
      }
    } @else {
      <p class="empty-msg">No hay proceso activo.</p>
    }
  </div>

  <!-- Historial -->
  <div class="card" style="padding:0; overflow:hidden">
    <div class="card-section-title" style="padding:var(--spacing-md) var(--spacing-lg)">
      <mat-icon>history</mat-icon> Historial de ejecuciones
    </div>
    @if (cargandoLog()) {
      <mat-spinner diameter="32" style="margin:16px auto" />
    } @else {
      <table mat-table [dataSource]="log()">
        <ng-container matColumnDef="fecha">
          <th mat-header-cell *matHeaderCellDef>Fecha</th>
          <td mat-cell *matCellDef="let r">{{ r.fecEjecucion | date:'dd/MM/yyyy HH:mm' }}</td>
        </ng-container>
        <ng-container matColumnDef="tributo">
          <th mat-header-cell *matHeaderCellDef>Tributo</th>
          <td mat-cell *matCellDef="let r">{{ r.tipoTributo ?? r.idTipoTributo ?? '—' }}</td>
        </ng-container>
        <ng-container matColumnDef="ejercicio">
          <th mat-header-cell *matHeaderCellDef>Ejercicio</th>
          <td mat-cell *matCellDef="let r">{{ r.ejercicio ?? '—' }}</td>
        </ng-container>
        <ng-container matColumnDef="resultado">
          <th mat-header-cell *matHeaderCellDef>Resultado</th>
          <td mat-cell *matCellDef="let r">
            <span [class]="'badge badge--' + resultadoBadge(r.resultado)">{{ r.resultado }}</span>
          </td>
        </ng-container>
        <ng-container matColumnDef="cuentas">
          <th mat-header-cell *matHeaderCellDef>Cuentas</th>
          <td mat-cell *matCellDef="let r">
            {{ r.cuentasDevengadas ?? 0 }} / {{ r.cuentasProcesadas ?? 0 }}
          </td>
        </ng-container>
        <ng-container matColumnDef="duracion">
          <th mat-header-cell *matHeaderCellDef>Duración</th>
          <td mat-cell *matCellDef="let r">
            {{ r.duracionSegundos != null ? r.duracionSegundos + 's' : '—' }}
          </td>
        </ng-container>
        <ng-container matColumnDef="operador">
          <th mat-header-cell *matHeaderCellDef>Operador</th>
          <td mat-cell *matCellDef="let r">{{ r.usrOperador ?? '—' }}</td>
        </ng-container>
        <ng-container matColumnDef="mensaje">
          <th mat-header-cell *matHeaderCellDef>Mensaje</th>
          <td mat-cell *matCellDef="let r">{{ r.mensaje ?? '' }}</td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="colsLog"></tr>
        <tr mat-row *matRowDef="let r; columns: colsLog;"
            [class.row-error]="r.resultado === 'ERROR'"></tr>
      </table>
      @if (!log().length) {
        <p class="empty-msg">Sin ejecuciones registradas.</p>
      }
    }
  </div>
</div>
`,
  styles: [`
    .card-section-title { display:flex; align-items:center; gap:8px; font-weight:700; font-size:14px;
      color:var(--color-text-heading); margin-bottom:16px;
      mat-icon { color:var(--color-primary); font-size:20px; width:20px; height:20px; } }
    .exec-row { display:flex; gap:16px; align-items:flex-start; flex-wrap:wrap; }
    .exec-msg { padding:10px 14px; border-radius:6px; font-size:13px; margin-top:12px; }
    .exec-msg--ok { background:#f0fdf4; color:#166534; }
    .exec-msg--error { background:#fef2f2; color:#b91c1c; }
    .estado-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:16px; }
    .estado-item { span { font-size:12px; color:var(--color-text-muted); display:block; }
                   strong { font-size:14px; } }
    .progress-row { display:flex; align-items:center; gap:12px; margin-bottom:8px;
      mat-progress-bar { flex:1; } }
    .progress-pct { font-size:14px; font-weight:700; min-width:40px; }
    .estado-msg { font-size:13px; color:var(--color-text-muted); margin-top:4px; }
    .row-error td { background:#fef2f2; }
    .empty-msg { text-align:center; padding:32px; color:var(--color-text-muted); }
  `]
})
export class DevengamientoV2Component implements OnInit, OnDestroy {
  private svc    = inject(DevengamientoService);
  private auth   = inject(AuthService);
  private fb     = inject(FormBuilder);
  private pollId: ReturnType<typeof setInterval> | null = null;

  tributos    = signal<TipoTributo[]>([]);
  parametrica = signal<ParametricaTributo[]>([]);
  estado      = signal<EstadoDevengamiento | null>(null);
  log         = signal<LogDevengamiento[]>([]);
  cargandoEstado = signal(false);
  cargandoLog    = signal(false);
  ejecutando     = signal(false);
  mensajeEjecucion = signal('');
  errorEjecucion   = signal(false);

  colsLog = ['fecha','tributo','ejercicio','resultado','cuentas','duracion','operador','mensaje'];

  form = this.fb.group({
    idTipoTributo: [null as number | null, Validators.required],
    ejercicio:     ['', [Validators.required, Validators.pattern(/^\d{4}$/)]],
  });

  ngOnInit() {
    this.svc.tributos().subscribe(t => this.tributos.set(t));
    this.svc.parametricaTributos().subscribe(p => this.parametrica.set(p));
    this.cargarEstado();
    this.cargarLog();
  }

  ngOnDestroy() {
    if (this.pollId) clearInterval(this.pollId);
  }

  cargarEstado() {
    this.cargandoEstado.set(true);
    this.svc.v2Estado().subscribe({
      next: e => { this.estado.set(e); this.cargandoEstado.set(false); },
      error: () => this.cargandoEstado.set(false),
    });
  }

  cargarLog() {
    this.cargandoLog.set(true);
    this.svc.v2Log().subscribe({
      next: l => { this.log.set(l); this.cargandoLog.set(false); },
      error: () => this.cargandoLog.set(false),
    });
  }

  ejecutar() {
    if (this.form.invalid) return;
    this.ejecutando.set(true); this.mensajeEjecucion.set(''); this.errorEjecucion.set(false);
    const v = this.form.value;
    const usuario = this.auth.currentUser()?.usuario ?? 'SISTEMA';
    this.svc.v2Ejecutar({ idJurisdiccion: 1, idTipoTributo: v.idTipoTributo!, ejercicio: v.ejercicio!, usuario }).subscribe({
      next: r => {
        this.ejecutando.set(false);
        this.mensajeEjecucion.set(r.mensaje);
        this.errorEjecucion.set(!r.ok);
        this.cargarEstado(); this.cargarLog();
        if (r.ok) this.iniciarPolling();
      },
      error: e => {
        this.ejecutando.set(false);
        this.mensajeEjecucion.set(e.error?.mensaje ?? 'Error al ejecutar.');
        this.errorEjecucion.set(true);
      },
    });
  }

  private iniciarPolling() {
    if (this.pollId) clearInterval(this.pollId);
    this.pollId = setInterval(() => {
      this.svc.v2Estado().subscribe(e => {
        this.estado.set(e);
        if (!e || e.estado === 'COMPLETADO' || e.estado === 'ERROR') {
          clearInterval(this.pollId!); this.pollId = null;
          this.cargarLog();
        }
      });
    }, 3000);
  }

  nombreTributo(id: number | null) {
    if (!id) return '—';
    return this.tributos().find(t => t.idTipoTributo === id)?.tipoTributo_ ?? String(id);
  }

  estadoBadge(estado: string) {
    const map: Record<string,string> = { COMPLETADO:'success', EN_PROCESO:'accent', ERROR:'danger', PENDIENTE:'muted' };
    return map[estado] ?? 'muted';
  }

  resultadoBadge(resultado: string) {
    const map: Record<string,string> = { EXITOSO:'success', ERROR:'danger', CANCELADO:'muted' };
    return map[resultado] ?? 'muted';
  }
}
