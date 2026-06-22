import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { DatePipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { FinancieroService, Proveedor } from '../../core/services/financiero.service';

@Component({
  selector: 'app-proveedores',
  standalone: true,
  imports: [
    ReactiveFormsModule, DatePipe,
    MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule,
    MatTableModule, MatProgressSpinnerModule, MatTooltipModule,
  ],
  template: `
<div class="page-container">
  <div class="eyebrow">Administración Financiera</div>
  <h1 class="page-title">Proveedores</h1>

  <div class="card filter-card">
    <form [formGroup]="form" (ngSubmit)="buscar()" class="filter-row">
      <mat-form-field appearance="outline" class="search-field">
        <mat-label>CUIT, nombre o razón social</mat-label>
        <mat-icon matPrefix>storefront</mat-icon>
        <input matInput formControlName="termino" />
      </mat-form-field>
      <button class="btn-action" type="submit" [disabled]="loading()">
        {{ loading() ? 'Buscando…' : 'Buscar' }}
      </button>
    </form>
  </div>

  @if (error()) { <div class="amber-banner" style="margin-top:16px">{{ error() }}</div> }

  @if (proveedores().length) {
    <div class="card" style="padding:0;overflow:hidden;margin-top:var(--spacing-md)">
      <div class="card-header">
        <mat-icon>storefront</mat-icon>
        <span>{{ proveedores().length }} proveedores encontrados</span>
      </div>
      <table mat-table [dataSource]="proveedores()">
        <ng-container matColumnDef="identificador">
          <th mat-header-cell *matHeaderCellDef>ID</th>
          <td mat-cell *matCellDef="let p"><code>{{ p.identificador }}</code></td>
        </ng-container>
        <ng-container matColumnDef="nombre">
          <th mat-header-cell *matHeaderCellDef>Nombre / Razón Social</th>
          <td mat-cell *matCellDef="let p"><strong>{{ p.apellido }}, {{ p.nombre }}</strong></td>
        </ng-container>
        <ng-container matColumnDef="cuit">
          <th mat-header-cell *matHeaderCellDef>CUIT</th>
          <td mat-cell *matCellDef="let p">{{ p.cuitCuil }}</td>
        </ng-container>
        <ng-container matColumnDef="email">
          <th mat-header-cell *matHeaderCellDef>Email</th>
          <td mat-cell *matCellDef="let p">{{ p.email || '—' }}</td>
        </ng-container>
        <ng-container matColumnDef="telefono">
          <th mat-header-cell *matHeaderCellDef>Teléfono</th>
          <td mat-cell *matCellDef="let p">{{ p.telefono || '—' }}</td>
        </ng-container>
        <ng-container matColumnDef="fechaAlta">
          <th mat-header-cell *matHeaderCellDef>Alta</th>
          <td mat-cell *matCellDef="let p">{{ p.fechaAlta ? (p.fechaAlta | date:'dd/MM/yyyy') : '—' }}</td>
        </ng-container>
        <ng-container matColumnDef="nroRegistro">
          <th mat-header-cell *matHeaderCellDef>N° Registro</th>
          <td mat-cell *matCellDef="let p">{{ p.nroRegistro || '—' }}</td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="cols"></tr>
        <tr mat-row *matRowDef="let row; columns: cols;"></tr>
      </table>
    </div>
  }
  @if (loading()) { <div style="text-align:center;padding:40px"><mat-spinner diameter="40" /></div> }
</div>`,
  styles: [`
    .filter-card { padding:var(--spacing-md) var(--spacing-lg); }
    .filter-row  { display:flex; gap:var(--spacing-md); align-items:flex-start; }
    .search-field { flex:1; }
    .btn-action  { height:56px; padding:0 24px; margin-top:4px; background:var(--color-primary); color:#fff; border:none; border-radius:4px; font-size:14px; cursor:pointer; &:disabled{opacity:.55;cursor:not-allowed;} }
    .card-header { display:flex; align-items:center; gap:8px; padding:var(--spacing-md) var(--spacing-lg); border-bottom:1px solid var(--color-border); font-weight:700; color:var(--color-text-heading); font-size:14px; mat-icon{color:var(--color-primary);font-size:20px;width:20px;height:20px;} }
    code { background:#f1f5f9; padding:2px 6px; border-radius:4px; font-size:12px; }
  `]
})
export class ProveedoresComponent {
  private svc  = inject(FinancieroService);
  private fb   = inject(FormBuilder);

  form       = this.fb.nonNullable.group({ termino: [''] });
  loading    = signal(false);
  error      = signal('');
  proveedores = signal<Proveedor[]>([]);

  cols = ['identificador','nombre','cuit','email','telefono','fechaAlta','nroRegistro'];

  buscar() {
    const t = this.form.value.termino?.trim() ?? '';
    if (t.length < 2) { this.error.set('Ingrese al menos 2 caracteres'); return; }
    this.error.set('');
    this.loading.set(true);
    this.svc.buscarProveedores(t).subscribe({
      next: d => { this.proveedores.set(d); this.loading.set(false); },
      error: () => { this.error.set('Error al buscar proveedores'); this.loading.set(false); },
    });
  }
}
