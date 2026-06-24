import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  // ── Admin app ──────────────────────────────────────────────────────────────
  { path: 'login', loadComponent: () => import('./features/login/login.component').then(m => m.LoginComponent) },
  {
    path: '',
    loadComponent: () => import('./layout/shell/shell.component').then(m => m.ShellComponent),
    canActivate: [authGuard],
    children: [
      { path: 'dashboard',                  loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent) },
      { path: 'tributaria/contribuyentes',  data: { titulo: 'Contribuyentes', botonLabel: 'Nuevo contribuyente', botonIcono: 'person_add' },                                                        loadComponent: () => import('./features/tributaria/contribuyentes/contribuyentes.component').then(m => m.ContribuyentesComponent) },
      { path: 'tributaria/inmobiliario',    data: { titulo: 'Inmobiliario',  botonLabel: 'Nuevo inmueble',       botonIcono: 'add_home',        tipoBienes: ['ININ'] },              loadComponent: () => import('./features/tributaria/contribuyentes/contribuyentes.component').then(m => m.ContribuyentesComponent) },
      { path: 'tributaria/automotores',     data: { titulo: 'Automotores',   botonLabel: 'Nuevo vehículo',       botonIcono: 'directions_car',  tipoBienes: ['AUAU'] },              loadComponent: () => import('./features/tributaria/contribuyentes/contribuyentes.component').then(m => m.ContribuyentesComponent) },
      { path: 'tributaria/cementerio',      data: { titulo: 'Cementerio',    botonLabel: 'Nueva parcela',        botonIcono: 'park',            tipoBienes: ['CECE'] },              loadComponent: () => import('./features/tributaria/contribuyentes/contribuyentes.component').then(m => m.ContribuyentesComponent) },
      { path: 'tributaria/catastro',        data: { titulo: 'Catastro',      botonLabel: 'Nuevo catastro',       botonIcono: 'map',             tipoBienes: ['CACA','OBSA','OBSC'] }, loadComponent: () => import('./features/tributaria/contribuyentes/contribuyentes.component').then(m => m.ContribuyentesComponent) },
      { path: 'tributaria/comercio',        data: { titulo: 'Comercio',      botonLabel: 'Nuevo comercio',       botonIcono: 'storefront',      tipoBienes: ['CICI'] },              loadComponent: () => import('./features/tributaria/contribuyentes/contribuyentes.component').then(m => m.ContribuyentesComponent) },
      { path: 'tributaria/deuda',           loadComponent: () => import('./features/tributaria/deuda/deuda.component').then(m => m.DeudaComponent) },
      { path: 'tributaria/planes-pago',     loadComponent: () => import('./features/tributaria/planes-pago/planes-pago.component').then(m => m.PlanesPagoComponent) },
      { path: 'tributaria/padron',            loadComponent: () => import('./features/tributaria/padron/padron.component').then(m => m.PadronComponent) },
      { path: 'tributaria/referencia/tasas', loadComponent: () => import('./features/tributaria/referencia/tasas/tasas.component').then(m => m.TasasComponent) },
      { path: 'tributaria/referencia/valuacion-automotores', loadComponent: () => import('./features/tributaria/referencia/valuacion-automotores/valuacion-automotores.component').then(m => m.ValuacionAutomotoresComponent) },
      { path: 'financiera/presupuesto',     loadComponent: () => import('./features/financiera/presupuesto/presupuesto.component').then(m => m.PresupuestoComponent) },
      { path: 'financiera/compromisos',     loadComponent: () => import('./features/financiera/compromisos/compromisos.component').then(m => m.CompromisosComponent) },
      { path: 'financiera/ordenes-pago',    loadComponent: () => import('./features/financiera/ordenes-pago/ordenes-pago.component').then(m => m.OrdenesPagoComponent) },
      { path: 'financiera/facturas',        loadComponent: () => import('./features/financiera/facturas/facturas.component').then(m => m.FacturasFinancieraComponent) },
      { path: 'financiera/proveedores',     loadComponent: () => import('./features/financiera/proveedores/proveedores.component').then(m => m.ProveedoresComponent) },
      { path: 'financiera/notas-pedido',    loadComponent: () => import('./features/financiera/notas-pedido/notas-pedido.component').then(m => m.NotasPedidoFinancieraComponent) },
      { path: 'admin/usuarios',             loadComponent: () => import('./features/seguridad/usuarios/usuarios.component').then(m => m.UsuariosComponent) },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    ]
  },
  // ── Portal ciudadano (sin authGuard admin) ────────────────────────────────
  {
    path: 'portal',
    loadComponent: () => import('./features/portal/portal-shell/portal-shell.component').then(m => m.PortalShellComponent),
    children: [
      { path: '',          loadComponent: () => import('./features/portal/portal-login/portal-login.component').then(m => m.PortalLoginComponent) },
      { path: 'dashboard', loadComponent: () => import('./features/portal/portal-dashboard/portal-dashboard.component').then(m => m.PortalDashboardComponent) },
    ]
  },
  { path: '**', redirectTo: 'login' }
];
