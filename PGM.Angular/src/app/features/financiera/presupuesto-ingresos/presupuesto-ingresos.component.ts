import { Component, inject, signal, computed, OnInit } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { CurrencyPipe, DecimalPipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatTooltipModule } from '@angular/material/tooltip';
import { FinancieraService, CuentaIngreso } from '../../../core/services/financiera.service';

interface TreeNode {
  cuenta: CuentaIngreso;
  nivel: number;
  hijos: TreeNode[];
  tieneHijos: boolean;
}

@Component({
  selector: 'app-presupuesto-ingresos',
  standalone: true,
  imports: [
    ReactiveFormsModule, CurrencyPipe, DecimalPipe,
    MatFormFieldModule, MatInputModule,
    MatButtonModule, MatIconModule,
    MatProgressSpinnerModule, MatProgressBarModule,
    MatTooltipModule,
  ],
  template: `
<div class="page-container">
  <div class="eyebrow">Administración Financiera</div>
  <h1 class="page-title">Presupuesto de Ingresos</h1>

  <!-- Filtro año -->
  <div class="card filter-card">
    <form [formGroup]="form" (ngSubmit)="cargar()" class="filter-row">
      <mat-form-field appearance="outline" style="width:140px">
        <mat-label>Año</mat-label>
        <mat-icon matPrefix>calendar_today</mat-icon>
        <input matInput formControlName="ano" maxlength="4" />
      </mat-form-field>
      <button class="btn-action" type="submit" [disabled]="loading()">Cargar</button>
    </form>
  </div>

  @if (error()) {
    <div class="amber-banner" style="margin-top:16px">{{ error() }}</div>
  }

  @if (loading()) {
    <div style="text-align:center;padding:48px">
      <mat-spinner diameter="40" />
    </div>
  }

  @if (filas().length) {
    <!-- KPIs -->
    <div class="kpi-grid">
      <div class="stat-card">
        <div class="stat-value" style="color:var(--color-info)">{{ totalPresupuestado() | currency:'ARS':'symbol':'1.0-0' }}</div>
        <div class="stat-label">Presupuesto autorizado</div>
      </div>
      <div class="stat-card">
        <div class="stat-value" style="color:var(--color-success)">{{ totalCobrado() | currency:'ARS':'symbol':'1.0-0' }}</div>
        <div class="stat-label">Recaudado</div>
      </div>
      <div class="stat-card">
        <div class="stat-value" [style.color]="totalDiferencia() >= 0 ? 'var(--color-warning)' : 'var(--color-danger)'">
          {{ totalDiferencia() | currency:'ARS':'symbol':'1.0-0' }}
        </div>
        <div class="stat-label">Diferencia (pendiente)</div>
      </div>
      <div class="stat-card ejecucion-card">
        <div class="stat-value" [class]="'color-' + colorEjecucion(pctEjecucion())">{{ pctEjecucion() | number:'1.1-1' }}%</div>
        <div class="stat-label">Ejecución global</div>
        <mat-progress-bar mode="determinate" [value]="pctEjecucion()" class="ej-bar" />
      </div>
    </div>

    <!-- Árbol de cuentas -->
    <div class="card tree-card">
      <div class="card-header">
        <mat-icon>trending_up</mat-icon>
        <span>Cuentas de ingreso</span>
        <div class="header-actions">
          <button class="btn-tree-action" (click)="expandirTodo()" matTooltip="Expandir todo">
            <mat-icon>unfold_more</mat-icon>
          </button>
          <button class="btn-tree-action" (click)="colapsarTodo()" matTooltip="Colapsar todo">
            <mat-icon>unfold_less</mat-icon>
          </button>
        </div>
      </div>

      <!-- Cabecera de columnas -->
      <div class="tree-header">
        <div class="col-toggle"></div>
        <div class="col-code">Cuenta</div>
        <div class="col-name">Designación</div>
        <div class="col-money">Presupuestado</div>
        <div class="col-money">Recaudado</div>
        <div class="col-money">Devengado</div>
        <div class="col-money">Diferencia</div>
        <div class="col-pct">% Ejec.</div>
      </div>

      <!-- Filas del árbol -->
      @for (node of filas(); track node.cuenta.nroCtaIng) {
        <div class="tree-row"
             [class.is-group]="node.tieneHijos"
             [class.is-leaf]="!node.tieneHijos"
             [style.padding-left.px]="node.nivel * 20">
          <div class="col-toggle">
            @if (node.tieneHijos) {
              <button class="toggle-btn" (click)="toggle(node)">
                <mat-icon>{{ estaAbierto(node.cuenta.nroCtaIng) ? 'expand_more' : 'chevron_right' }}</mat-icon>
              </button>
            } @else {
              <span class="leaf-dot"></span>
            }
          </div>

          <div class="col-code">
            <span class="code-badge" [class.code-root]="node.nivel === 0" [class.code-group]="node.tieneHijos && node.nivel > 0">
              {{ node.cuenta.nroCtaIng }}
            </span>
          </div>

          <div class="col-name" [class.font-bold]="node.nivel === 0" [class.font-medium]="node.nivel === 1">
            {{ node.cuenta.designacion }}
          </div>

          <div class="col-money">{{ node.cuenta.presupuestoAutorizado | currency:'ARS':'symbol':'1.0-0' }}</div>
          <div class="col-money"><strong>{{ node.cuenta.montoCobrado | currency:'ARS':'symbol':'1.0-0' }}</strong></div>
          <div class="col-money muted">{{ node.cuenta.montoDevengado | currency:'ARS':'symbol':'1.0-0' }}</div>
          <div class="col-money"
               [class.text-success]="node.cuenta.presupuestoAutorizado - node.cuenta.montoCobrado >= 0"
               [class.text-danger]="node.cuenta.presupuestoAutorizado - node.cuenta.montoCobrado < 0">
            {{ node.cuenta.presupuestoAutorizado - node.cuenta.montoCobrado | currency:'ARS':'symbol':'1.0-0' }}
          </div>

          <div class="col-pct">
            <span class="pct-label" [class]="'color-' + colorEjecucion(ejecucionPct(node.cuenta))">
              {{ ejecucionPct(node.cuenta) | number:'1.1-1' }}%
            </span>
            @if (node.cuenta.presupuestoAutorizado > 0) {
              <mat-progress-bar mode="determinate" [value]="ejecucionPct(node.cuenta)"
                [class]="'bar-' + colorEjecucion(ejecucionPct(node.cuenta))" />
            }
          </div>
        </div>
      }
    </div>
  }
</div>
  `,
  styleUrl: './presupuesto-ingresos.component.scss',
})
export class PresupuestoIngresosComponent implements OnInit {
  private svc = inject(FinancieraService);
  private fb  = inject(FormBuilder);

  anoActual = new Date().getFullYear().toString();
  form = this.fb.nonNullable.group({ ano: [this.anoActual] });

  loading = signal(false);
  error   = signal('');

  private roots    = signal<TreeNode[]>([]);
  private abiertos = signal<Set<string>>(new Set());

  filas = computed(() => this.flatten(this.roots(), this.abiertos()));

  private hojas = computed(() => this.extractLeaves(this.roots()));
  totalPresupuestado = computed(() => this.hojas().reduce((a, c) => a + c.presupuestoAutorizado, 0));
  totalCobrado       = computed(() => this.hojas().reduce((a, c) => a + c.montoCobrado, 0));
  totalDiferencia    = computed(() => this.totalPresupuestado() - this.totalCobrado());
  pctEjecucion       = computed(() =>
    this.totalPresupuestado() ? (this.totalCobrado() / this.totalPresupuestado()) * 100 : 0
  );

  ngOnInit() { this.cargar(); }

  cargar() {
    this.loading.set(true);
    this.error.set('');
    this.svc.presupuestoIngresos(this.form.getRawValue().ano).subscribe({
      next: data => {
        const tree = this.buildTree(data);
        this.roots.set(tree);
        const abiertos = new Set<string>();
        for (const r of tree) {
          abiertos.add(r.cuenta.nroCtaIng);
          for (const h of r.hijos) abiertos.add(h.cuenta.nroCtaIng);
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
    s.has(node.cuenta.nroCtaIng) ? s.delete(node.cuenta.nroCtaIng) : s.add(node.cuenta.nroCtaIng);
    this.abiertos.set(s);
  }

  expandirTodo() {
    const s = new Set<string>();
    this.addAll(this.roots(), s);
    this.abiertos.set(s);
  }

  colapsarTodo() { this.abiertos.set(new Set()); }

  estaAbierto(code: string) { return this.abiertos().has(code); }

  ejecucionPct(c: CuentaIngreso): number {
    return c.presupuestoAutorizado ? (c.montoCobrado / c.presupuestoAutorizado) * 100 : 0;
  }

  colorEjecucion(pct: number): string {
    if (pct >= 80) return 'success';
    if (pct >= 50) return 'warning';
    return 'danger';
  }

  private buildTree(cuentas: CuentaIngreso[]): TreeNode[] {
    const sorted = [...cuentas].sort((a, b) =>
      a.nroCtaIng.length !== b.nroCtaIng.length
        ? a.nroCtaIng.length - b.nroCtaIng.length
        : a.nroCtaIng.localeCompare(b.nroCtaIng)
    );

    const map = new Map<string, TreeNode>();
    const roots: TreeNode[] = [];

    for (const c of sorted) {
      const node: TreeNode = { cuenta: c, nivel: 0, hijos: [], tieneHijos: false };

      let parentKey = '';
      for (const key of map.keys()) {
        if (c.nroCtaIng.startsWith(key) && key.length > parentKey.length) {
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

      map.set(c.nroCtaIng, node);
    }

    return roots;
  }

  private flatten(nodes: TreeNode[], abiertos: Set<string>): TreeNode[] {
    const result: TreeNode[] = [];
    for (const n of nodes) {
      result.push(n);
      if (n.tieneHijos && abiertos.has(n.cuenta.nroCtaIng)) {
        result.push(...this.flatten(n.hijos, abiertos));
      }
    }
    return result;
  }

  private extractLeaves(nodes: TreeNode[]): CuentaIngreso[] {
    const leaves: CuentaIngreso[] = [];
    for (const n of nodes) {
      if (!n.tieneHijos) leaves.push(n.cuenta);
      else leaves.push(...this.extractLeaves(n.hijos));
    }
    return leaves;
  }

  private addAll(nodes: TreeNode[], set: Set<string>) {
    for (const n of nodes) {
      if (n.tieneHijos) { set.add(n.cuenta.nroCtaIng); this.addAll(n.hijos, set); }
    }
  }
}
