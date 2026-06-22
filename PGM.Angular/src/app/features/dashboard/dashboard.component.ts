import { Component, inject } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [MatIconModule, RouterLink],
  template: `
    <div class="page-container">
      <div class="eyebrow">Panel principal</div>
      <h1 class="page-title">Bienvenido, {{ auth.currentUser()?.usuario }}</h1>
      <p class="page-subtitle">{{ auth.currentUser()?.grupo }}</p>

      <div class="dashboard-grid">
        @for (item of accesos; track item.route) {
          <a [routerLink]="item.route" class="acceso-card">
            <div class="acceso-card__icon" [style.background]="item.color">
              <mat-icon>{{ item.icon }}</mat-icon>
            </div>
            <div class="acceso-card__label">{{ item.label }}</div>
            <div class="acceso-card__desc">{{ item.desc }}</div>
          </a>
        }
      </div>
    </div>
  `,
  styleUrl: './dashboard.component.scss'
})
export class DashboardComponent {
  auth = inject(AuthService);

  accesos = [
    { label: 'Contribuyentes',  icon: 'people',          route: '/tributaria/contribuyentes', color: '#3498DB', desc: 'Buscar y gestionar contribuyentes' },
    { label: 'Deuda',           icon: 'receipt_long',    route: '/tributaria/deuda',           color: '#E74C3C', desc: 'Consulta de deuda tributaria' },
    { label: 'Presupuesto',     icon: 'account_balance', route: '/financiera/presupuesto',     color: '#27AE60', desc: 'Ejecución presupuestaria' },
    { label: 'Órdenes de Pago', icon: 'payments',        route: '/financiera/ordenes-pago',    color: '#9B59B6', desc: 'Gestión de órdenes de pago' },
    { label: 'Proveedores',     icon: 'storefront',      route: '/financiera/proveedores',     color: '#E67E22', desc: 'Facturas de compra' },
  ];
}
