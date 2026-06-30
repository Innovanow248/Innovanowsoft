import { Component, inject, signal, OnInit } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive, Router, NavigationEnd } from '@angular/router';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { filter } from 'rxjs/operators';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTooltipModule } from '@angular/material/tooltip';
import { AuthService } from '../../core/services/auth.service';

// ── Tipos ────────────────────────────────────────────────────────────────────
interface NavLeaf {
  label: string;
  icon: string;
  route: string;
}

interface NavGroup {
  label: string;
  icon: string;
  children: NavLeaf[];
}

type NavChild = NavLeaf | NavGroup;

interface NavSection {
  title: string;
  icon: string;
  children: NavChild[];
}

function isGroup(item: NavChild): item is NavGroup {
  return 'children' in item;
}

// ── Componente ───────────────────────────────────────────────────────────────
@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive, MatIconModule, MatButtonModule, MatTooltipModule],
  template: `
    <div class="shell">
      <nav class="sidebar" [class.collapsed]="collapsed()">

        <!-- Header -->
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

        <!-- Usuario -->
        @if (!collapsed()) {
          <div class="sidebar__user">
            <mat-icon class="sidebar__user-icon">account_circle</mat-icon>
            <div>
              <div class="sidebar__user-name">{{ auth.currentUser()?.usuario }}</div>
              <div class="sidebar__user-grupo">{{ auth.currentUser()?.grupo }}</div>
            </div>
          </div>
        }

        <!-- Nav -->
        <ul class="sidebar__nav">

          <!-- Inicio -->
          <li>
            <a routerLink="/dashboard" routerLinkActive="active" class="nav-link"
               [matTooltip]="collapsed() ? 'Inicio' : ''" matTooltipPosition="right">
              <mat-icon>dashboard</mat-icon>
              @if (!collapsed()) { <span>Inicio</span> }
            </a>
          </li>

          <!-- Secciones -->
          @for (section of navSections; track section.title) {
            <li class="nav-section-item">

              @if (!collapsed()) {
                <!-- Cabecera de sección (nivel 1) -->
                <button class="nav-section-btn"
                        [class.open]="isSectionOpen(section.title)"
                        [class.has-active]="sectionHasActive(section)"
                        (click)="toggleSection(section.title)">
                  <mat-icon class="section-icon">{{ section.icon }}</mat-icon>
                  <span class="section-title">{{ section.title }}</span>
                  <mat-icon class="chevron">chevron_right</mat-icon>
                </button>

                <!-- Hijos de nivel 1 -->
                <ul class="nav-children" [class.open]="isSectionOpen(section.title)">
                  @for (child of section.children; track child.label) {

                    @if (isGroup(child)) {
                      <!-- Submenú (nivel 2) -->
                      <li class="nav-group-item">
                        <button class="nav-group-btn"
                                [class.open]="isGroupOpen(child.label)"
                                [class.has-active]="groupHasActive(child)"
                                (click)="toggleGroup(child.label)">
                          <mat-icon>{{ child.icon }}</mat-icon>
                          <span>{{ child.label }}</span>
                          <mat-icon class="chevron">chevron_right</mat-icon>
                        </button>
                        <ul class="nav-grandchildren" [class.open]="isGroupOpen(child.label)">
                          @for (leaf of child.children; track leaf.route) {
                            <li>
                              <a [routerLink]="leaf.route" routerLinkActive="active" class="nav-leaf-link">
                                <mat-icon>{{ leaf.icon }}</mat-icon>
                                <span>{{ leaf.label }}</span>
                              </a>
                            </li>
                          }
                        </ul>
                      </li>

                    } @else {
                      <!-- Hoja (nivel 2) -->
                      <li>
                        <a [routerLink]="child.route" routerLinkActive="active" class="nav-child-link">
                          <mat-icon>{{ child.icon }}</mat-icon>
                          <span>{{ child.label }}</span>
                        </a>
                      </li>
                    }

                  }
                </ul>

              } @else {
                <!-- Colapsado: ícono de sección -->
                <div class="nav-section-icon-only" [matTooltip]="section.title" matTooltipPosition="right">
                  <mat-icon>{{ section.icon }}</mat-icon>
                </div>
                <!-- Colapsado: hojas directas -->
                @for (child of section.children; track child.label) {
                  @if (isGroup(child)) {
                    @for (leaf of child.children; track leaf.route) {
                      <a [routerLink]="leaf.route" routerLinkActive="active" class="nav-link"
                         [matTooltip]="leaf.label" matTooltipPosition="right">
                        <mat-icon>{{ leaf.icon }}</mat-icon>
                      </a>
                    }
                  } @else {
                    <a [routerLink]="child.route" routerLinkActive="active" class="nav-link"
                       [matTooltip]="child.label" matTooltipPosition="right">
                      <mat-icon>{{ child.icon }}</mat-icon>
                    </a>
                  }
                }
              }

            </li>
          }
        </ul>

        <!-- Footer -->
        <div class="sidebar__footer">
          <a (click)="auth.logout()" style="cursor:pointer"
             [matTooltip]="collapsed() ? 'Cerrar sesión' : ''" matTooltipPosition="right"
             class="nav-link">
            <mat-icon>logout</mat-icon>
            @if (!collapsed()) { <span>Cerrar sesión</span> }
          </a>
        </div>
      </nav>

      <main class="main-content">
        <router-outlet />
      </main>
    </div>
  `,
  styleUrl: './shell.component.scss'
})
export class ShellComponent implements OnInit {
  auth           = inject(AuthService);
  private router = inject(Router);

  collapsed      = signal(false);
  private openSections  = signal<Set<string>>(new Set());
  private openGroups    = signal<Set<string>>(new Set());

  readonly isGroup = isGroup;

  constructor() {
    this.router.events.pipe(
      filter(e => e instanceof NavigationEnd),
      takeUntilDestroyed(),
    ).subscribe(e => this.expandForUrl((e as NavigationEnd).urlAfterRedirects));
  }

  ngOnInit() { this.expandForUrl(this.router.url); }

  private expandForUrl(url: string) {
    for (const section of this.navSections) {
      if (this.sectionContainsUrl(section, url)) {
        this.openSections.update(s => new Set([...s, section.title]));
        for (const child of section.children) {
          if (isGroup(child) && child.children.some(l => url.startsWith(l.route))) {
            this.openGroups.update(s => new Set([...s, child.label]));
          }
        }
      }
    }
  }

  private sectionContainsUrl(section: NavSection, url: string): boolean {
    return section.children.some(c =>
      isGroup(c) ? c.children.some(l => url.startsWith(l.route)) : url.startsWith(c.route)
    );
  }

  isSectionOpen(title: string)   { return this.openSections().has(title); }
  isGroupOpen(label: string)     { return this.openGroups().has(label); }

  toggleSection(title: string) {
    this.openSections.update(s => {
      const n = new Set(s); n.has(title) ? n.delete(title) : n.add(title); return n;
    });
  }

  toggleGroup(label: string) {
    this.openGroups.update(s => {
      const n = new Set(s); n.has(label) ? n.delete(label) : n.add(label); return n;
    });
  }

  sectionHasActive(section: NavSection) { return this.sectionContainsUrl(section, this.router.url); }
  groupHasActive(group: NavGroup)       { return group.children.some(l => this.router.url.startsWith(l.route)); }

  navSections: NavSection[] = [
    {
      title: 'Administración Tributaria',
      icon: 'account_balance_wallet',
      children: [
        { label: 'Inmobiliario',   icon: 'home_work',      route: '/tributaria/inmobiliario' },
        { label: 'Automotores',    icon: 'directions_car', route: '/tributaria/automotores' },
        { label: 'Cementerio',     icon: 'park',           route: '/tributaria/cementerio' },
        { label: 'Catastro',       icon: 'map',            route: '/tributaria/catastro' },
        { label: 'Comercio',       icon: 'storefront',     route: '/tributaria/comercio' },
        { label: 'Contribuyentes', icon: 'people',         route: '/tributaria/contribuyentes' },
        { label: 'Deuda',          icon: 'receipt_long',   route: '/tributaria/deuda' },
        { label: 'Planes de Pago', icon: 'event_repeat',   route: '/tributaria/planes-pago' },
        { label: 'Padrón',         icon: 'domain',         route: '/tributaria/padron' },
        { label: 'Caja',           icon: 'point_of_sale',   route: '/tributaria/caja' },
        { label: 'Cajeros',        icon: 'manage_accounts', route: '/tributaria/cajeros' },
        { label: 'Tasas',          icon: 'percent',         route: '/tributaria/referencia/tasas' },
        { label: 'Valuación Auto', icon: 'directions_car', route: '/tributaria/referencia/valuacion-automotores' },
        {
          label: 'Parametrización',
          icon: 'tune',
          children: [
            { label: 'Conceptos',         icon: 'category',        route: '/devengamiento/conceptos' },
            { label: 'Conceptos por Año', icon: 'event_note',      route: '/devengamiento/conceptos-anio' },
            { label: 'Vencimientos',      icon: 'event',           route: '/devengamiento/vencimientos' },
            { label: 'Planes de Pago',    icon: 'event_repeat',    route: '/devengamiento/planes-pago' },
            { label: 'Intereses',         icon: 'percent',         route: '/devengamiento/intereses' },
            { label: 'Parametrizar Trib.', icon: 'settings',       route: '/devengamiento/parametrizar' },
            { label: 'Vinculación Conc.', icon: 'link',            route: '/devengamiento/vinculacion' },
            { label: 'Motor Ejec. V2',    icon: 'rocket_launch',   route: '/devengamiento/v2' },
          ],
        },
      ],
    },
    {
      title: 'Administración Financiera',
      icon: 'savings',
      children: [
        { label: 'Presupuesto Gastos',    icon: 'account_balance', route: '/financiera/presupuesto' },
        { label: 'Presupuesto Ingresos', icon: 'trending_up',     route: '/financiera/presupuesto-ingresos' },
        { label: 'Compromisos',          icon: 'handshake',        route: '/financiera/compromisos' },
        { label: 'Órdenes de Pago', icon: 'payments',        route: '/financiera/ordenes-pago' },
        { label: 'Facturas',        icon: 'receipt_long',    route: '/financiera/facturas' },
        { label: 'Proveedores',     icon: 'storefront',      route: '/financiera/proveedores' },
        { label: 'Notas de Pedido', icon: 'assignment',      route: '/financiera/notas-pedido' },
      ],
    },
    {
      title: 'Seguridad',
      icon: 'admin_panel_settings',
      children: [
        { label: 'Usuarios', icon: 'manage_accounts', route: '/admin/usuarios' },
      ],
    },
  ];
}
