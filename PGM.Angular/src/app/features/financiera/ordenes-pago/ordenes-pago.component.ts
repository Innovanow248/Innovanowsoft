import { Component, inject, signal, computed, OnInit } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { CurrencyPipe, DatePipe, NgFor } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatChipsModule } from '@angular/material/chips';
import { MatDialog, MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { FinancieraService, OrdenPago, CuentaErogacion } from '../../../core/services/financiera.service';
import { TributariaService } from '../../../core/services/tributaria.service';

// ── Dialog: Nueva Orden de Pago ───────────────────────────────────────────────
@Component({
  selector: 'app-nueva-op-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, FormsModule, MatDialogModule, MatFormFieldModule,
            MatInputModule, MatButtonModule, MatIconModule],
  template: `
<div class="dlg-header">
  <mat-icon>add_card</mat-icon>
  <h2>Nueva Orden de Pago</h2>
</div>
<mat-dialog-content>
  <div class="section-label">Proveedor</div>
  <div class="search-row">
    <mat-form-field appearance="outline" class="flex-field">
      <mat-label>CUIT / DNI / Apellido</mat-label>
      <mat-icon matPrefix>search</mat-icon>
      <input matInput [(ngModel)]="busqueda" (keyup.enter)="buscarProveedor()" placeholder="Ej: 20236835015" />
    </mat-form-field>
    <button class="btn-buscar" (click)="buscarProveedor()" [disabled]="buscando()">
      {{ buscando() ? '…' : 'Buscar' }}
    </button>
  </div>
  @if (proveedor()) {
    <div class="prov-found">
      <mat-icon>verified_user</mat-icon>
      <div>
        <div class="prov-name">{{ proveedor().apellido }}, {{ proveedor().nombre }}</div>
        <div class="prov-meta">CUIT {{ proveedor().cuitCuil }}</div>
      </div>
    </div>
  }
  @if (errBusq()) { <div class="msg-warn">{{ errBusq() }}</div> }

  <form [formGroup]="form" class="form-grid" style="margin-top:16px">
    <mat-form-field appearance="outline" class="full">
      <mat-label>Cuenta de erogación</mat-label>
      <select matNativeControl formControlName="nroCta">
        <option value="">— Seleccionar —</option>
        @for (c of cuentas; track c.nroCtaEro) {
          <option [value]="c.nroCtaEro">{{ c.nroCtaEro }} — {{ c.designacion }}</option>
        }
      </select>
    </mat-form-field>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Monto a pagar ($)</mat-label>
      <input matInput type="number" step="100" min="1" formControlName="montoAPagar" />
    </mat-form-field>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Observaciones</mat-label>
      <input matInput formControlName="observaciones" />
    </mat-form-field>
  </form>
  @if (error()) { <div class="msg-err">{{ error() }}</div> }
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="!proveedor() || form.invalid || loading()">
    {{ loading() ? 'Guardando…' : 'Crear Orden' }}
  </button>
</mat-dialog-actions>`,
  styles: [`.dlg-header{display:flex;align-items:center;gap:10px;padding:20px 24px 0;color:#1e293b;h2{margin:0;font-size:18px}}
    mat-dialog-content{min-width:440px} .section-label{font-size:11px;font-weight:700;letter-spacing:.08em;color:#64748b;text-transform:uppercase;margin-bottom:8px}
    .search-row{display:flex;align-items:flex-start;gap:10px} .flex-field{flex:1}
    .btn-buscar{height:56px;padding:0 16px;background:#f1f5f9;border:1px solid #cbd5e1;border-radius:4px;font-size:14px;cursor:pointer;white-space:nowrap;
      &:disabled{opacity:.55;cursor:not-allowed}}
    .prov-found{display:flex;align-items:center;gap:10px;background:#f0fdf4;border:1px solid #bbf7d0;border-radius:6px;padding:10px 14px;margin:8px 0;
      mat-icon{color:#16a34a} .prov-name{font-weight:600;color:#15803d} .prov-meta{font-size:12px;color:#64748b}}
    .msg-warn{background:#fefce8;color:#a16207;border:1px solid #fde68a;border-radius:4px;padding:8px 12px;font-size:13px;margin:4px 0}
    .msg-err{background:#fef2f2;color:#b91c1c;padding:8px 12px;border-radius:4px;font-size:13px}
    .form-grid{display:grid;grid-template-columns:1fr;gap:8px} .full{grid-column:1/-1}
    .btn-ok{height:36px;padding:0 20px;background:var(--color-primary);color:#fff;border:none;border-radius:4px;font-size:14px;cursor:pointer;
      &:disabled{opacity:.55;cursor:not-allowed}}`],
})
export class NuevaOPDialogComponent {
  private finSvc  = inject(FinancieraService);
  private tribSvc = inject(TributariaService);
  private fb      = inject(FormBuilder);
  private ref     = inject(MatDialogRef<NuevaOPDialogComponent>);
  data: {ano: string} = inject(MAT_DIALOG_DATA);

  loading  = signal(false);
  buscando = signal(false);
  error    = signal('');
  errBusq  = signal('');
  proveedor = signal<any>(null);
  cuentas: CuentaErogacion[] = [];
  busqueda = '';

  form = this.fb.nonNullable.group({
    nroCta:       ['', Validators.required],
    montoAPagar:  [0, [Validators.required, Validators.min(1)]],
    observaciones:[''],
  });

  constructor() {
    this.finSvc.presupuesto(this.data.ano).subscribe({ next: d => this.cuentas = d });
  }

  buscarProveedor() {
    const val = this.busqueda.trim().replace(/[-\.]/g, '');
    if (!val) return;
    this.buscando.set(true); this.errBusq.set(''); this.proveedor.set(null);
    const soloDigitos = /^\d+$/.test(val);
    const params = soloDigitos ? (val.length >= 10 ? { cuit: val } : { documento: val }) : { apellido: val };
    this.tribSvc.buscar(params).subscribe({
      next: (r: any) => {
        if (Array.isArray(r)) { this.errBusq.set(`${r.length} resultados — usá CUIT para búsqueda exacta`); }
        else { this.proveedor.set(r.persona); }
        this.buscando.set(false);
      },
      error: () => { this.errBusq.set('Sin resultados.'); this.buscando.set(false); },
    });
  }

  guardar() {
    if (!this.proveedor() || this.form.invalid) return;
    this.loading.set(true);
    const v = this.form.getRawValue();
    this.finSvc.crearOrdenPago(this.data.ano, {
      identificador: this.proveedor().identificador,
      nroCta: v.nroCta, anoEro: this.data.ano,
      montoAPagar: v.montoAPagar, observaciones: v.observaciones,
    }).subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set(e.error?.title ?? 'Error al guardar'); this.loading.set(false); },
    });
  }
}

// ── Componente principal ──────────────────────────────────────────────────────
@Component({
  selector: 'app-ordenes-pago',
  standalone: true,
  imports: [
    ReactiveFormsModule, CurrencyPipe, DatePipe, NgFor,
    MatFormFieldModule, MatInputModule, MatSelectModule,
    MatButtonModule, MatIconModule, MatTableModule,
    MatProgressSpinnerModule, MatChipsModule, MatDialogModule, MatTooltipModule,
    MatPaginatorModule,
    NuevaOPDialogComponent,
  ],
  templateUrl: './ordenes-pago.component.html',
  styleUrl: './ordenes-pago.component.scss',
})
export class OrdenesPagoComponent implements OnInit {
  private svc    = inject(FinancieraService);
  private fb     = inject(FormBuilder);
  private dialog = inject(MatDialog);

  anoActual = new Date().getFullYear().toString();
  form = this.fb.nonNullable.group({ ano: [this.anoActual], estado: [''] });

  loading  = signal(false);
  ordenes  = signal<OrdenPago[]>([]);
  total    = signal(0);
  page     = signal(0);
  pageSize = signal(100);

  cols = ['nroOpago','proveedor','cuitCuil','estadoOpago','montoAPagar','montoPagado','fechaAprobacion','accion'];

  totalAPagar = computed(() => this.ordenes().reduce((a, o) => a + o.montoAPagar, 0));
  totalPagado = computed(() => this.ordenes().reduce((a, o) => a + o.montoPagado, 0));

  estados = [
    { v: '',  l: 'Todos' }, { v: 'P', l: 'Pendiente' },
    { v: 'A', l: 'Aprobada' }, { v: 'E', l: 'Emitida' }, { v: 'C', l: 'Cancelada' },
  ];

  ngOnInit() {
    this.cargar(true);
  }

  onPage(e: PageEvent) {
    this.page.set(e.pageIndex);
    this.pageSize.set(e.pageSize);
    this.cargar();
  }

  cargar(fallback = false) {
    this.loading.set(true);
    const { ano, estado } = this.form.value;
    this.svc.ordenesPago(ano!, estado || undefined, this.page(), this.pageSize()).subscribe({
      next: r => {
        if (fallback && r.total === 0 && ano === this.anoActual) {
          const anoAnterior = (parseInt(this.anoActual) - 1).toString();
          this.form.patchValue({ ano: anoAnterior });
          this.cargar();
        } else {
          this.ordenes.set(r.items);
          this.total.set(r.total);
          this.loading.set(false);
        }
      },
      error: () => this.loading.set(false),
    });
  }

  nuevaOP() {
    const ano = this.form.value.ano ?? this.anoActual;
    this.dialog.open(NuevaOPDialogComponent, { data: { ano }, width: '520px', maxWidth: '95vw' })
      .afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  cambiarEstado(o: OrdenPago, estado: string) {
    const labels: Record<string,string> = { A:'Aprobar', E:'Emitir/Pagar', C:'Cancelar' };
    if (!confirm(`¿${labels[estado]} la OP ${o.tipoOpago}-${o.nroOpago}?`)) return;
    this.svc.cambiarEstadoOP(o.tipoOpago, o.anoOpago, o.nroOpago, estado).subscribe({
      next: () => this.cargar(),
    });
  }

  estadoClass(e: string): string {
    const m: Record<string,string> = { P:'warning', A:'info', E:'success', C:'muted' };
    return `badge badge--${m[e] ?? 'muted'}`;
  }

  estadoLabel(e: string): string {
    const m: Record<string,string> = { P:'Pendiente', A:'Aprobada', E:'Emitida', C:'Cancelada' };
    return m[e] ?? e;
  }
}
