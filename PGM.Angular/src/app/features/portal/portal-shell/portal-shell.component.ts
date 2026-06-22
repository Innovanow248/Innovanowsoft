import { Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { PortalService } from '../../../core/services/portal.service';

@Component({
  selector: 'app-portal-shell',
  standalone: true,
  imports: [RouterOutlet, MatIconModule],
  template: `
<div class="portal-shell">
  <header class="portal-header">
    <div class="header-brand">
      <mat-icon class="brand-icon">location_city</mat-icon>
      <div>
        <div class="brand-name">Portal Ciudadano</div>
        <div class="brand-sub">Municipalidad</div>
      </div>
    </div>
    @if (svc.ciudadano()) {
      <div class="header-user">
        <div class="user-info">
          <div class="user-name">{{ svc.ciudadano()!.apellido }}, {{ svc.ciudadano()!.nombre }}</div>
          <div class="user-id">ID: {{ svc.ciudadano()!.identificador }}</div>
        </div>
        <button class="btn-salir" (click)="svc.logout()">
          <mat-icon>logout</mat-icon> Salir
        </button>
      </div>
    }
  </header>
  <main class="portal-content">
    <router-outlet />
  </main>
  <footer class="portal-footer">
    Municipalidad · Sistema de Gestión Tributaria · {{ year }}
  </footer>
</div>
`,
  styles: [`
    .portal-shell {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      background: #f1f5f9;
    }
    .portal-header {
      background: #1a3a5c;
      padding: 0 32px;
      height: 64px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      box-shadow: 0 2px 8px rgba(0,0,0,0.2);
    }
    .header-brand {
      display: flex; align-items: center; gap: 12px;
    }
    .brand-icon { color: #f5a623; font-size: 32px; width: 32px; height: 32px; }
    .brand-name { color: #fff; font-size: 16px; font-weight: 700; }
    .brand-sub  { color: rgba(255,255,255,0.6); font-size: 11px; }
    .header-user { display: flex; align-items: center; gap: 16px; }
    .user-info   { text-align: right; }
    .user-name   { color: #fff; font-size: 14px; font-weight: 600; }
    .user-id     { color: rgba(255,255,255,0.6); font-size: 11px; }
    .btn-salir {
      display: flex; align-items: center; gap: 6px;
      background: rgba(255,255,255,0.12); color: #fff;
      border: 1px solid rgba(255,255,255,0.2); border-radius: 6px;
      padding: 6px 14px; font-size: 13px; cursor: pointer;
      &:hover { background: rgba(255,255,255,0.2); }
      mat-icon { font-size: 16px; }
    }
    .portal-content {
      flex: 1;
      padding: 32px;
      max-width: 960px;
      width: 100%;
      margin: 0 auto;
    }
    .portal-footer {
      background: #1a3a5c;
      color: rgba(255,255,255,0.4);
      text-align: center;
      font-size: 11px;
      padding: 12px;
    }
    @media (max-width: 640px) {
      .portal-header { padding: 0 16px; }
      .portal-content { padding: 16px; }
      .user-info { display: none; }
    }
  `],
})
export class PortalShellComponent {
  svc  = inject(PortalService);
  year = new Date().getFullYear();
}
