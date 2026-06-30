import { Component, inject, signal, OnInit } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { CajaService, CajeroUsuario } from '../../core/services/caja.service';

@Component({
  selector: 'app-cajeros-admin',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    MatFormFieldModule, MatInputModule, MatButtonModule,
    MatIconModule, MatSlideToggleModule, MatProgressSpinnerModule,
  ],
  templateUrl: './cajeros-admin.component.html',
  styleUrl: './cajeros-admin.component.scss',
})
export class CajerosAdminComponent implements OnInit {
  private cajaSvc = inject(CajaService);

  cajeros    = signal<CajeroUsuario[]>([]);
  loading    = signal(false);
  saving     = signal(false);
  msgOk      = signal('');
  msgErr     = signal('');
  toggling   = signal<Set<string>>(new Set());

  form = new FormGroup({
    cajero:      new FormControl('', [Validators.required, Validators.maxLength(15)]),
    descripcion: new FormControl('', [Validators.required, Validators.maxLength(50)]),
    nivel:       new FormControl(1,  [Validators.required, Validators.min(1)]),
  });

  ngOnInit() { this.cargar(); }

  cargar() {
    this.loading.set(true);
    this.cajaSvc.listarCajeros().subscribe({
      next: list => { this.cajeros.set(list); this.loading.set(false); },
      error: ()  => this.loading.set(false),
    });
  }

  toggleHabilitado(c: CajeroUsuario) {
    const nuevo = !c.habilitado;
    this.toggling.update(s => { const n = new Set(s); n.add(c.cajero); return n; });
    this.cajaSvc.toggleHabilitado(c.cajero, nuevo).subscribe({
      next: () => {
        this.cajeros.update(list =>
          list.map(x => x.cajero === c.cajero ? { ...x, habilitado: nuevo } : x)
        );
        this.toggling.update(s => { const n = new Set(s); n.delete(c.cajero); return n; });
      },
      error: () => this.toggling.update(s => { const n = new Set(s); n.delete(c.cajero); return n; }),
    });
  }

  agregar() {
    if (this.form.invalid) return;
    this.saving.set(true);
    this.msgOk.set('');
    this.msgErr.set('');
    const { cajero, descripcion, nivel } = this.form.getRawValue();
    this.cajaSvc.crearCajero(cajero!, descripcion!, nivel!).subscribe({
      next: r => {
        this.msgOk.set(r.mensaje);
        this.form.reset({ nivel: 1 });
        this.cargar();
        this.saving.set(false);
      },
      error: e => {
        this.msgErr.set(e.error?.mensaje ?? 'Error al crear cajero');
        this.saving.set(false);
      },
    });
  }
}
