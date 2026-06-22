import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { DatePipe, DecimalPipe } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog, MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { TributariaService } from '../../../../core/services/tributaria.service';

// ── Dialog inline ────────────────────────────────────────────────────────────
@Component({
  selector: 'app-tasa-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatIconModule],
  template: `
<div class="dlg-header">
  <mat-icon>{{ data ? 'edit' : 'add_circle' }}</mat-icon>
  <h2>{{ data ? 'Editar tasa' : 'Nueva tasa' }}</h2>
</div>
<mat-dialog-content>
  <form [formGroup]="form" class="form-grid">
    <mat-form-field appearance="outline">
      <mat-label>Tipo interés (A/B/C…)</mat-label>
      <input matInput formControlName="interes" maxlength="1" [readonly]="!!data" />
    </mat-form-field>
    <mat-form-field appearance="outline">
      <mat-label>Fecha vigencia</mat-label>
      <input matInput type="date" formControlName="fecha" [readonly]="!!data" />
    </mat-form-field>
    <mat-form-field appearance="outline" class="full">
      <mat-label>Tasa mensual (%)</mat-label>
      <input matInput type="number" step="0.01" formControlName="tasaMensual" />
    </mat-form-field>
  </form>
  @if (error()) { <div class="msg-err">{{ error() }}</div> }
</mat-dialog-content>
<mat-dialog-actions align="end">
  <button mat-button mat-dialog-close>Cancelar</button>
  <button class="btn-ok" (click)="guardar()" [disabled]="form.invalid || loading()">
    {{ loading() ? 'Guardando…' : 'Guardar' }}
  </button>
</mat-dialog-actions>`,
  styles: [`.dlg-header{display:flex;align-items:center;gap:10px;padding:20px 24px 0;color:#1e293b;h2{margin:0;font-size:18px}}
    mat-dialog-content{min-width:360px} .form-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;padding:16px 0}
    .full{grid-column:1/-1} .msg-err{background:#fef2f2;color:#b91c1c;padding:8px 12px;border-radius:4px;font-size:13px}
    .btn-ok{height:36px;padding:0 20px;background:var(--color-primary);color:#fff;border:none;border-radius:4px;font-size:14px;cursor:pointer;
    &:disabled{opacity:.55;cursor:not-allowed}}`],
})
export class TasaDialogComponent {
  private svc = inject(TributariaService);
  private fb  = inject(FormBuilder);
  private ref = inject(MatDialogRef<TasaDialogComponent>);
  data: any = inject(MAT_DIALOG_DATA);

  loading = signal(false);
  error   = signal('');

  form = this.fb.nonNullable.group({
    interes:    [this.data?.interes ?? '', [Validators.required, Validators.maxLength(1)]],
    fecha:      [this.data ? new Date(this.data.fecha).toISOString().substring(0,10) : '', Validators.required],
    tasaMensual:[this.data?.tasaMensual ?? 0, [Validators.required, Validators.min(0)]],
  });

  guardar() {
    if (this.form.invalid) return;
    this.loading.set(true);
    const v = this.form.getRawValue();
    const body = { interes: v.interes, fecha: new Date(v.fecha), tasaMensual: v.tasaMensual };
    const obs = this.data
      ? this.svc.actualizarTasa(body)
      : this.svc.crearTasa(body);
    obs.subscribe({
      next: () => this.ref.close(true),
      error: e => { this.error.set(e.error?.title ?? 'Error al guardar'); this.loading.set(false); },
    });
  }
}

// ── Componente principal ──────────────────────────────────────────────────────
@Component({
  selector: 'app-tasas',
  standalone: true,
  imports: [DatePipe, DecimalPipe, MatIconModule, MatTableModule, MatButtonModule, MatDialogModule],
  template: `
<div class="page-container">
  <div class="eyebrow">Administración Tributaria · Referencia</div>
  <div class="page-header">
    <h1 class="page-title">Tasas de Actualización</h1>
    <button class="btn-header" (click)="nueva()">
      <mat-icon>add</mat-icon> Nueva tasa
    </button>
  </div>

  @if (loading()) {
    <div class="loading-msg"><mat-icon class="spin">sync</mat-icon> Cargando…</div>
  }

  @if (!loading() && tasas.length) {
    <div class="card table-card">
      <table mat-table [dataSource]="tasas">
        <ng-container matColumnDef="interes">
          <th mat-header-cell *matHeaderCellDef>Tipo</th>
          <td mat-cell *matCellDef="let t"><span class="chip">{{ t.interes }}</span></td>
        </ng-container>
        <ng-container matColumnDef="fecha">
          <th mat-header-cell *matHeaderCellDef>Vigencia desde</th>
          <td mat-cell *matCellDef="let t">{{ t.fecha | date:'dd/MM/yyyy' }}</td>
        </ng-container>
        <ng-container matColumnDef="tasaMensual">
          <th mat-header-cell *matHeaderCellDef>Tasa mensual</th>
          <td mat-cell *matCellDef="let t"><strong>{{ t.tasaMensual | number:'1.2-4' }}%</strong></td>
        </ng-container>
        <ng-container matColumnDef="accion">
          <th mat-header-cell *matHeaderCellDef></th>
          <td mat-cell *matCellDef="let t" class="accion-cell">
            <button class="icon-btn" (click)="editar(t)" title="Editar"><mat-icon>edit</mat-icon></button>
            <button class="icon-btn danger" (click)="eliminar(t)" title="Eliminar"><mat-icon>delete</mat-icon></button>
          </td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="cols"></tr>
        <tr mat-row *matRowDef="let row; columns: cols;"></tr>
      </table>
    </div>
  }
</div>`,
  styles: [`
    .page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:20px}
    .btn-header{display:flex;align-items:center;gap:6px;background:var(--color-primary);color:#fff;
      border:none;border-radius:6px;padding:0 16px;height:40px;font-size:14px;font-weight:600;cursor:pointer}
    .table-card{padding:0;overflow:hidden}
    .chip{background:#e0f2fe;color:#0369a1;border-radius:6px;padding:2px 10px;font-size:12px;font-weight:700}
    .accion-cell{display:flex;gap:4px;justify-content:flex-end}
    .icon-btn{background:none;border:none;cursor:pointer;border-radius:4px;padding:4px;display:flex;align-items:center;
      mat-icon{font-size:18px;color:#64748b} &:hover mat-icon{color:var(--color-primary)}}
    .icon-btn.danger:hover mat-icon{color:#dc2626}
    .loading-msg{display:flex;align-items:center;gap:8px;color:#64748b;padding:20px 0}
    .spin{animation:spin 1s linear infinite} @keyframes spin{from{transform:rotate(0)}to{transform:rotate(360deg)}}
  `],
})
export class TasasComponent {
  private svc    = inject(TributariaService);
  private dialog = inject(MatDialog);

  loading = signal(true);
  tasas:   any[] = [];
  cols = ['interes','fecha','tasaMensual','accion'];

  constructor() { this.cargar(); }

  cargar() {
    this.loading.set(true);
    this.svc.tasas().subscribe({
      next: d => { this.tasas = d; this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  nueva() {
    this.dialog.open(TasaDialogComponent, { data: null, width: '440px', maxWidth: '95vw' })
      .afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  editar(t: any) {
    this.dialog.open(TasaDialogComponent, { data: t, width: '440px', maxWidth: '95vw' })
      .afterClosed().subscribe(ok => { if (ok) this.cargar(); });
  }

  eliminar(t: any) {
    if (!confirm(`¿Eliminar tasa ${t.interes} al ${t.tasaMensual}% vigente desde ${new Date(t.fecha).toLocaleDateString()}?`)) return;
    this.svc.eliminarTasa(t.interes, t.fecha).subscribe({ next: () => this.cargar() });
  }
}
