import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { NgFor } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatChipsModule } from '@angular/material/chips';
import { TributariaService, TipoBien, PlanPago } from '../../../core/services/tributaria.service';

@Component({
  selector: 'app-planes-pago',
  standalone: true,
  imports: [
    ReactiveFormsModule, NgFor,
    MatFormFieldModule, MatInputModule,
    MatButtonModule, MatIconModule,
    MatTableModule, MatProgressSpinnerModule, MatChipsModule,
  ],
  templateUrl: './planes-pago.component.html',
  styleUrl: './planes-pago.component.scss',
})
export class PlanesPagoComponent {
  private svc = inject(TributariaService);
  private fb  = inject(FormBuilder);

  form = this.fb.nonNullable.group({ tipoBien: [''] });

  allTipos:      TipoBien[] = [];
  filteredTipos: TipoBien[] = [];
  planes  = signal<PlanPago[]>([]);
  loading = signal(false);
  cols    = ['tipoPlan', 'designacionPlan', 'cantidadCuotas'];

  constructor() {
    this.svc.tiposBien$.subscribe(t => {
      this.allTipos = t;
      this.filteredTipos = t;
    });
  }

  onInput(val: string) {
    const q = val.toLowerCase();
    this.filteredTipos = q
      ? this.allTipos.filter(t =>
          t.codigoTipoBien.toLowerCase().includes(q) ||
          t.concepto.toLowerCase().includes(q))
      : [...this.allTipos];
  }

  displayFn(code: string): string {
    const t = this.allTipos.find(x => x.codigoTipoBien === code);
    return t ? `${t.codigoTipoBien} — ${t.concepto}` : code ?? '';
  }

  cargar() {
    const tipo = this.form.value.tipoBien?.trim() ?? '';
    if (!tipo) return;
    this.loading.set(true);
    this.planes.set([]);
    this.svc.planes(tipo).subscribe({
      next: p => { this.planes.set(p); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  conceptoActual(): string {
    const t = this.allTipos.find(x => x.codigoTipoBien === this.form.value.tipoBien);
    return t?.concepto ?? '';
  }
}
