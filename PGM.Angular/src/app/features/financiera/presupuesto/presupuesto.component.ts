import { Component, inject, signal, computed, OnInit } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { CurrencyPipe, DecimalPipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatDialog, MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { FinancieraService, CuentaErogacion } from '../../../core/services/financiera.service';

// ── Nodo del árbol ────────────────────────────────────────────────────────────
interface TreeNode {
  cuenta: CuentaErogacion;
  nivel: number;
  hijos: TreeNode[];
  tieneHijos: boolean;
}

// ── Dialog: Ajuste presupuestario ─────────────────────────────────────────────
@Component({
  selector: 'app-ajuste-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, CurrencyPipe, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule],
  template: `
<div class="dlg-header">
  <mat-icon>tune</mat-icon>
  <h2>Ajuste presupuestario</h2>
</div>
<mat-dialog-content>
  <div class="cuenta-info">
    <div class="cta-nro">{{ data.nroCtaEro }}</div>
    <div class="cta-des">{{ data.designacion }}</div>
  </div>
  <div class="monto-actual">
    Presupuesto actual: <strong>{{ data.presupuestoAutorizado | currency:'ARS':'symbol':'1.0-0' }}</strong>
  </div>
  <form [formGroup]="form" style="margin-top:16px">
    <mat-form-field appearance="outline" style="width:100%">
      <mat-label>Nuevo monto autorizado ($)</mat-label>
      <input matInput type="number" step="1000" min="0" formControlName="nuevoMonto" />
    </mat-form-field>
  </form>
  @if (error()) { <div class="msg-err">{{ error() }}</div> }
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="form.invalid || loading()">
    {{ loading() ? 'Guardando…' : 'Confirmar ajuste' }}
  </button>
</mat-dialog-actions>`,
  styles: [`.dlg-header{display:flex;align-items:center;gap:10px;padding:20px 24px 0;color:#1e293b;h2{margin:0;font-size:18px}}
    mat-dialog-content{min-width:380px;padding-top:12px!important}
    .cuenta-info{background:#f8fafc;border-radius:6px;padding:10px 14px;margin-bottom:12px}
    .cta-nro{font-size:12px;font-weight:700;color:#0369a1} .cta-des{font-size:14px;color:#334155}
    .monto-actual{font-size:13px;color:#64748b;margin-bottom:4px}
    .msg-err{background:#fef2f2;color:#b91c1c;padding:8px 12px;border-radius:4px;font-size:13px}
    .btn-ok{height:36px;padding:0 20px;background:var(--color-primary);color:#fff;border:none;border-radius:4px;font-size:14px;cursor:pointer;
      &:disabled{opacity:.55;cursor:not-allowed}}`],
})
export class AjustePresupuestoDialogComponent {
  private svc = inject(FinancieraService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<AjustePresupuestoDialogComponent>);
  data: CuentaErogacion = inject(MAT_DIALOG_DATA);

  loading = signal(false);
  error   = signal('');

  form = this.fb.nonNullable.group({
    nuevoMonto: [this.data.presupuestoAutorizado, [Validators.required, Validators.min(0)]],
  });

  guardar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.svc.ajustarPresupuesto(this.data.anoEro, this.data.nroCtaEro, this.form.getRawValue().nuevoMonto)
      .subscribe({
        next: () => this.ref.close(true),
        error: e => { this.error.set(e.error?.title ?? 'Error al guardar'); this.loading.set(false); },
      });
  }
}

// ── Componente principal ──────────────────────────────────────────────────────
@Component({
  selector: 'app-presupuesto',
  standalone: true,
  imports: [
    ReactiveFormsModule, CurrencyPipe, DecimalPipe,
    MatFormFieldModule, MatInputModule,
    MatButtonModule, MatIconModule,
    MatProgressSpinnerModule, MatProgressBarModule,
    MatDialogModule, MatTooltipModule,
    AjustePresupuestoDialogComponent,
  ],
  templateUrl: './presupuesto.component.html',
  styleUrl: './presupuesto.component.scss',
})
export class PresupuestoComponent implements OnInit {
  private svc    = inject(FinancieraService);
  private fb     = inject(FormBuilder);
  private dialog = inject(MatDialog);

  anoActual = new Date().getFullYear().toString();
  form = this.fb.nonNullable.group({ ano: [this.anoActual] });

  loading = signal(false);
  error   = signal('');

  // Árbol
  private roots = signal<TreeNode[]>([]);
  private abiertos = signal<Set<string>>(new Set());

  filas = computed(() => this.flatten(this.roots(), this.abiertos()));

  // KPIs — usa solo las hojas para no sumar doble
  private hojas = computed(() => this.extractLeaves(this.roots()));
  totalAutorizado = computed(() => this.hojas().reduce((a, c) => a + c.presupuestoAutorizado, 0));
  totalPagado     = computed(() => this.hojas().reduce((a, c) => a + c.montoPagado, 0));
  totalDisponible = computed(() => this.hojas().reduce((a, c) => a + (c.presupuestoAutorizado - c.montoAfectado), 0));
  pctEjecucion    = computed(() => this.totalAutorizado() ? (this.totalPagado() / this.totalAutorizado()) * 100 : 0);

  ngOnInit() { this.cargar(); }

  cargar() {
    this.loading.set(true);
    this.error.set('');
    this.svc.presupuesto(this.form.getRawValue().ano).subscribe({
      next: data => {
        const tree = this.buildTree(data);
        this.roots.set(tree);
        // Abrir los dos primeros niveles por defecto
        const abiertos = new Set<string>();
        for (const r of tree) {
          abiertos.add(r.cuenta.nroCtaEro);
          for (const h of r.hijos) abiertos.add(h.cuenta.nroCtaEro);
        }
        this.abiertos.set(abiertos);
        this.loading.set(false);
      },
      error: e => {
        this.error.set('Error al cargar: ' + (e.error?.title ?? e.message ?? 'Error de conexión'));
        this.loading.set(false);
      },
    });
  }

  toggle(node: TreeNode) {
    const s = new Set(this.abiertos());
    s.has(node.cuenta.nroCtaEro) ? s.delete(node.cuenta.nroCtaEro) : s.add(node.cuenta.nroCtaEro);
    this.abiertos.set(s);
  }

  expandirTodo() {
    const s = new Set<string>();
    this.addAll(this.roots(), s);
    this.abiertos.set(s);
  }

  colapsarTodo() {
    this.abiertos.set(new Set());
  }

  estaAbierto(code: string) { return this.abiertos().has(code); }

  ajustar(c: CuentaErogacion) {
    this.dialog.open(AjustePresupuestoDialogComponent, { data: c, width: '420px', maxWidth: '95vw' })
      .afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  ejecucionPct(c: CuentaErogacion): number {
    return c.presupuestoAutorizado ? (c.montoPagado / c.presupuestoAutorizado) * 100 : 0;
  }

  disponible(c: CuentaErogacion): number { return c.presupuestoAutorizado - c.montoAfectado; }

  colorEjecucion(pct: number): string {
    if (pct >= 90) return 'danger';
    if (pct >= 70) return 'warning';
    return 'success';
  }

  // ── Árbol: construcción ───────────────────────────────────────────────────
  private buildTree(cuentas: CuentaErogacion[]): TreeNode[] {
    // Ordenar por longitud de código (padres antes que hijos)
    const sorted = [...cuentas].sort((a, b) =>
      a.nroCtaEro.length !== b.nroCtaEro.length
        ? a.nroCtaEro.length - b.nroCtaEro.length
        : a.nroCtaEro.localeCompare(b.nroCtaEro)
    );

    const map = new Map<string, TreeNode>();
    const roots: TreeNode[] = [];

    for (const c of sorted) {
      const node: TreeNode = { cuenta: c, nivel: 0, hijos: [], tieneHijos: false };

      // Encontrar padre: el prefijo más largo que exista en el mapa
      let parentKey = '';
      for (const key of map.keys()) {
        if (c.nroCtaEro.startsWith(key) && key.length > parentKey.length) {
          parentKey = key;
        }
      }

      if (parentKey) {
        const parent = map.get(parentKey)!;
        node.nivel = parent.nivel + 1;
        parent.hijos.push(node);
        parent.tieneHijos = true;
      } else {
        roots.push(node);
      }

      map.set(c.nroCtaEro, node);
    }

    return roots;
  }

  private flatten(nodes: TreeNode[], abiertos: Set<string>): TreeNode[] {
    const result: TreeNode[] = [];
    for (const n of nodes) {
      result.push(n);
      if (n.tieneHijos && abiertos.has(n.cuenta.nroCtaEro)) {
        result.push(...this.flatten(n.hijos, abiertos));
      }
    }
    return result;
  }

  private extractLeaves(nodes: TreeNode[]): CuentaErogacion[] {
    const leaves: CuentaErogacion[] = [];
    for (const n of nodes) {
      if (!n.tieneHijos) leaves.push(n.cuenta);
      else leaves.push(...this.extractLeaves(n.hijos));
    }
    return leaves;
  }

  private addAll(nodes: TreeNode[], set: Set<string>) {
    for (const n of nodes) {
      if (n.tieneHijos) { set.add(n.cuenta.nroCtaEro); this.addAll(n.hijos, set); }
    }
  }
}
