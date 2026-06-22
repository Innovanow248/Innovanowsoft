import { Component, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { CurrencyPipe, DatePipe, NgClass } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { MatDialogModule, MatDialog } from '@angular/material/dialog';
import { PortalService } from '../../../core/services/portal.service';
import { PortalPagoDialogComponent } from '../portal-pago-dialog/portal-pago-dialog.component';

@Component({
  selector: 'app-portal-dashboard',
  standalone: true,
  imports: [
    CurrencyPipe, DatePipe, NgClass,
    MatIconModule, MatTableModule, MatChipsModule, MatDialogModule,
  ],
  template: `
<div class="dashboard">

  <!-- Bienvenida -->
  <div class="welcome-card">
    <div class="welcome-avatar">{{ inicial() }}</div>
    <div>
      <div class="welcome-name">Bienvenido/a, {{ svc.ciudadano()?.apellido }}</div>
      <div class="welcome-sub">Consultá tu deuda y realizá pagos en línea</div>
    </div>
  </div>

  @if (loading()) {
    <div class="loading-state"><mat-icon class="spin">sync</mat-icon> Cargando tu información…</div>
  }

  @if (error()) {
    <div class="error-banner"><mat-icon>error</mat-icon> {{ error() }}</div>
  }

  @if (!loading() && datos) {

    <!-- Estadísticas -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon"><mat-icon>home</mat-icon></div>
        <div class="stat-value">{{ datos.bienes?.length ?? 0 }}</div>
        <div class="stat-label">Bienes registrados</div>
      </div>
      <div class="stat-card" [class.stat-danger]="totalDeuda > 0">
        <div class="stat-icon"><mat-icon>receipt_long</mat-icon></div>
        <div class="stat-value">{{ totalDeuda | currency:'ARS':'symbol':'1.0-0' }}</div>
        <div class="stat-label">Deuda total actualizada</div>
      </div>
      <div class="stat-card">
        <div class="stat-icon"><mat-icon>list_alt</mat-icon></div>
        <div class="stat-value">{{ cuotas.length }}</div>
        <div class="stat-label">Cuotas pendientes</div>
      </div>
    </div>

    <!-- Datos personales -->
    <div class="section-card">
      <div class="section-header"><mat-icon>person</mat-icon> Mis datos</div>
      <div class="datos-grid">
        <div class="dato"><span>Nombre</span><strong>{{ datos.persona?.apellido }}, {{ datos.persona?.nombre }}</strong></div>
        <div class="dato"><span>CUIT/CUIL</span><strong>{{ datos.persona?.cuitCuil }}</strong></div>
        <div class="dato"><span>Documento</span><strong>{{ datos.persona?.tipoDocumento }} {{ datos.persona?.documento }}</strong></div>
        <div class="dato"><span>Domicilio</span><strong>{{ datos.persona?.domicilio }}</strong></div>
        <div class="dato"><span>Localidad</span><strong>{{ datos.persona?.localidad }}</strong></div>
        @if (datos.persona?.telefono) {
          <div class="dato"><span>Teléfono</span><strong>{{ datos.persona?.telefono }}</strong></div>
        }
        @if (datos.persona?.email) {
          <div class="dato"><span>Email</span><strong>{{ datos.persona?.email }}</strong></div>
        }
      </div>
    </div>

    <!-- Bienes -->
    @if (datos.bienes?.length) {
      <div class="section-card">
        <div class="section-header"><mat-icon>home_work</mat-icon> Mis bienes</div>
        <div class="bienes-list">
          @for (b of datos.bienes; track b.idBien) {
            <div class="bien-item">
              <div class="bien-tipo">
                <span class="chip">{{ b.tipoBien }}</span>
              </div>
              <div class="bien-clave">{{ b.claveBien }}</div>
              <div [class]="b.activo === 'S' ? 'badge-ok' : 'badge-off'">
                {{ b.activo === 'S' ? 'Activo' : 'Inactivo' }}
              </div>
            </div>
          }
        </div>
      </div>
    }

    <!-- Resumen de deuda -->
    @if (resumen.length) {
      <div class="section-card">
        <div class="section-header"><mat-icon>account_balance_wallet</mat-icon> Resumen de deuda</div>
        <table mat-table [dataSource]="resumen" class="portal-table">
          <ng-container matColumnDef="tipoBien">
            <th mat-header-cell *matHeaderCellDef>Tipo de bien</th>
            <td mat-cell *matCellDef="let r"><span class="chip">{{ r.tipoBien }}</span></td>
          </ng-container>
          <ng-container matColumnDef="montoHistorico">
            <th mat-header-cell *matHeaderCellDef>Capital original</th>
            <td mat-cell *matCellDef="let r">{{ r.montoHistorico | currency:'ARS':'symbol':'1.2-2' }}</td>
          </ng-container>
          <ng-container matColumnDef="montoActualizado">
            <th mat-header-cell *matHeaderCellDef>Total actualizado</th>
            <td mat-cell *matCellDef="let r"><strong class="monto-danger">{{ r.montoActualizado | currency:'ARS':'symbol':'1.2-2' }}</strong></td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="colsResumen"></tr>
          <tr mat-row *matRowDef="let row; columns: colsResumen;"></tr>
        </table>
      </div>
    } @else if (!loading()) {
      <div class="sin-deuda">
        <mat-icon>check_circle</mat-icon>
        <strong>¡Felicitaciones!</strong> No registrás deuda pendiente.
      </div>
    }

    <!-- Cuotas pendientes con botón pago -->
    @if (cuotas.length) {
      <div class="section-card">
        <div class="section-header">
          <mat-icon>payments</mat-icon> Cuotas pendientes
          <span class="header-badge">{{ cuotas.length }}</span>
        </div>
        <div class="cuotas-list">
          @for (c of cuotas; track c.nroInterno) {
            <div class="cuota-item">
              <div class="cuota-info">
                <div class="cuota-periodo">{{ c.periodo }}</div>
                <div class="cuota-tipo">
                  <span class="chip">{{ c.tipoBien }}</span>
                  {{ c.claveBien }}
                </div>
              </div>
              <div class="cuota-monto">
                <div class="cuota-total">{{ c.deudaTotalActualizada | currency:'ARS':'symbol':'1.2-2' }}</div>
                <div class="cuota-vence">1° vto: {{ c.imp1Vence | currency:'ARS':'symbol':'1.2-2' }}</div>
              </div>
              <button class="btn-pagar" (click)="pagar(c)">
                <mat-icon>payment</mat-icon> Pagar
              </button>
            </div>
          }
        </div>
      </div>
    }
  }
</div>
`,
  styles: [`
    .dashboard { display: flex; flex-direction: column; gap: 20px; }

    .welcome-card {
      background: #1a3a5c; border-radius: 12px; padding: 24px 28px;
      display: flex; align-items: center; gap: 20px; color: #fff;
    }
    .welcome-avatar {
      width: 56px; height: 56px; border-radius: 50%;
      background: #f5a623; color: #1a3a5c; font-size: 28px; font-weight: 700;
      display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .welcome-name { font-size: 20px; font-weight: 700; }
    .welcome-sub  { font-size: 13px; color: rgba(255,255,255,.65); margin-top: 2px; }

    .loading-state, .error-banner {
      display: flex; align-items: center; gap: 10px; padding: 16px 20px;
      border-radius: 10px; font-size: 15px;
    }
    .loading-state { background: #e0f2fe; color: #0369a1; }
    .error-banner  { background: #fef2f2; color: #b91c1c; }
    .spin { animation: spin 1s linear infinite; }
    @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

    .stats-grid {
      display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px;
    }
    .stat-card {
      background: #fff; border-radius: 12px; padding: 20px; text-align: center;
      border: 2px solid #e2e8f0; box-shadow: 0 1px 4px rgba(0,0,0,.06);
    }
    .stat-card.stat-danger { border-color: #fca5a5; background: #fff5f5; }
    .stat-icon { color: #1a3a5c; margin-bottom: 8px; mat-icon { font-size: 28px; } }
    .stat-value { font-size: 22px; font-weight: 700; color: #1e293b; }
    .stat-label { font-size: 12px; color: #64748b; margin-top: 4px; }

    .section-card {
      background: #fff; border-radius: 12px; border: 1px solid #e2e8f0;
      box-shadow: 0 1px 4px rgba(0,0,0,.06); overflow: hidden;
    }
    .section-header {
      display: flex; align-items: center; gap: 10px;
      padding: 16px 20px; border-bottom: 1px solid #e2e8f0;
      font-size: 15px; font-weight: 700; color: #1e293b;
      mat-icon { color: #1a3a5c; }
    }
    .header-badge {
      margin-left: auto; background: #dc2626; color: #fff;
      font-size: 12px; font-weight: 700; padding: 2px 10px; border-radius: 12px;
    }

    .datos-grid {
      display: grid; grid-template-columns: 1fr 1fr; gap: 0;
      padding: 0;
    }
    .dato {
      display: flex; flex-direction: column; padding: 12px 20px;
      border-bottom: 1px solid #f1f5f9;
      span { font-size: 11px; color: #94a3b8; text-transform: uppercase; letter-spacing: .5px; }
      strong { font-size: 14px; color: #1e293b; margin-top: 2px; }
    }

    .bienes-list { padding: 8px 0; }
    .bien-item {
      display: flex; align-items: center; gap: 16px;
      padding: 10px 20px; border-bottom: 1px solid #f1f5f9;
      &:last-child { border-bottom: none; }
    }
    .bien-tipo { flex-shrink: 0; }
    .bien-clave { flex: 1; font-size: 14px; color: #475569; font-family: monospace; }
    .badge-ok  { background: #dcfce7; color: #166534; padding: 2px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; }
    .badge-off { background: #f1f5f9; color: #64748b; padding: 2px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; }

    .portal-table { width: 100%; }

    .monto-danger { color: #dc2626; }

    .sin-deuda {
      background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 12px;
      padding: 20px 24px; display: flex; align-items: center; gap: 12px;
      font-size: 15px; color: #166534;
      mat-icon { font-size: 28px; color: #16a34a; }
    }

    .cuotas-list { padding: 8px 0; }
    .cuota-item {
      display: flex; align-items: center; gap: 16px;
      padding: 14px 20px; border-bottom: 1px solid #f1f5f9;
      &:last-child { border-bottom: none; }
    }
    .cuota-info { flex: 1; }
    .cuota-periodo { font-size: 15px; font-weight: 700; color: #1e293b; }
    .cuota-tipo { font-size: 12px; color: #64748b; margin-top: 2px;
                  display: flex; align-items: center; gap: 6px; }
    .cuota-monto { text-align: right; flex-shrink: 0; }
    .cuota-total { font-size: 16px; font-weight: 700; color: #dc2626; }
    .cuota-vence { font-size: 11px; color: #94a3b8; margin-top: 2px; }

    .btn-pagar {
      display: flex; align-items: center; gap: 6px;
      background: #1a3a5c; color: #fff;
      border: none; border-radius: 8px; padding: 10px 18px;
      font-size: 14px; font-weight: 600; cursor: pointer; flex-shrink: 0;
      &:hover { background: #243f5e; }
      mat-icon { font-size: 18px; }
    }

    .chip {
      background: #e0f2fe; color: #0369a1; border-radius: 6px;
      padding: 2px 8px; font-size: 12px; font-weight: 600;
    }

    @media (max-width: 640px) {
      .stats-grid { grid-template-columns: 1fr; }
      .datos-grid { grid-template-columns: 1fr; }
      .cuota-item { flex-wrap: wrap; }
      .btn-pagar { width: 100%; justify-content: center; }
    }
  `],
})
export class PortalDashboardComponent {
  svc    = inject(PortalService);
  dialog = inject(MatDialog);
  router = inject(Router);

  loading = signal(true);
  error   = signal('');

  datos:    any = null;
  resumen:  any[] = [];
  cuotas:   any[] = [];

  colsResumen = ['tipoBien','montoHistorico','montoActualizado'];

  get totalDeuda(): number {
    return this.resumen.reduce((a, r) => a + (r.montoActualizado ?? 0), 0);
  }

  inicial(): string {
    return this.svc.ciudadano()?.apellido?.[0]?.toUpperCase() ?? '?';
  }

  constructor() {
    if (!this.svc.isLoggedIn()) { this.router.navigate(['/portal']); return; }
    this.cargarDatos();
  }

  cargarDatos() {
    this.loading.set(true);
    this.svc.perfil().subscribe({
      next: d => {
        this.datos = d;
        this.loading.set(false);
        this.cargarDeuda();
      },
      error: (e) => {
        if (e.status === 401 || e.status === 403) {
          this.svc.logout(); // token inválido → redirige a /portal
        } else {
          this.error.set('Error al cargar datos. Intentá cerrar sesión y volver a ingresar.');
        }
        this.loading.set(false);
      },
    });
  }

  cargarDeuda() {
    this.svc.deuda().subscribe({
      next: d => {
        this.resumen = d.resumen ?? [];
        this.cuotas  = d.cuotas  ?? [];
      },
      error: () => {},
    });
  }

  pagar(cuota: any) {
    this.dialog.open(PortalPagoDialogComponent, {
      data: { cuota },
      width: '480px',
      maxWidth: '95vw',
    }).afterClosed().subscribe(ok => {
      if (ok) this.cargarDeuda();
    });
  }
}
