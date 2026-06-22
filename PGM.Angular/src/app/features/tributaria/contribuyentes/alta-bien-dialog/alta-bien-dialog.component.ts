import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { NgFor, NgIf } from '@angular/common';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatStepperModule } from '@angular/material/stepper';
import { TributariaService, TipoBien } from '../../../../core/services/tributaria.service';

@Component({
  selector: 'app-alta-bien-dialog',
  standalone: true,
  imports: [
    ReactiveFormsModule, NgFor, NgIf,
    MatDialogModule, MatFormFieldModule, MatInputModule,
    MatButtonModule, MatIconModule, MatStepperModule,
  ],
  template: `
<h2 mat-dialog-title><mat-icon>add_circle</mat-icon> Alta de Bien en Padrón</h2>

<mat-dialog-content>
  <mat-stepper linear #stepper>

    <!-- PASO 1: Datos del padrón -->
    <mat-step [stepControl]="paso1" label="Datos padrón">
      <form [formGroup]="paso1" class="step-form">
        <mat-form-field appearance="outline" class="full">
          <mat-label>Tipo de bien</mat-label>
          <select matNativeControl formControlName="tipoBien">
            <option value="">— Seleccione —</option>
            <option *ngFor="let t of tipos" [value]="t.codigoTipoBien">
              {{ t.codigoTipoBien }} — {{ t.concepto }}
            </option>
          </select>
        </mat-form-field>
        <mat-form-field appearance="outline" class="full">
          <mat-label>Clave bien (patente / partida catastral / CUIT)</mat-label>
          <input matInput formControlName="claveBien" />
        </mat-form-field>
        <div class="row-2">
          <mat-form-field appearance="outline">
            <mat-label>Exención</mat-label>
            <select matNativeControl formControlName="exencion">
              <option value="NOEX">Sin exención</option>
              <option value="EX01">Exento</option>
              <option value="EX02">Parcial</option>
            </select>
          </mat-form-field>
          <mat-form-field appearance="outline">
            <mat-label>Plan</mat-label>
            <select matNativeControl formControlName="tipoPlan">
              <option value="1 ">Plan general</option>
              <option value="2 ">Plan especial</option>
            </select>
          </mat-form-field>
        </div>
        <div class="step-actions">
          <button type="button" class="btn-action" matStepperNext
                  [disabled]="paso1.invalid">Siguiente</button>
        </div>
      </form>
    </mat-step>

    <!-- PASO 2: Detalles tipo-específico -->
    <mat-step label="Detalles específicos">
      <div class="step-form">

        <!-- Automotor -->
        @if (esAutomotor()) {
          <form [formGroup]="fAuto">
            <div class="row-2">
              <mat-form-field appearance="outline">
                <mat-label>Marca</mat-label>
                <input matInput formControlName="marca" />
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>Año fabricación</mat-label>
                <input matInput formControlName="modeloAno" type="number" />
              </mat-form-field>
            </div>
            <div class="row-2">
              <mat-form-field appearance="outline">
                <mat-label>Patente</mat-label>
                <input matInput formControlName="patente" />
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>Año valuación</mat-label>
                <input matInput formControlName="anoValuacion" maxlength="4" />
              </mat-form-field>
            </div>
            <div class="row-2">
              <mat-form-field appearance="outline">
                <mat-label>N° Motor</mat-label>
                <input matInput formControlName="nroMotor" />
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>N° Chasis</mat-label>
                <input matInput formControlName="nroChasis" />
              </mat-form-field>
            </div>
            <div class="row-2">
              <mat-form-field appearance="outline">
                <mat-label>Categoría</mat-label>
                <select matNativeControl formControlName="categoriaAutomotor">
                  <option value="A1  ">A1 - Automóvil</option>
                  <option value="A2  ">A2 - Automóvil lujo</option>
                  <option value="C1  ">C1 - Camión</option>
                  <option value="M1  ">M1 - Moto</option>
                  <option value="L1  ">L1 - Liviano</option>
                  <option value="R1  ">R1 - Rural/Pick-up</option>
                </select>
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>Valor factura</mat-label>
                <input matInput formControlName="valorFactura" type="number" />
              </mat-form-field>
            </div>
          </form>
        }

        <!-- Inmueble/Catastro -->
        @if (esCatastro()) {
          <form [formGroup]="fCatastro">
            <mat-form-field appearance="outline" class="full">
              <mat-label>N° de partida catastral</mat-label>
              <input matInput formControlName="nroRenta" />
            </mat-form-field>
            <div class="row-2">
              <mat-form-field appearance="outline">
                <mat-label>Calle</mat-label>
                <input matInput formControlName="calle" />
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>Número</mat-label>
                <input matInput formControlName="numeracionCalle" />
              </mat-form-field>
            </div>
            <div class="row-2">
              <mat-form-field appearance="outline">
                <mat-label>Barrio</mat-label>
                <input matInput formControlName="barrio" />
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>Designación oficial</mat-label>
                <input matInput formControlName="designacionOficial" placeholder="MZ: A-LT: 6" />
              </mat-form-field>
            </div>
            <div class="row-2">
              <mat-form-field appearance="outline">
                <mat-label>Superficie terreno (m²)</mat-label>
                <input matInput formControlName="superficieTerreno" type="number" />
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>Metros de frente</mat-label>
                <input matInput formControlName="metrosFrente" type="number" />
              </mat-form-field>
            </div>
            <div class="row-2">
              <mat-form-field appearance="outline">
                <mat-label>Estado</mat-label>
                <select matNativeControl formControlName="baldioEdificado">
                  <option value="01">Edificado</option>
                  <option value="02">Baldío</option>
                </select>
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>Unidades locativas</mat-label>
                <input matInput type="number" min="0" formControlName="unidadesLocativas" />
              </mat-form-field>
            </div>
          </form>
        }

        <!-- Comercio -->
        @if (esComercio()) {
          <form [formGroup]="fComercio">
            <div class="row-2">
              <mat-form-field appearance="outline">
                <mat-label>Nombre fantasía</mat-label>
                <input matInput formControlName="nombreFantasia" />
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>Razón social</mat-label>
                <input matInput formControlName="nombreSociedad" />
              </mat-form-field>
            </div>
            <div class="row-2">
              <mat-form-field appearance="outline">
                <mat-label>Tipo sociedad</mat-label>
                <select matNativeControl formControlName="tipoSociedad">
                  <option value="UNIP">Unipersonal</option>
                  <option value="SRL ">SRL</option>
                  <option value="SA  ">SA</option>
                  <option value="SAS ">SAS</option>
                </select>
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>CUIT</mat-label>
                <input matInput formControlName="cuit" />
              </mat-form-field>
            </div>
            <div class="row-2">
              <mat-form-field appearance="outline">
                <mat-label>Ingresos brutos</mat-label>
                <input matInput formControlName="ingresosBrutos" />
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>N° resolución habilitación</mat-label>
                <input matInput formControlName="resolucionHabilitacion" />
              </mat-form-field>
            </div>
            <div class="row-2">
              <mat-form-field appearance="outline">
                <mat-label>Calle</mat-label>
                <input matInput formControlName="calle" />
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>Número</mat-label>
                <input matInput formControlName="numeracionCalle" />
              </mat-form-field>
            </div>
            <div class="row-2">
              <mat-form-field appearance="outline">
                <mat-label>Capital declarado</mat-label>
                <input matInput formControlName="capitalDeclarado" type="number" />
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>Personal ocupado</mat-label>
                <input matInput formControlName="personalOcupado" type="number" />
              </mat-form-field>
            </div>
          </form>
        }

        <!-- Sin detalles adicionales -->
        @if (!esAutomotor() && !esCatastro() && !esComercio()) {
          <p style="color:var(--color-text-muted);text-align:center;padding:24px 0">
            <mat-icon style="font-size:40px;display:block;margin:0 auto 8px">check_circle</mat-icon>
            No se requieren datos adicionales para este tipo de bien.
          </p>
        }

        <div class="step-actions">
          <button type="button" mat-button matStepperPrevious>Atrás</button>
          <button type="button" class="btn-action" (click)="guardar()" [disabled]="loading()">
            Guardar
          </button>
        </div>
      </div>
    </mat-step>

  </mat-stepper>

  @if (error()) {
    <div class="dialog-error">{{ error() }}</div>
  }
</mat-dialog-content>
`,
  styles: [`
    mat-dialog-content { min-width: 560px; max-width: 680px; }
    .step-form { padding: 16px 0; }
    .full { width: 100%; }
    .row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    mat-form-field { width: 100%; margin-bottom: 4px; }
    .step-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px; }
    .btn-action { height: 40px; padding: 0 20px; background: var(--color-primary); color: #fff;
                  border: none; border-radius: 4px; font-size: 14px; cursor: pointer;
                  &:disabled { opacity: .55; cursor: not-allowed; } }
    .dialog-error { background: #fef2f2; color: #b91c1c; padding: 8px 12px;
                    border-radius: 4px; margin-top: 8px; font-size: 13px; }
  `],
})
export class AltaBienDialogComponent {
  private svc  = inject(TributariaService);
  private fb   = inject(FormBuilder);
  private ref  = inject(MatDialogRef<AltaBienDialogComponent>);
  data: { identificador: string } = inject(MAT_DIALOG_DATA);

  loading = signal(false);
  error   = signal('');
  tipos: TipoBien[] = [];

  paso1 = this.fb.nonNullable.group({
    tipoBien:  ['', Validators.required],
    claveBien: ['', Validators.required],
    exencion:  ['NOEX'],
    tipoPlan:  ['1 '],
  });

  fAuto = this.fb.nonNullable.group({
    marca:             [''],
    modeloAno:         [new Date().getFullYear()],
    patente:           [''],
    anoValuacion:      [new Date().getFullYear().toString()],
    nroMotor:          [''],
    nroChasis:         [''],
    categoriaAutomotor:['A1  '],
    valorFactura:      [0],
  });

  fCatastro = this.fb.nonNullable.group({
    nroRenta:           [''],
    calle:              [''],
    numeracionCalle:    [''],
    barrio:             [''],
    designacionOficial: [''],
    superficieTerreno:  [0],
    metrosFrente:       [0],
    baldioEdificado:    ['01'],
    unidadesLocativas:  [0],
  });

  fComercio = this.fb.nonNullable.group({
    nombreFantasia:         [''],
    nombreSociedad:         [''],
    tipoSociedad:           ['UNIP'],
    cuit:                   [''],
    ingresosBrutos:         [''],
    resolucionHabilitacion: [''],
    calle:                  [''],
    numeracionCalle:        [''],
    capitalDeclarado:       [0],
    personalOcupado:        [1],
  });

  constructor() {
    this.svc.tiposBien$.subscribe(t => this.tipos = t);
  }

  esAutomotor() { return this.paso1.value.tipoBien?.trim() === 'AUAU'; }
  esCatastro()  {
    const t = this.paso1.value.tipoBien?.trim() ?? '';
    return ['ININ','CACA','OBSA','OBSC'].includes(t);
  }
  esComercio()  { return this.paso1.value.tipoBien?.trim() === 'CICI'; }

  guardar() {
    if (this.paso1.invalid) return;
    this.loading.set(true);
    this.error.set('');

    const padron = {
      ...this.paso1.getRawValue(),
      identificador: this.data.identificador,
    };

    this.svc.altaPadron(padron).subscribe({
      next: ({ idBien }) => this.guardarDetalle(idBien),
      error: e => { this.error.set('Error al dar de alta: ' + (e.error?.title ?? e.message)); this.loading.set(false); },
    });
  }

  private guardarDetalle(idBien: string) {
    if (this.esAutomotor()) {
      this.svc.altaAutomotor(idBien, this.fAuto.getRawValue()).subscribe({
        next: () => this.ref.close(true),
        error: e => { this.error.set('Padrón creado (ID: ' + idBien + ') pero error en automotor: ' + e.message); this.loading.set(false); },
      });
    } else if (this.esCatastro()) {
      this.svc.altaCatastro(idBien, this.fCatastro.getRawValue()).subscribe({
        next: () => this.ref.close(true),
        error: e => { this.error.set('Padrón creado (ID: ' + idBien + ') pero error en catastro: ' + e.message); this.loading.set(false); },
      });
    } else if (this.esComercio()) {
      this.svc.altaComercio(idBien, this.fComercio.getRawValue()).subscribe({
        next: () => this.ref.close(true),
        error: e => { this.error.set('Padrón creado (ID: ' + idBien + ') pero error en comercio: ' + e.message); this.loading.set(false); },
      });
    } else {
      this.ref.close(true);
    }
  }
}
