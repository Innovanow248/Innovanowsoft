import { Component, inject, signal } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTooltipModule } from '@angular/material/tooltip';
import { AuthService } from '../../core/services/auth.service';

interface NavItem {
  label: string;
  icon: string;
  route: string;
}

interface NavSection {
  title: string;
  icon: string;
  items: NavItem[];
}

@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive, MatIconModule, MatButtonModule, MatTooltipModule],
  template: `
    <div class="shell">
      <!-- Sidebar -->
      <nav class="sidebar" [class.collapsed]="collapsed()">
        <div class="sidebar__header">
          @if (!collapsed()) {
            <span class="sidebar__logo">
              <span class="logo-innova">PGM</span><span class="logo-now">·GOB</span>
            </span>
          }
          <button mat-icon-button (click)="collapsed.set(!collapsed())" class="sidebar__toggle">
            <mat-icon>{{ collapsed() ? 'menu' : 'menu_open' }}</mat-icon>
          </button>
        </div>

        @if (!collapsed()) {
          <div class="sidebar__user">
            <mat-icon class="sidebar__user-icon">account_circle</mat-icon>
            <div>
              <div class="sidebar__user-name">{{ auth.currentUser()?.usuario }}</div>
              <div class="sidebar__user-grupo">{{ auth.currentUser()?.grupo }}</div>
            </div>
          </div>
        }

        <ul class="sidebar__nav">
          <li>
            <a routerLink="/dashboard" routerLinkActive="active"
               [matTooltip]="collapsed() ? 'Inicio' : ''" matTooltipPosition="right">
              <mat-icon>dashboard</mat-icon>
              @if (!collapsed()) { <span>Inicio</span> }
            </a>
          </li>
          @for (section of navSections; track section.title) {
            @if (!collapsed()) {
              <li class="nav-section-header">
                <mat-icon class="section-icon">{{ section.icon }}</mat-icon>
                <span>{{ section.title }}</span>
              </li>
            } @else {
              <li class="nav-section-divider" [matTooltip]="section.title" matTooltipPosition="right">
                <mat-icon>{{ section.icon }}</mat-icon>
              </li>
            }
            @for (item of section.items; track item.route) {
              <li>
                <a [routerLink]="item.route" routerLinkActive="active"
                   [matTooltip]="collapsed() ? item.label : ''" matTooltipPosition="right">
                  <mat-icon>{{ item.icon }}</mat-icon>
                  @if (!collapsed()) { <span>{{ item.label }}</span> }
                </a>
              </li>
            }
          }
        </ul>

        <div class="sidebar__footer">
          <a (click)="auth.logout()" style="cursor:pointer"
             [matTooltip]="collapsed() ? 'Cerrar sesión' : ''" matTooltipPosition="right">
            <mat-icon>logout</mat-icon>
            @if (!collapsed()) { <span>Cerrar sesión</span> }
          </a>
        </div>
      </nav>

      <!-- Contenido principal -->
      <main class="main-content">
        <router-outlet />
      </main>
    </div>
  `,
  styleUrl: './shell.component.scss'
})
export class ShellComponent {
  auth      = inject(AuthService);
  collapsed = signal(false);

  navSections: NavSection[] = [
    {
      title: 'Administración Tributaria',
      icon: 'account_balance_wallet',
      items: [
        { label: 'Inmobiliario',   icon: 'home_work',      route: '/tributaria/inmobiliario' },
        { label: 'Automotores',    icon: 'directions_car', route: '/tributaria/automotores' },
        { label: 'Cementerio',     icon: 'park',           route: '/tributaria/cementerio' },
        { label: 'Catastro',       icon: 'map',            route: '/tributaria/catastro' },
        { label: 'Comercio',       icon: 'storefront',     route: '/tributaria/comercio' },
        { label: 'Contribuyentes', icon: 'people',         route: '/tributaria/contribuyentes' },
        { label: 'Deuda',          icon: 'receipt_long',   route: '/tributaria/deuda' },
        { label: 'Planes de Pago', icon: 'event_repeat',   route: '/tributaria/planes-pago' },
        { label: 'Padrón',         icon: 'domain',         route: '/tributaria/padron' },
        { label: 'Tasas',          icon: 'percent',        route: '/tributaria/referencia/tasas' },
        { label: 'Valuación Auto', icon: 'directions_car', route: '/tributaria/referencia/valuacion-automotores' },
      ],
    },
    {
      title: 'Administración Financiera',
      icon: 'savings',
      items: [
        { label: 'Presupuesto',     icon: 'account_balance', route: '/financiera/presupuesto' },
        { label: 'Compromisos',     icon: 'handshake',       route: '/financiera/compromisos' },
        { label: 'Órdenes de Pago', icon: 'payments',        route: '/financiera/ordenes-pago' },
        { label: 'Facturas',        icon: 'receipt_long',    route: '/financiera/facturas' },
        { label: 'Proveedores',     icon: 'storefront',      route: '/financiera/proveedores' },
        { label: 'Notas de Pedido', icon: 'assignment',      route: '/financiera/notas-pedido' },
      ],
    },
    {
      title: 'Seguridad',
      icon: 'admin_panel_settings',
      items: [
        { label: 'Usuarios', icon: 'manage_accounts', route: '/admin/usuarios' },
      ],
    },
  ];
}
