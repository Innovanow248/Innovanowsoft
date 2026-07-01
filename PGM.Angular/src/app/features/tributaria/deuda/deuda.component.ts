import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { CurrencyPipe, DatePipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { TributariaService, DeudaContribuyente, DeudaResumen, Persona } from '../../../core/services/tributaria.service';

@Component({
  selector: 'app-deuda',
  standalone: true,
  imports: [
    ReactiveFormsModule, CurrencyPipe, DatePipe,
    MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule,
    MatTableModule, MatChipsModule,
  ],
  templateUrl: './deuda.component.html',
  styleUrl: './deuda.component.scss',
})
export class DeudaComponent {
  private svc = inject(TributariaService);
  private fb  = inject(FormBuilder);

  form = this.fb.nonNullable.group({ busqueda: [''] });

  loading = signal(false);
  error   = signal('');

  // Arrays planos — mat-table detecta cambios por referencia sin problemas
  persona:    Persona | null = null;
  resumen:    DeudaResumen[] = [];
  cuotas:     DeudaContribuyente[] = [];
  resultados: Persona[] = [];   // lista cuando hay múltiples coincidencias

  colsResumen = ['tipoBien','montoHistorico','montoActualizado','fechaActualizacion'];
  colsCuotas  = ['periodo','tipoBien','claveBien','situacionDeuda','capitalFacturado','deudaTotalActualizada','imp1Vence','fechaVencimiento1'];

  situacionLabel(s: string): string {
    const map: Record<string,string> = { RE:'Rescindida', BL:'Bloqueada', JU:'Judicial', DE:'Normal' };
    return map[s] ?? s;
  }

  situacionClass(s: string): string {
    const map: Record<string,string> = { RE:'badge badge--muted', BL:'badge badge--warning', JU:'badge badge--danger', DE:'badge badge--success' };
    return map[s] ?? 'badge badge--muted';
  }

  buscar() {
    const val = this.form.value.busqueda?.trim() ?? '';
    if (!val) return;
    this.loading.set(true);
    this.error.set('');
    this.persona    = null;
    this.resumen    = [];
    this.cuotas     = [];
    this.resultados = [];

    const soloDigitos = /^\d+$/.test(val);
    const params = soloDigitos
      ? (val.length >= 10 ? { cuit: val } : { documento: val })
      : { apellido: val };

    this.svc.buscar(params).subscribe({
      next: (r: any) => {
        if (Array.isArray(r)) {
          this.resultados = r;
          this.loading.set(false);
          return;
        }
        this.resultados = [];
        this.cargarDeuda(r);
      },
      error: () => { this.error.set('Sin resultados.'); this.loading.set(false); }
    });
  }

  seleccionar(p: Persona) {
    this.resultados = [];
    this.loading.set(true);
    this.svc.buscar({ cuit: p.cuitCuil || p.documento }).subscribe({
      next: (r: any) => this.cargarDeuda(r),
      error: () => { this.error.set('Error al cargar.'); this.loading.set(false); }
    });
  }

  private cargarDeuda(r: any) {
    this.persona = r.persona;
    this.resumen = r.resumen ?? [];
    this.loading.set(false);
    this.svc.deuda(r.persona.identificador).subscribe({
      next: d => { this.cuotas = d; },
      error: () => {}
    });
  }

  get totalActualizado(): number {
    return this.resumen.reduce((a, r) => a + r.montoActualizado, 0);
  }
}
