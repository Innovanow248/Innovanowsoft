import { Component, inject, signal, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { CurrencyPipe, DatePipe } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { FinancieraService, OrdenPago, FacturaCompra } from '../../../core/services/financiera.service';

@Component({
  selector: 'app-ordenes-pago-detalle',
  standalone: true,
  imports: [
    CurrencyPipe, DatePipe,
    MatButtonModule, MatIconModule,
    MatTableModule, MatProgressSpinnerModule, MatTooltipModule,
  ],
  template: `
<div class="page-container">

  <!-- Breadcrumb + volver -->
  <div class="breadcrumb">
    <button class="btn-back" (click)="volver()">
      <mat-icon>arrow_back</mat-icon> Órdenes de Pago
    </button>
    <span class="sep">/</span>
    <span class="crumb-current">OP {{ tipo }}-{{ ano }}-{{ nro }}</span>
  </div>

  @if (loading()) {
    <div style="text-align:center;padding:64px"><mat-spinner diameter="44"/></div>
  }

  @if (!loading() && op()) {
    <!-- Encabezado -->
    <div class="op-header card">
      <div class="op-header__top">
        <div class="op-id">
          <mat-icon class="op-icon">payments</mat-icon>
          <div>
            <div class="op-numero">OP {{ op()!.tipoOpago }}-{{ op()!.anoOpago }}-{{ op()!.nroOpago }}</div>
            <div class="op-fecha">
              @if (op()!.fechaAprobacion) { Aprobada {{ op()!.fechaAprobacion | date:'dd/MM/yyyy' }} }
              @else { Sin fecha de aprobación }
            </div>
          </div>
        </div>
        <span [class]="estadoClass(op()!.estadoOpago)">{{ estadoLabel(op()!.estadoOpago) }}</span>
      </div>

      <div class="op-info-grid">
        <div class="info-block">
          <div class="info-label">Proveedor</div>
          <div class="info-value strong">{{ op()!.proveedor }}</div>
          <div class="info-sub">CUIT {{ op()!.cuitCuil }}</div>
        </div>
        <div class="info-block">
          <div class="info-label">Observaciones</div>
          <div class="info-value">{{ op()!.observaciones || '—' }}</div>
        </div>
      </div>
    </div>

    <!-- KPIs de montos -->
    <div class="montos-grid">
      <div class="stat-card">
        <div class="stat-value" style="color:var(--color-warning)">
          {{ op()!.montoAPagar | currency:'ARS':'symbol':'1.2-2' }}
        </div>
        <div class="stat-label">Monto a pagar</div>
      </div>
      <div class="stat-card">
        <div class="stat-value" style="color:var(--color-success)">
          {{ op()!.montoPagado | currency:'ARS':'symbol':'1.2-2' }}
        </div>
        <div class="stat-label">Pagado</div>
      </div>
      <div class="stat-card">
        <div class="stat-value" [style.color]="saldo() > 0 ? 'var(--color-danger)' : 'var(--color-success)'">
          {{ saldo() | currency:'ARS':'symbol':'1.2-2' }}
        </div>
        <div class="stat-label">Saldo pendiente</div>
      </div>
    </div>

    <!-- Acciones de estado -->
    <div class="acciones-bar card">
      <span class="acciones-label">Acciones</span>
      @if (op()!.estadoOpago === 'P') {
        <button class="btn-accion ok" (click)="cambiarEstado('A')">
          <mat-icon>check_circle</mat-icon> Aprobar
        </button>
        <button class="btn-accion danger" (click)="cambiarEstado('C')">
          <mat-icon>cancel</mat-icon> Cancelar
        </button>
      }
      @if (op()!.estadoOpago === 'A') {
        <button class="btn-accion pay" (click)="cambiarEstado('E')">
          <mat-icon>payments</mat-icon> Emitir / Pagar
        </button>
        <button class="btn-accion danger" (click)="cambiarEstado('C')">
          <mat-icon>cancel</mat-icon> Cancelar
        </button>
      }
      @if (op()!.estadoOpago === 'E' || op()!.estadoOpago === 'C') {
        <span class="acciones-final">No hay acciones disponibles para este estado.</span>
      }
    </div>

    <!-- Facturas asociadas -->
    <div class="card facturas-card">
      <div class="card-header">
        <mat-icon>receipt_long</mat-icon>
        <span>Facturas asociadas</span>
        @if (loadingFacturas()) { <mat-spinner diameter="18" style="margin-left:8px"/> }
        @else { <span class="fact-count">{{ facturas().length }}</span> }
      </div>

      @if (!loadingFacturas() && facturas().length === 0) {
        <div class="empty-facts">Sin facturas asociadas a esta orden de pago.</div>
      }

      @if (facturas().length > 0) {
        <table mat-table [dataSource]="facturas()">
          <ng-container matColumnDef="nroFactura">
            <th mat-header-cell *matHeaderCellDef>N° Factura</th>
            <td mat-cell *matCellDef="let f">
              <strong>{{ f.tipoComprobante }}-{{ f.letraComprobante }}-{{ f.nroFactura }}</strong>
            </td>
          </ng-container>
          <ng-container matColumnDef="fecha">
            <th mat-header-cell *matHeaderCellDef>Fecha</th>
            <td mat-cell *matCellDef="let f">{{ f.fecha | date:'dd/MM/yyyy' }}</td>
          </ng-container>
          <ng-container matColumnDef="neto">
            <th mat-header-cell *matHeaderCellDef>Neto gravado</th>
            <td mat-cell *matCellDef="let f">{{ f.netoGravado | currency:'ARS':'symbol':'1.2-2' }}</td>
          </ng-container>
          <ng-container matColumnDef="iva">
            <th mat-header-cell *matHeaderCellDef>IVA</th>
            <td mat-cell *matCellDef="let f">{{ f.iva | currency:'ARS':'symbol':'1.2-2' }}</td>
          </ng-container>
          <ng-container matColumnDef="total">
            <th mat-header-cell *matHeaderCellDef>Total</th>
            <td mat-cell *matCellDef="let f">
              <strong>{{ f.totalFactura | currency:'ARS':'symbol':'1.2-2' }}</strong>
            </td>
          </ng-container>
          <ng-container matColumnDef="estado">
            <th mat-header-cell *matHeaderCellDef>Estado</th>
            <td mat-cell *matCellDef="let f">
              <span [class]="factEstadoClass(f.estado)">{{ f.estado }}</span>
            </td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="factCols"></tr>
          <tr mat-row *matRowDef="let row; columns: factCols;"></tr>
        </table>

        <div class="facts-total">
          Total facturas: <strong>{{ totalFacturas() | currency:'ARS':'symbol':'1.2-2' }}</strong>
        </div>
      }
    </div>
  }

  @if (!loading() && !op()) {
    <div class="amber-banner">No se encontró la orden de pago {{ tipo }}-{{ ano }}-{{ nro }}.</div>
  }

</div>
  `,
  styles: [`
    .breadcrumb {
      display: flex; align-items: center; gap: 8px;
      margin-bottom: var(--spacing-lg); font-size: 13px; color: #64748b;
    }
    .btn-back {
      display: flex; align-items: center; gap: 4px;
      background: none; border: none; cursor: pointer;
      color: var(--color-primary); font-size: 13px; font-weight: 600; padding: 0;
      &:hover { text-decoration: underline; }
      mat-icon { font-size: 18px; width: 18px; height: 18px; }
    }
    .sep { color: #cbd5e1; }
    .crumb-current { color: #1e293b; font-weight: 600; }

    // Encabezado OP
    .op-header {
      padding: var(--spacing-lg);
      margin-bottom: var(--spacing-md);
    }
    .op-header__top {
      display: flex; align-items: flex-start; justify-content: space-between;
      margin-bottom: var(--spacing-md);
    }
    .op-id { display: flex; align-items: center; gap: 12px; }
    .op-icon { font-size: 36px; width: 36px; height: 36px; color: var(--color-primary); }
    .op-numero { font-size: 20px; font-weight: 700; color: #1e293b; }
    .op-fecha  { font-size: 12px; color: #64748b; margin-top: 2px; }

    .op-info-grid {
      display: grid; grid-template-columns: 1fr 1fr; gap: var(--spacing-md);
    }
    .info-block { background: #f8fafc; border-radius: 6px; padding: 10px 14px; }
    .info-label { font-size: 11px; font-weight: 700; text-transform: uppercase; color: #94a3b8; letter-spacing: .04em; margin-bottom: 4px; }
    .info-value { font-size: 14px; color: #1e293b; &.strong { font-weight: 600; } }
    .info-sub   { font-size: 12px; color: #64748b; margin-top: 2px; }

    // KPIs
    .montos-grid {
      display: grid; grid-template-columns: repeat(3, 1fr);
      gap: var(--spacing-md); margin-bottom: var(--spacing-md);
    }

    // Acciones
    .acciones-bar {
      display: flex; align-items: center; gap: 10px;
      padding: var(--spacing-md) var(--spacing-lg);
      margin-bottom: var(--spacing-md);
    }
    .acciones-label { font-size: 12px; font-weight: 700; color: #64748b; text-transform: uppercase; margin-right: 4px; }
    .acciones-final { font-size: 13px; color: #94a3b8; }
    .btn-accion {
      display: flex; align-items: center; gap: 6px;
      border: none; border-radius: 6px; padding: 0 16px; height: 36px;
      font-size: 13px; font-weight: 600; cursor: pointer;
      mat-icon { font-size: 18px; width: 18px; height: 18px; }
      &.ok     { background: #dcfce7; color: #166534; &:hover { background: #bbf7d0; } }
      &.pay    { background: #dbeafe; color: #1d4ed8; &:hover { background: #bfdbfe; } }
      &.danger { background: #fee2e2; color: #b91c1c; &:hover { background: #fecaca; } }
    }

    // Facturas
    .facturas-card { padding: 0; overflow: hidden; }
    .card-header {
      display: flex; align-items: center; gap: 8px;
      padding: var(--spacing-md) var(--spacing-lg);
      border-bottom: 1px solid var(--color-border);
      font-weight: 700; color: var(--color-text-heading); font-size: 14px;
      mat-icon { color: var(--color-primary); font-size: 20px; width: 20px; height: 20px; }
    }
    .fact-count {
      background: #e2e8f0; color: #475569;
      font-size: 11px; font-weight: 700;
      padding: 2px 8px; border-radius: 10px;
    }
    .empty-facts {
      padding: 32px; text-align: center; color: #94a3b8; font-size: 13px;
    }
    .facts-total {
      padding: 12px 16px; text-align: right;
      font-size: 13px; color: #475569;
      border-top: 1px solid #f1f5f9;
      strong { color: #1e293b; }
    }

    // Badges
    .badge { display:inline-flex; align-items:center; padding:3px 10px; border-radius:12px; font-size:12px; font-weight:600; }
    .badge--warning { background:#fef9c3; color:#854d0e; }
    .badge--info    { background:#dbeafe; color:#1d4ed8; }
    .badge--success { background:#dcfce7; color:#166534; }
    .badge--muted   { background:#f1f5f9; color:#64748b; }

    @media (max-width: 768px) {
      .op-info-grid  { grid-template-columns: 1fr; }
      .montos-grid   { grid-template-columns: 1fr; }
    }
  `],
})
export class OrdenesPagoDetalleComponent implements OnInit {
  private svc    = inject(FinancieraService);
  private route  = inject(ActivatedRoute);
  private router = inject(Router);

  tipo = '';
  ano  = '';
  nro  = '';

  loading         = signal(true);
  loadingFacturas = signal(true);
  op              = signal<OrdenPago | null>(null);
  facturas        = signal<FacturaCompra[]>([]);

  factCols = ['nroFactura', 'fecha', 'neto', 'iva', 'total', 'estado'];

  saldo()          { return (this.op()?.montoAPagar ?? 0) - (this.op()?.montoPagado ?? 0); }
  totalFacturas()  { return this.facturas().reduce((a, f) => a + f.totalFactura, 0); }

  ngOnInit() {
    this.tipo = this.route.snapshot.paramMap.get('tipo')!;
    this.ano  = this.route.snapshot.paramMap.get('ano')!;
    this.nro  = this.route.snapshot.paramMap.get('nro')!;

    // Intentar usar el estado del router (evita un round-trip si viene de la lista)
    const state = history.state as { op?: OrdenPago };
    if (state?.op) {
      this.op.set(state.op);
      this.loading.set(false);
    } else {
      this.svc.ordenPago(this.tipo, this.ano, this.nro).subscribe({
        next: d  => { this.op.set(d); this.loading.set(false); },
        error: () => this.loading.set(false),
      });
    }

    this.svc.facturasPorOrden(this.tipo, this.ano, this.nro).subscribe({
      next: d  => { this.facturas.set(d); this.loadingFacturas.set(false); },
      error: () => this.loadingFacturas.set(false),
    });
  }

  volver() { this.router.navigate(['/financiera/ordenes-pago']); }

  cambiarEstado(estado: string) {
    const labels: Record<string, string> = { A: 'Aprobar', E: 'Emitir/Pagar', C: 'Cancelar' };
    if (!confirm(`¿${labels[estado]} la OP ${this.tipo}-${this.ano}-${this.nro}?`)) return;
    this.svc.cambiarEstadoOP(this.tipo, this.ano, this.nro, estado).subscribe({
      next: () => this.svc.ordenPago(this.tipo, this.ano, this.nro).subscribe(d => this.op.set(d)),
    });
  }

  estadoLabel(e: string) {
    return ({ P: 'Pendiente', A: 'Aprobada', E: 'Emitida', C: 'Cancelada' } as Record<string,string>)[e] ?? e;
  }
  estadoClass(e: string) {
    const m: Record<string,string> = { P: 'warning', A: 'info', E: 'success', C: 'muted' };
    return `badge badge--${m[e] ?? 'muted'}`;
  }
  factEstadoClass(e: string) {
    return `badge badge--${e === 'A' ? 'success' : e === 'P' ? 'warning' : 'muted'}`;
  }
}
