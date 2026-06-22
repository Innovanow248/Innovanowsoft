import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  { path: 'login', loadComponent: () => import('./features/login/login.component').then(m => m.LoginComponent) },
  {
    path: '',
    loadComponent: () => import('./layout/shell/shell.component').then(m => m.ShellComponent),
    canActivate: [authGuard],
    children: [
      { path: 'dashboard',    loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent) },
      { path: 'presupuesto',  loadComponent: () => import('./features/presupuesto/presupuesto.component').then(m => m.PresupuestoComponent) },
      { path: 'compromisos',  loadComponent: () => import('./features/compromisos/compromisos.component').then(m => m.CompromisosComponent) },
      { path: 'ordenes-pago', loadComponent: () => import('./features/ordenes-pago/ordenes-pago.component').then(m => m.OrdenesPagoComponent) },
      { path: 'facturas',     loadComponent: () => import('./features/facturas/facturas.component').then(m => m.FacturasComponent) },
      { path: 'proveedores',  loadComponent: () => import('./features/proveedores/proveedores.component').then(m => m.ProveedoresComponent) },
      { path: 'notas-pedido', loadComponent: () => import('./features/notas-pedido/notas-pedido.component').then(m => m.NotasPedidoComponent) },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    ]
  },
  { path: '**', redirectTo: 'login' }
];
