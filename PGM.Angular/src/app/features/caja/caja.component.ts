import { Component, inject, signal, computed, OnInit } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { CurrencyPipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { CajaService, FormaPagoItem, SesionCajero, ResumenSesion } from '../../core/services/caja.service';
import { TributariaService, Persona, DeudaContribuyente } from '../../core/services/tributaria.service';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-caja',
  standalone: true,
  imports: [
    ReactiveFormsModule, CurrencyPipe,
    MatFormFieldModule, MatInputModule, MatButtonModule,
    MatIconModule, MatCheckboxModule, MatProgressSpinnerModule,
  ],
  templateUrl: './caja.component.html',
  styleUrl: './caja.component.scss',
})
export class CajaComponent implements OnInit {
  private cajaSvc  = inject(CajaService);
  private tribSvc  = inject(TributariaService);
  private authSvc  = inject(AuthService);

  private get usuarioActual() { return this.authSvc.currentUser()?.usuario ?? ''; }

  sesion          = signal<SesionCajero | null>(null);
  loadingApertura = signal(false);
  errApertura     = signal('');

  busquedaCtrl    = new FormControl('');
  loadingBusq     = signal(false);
  errBusq         = signal('');
  resultados      = signal<Persona[]>([]);        // múltiples resultados de búsqueda
  contribuyente   = signal<Persona | null>(null);
  cuotas          = signal<DeudaContribuyente[]>([]);
  seleccionadas   = signal<Set<string>>(new Set());

  formasPago      = signal<FormaPagoItem[]>([]);
  loadingCobro    = signal(false);
  msgCobro        = signal('');
  errCobro        = signal('');

  resumen         = signal<ResumenSesion | null>(null);
  loadingCierre   = signal(false);

  totalSeleccionado = computed(() => {
    const sel = this.seleccionadas();
    return this.cuotas()
      .filter(c => sel.has(c.nroInterno))
      .reduce((acc, c) => acc + c.deudaTotalActualizada, 0);
  });

  totalIngresado = computed(() => this.formasPago().reduce((a, f) => a + f.importe, 0));
  vuelto         = computed(() => this.totalIngresado() - this.totalSeleccionado());
  puedeConfirmar = computed(() =>
    this.seleccionadas().size > 0 &&
    this.formasPago().length > 0 &&
    this.totalIngresado() >= this.totalSeleccionado()
  );

  ngOnInit() {
    this.cajaSvc.obtenerSesionActiva().subscribe({
      next: s => this.sesion.set(s),
      error: () => this.sesion.set(null),
    });
  }

  abrirCaja() {
    this.loadingApertura.set(true);
    this.errApertura.set('');
    const cajero = this.usuarioActual;
    const hoy = new Date().toISOString().split('T')[0];
    this.cajaSvc.abrirSesion(cajero, hoy).subscribe({
      next: s => { this.sesion.set(s); this.loadingApertura.set(false); },
      error: e => { this.errApertura.set(e.error?.mensaje ?? 'Error al abrir caja'); this.loadingApertura.set(false); },
    });
  }

  buscar() {
    const val = this.busquedaCtrl.value?.trim() ?? '';
    if (!val) return;
    this.loadingBusq.set(true);
    this.errBusq.set('');
    this.resultados.set([]);
    this.contribuyente.set(null);
    this.cuotas.set([]);
    this.seleccionadas.set(new Set());
    const soloDigitos = /^\d+$/.test(val);
    const params: any = soloDigitos
      ? (val.length >= 10 ? { cuit: val } : { documento: val })
      : { apellido: val };
    this.tribSvc.buscar(params).subscribe({
      next: (r: any) => {
        this.loadingBusq.set(false);
        if (Array.isArray(r)) {
          if (r.length === 0) { this.errBusq.set('Sin resultados.'); return; }
          if (r.length === 1) { this.elegirContribuyente(r[0]); return; }
          this.resultados.set(r);          // muestra lista para elegir
        } else if (r?.persona) {
          this.elegirContribuyente(r.persona);
        }
      },
      error: () => { this.errBusq.set('Sin resultados.'); this.loadingBusq.set(false); },
    });
  }

  elegirContribuyente(persona: Persona) {
    this.resultados.set([]);
    this.contribuyente.set(persona);
    this.cuotas.set([]);
    this.seleccionadas.set(new Set());
    this.loadingBusq.set(true);
    this.tribSvc.deuda(persona.identificador).subscribe({
      next: (d: DeudaContribuyente[]) => {
        // Solo períodos con deuda pendiente (ESTADO_DEUDA = 'PT')
        this.cuotas.set(d.filter(c => c.estadoDeuda === 'PT'));
        this.loadingBusq.set(false);
      },
      error: () => this.loadingBusq.set(false),
    });
  }

  toggleCuota(nroInterno: string) {
    const s = new Set(this.seleccionadas());
    s.has(nroInterno) ? s.delete(nroInterno) : s.add(nroInterno);
    this.seleccionadas.set(s);
  }

  agregarForma(tipo: 'EF' | 'CH' | 'TJ') {
    this.formasPago.update(fps => [...fps, { tipoMoneda: tipo, importe: 0 }]);
  }

  quitarForma(i: number) {
    this.formasPago.update(fps => fps.filter((_, idx) => idx !== i));
  }

  actualizarImporte(i: number, valor: number) {
    this.formasPago.update(fps => {
      const n = [...fps]; n[i] = { ...n[i], importe: valor }; return n;
    });
  }

  actualizarCampo(i: number, campo: string, valor: string) {
    this.formasPago.update(fps => {
      const n = [...fps]; n[i] = { ...n[i], [campo]: valor }; return n;
    });
  }

  confirmarCobro() {
    const s = this.sesion();
    if (!s) return;
    this.loadingCobro.set(true);
    this.msgCobro.set('');
    this.errCobro.set('');
    const hoy = new Date().toISOString().split('T')[0];
    this.cajaSvc.registrarCobro({
      cajero: s.cajero,
      fechaCaja: s.fechaCaja.split('T')[0],
      nroSession: s.nroSession,
      nrosInternos: Array.from(this.seleccionadas()),
      fechaPago: hoy,
      formasPago: this.formasPago(),
      impVuelto: Math.max(0, this.vuelto()),
    }).subscribe({
      next: r => {
        this.msgCobro.set(`Cobro registrado. Operación Nro ${r.nroOperacion}`);
        this.seleccionadas.set(new Set());
        this.formasPago.set([]);
        this.cuotas.set(this.cuotas().filter(c => !Array.from(this.seleccionadas()).includes(c.nroInterno)));
        this.buscar();
        this.loadingCobro.set(false);
      },
      error: e => { this.errCobro.set(e.error?.mensaje ?? 'Error al registrar cobro'); this.loadingCobro.set(false); },
    });
  }

  cargarResumen() {
    const s = this.sesion();
    if (!s) return;
    this.cajaSvc.resumenSesion(s.cajero, s.fechaCaja.split('T')[0], s.nroSession).subscribe({
      next: r => this.resumen.set(r),
    });
  }

  cerrarCaja() {
    const s = this.sesion();
    if (!s || !confirm('¿Confirmar cierre de caja?')) return;
    this.loadingCierre.set(true);
    const res = this.resumen();
    this.cajaSvc.cerrarSesion(s.cajero, s.fechaCaja.split('T')[0], s.nroSession, 0).subscribe({
      next: () => { this.sesion.set(null); this.resumen.set(null); this.loadingCierre.set(false); },
      error: () => this.loadingCierre.set(false),
    });
  }
}
