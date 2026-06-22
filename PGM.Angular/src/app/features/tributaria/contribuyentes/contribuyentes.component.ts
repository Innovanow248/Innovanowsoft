import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { DecimalPipe, CurrencyPipe, NgClass } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatTabsModule } from '@angular/material/tabs';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatChipsModule } from '@angular/material/chips';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialog } from '@angular/material/dialog';
import { TributariaService, Persona, BienPadron, DeudaResumen, DeudaContribuyente } from '../../../core/services/tributaria.service';
import { PersonaDialogComponent } from './persona-dialog/persona-dialog.component';
import { AltaBienDialogComponent } from './alta-bien-dialog/alta-bien-dialog.component';
import { CobroDialogComponent } from './cobro-dialog/cobro-dialog.component';
import { CambioTitularDialogComponent } from './cambio-titular-dialog/cambio-titular-dialog.component';
import { PortalWebDialogComponent } from './portal-web-dialog/portal-web-dialog.component';
import { CatastroDetalleDialogComponent } from './catastro-detalle-dialog/catastro-detalle-dialog.component';

@Component({
  selector: 'app-contribuyentes',
  standalone: true,
  imports: [
    ReactiveFormsModule, DecimalPipe, CurrencyPipe, NgClass,
    MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule,
    MatTableModule, MatTabsModule, MatProgressSpinnerModule,
    MatChipsModule, MatTooltipModule,
  ],
  templateUrl: './contribuyentes.component.html',
  styleUrl: './contribuyentes.component.scss',
})
export class ContribuyentesComponent {
  private svc    = inject(TributariaService);
  private fb     = inject(FormBuilder);
  private dialog = inject(MatDialog);

  form = this.fb.nonNullable.group({ busqueda: [''] });

  loading      = signal(false);
  error        = signal('');
  resultado    = signal<{ persona: Persona; resumen: DeudaResumen[]; bienes: BienPadron[] } | Persona[] | null>(null);
  seleccionado = signal<Persona | null>(null);
  detalleDeuda = signal<DeudaContribuyente[]>([]);
  loadingDeuda = signal(false);

  get esLista(): boolean { return Array.isArray(this.resultado()); }
  get lista(): Persona[] { return Array.isArray(this.resultado()) ? this.resultado() as Persona[] : []; }
  get detalle() { return !Array.isArray(this.resultado()) && this.resultado() ? this.resultado() as any : null; }

  colsPersonas: string[] = ['identificador','nombre','cuitCuil','documento','localidad','accion'];
  colsBienes:   string[] = ['tipoBien','claveBien','activo','situacionDeuda','montoDeudaActualizado','accion'];
  colsDeuda:    string[] = ['periodo','tipoBien','claveBien','capitalFacturado','deudaTotalActualizada','imp1Vence','accion'];
  colsResumen:  string[] = ['tipoBien','montoHistorico','montoActualizado'];

  buscar() {
    const val = this.form.value.busqueda?.trim() ?? '';
    if (!val) return;
    this.loading.set(true);
    this.error.set('');
    this.resultado.set(null);
    this.seleccionado.set(null);
    this.detalleDeuda.set([]);

    const soloDigitos = /^\d+$/.test(val);
    const params = soloDigitos
      ? (val.length >= 10 ? { cuit: val } : { documento: val })
      : { apellido: val };

    this.svc.buscar(params).subscribe({
      next: (r) => {
        this.resultado.set(r);
        this.loading.set(false);
        if (!Array.isArray(r) && r.persona) this.seleccionado.set(r.persona);
      },
      error: () => { this.error.set('Sin resultados.'); this.loading.set(false); }
    });
  }

  seleccionar(persona: Persona) {
    this.seleccionado.set(persona);
    this.detalleDeuda.set([]);
    this.svc.buscar({ cuit: persona.cuitCuil }).subscribe({
      next: (r) => this.resultado.set(r),
      error: () => {},
    });
  }

  verDeuda(identificador: string) {
    this.loadingDeuda.set(true);
    this.svc.deuda(identificador).subscribe({
      next: (d) => { this.detalleDeuda.set(d); this.loadingDeuda.set(false); },
      error: () => this.loadingDeuda.set(false),
    });
  }

  recargarDetalle() {
    const p = this.seleccionado();
    if (p) this.seleccionar(p);
  }

  abrirNuevo() {
    this.dialog.open(PersonaDialogComponent, { data: null, width: '600px', maxWidth: '95vw' })
      .afterClosed().subscribe(res => { if (res) this.buscar(); });
  }

  abrirEditar(persona: Persona) {
    this.dialog.open(PersonaDialogComponent, { data: persona, width: '600px', maxWidth: '95vw' })
      .afterClosed().subscribe(res => { if (res) this.seleccionar(persona); });
  }

  abrirAltaBien() {
    const p = this.seleccionado();
    if (!p) return;
    this.dialog.open(AltaBienDialogComponent, {
      data: { identificador: p.identificador },
      width: '700px', maxWidth: '95vw',
    }).afterClosed().subscribe(res => { if (res) this.recargarDetalle(); });
  }

  abrirCobro(cuota: DeudaContribuyente) {
    this.dialog.open(CobroDialogComponent, {
      data: { cuota },
      width: '480px', maxWidth: '95vw',
    }).afterClosed().subscribe(res => {
      if (res) {
        const p = this.seleccionado();
        if (p) { this.recargarDetalle(); this.verDeuda(p.identificador); }
      }
    });
  }

  abrirCambioTitular(bien: BienPadron) {
    const p = this.seleccionado();
    if (!p) return;
    this.dialog.open(CambioTitularDialogComponent, {
      data: {
        idBien: bien.idBien,
        tipoBien: bien.tipoBien,
        claveBien: bien.claveBien,
        identificadorActual: p.identificador,
      },
      width: '480px', maxWidth: '95vw',
    }).afterClosed().subscribe(res => { if (res) this.recargarDetalle(); });
  }

  abrirBajaBien(bien: BienPadron) {
    if (!confirm(`¿Dar de baja el bien ${bien.tipoBien} — ${bien.claveBien}?\nEsta acción desactiva el bien (no se elimina).`)) return;
    this.svc.bajarBien(bien.idBien, bien.tipoBien.trim()).subscribe({
      next: () => this.recargarDetalle(),
      error: e => alert('Error: ' + (e.error?.title ?? e.message)),
    });
  }

  esCatastro(b: BienPadron): boolean {
    return ['ININ','CACA','OBSA','OBSC'].includes(b.tipoBien?.trim() ?? '');
  }

  abrirCatastroDetalle(bien: BienPadron) {
    this.dialog.open(CatastroDetalleDialogComponent, {
      data: { idBien: bien.idBien, claveBien: bien.claveBien },
      width: '900px', maxWidth: '98vw',
    });
  }

  abrirPortalWeb() {
    const p = this.seleccionado();
    const d = this.detalle;
    if (!p) return;
    this.dialog.open(PortalWebDialogComponent, {
      data: { identificador: p.identificador, nombre: `${d?.persona?.apellido}, ${d?.persona?.nombre}` },
      width: '420px', maxWidth: '95vw',
    });
  }

  situacionClass(s: string): string {
    const m: Record<string, string> = { 'PT': 'danger', 'RE': 'success', 'JD': 'warning', 'PL': 'info' };
    return `badge badge--${m[s] ?? 'muted'}`;
  }

  totalDeuda(resumen: DeudaResumen[]): number {
    return resumen.reduce((a, r) => a + (r.montoActualizado ?? 0), 0);
  }
}
