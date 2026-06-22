import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { CurrencyPipe, DecimalPipe, NgFor } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { TributariaService, TipoBien, BienPadronDetalle } from '../../../core/services/tributaria.service';

@Component({
  selector: 'app-padron',
  standalone: true,
  imports: [
    ReactiveFormsModule, CurrencyPipe, DecimalPipe, NgFor,
    MatFormFieldModule, MatSelectModule, MatInputModule,
    MatButtonModule, MatIconModule, MatTableModule,
    MatProgressSpinnerModule, MatPaginatorModule,
  ],
  templateUrl: './padron.component.html',
  styleUrl: './padron.component.scss',
})
export class PadronComponent {
  private svc = inject(TributariaService);
  private fb  = inject(FormBuilder);

  form = this.fb.nonNullable.group({
    titular:   [''],
    tipoBien:  [''],
    activo:    [''],
    situacion: [''],
  });

  allTipos:      TipoBien[] = [];
  filteredTipos: TipoBien[] = [];
  items    = signal<BienPadronDetalle[]>([]);
  total    = signal(0);
  loading  = signal(false);
  page     = signal(1);
  pageSize = signal(50);

  cols = ['idBien','tipoBien','claveBien','apellido','cuitCuil','activo','situacionDeuda','montoDeudaActualizado'];

  activos     = [{ v: '',  l: 'Todos' }, { v: '1', l: 'Activo' }, { v: '0', l: 'Inactivo' }];
  situaciones = [
    { v: '', l: 'Todas' },
    { v: 'RE', l: 'Regular' },
    { v: 'PT', l: 'Pendiente' },
    { v: 'JU', l: 'Judicial' },
    { v: 'EX', l: 'Exento' },
  ];

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

  limpiarTipo() {
    this.form.controls.tipoBien.setValue('');
    this.filteredTipos = [...this.allTipos];
  }

  buscar(resetPage = true) {
    if (resetPage) this.page.set(1);
    this.loading.set(true);
    const f = this.form.value;
    const params: Record<string, string | number> = {
      page:     this.page(),
      pageSize: this.pageSize(),
    };
    if (f.titular)   params['titular']   = f.titular;
    if (f.tipoBien)  params['tipoBien']  = f.tipoBien;
    if (f.activo)    params['activo']    = f.activo;
    if (f.situacion) params['situacion'] = f.situacion;
    this.svc.padron(params).subscribe({
      next: r => { this.items.set(r.items); this.total.set(r.total); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  onPage(e: PageEvent) {
    this.page.set(e.pageIndex + 1);
    this.pageSize.set(e.pageSize);
    this.buscar(false);
  }

  situacionClass(s: string): string {
    const m: Record<string,string> = { RE:'success', PT:'warning', JU:'danger', EX:'info' };
    return `badge badge--${m[s?.trim()] ?? 'muted'}`;
  }

  situacionLabel(s: string): string {
    const m: Record<string,string> = { RE:'Regular', PT:'Pendiente', JU:'Judicial', EX:'Exento' };
    return m[s?.trim()] ?? s;
  }
}
