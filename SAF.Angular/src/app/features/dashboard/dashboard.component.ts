import { Component, inject, signal, OnInit } from '@angular/core';
import { CurrencyPipe, DecimalPipe } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { RouterLink } from '@angular/router';
import { FinancieroService } from '../../core/services/financiero.service';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CurrencyPipe, DecimalPipe, MatIconModule, RouterLink],
  template: `
    <div class="page-container">
      <div class="eyebrow">Sistema de Administración Financiera</div>
      <h1 class="page-title">Bienvenido, {{ auth.currentUser()?.usuario }}</h1>
      <p class="page-subtitle">{{ anoActual }} · Administración Financiera Municipal</p>

      <div class="kpi-grid">
        <div class="stat-card">
          <div class="stat-value" style="color:var(--color-primary)">{{ totalPresupuesto | currency:'ARS':'symbol':'1.0-0' }}</div>
          <div class="stat-label">Presupuesto autorizado {{ anoActual }}</div>
        </div>
        <div class="stat-card">
          <div class="stat-value" style="color:var(--color-info)">{{ totalCompromisos | currency:'ARS':'symbol':'1.0-0' }}</div>
          <div class="stat-label">Compromisos {{ anoActual }}</div>
        </div>
        <div class="stat-card">
          <div class="stat-value" style="color:var(--color-warning)">{{ totalOP | currency:'ARS':'symbol':'1.0-0' }}</div>
          <div class="stat-label">Órdenes de Pago {{ anoActual }}</div>
        </div>
        <div class="stat-card">
          <div class="stat-value" style="color:var(--color-success)">{{ totalFacturas | currency:'ARS':'symbol':'1.0-0' }}</div>
          <div class="stat-label">Facturas {{ anoActual }}</div>
        </div>
      </div>

      <div class="accesos-grid">
        @for (item of accesos; track item.route) {
          <a [routerLink]="item.route" class="acceso-card">
            <mat-icon class="acceso-icon">{{ item.icon }}</mat-icon>
            <span class="acceso-label">{{ item.label }}</span>
            <span class="acceso-desc">{{ item.desc }}</span>
          </a>
        }
      </div>
    </div>
  `,
  styles: [`
    .kpi-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: var(--spacing-md);
      margin-bottom: var(--spacing-lg);
    }
    .accesos-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: var(--spacing-md);
    }
    .acceso-card {
      background: var(--color-surface);
      border: 1px solid var(--color-border);
      border-radius: var(--radius-md);
      padding: var(--spacing-lg);
      text-decoration: none;
      display: flex;
      flex-direction: column;
      gap: 6px;
      transition: box-shadow 0.15s, border-color 0.15s;
      &:hover { box-shadow: var(--shadow-elevated); border-color: var(--color-accent); }
    }
    .acceso-icon { font-size: 32px; width: 32px; height: 32px; color: var(--color-primary); }
    .acceso-label { font-size: 15px; font-weight: 700; color: var(--color-text-heading); }
    .acceso-desc  { font-size: 12px; color: var(--color-text-muted); }
    @media (max-width: 900px) {
      .kpi-grid { grid-template-columns: 1fr 1fr; }
      .accesos-grid { grid-template-columns: 1fr 1fr; }
    }
  `]
})
export class DashboardComponent implements OnInit {
  private svc = inject(FinancieroService);
  auth = inject(AuthService);

  anoActual = new Date().getFullYear().toString();
  totalPresupuesto = 0;
  totalCompromisos = 0;
  totalOP          = 0;
  totalFacturas    = 0;

  accesos = [
    { label: 'Presupuesto',     icon: 'account_balance',  route: '/presupuesto',   desc: 'Cuentas de erogación y ejecución' },
    { label: 'Compromisos',     icon: 'handshake',        route: '/compromisos',   desc: 'Compromisos presupuestarios' },
    { label: 'Órdenes de Pago', icon: 'payments',         route: '/ordenes-pago',  desc: 'Gestión de órdenes de pago' },
    { label: 'Facturas',        icon: 'receipt_long',     route: '/facturas',      desc: 'Facturas de compras globales' },
    { label: 'Proveedores',     icon: 'storefront',       route: '/proveedores',   desc: 'Padrón de proveedores' },
    { label: 'Notas de Pedido', icon: 'assignment',       route: '/notas-pedido',  desc: 'Solicitudes de abastecimiento' },
  ];

  ngOnInit() {
    this.svc.presupuesto(this.anoActual).subscribe(d => {
      this.totalPresupuesto = d.reduce((a, c) => a + c.presupuestoAutorizado, 0);
    });
    this.svc.compromisos(this.anoActual).subscribe(d => {
      this.totalCompromisos = d.reduce((a, c) => a + c.montoComprometido, 0);
    });
    this.svc.ordenesPago(this.anoActual).subscribe(d => {
      this.totalOP = d.reduce((a, c) => a + c.montoAPagar, 0);
    });
    this.svc.facturas(parseInt(this.anoActual)).subscribe(d => {
      this.totalFacturas = d.reduce((a, c) => a + c.totalFactura, 0);
    });
  }
}
