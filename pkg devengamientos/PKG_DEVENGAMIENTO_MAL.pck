CREATE OR REPLACE PACKAGE PKG_DEVENGAMIENTO_MAL IS
  TYPE TY_CURSOR IS REF CURSOR;

  PROCEDURE GENERA_DEVENGAMIENTO_AUAU_MAL (P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                         P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL,
                                         P_CUOTAS                   IN VARCHAR2 DEFAULT NULL,
                                         P_USR_ING                  IN VARCHAR2 DEFAULT NULL,
                                         P_MODO                     IN VARCHAR2 DEFAULT NULL,
                                         P_MSG                      OUT VARCHAR2);

   function F_GENERA_TASABASICA_AUTOMOTOR_MAL(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                           P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL ,
                                            P_MSG                      OUT VARCHAR2
                                           ) return NUMBER;
                                           
     PROCEDURE GENERA_DEVENGAMIENTO_ININ_MAL(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                         P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL,
                                         P_USR_ING                  IN VARCHAR2,
                                         P_CUOTAS                   IN VARCHAR2 DEFAULT NULL,
                                         P_MODO                     IN VARCHAR2,
                                         P_MSG                      OUT VARCHAR2);
                                         
     FUNCTION F_TASABASICA_INMUEBLE_MAL(P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL,
                                    P_ID_TRIBUTO_CONTRIBUYENTE IN VARCHAR2 DEFAULT NULL,
                                    P_NRO_CUOTA                IN NUMBER)
    RETURN NUMBER; 
    
    FUNCTION F_TASABASICA_CECE_MAL(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                 P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL --A= ALQUILER / M= MANTENIMIENTO
                                 --  P_MSG             OUT VARCHAR2
                                 )  RETURN NUMBER;                                  
                                         
                                 
   PROCEDURE GENERA_DEVENGAMIENTO_CECE_MAL(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                            P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL,
                                            P_USR_ING                  IN VARCHAR2,
                                            P_CUOTAS                   IN VARCHAR2 DEFAULT NULL,
                                            P_MODO                     IN VARCHAR2,
                                            P_MSG                      OUT VARCHAR2);   
                                            
   PROCEDURE GENERA_DEVENGAMIENTO_CLOACA_MAL(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                         P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL,
                                         P_USR_ING                  IN VARCHAR2,
                                         P_CUOTAS                   IN VARCHAR2 DEFAULT NULL,
                                         P_MODO                     IN VARCHAR2,
                                         P_MSG                      OUT VARCHAR2);    
                                         
   PROCEDURE GENERA_DEVENGAMIENTO_CICI_FIJO(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                         P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL,
                                         P_ID_JURISDICCION          IN NUMBER DEFAULT NULL,
                                         P_USR_ING                  IN VARCHAR2 DEFAULT NULL,
                                         P_ID_CATEGORIA             IN NUMBER DEFAULT NULL,
                                         P_MES                      IN VARCHAR2 DEFAULT NULL,
                                         P_ID_SITUACION_IMPOSITIVA  IN VARCHAR2 DEFAULT NULL,
                                         P_MSG                      OUT VARCHAR2,
                                         P_CUOTA_CERO               OUT NUMBER,
                                         P_CUENTAS_DEVENGADAS       OUT NUMBER,
                                         P_CUOTAS_GENERADAS         OUT NUMBER,
                                         P_VARIABLE                 OUT VARCHAR2);  
    
   FUNCTION F_CUMPLIDOR_MAL(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                             P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL) RETURN NUMBER ;                                                                     
                                         
                                              

END PKG_DEVENGAMIENTO_MAL;
/
CREATE OR REPLACE PACKAGE BODY PKG_DEVENGAMIENTO_MAL IS

     PROCEDURE GENERA_DEVENGAMIENTO_AUAU_MAL(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                         P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL,
                                         P_CUOTAS                   IN VARCHAR2 DEFAULT NULL,
                                         P_USR_ING                  IN VARCHAR2 DEFAULT NULL,
                                         P_MODO                     IN VARCHAR2 DEFAULT NULL,
                                         P_MSG                      OUT VARCHAR2) IS

    /*contempla devengamiento multianual
    CONTEMPLA CUOTA UNICA */

    V_ANIO_DESDE               NUMBER(4);
    V_ANIO                     NUMBER(4);
    V_ANIO_ALTA                NUMBER(4);
    V_CATE_VA                  NUMBER(4);
    V_MODE_VA                  NUMBER(4);
    V_ANIO_HASTA               NUMBER(4);
    V_ID_OBLIGACION            NUMBER(10);
    V_ID_OBLIGACION_DETALLE    NUMBER(10);
    V_MONTO_ITEM               NUMBER(19, 5) := 0;
    V_TASA_BASICA_CUOTA_0      NUMBER(19, 5) := 0;
    V_TASA_BASICA              NUMBER(19, 5) := 0;
    V_TIPO_TIBUTO              VARCHAR2(10) := 'AUAU';
    P_ID_COMPROBANTE           NUMBER(10);
    V_FECHA_ALTA               DATE;
    V_ID_JURISDICCION          NUMBER(10);
    V_FECHA_VENCIMIENTO        DATE;
    V_ID_TRIBUTO_CONTRIBUYENTE VARCHAR2(50);
    V_DESCUENTO_ALDIA          NUMBER(19, 5) := 0;
    V_CODIGO_BARRA             VARCHAR2(100);
    V_FONDO_OMMV               NUMBER(19, 5) := 0;
    V_FONDO_FDRE               NUMBER(19, 5) := 0;
    V_FONDO_FDOP               NUMBER(19, 5) := 0;
    V_GASTO_ADM                NUMBER(19, 5) := 0;
    V_DESC_CUOTA_UNICA         NUMBER(19, 5) := 0;
    V_TASA_BASICA_CTAU         NUMBER(19, 5) := 0;
    V_FEC_ALTA_VAL             DATE;
    V_SENTENCIA                VARCHAR2(100);
    CIP                        VARCHAR2(50);
    MONTO_FACT                 NUMBER(19, 5) := 0;
    V_PASO                     NUMBER(10) := 0;
    V_ID_TIPO_TRIBUTO          NUMBER;
    V_TIENE_OBLIGACIONES       NUMBER;
    V_CONTADOR_ROLLBACK        NUMBER;
    V_OBLIGACION               NUMBER;
    V_PATENTE                  VARCHAR2(10);
    V_DESC_CUMPLIDOR           NUMBER;
     ----------------- barra carga ----------------------
    V_CONTADOR      NUMBER := 0;
    V_PROCESADAS    NUMBER := 0;
    V_TOTAL         NUMBER := 0;
    V_MENSAJE_ERROR VARCHAR2(1000);


    CURSOR C_TRIBUTOS IS
    SELECT TT.TIPO_TRIBUTO,
             TC.ID_TRIBUTO_CONTRIBUYENTE,
             TC.ID_TIPO_TRIBUTO,
             TC.ID_PERSONA,
             TC.CLAVE_BIEN,
             LPAD(AU.CIP, 10, 0) CIP,
             --AU.ANO_VALUACION,
             AU.MODELO_AUTOMOTOR,
             AU.NRO_MOTOR,
             AU.NRO_CHASIS,
             AU.PATENTE,
             AU.VALOR_FACTURA,
             AU.PESO_CILINDRADA,
             AC.ID_CATEGORIA_AUTOMOTOR,
             AC.TIPO_CATEGORIA_AUTOMOTOR,
             AC.ALICUOTA,
             AC.MONTO_MINIMO,
             DECODE(AC.ID_JURISDICCION, 4000, NULL, AC.MODELO_MINIMO) MODELO_MINIMO,
             NVL(AU.IMPORTADO, 0) IMPORTADO,
             NVL(AU.CUMPLIDOR, 0) CUMPLIDOR,
             TC.ID_JURISDICCION,
             AU.FECHA_ALTA

        FROM T_TRIBUTOS_CONTRIBUYENTES TC,
             T_TIPOS_TRIBUTOS          TT,
             T_AUTOMOTORES             AU,
             VT_AUTOMOTORES_CATEGORIAS AC
       WHERE TC.ID_TRIBUTO_CONTRIBUYENTE = AU.ID_AUTOMOTOR
         AND TC.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND AU.ID_CATEGORIA_AUTOMOTOR = AC.ID_CATEGORIA_AUTOMOTOR
         AND AU.ID_JURISDICCION = AC.ID_JURISDICCION
         AND TT.TIPO_TRIBUTO = 'AUAU'
         AND AC.ANIO_VALUACION = V_ANIO
         AND ID_TRIBUTO_CONTRIBUYENTE = P_ID_TRIBUTO_CONTRIBUYENTE
         AND ROWNUM=1;

 CURSOR C_CUOTAS IS

        SELECT NRO_CUOTA,
             FECHA_PRIMER_VTO,
             FECHA_SEGUNDO_VTO,
             FECHA_TERCER_VTO,
             VTO.DESC_PRIMER_VTO,
             VTO.DESC_SEGUNDO_VTO
        FROM T_VENCIMIENTOS VTO, T_TIPOS_TRIBUTOS TT
       WHERE VTO.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND TT.TIPO_TRIBUTO = 'AUAU'
         AND N_TIPO = 'CUOTA'
         AND VTO.EJERCICIO = V_ANIO
        /* AND (VTO.NRO_CUOTA IN
             (SELECT TO_NUMBER(REGEXP_SUBSTR(P_CUOTAS, '[^,]+', 1, LEVEL)) AS LIST
                 FROM DUAL
               CONNECT BY REGEXP_SUBSTR(P_CUOTAS, '[^,]+', 1, LEVEL) IS NOT NULL))*/
         AND (FECHA_PRIMER_VTO >= V_FECHA_ALTA)
         AND (VTO.ID_JURISDICCION = 4000)
         AND TT.FEC_BAJA IS NULL
         AND VTO.FEC_BAJA IS NULL
       ORDER BY NRO_CUOTA;


    CURSOR C_CONCEPTOS IS

      SELECT TC.ID_TIPO_CONCEPTO,
             TC.CONCEPTO,
             TC.DESCRIPCION,
             TC.IMPACTO,
             TC.PORCENTAJE,
             TC.VALOR,
             TC.OBJETO_REF
        FROM T_TIPOS_CONCEPTOS TC, T_TIPOS_TRIBUTOS TT
       WHERE TC.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND TT.TIPO_TRIBUTO = 'AUAU'
         AND OBJETO_REF IS NOT NULL
         AND TC.FEC_BAJA IS NULL
         AND (TC.ID_JURISDICCION = 4000)
       ORDER BY ORDEN;

  BEGIN

    V_SENTENCIA := '  ALTER SESSION SET NLS_DATE_FORMAT=' || '''' ||
                   ' DD/MM/RRRR' || '''';
    EXECUTE IMMEDIATE V_SENTENCIA;
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';
    ------------- VALIDO QUE NO SEA MASIVO
    V_PASO := 1;
    IF P_ID_TRIBUTO_CONTRIBUYENTE IS NOT NULL THEN

      SELECT A.ID_CATEGORIA_AUTOMOTOR,
             A.MODELO_AUTOMOTOR,
             TO_CHAR(A.FECHA_ALTA, 'YYYY'),
             A.CIP,
             A.VALOR_FACTURA
        INTO V_CATE_VA, V_MODE_VA, V_ANIO_ALTA, CIP, MONTO_FACT
        FROM T_AUTOMOTORES A
       WHERE A.ID_JURISDICCION = 4000
         AND A.ID_AUTOMOTOR = P_ID_TRIBUTO_CONTRIBUYENTE;

    END IF;

    SELECT COUNT(*)
      INTO V_TOTAL

      FROM T_AUTOMOTORES A, T_TRIBUTOS_CONTRIBUYENTES TC
     WHERE A.ID_AUTOMOTOR = TC.ID_TRIBUTO_CONTRIBUYENTE
       AND (TC.ID_TRIBUTO_CONTRIBUYENTE = P_ID_TRIBUTO_CONTRIBUYENTE OR
           P_ID_TRIBUTO_CONTRIBUYENTE IS NULL)
       AND A.FEC_BAJA IS NULL
       AND A.USR_BAJA IS NULL
       AND A.ID_JURISDICCION = 2389 -- SOLO UNQUILLO
       AND ((A.MODELO_AUTOMOTOR +19) >=P_EJERCICIO_LIQ) ;

    V_PASO       := 2;
    V_ANIO_DESDE := P_EJERCICIO_LIQ;
    V_ANIO_HASTA := P_EJERCICIO_LIQ;
    V_ANIO       := P_EJERCICIO_LIQ;
    -------------------------------------------------

    V_PASO := 3;


    IF P_MODO = 'G' THEN

        FOR R_TRIBUTOS IN C_TRIBUTOS LOOP
          V_ID_TRIBUTO_CONTRIBUYENTE := R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE;
          V_ID_JURISDICCION          := R_TRIBUTOS.ID_JURISDICCION;
          V_FECHA_ALTA               := R_TRIBUTOS.FECHA_ALTA;

          V_TASA_BASICA := F_GENERA_TASABASICA_AUTOMOTOR_MAL(V_ID_TRIBUTO_CONTRIBUYENTE,
                                                             V_ANIO_DESDE,
                                                             P_MSG);


          IF V_TASA_BASICA <> 0 THEN
            -- SI EL AVEHICULO GENERA IMPUESTO INGRESO

            FOR R_CUOTAS IN C_CUOTAS LOOP

              SELECT COUNT(TOB.ID_OBLIGACION)
              INTO V_TIENE_OBLIGACIONES
              FROM T_OBLIGACIONES TOB
             WHERE TOB.ID_TRIBUTO_CONTRIBUYENTE =
                   P_ID_TRIBUTO_CONTRIBUYENTE
               AND TOB.ANO_CUOTA = V_ANIO
               AND TOB.ID_JURISDICCION = V_ID_JURISDICCION
               AND TOB.NRO_CUOTA = R_CUOTAS.NRO_CUOTA
               AND TOB.TIPO_CUOTA = 'BA'
               AND TOB.FEC_BAJA IS NULL
               AND TOB.USR_BAJA IS NULL
               AND TOB.ESTADO_DEUDA NOT IN ('PP','CA');

            IF V_TIENE_OBLIGACIONES > 0 THEN
              V_CONTADOR_ROLLBACK := V_CONTADOR_ROLLBACK + 1;
              P_MSG               := '. Ya hay obligaciones pagadas para el periodo seleccionado';
              CONTINUE;

              ELSE
                 V_OBLIGACION := 0;
            SELECT  count(distinct (O.ID_OBLIGACION))
            INTO V_OBLIGACION
            FROM T_OBLIGACIONES O
            JOIN T_OBLIGACIONES_DETALLE OD
            ON O.ID_OBLIGACION = OD.ID_OBLIGACION
            WHERE O.ID_TRIBUTO_CONTRIBUYENTE = P_ID_TRIBUTO_CONTRIBUYENTE
            AND O.ID_JURISDICCION = 4000
            AND O.ESTADO_DEUDA = 'PP'
            AND O.ANO_CUOTA = V_ANIO
            AND O.NRO_CUOTA = R_CUOTAS.NRO_CUOTA
            AND O.ID_OBLIGACION  NOT IN (SELECT OD.ID_OBLIGACION
                                         FROM T_OBLIGACIONES_DETALLE OD
                                         WHERE OD.ID_OBLIGACION = O.ID_OBLIGACION
                                         AND OD.ID_TIPO_CONCEPTO IN (SELECT TC.ID_TIPO_CONCEPTO
                                                                     FROM T_TIPOS_CONCEPTOS TC
                                                                     WHERE TC.ID_TIPO_CONCEPTO = OD.ID_TIPO_CONCEPTO
                                                                     AND TC.ID_TIPO_TRIBUTO = 2
                                                                     AND TC.ID_JURISDICCION  = 4000
                                                                     AND TC.DESCRIPCION LIKE 'AJUSTE DE LIQUIDACI%'))
            AND O.FEC_BAJA IS NULL
            AND O.USR_BAJA IS NULL;


            IF V_OBLIGACION > 0 THEN
            UPDATE T_OBLIGACIONES OBL
               SET OBL.FEC_BAJA     = SYSDATE,
                   OBL.USR_BAJA     = P_USR_ING,
                   OBL.ESTADO_DEUDA = 'CA'
             WHERE OBL.ID_TRIBUTO_CONTRIBUYENTE =
                   P_ID_TRIBUTO_CONTRIBUYENTE
               AND OBL.ANO_CUOTA = V_ANIO
               AND OBL.NRO_CUOTA = LPAD(R_CUOTAS.NRO_CUOTA,3,0)
               AND OBL.ESTADO_DEUDA = 'PP'
               AND OBL.ID_JURISDICCION = 4000
               AND OBL.FEC_BAJA IS NULL
               AND OBL.USR_BAJA IS NULL;
            END IF;
            END IF;

              V_FECHA_VENCIMIENTO := R_CUOTAS.FECHA_PRIMER_VTO;

              SELECT SQ_T_OBLIGACIONES.NEXTVAL
                INTO V_ID_OBLIGACION
                FROM DUAL;

              INSERT INTO T_OBLIGACIONES
                (ID_OBLIGACION,
                 ID_TRIBUTO_CONTRIBUYENTE,
                 ID_TIPOS_TRIBUTOS,
                 TIPO_PLAN,
                 TIPO_CUOTA,
                 ANO_CUOTA,
                 NRO_CUOTA,
                 ESTADO_DEUDA,
                 SITUACION_DEUDA,
                 FECHA_ESTADO_DEUDA,
                 FECHA_GENERACION_DEUDA,
                 FECHA_PRIMER_VENCIMIENTO,
                 FECHA_SEGUNDO_VENCIMIENTO,
                 FECHA_ACTUALIZACION_DEUDA,
                 CAPITAL_FACTURADO,
                 INTERESES_FACTURADOS,
                 FECHA_COBRADO,
                 FECHA_CONTABILIZACION,
                 ENTE_RECA,
                 NRO_OPERACION,
                 CAPITAL_COBRADO,
                 INTERESES_COBRADOS,
                 CAPITAL_FINANCIADO,
                 INTERESES_FINANCIADOS,
                 ID_PERSONA,
                 USR_ING,
                 FEC_ING,
                 USR_MOD,
                 FEC_MOD,
                 DIAS_MORA,
                 ID_JURISDICCION,
                 FECHA_TERCERO_VENCIMIENTO)
              VALUES
                (V_ID_OBLIGACION,
                 R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
                 R_TRIBUTOS.ID_TIPO_TRIBUTO,
                 213, --TIPO_PLAN POR FECTO GENERAL 6 CTAS
                 'BA',
                 V_ANIO,
                 LPAD(R_CUOTAS.NRO_CUOTA, 3, 0),
                 'PP',
                 'DN',
                 SYSDATE,
                 SYSDATE,
                 R_CUOTAS.FECHA_PRIMER_VTO,
                 R_CUOTAS.FECHA_SEGUNDO_VTO,
                 SYSDATE,
                 0,
                 0,
                 NULL,
                 NULL,
                 '',
                 '',
                 0,
                 0,
                 0,
                 0,
                 R_TRIBUTOS.ID_PERSONA,
                 P_USR_ING, -- 'USR_MASIVA_AUUNQ' , --'USR_MASIVA_AU'
                 SYSDATE,
                 NULL,
                 NULL,
                 0,
                 V_ID_JURISDICCION,
                 R_CUOTAS.FECHA_TERCER_VTO);

              V_MONTO_ITEM       := 0;
              V_DESCUENTO_ALDIA  := 0;
              V_FONDO_OMMV       := 0;
              V_FONDO_FDRE       := 0;
              V_FONDO_FDOP       := 0;
              V_GASTO_ADM        := 0;
              V_TASA_BASICA_CTAU := 0;

              FOR R_CONCEPTOS IN C_CONCEPTOS LOOP

                IF R_CONCEPTOS.CONCEPTO = 'AUAUBASI' THEN
                  V_MONTO_ITEM := V_TASA_BASICA;

                  -----------------AGREGADO POR CTA CERO
                  IF R_CUOTAS.NRO_CUOTA = 0 THEN
                    -- SI ES LA CERO ES LA CUOTA UNICA POR LO TANTO LA GENERO POR EL MONTO ANUAL
                    
                      V_MONTO_ITEM := V_TASA_BASICA * 6;
                      
                      IF R_CUOTAS.DESC_PRIMER_VTO > 0  THEN                                               
                     
                              V_MONTO_ITEM := V_MONTO_ITEM - (V_MONTO_ITEM * (R_CUOTAS.DESC_PRIMER_VTO / 100)); 
                     
                     
                              V_DESC_CUMPLIDOR := F_CUMPLIDOR_MAL(V_ID_TRIBUTO_CONTRIBUYENTE,(V_ANIO - 1)) ;
                                
                                     IF V_DESC_CUMPLIDOR = 0 THEN -- 10%DE DESCUENTO SI ES CUMPLIDOR AL 31/12/ DEL A?O INMEDIATO ANTERIOR
                                        
                                          V_MONTO_ITEM := V_MONTO_ITEM - (V_MONTO_ITEM * ('0,10')); 
                                          
                                     END IF;   
                      END IF;   
                  END IF;

                END IF;

                IF R_CONCEPTOS.CONCEPTO = 'AUAUCOMP' THEN
                  V_GASTO_ADM  := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_GASTOS_ADM(V_TIPO_TIBUTO,
                                                                                  R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
                                                                                  V_ANIO,
                                                                                  P_MSG);
                  V_MONTO_ITEM := V_GASTO_ADM;
                END IF;
                
                IF V_MONTO_ITEM <> 0 THEN
                  SELECT SQ_T_OBLIGACIONES_DETALLE.NEXTVAL
                    INTO V_ID_OBLIGACION_DETALLE
                    FROM DUAL;

                  INSERT INTO T_OBLIGACIONES_DETALLE
                    (ID_OBLIGACION_DETALLE,
                     ID_OBLIGACION,
                     ID_TIPO_CONCEPTO,
                     MONTO_ITEM,
                     --financiacion_item,
                     INTERESES_ITEM,
                     --  iva_item,
                     COBRADO_ITEM,
                     COBRADO_INTERESES_ITEM,
                     USR_ING,
                     FEC_ING,
                     USR_MOD,
                     FEC_MOD)
                  VALUES
                    (V_ID_OBLIGACION_DETALLE,
                     V_ID_OBLIGACION,
                     R_CONCEPTOS.ID_TIPO_CONCEPTO,
                     DECODE(R_CONCEPTOS.IMPACTO,
                            '-',
                            V_MONTO_ITEM * (-1),
                            V_MONTO_ITEM),
                     --  0,
                     0,
                     --   0,
                     0,
                     0,
                     USER, --'USR_MASIVA_AU_UQ', -- USER,
                     SYSDATE,
                     NULL,
                     NULL);

                END IF;

                V_MONTO_ITEM := 0;
              END LOOP;
              
                ---------------------INSERTO ADCIONAL DE FACTURACION SI LOS TIENE-----------------------------------
              PRC_INSERTA_ADICIONAL_FACT(V_ID_OBLIGACION, USER, P_MSG);

              -- genero la tabla comporbantes que es el reporte de liquidacion
              PKG_TRIBUTOS_CONTRIBUYENTES.GENERA_COMPROBANTES_CAB(R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
                                                                  1, -- masivo
                                                                  0,
                                                                  P_ID_COMPROBANTE,
                                                                  P_MSG);
              PKG_TRIBUTOS_CONTRIBUYENTES.GENERA_COMPROBANTES_DET(P_ID_COMPROBANTE,
                                                                  1,
                                                                  V_ID_OBLIGACION,
                                                                  0,
                                                                  P_MSG);
                SELECT F_GENERA_CODIGO_BARRA(P_ID_COMPROBANTE)
                  INTO V_CODIGO_BARRA
                  FROM DUAL;


              UPDATE T_COMPROBANTES C
                 SET COGIDO_BARRA_BANCO  = V_CODIGO_BARRA,
                     MONTO_DEUDA_A_PAGAR =
                     (SELECT SUM(MONTO_DEUDA_ORIG + INTERESES)
                        FROM T_COMPROBANTES_DETALLE
                       WHERE ID_COMPROBANTE = P_ID_COMPROBANTE),
                     USR_ING             = P_USR_ING -- , USR_ING='USR_MASIVA_AU_UQ'

               WHERE ID_COMPROBANTE = P_ID_COMPROBANTE;

            END LOOP;

            P_MSG := '';

            ---- INSERTO CONTROL DE INMUEBLES GENERADOS
            INSERT INTO TMP_TRIBUTOS_GENERADOS
              (ID_TRIBUTO_GENERADO,
               ID_TIPO_TRIBUTO,
               ID_TRIBUTO_CONTRIBUYENTE,
               ANIO_EJERCICIO,
               FECHA,
               GENERADO,
               MONTO)
            VALUES
              (SQ_TMP_TRIBUTOS_GENERADOS.NEXTVAL,
               2,
               R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
               V_ANIO,
               SYSDATE,
               'S',
               V_MONTO_ITEM);

          ELSE


              P_MSG := P_MSG; --'AUTOMOTOR LIBRE DE IMPUESTOS.. ' || V_monto_item;

               PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(2,
                                                   2389,
                                                   V_TOTAL,
                                                   V_PROCESADAS,
                                                   P_MSG,
                                                   'E');

            INSERT INTO TMP_TRIBUTOS_GENERADOS
              (ID_TRIBUTO_GENERADO,
               ID_TIPO_TRIBUTO,
               ID_TRIBUTO_CONTRIBUYENTE,
               ANIO_EJERCICIO,
               FECHA,
               GENERADO,
               MENSAJE,
               MONTO)
            VALUES
              (SQ_TMP_TRIBUTOS_GENERADOS.NEXTVAL,
               2,
               V_ID_TRIBUTO_CONTRIBUYENTE,
               V_ANIO,
               SYSDATE,
               'N',
               P_MSG,
               V_MONTO_ITEM);

          END IF;
            V_PROCESADAS := V_PROCESADAS + 1;

        PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(2,
                                               4000,
                                               V_TOTAL,
                                               V_PROCESADAS,
                                               '',
                                               'P');


          -- COMMIT;
        END LOOP;
           PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(2,
                                               4000,
                                               V_TOTAL,
                                               V_PROCESADAS,
                                               '',
                                               'T');

    ELSE --SIMULACION
      DELETE T_OBLIGA_SIMU;
      DELETE T_OBLIG_DET_SIMU;

          FOR R_TRIBUTOS IN C_TRIBUTOS LOOP
          V_ID_TRIBUTO_CONTRIBUYENTE := R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE;
          V_ID_JURISDICCION          := R_TRIBUTOS.ID_JURISDICCION;
          V_FECHA_ALTA               := R_TRIBUTOS.FECHA_ALTA;

          V_TASA_BASICA := F_GENERA_TASABASICA_AUTOMOTOR_MAL(V_ID_TRIBUTO_CONTRIBUYENTE,
                                                             V_ANIO_DESDE,
                                                             P_MSG);


          IF V_TASA_BASICA  <> 0 THEN
            -- SI EL AVEHICULO GENERA IMPUESTO INGRESO

            FOR R_CUOTAS IN C_CUOTAS LOOP

              V_FECHA_VENCIMIENTO := R_CUOTAS.FECHA_PRIMER_VTO;

              SELECT SQ_T_OBLIGACIONES_SIM.NEXTVAL
                INTO V_ID_OBLIGACION
                FROM DUAL;

              INSERT INTO T_OBLIGA_SIMU
                (ID_OBLIGACION,
                 ID_TRIBUTO_CONTRIBUYENTE,
                 ID_TIPOS_TRIBUTOS,
                 TIPO_PLAN,
                 TIPO_CUOTA,
                 ANO_CUOTA,
                 NRO_CUOTA,
                 ESTADO_DEUDA,
                 SITUACION_DEUDA,
                 FECHA_ESTADO_DEUDA,
                 FECHA_GENERACION_DEUDA,
                 FECHA_PRIMER_VENCIMIENTO,
                 FECHA_SEGUNDO_VENCIMIENTO,
                 FECHA_ACTUALIZACION_DEUDA,
                 CAPITAL_FACTURADO,
                 INTERESES_FACTURADOS,
                 FECHA_COBRADO,
                 FECHA_CONTABILIZACION,
                 ENTE_RECA,
                 NRO_OPERACION,
                 CAPITAL_COBRADO,
                 INTERESES_COBRADOS,
                 CAPITAL_FINANCIADO,
                 INTERESES_FINANCIADOS,
                 ID_PERSONA,
                 USR_ING,
                 FEC_ING,
                 USR_MOD,
                 FEC_MOD,
                 DIAS_MORA,
                 ID_JURISDICCION,
                 FECHA_TERCERO_VENCIMIENTO)
              VALUES
                (V_ID_OBLIGACION,
                 R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
                 R_TRIBUTOS.ID_TIPO_TRIBUTO,
                 213, --TIPO_PLAN POR FECTO GENERAL 6 CTAS
                 'BA',
                 V_ANIO,
                 LPAD(R_CUOTAS.NRO_CUOTA, 3, 0),
                 'PP',
                 'DN',
                 SYSDATE,
                 SYSDATE,
                 R_CUOTAS.FECHA_PRIMER_VTO,
                 R_CUOTAS.FECHA_SEGUNDO_VTO,
                 SYSDATE,
                 0,
                 0,
                 NULL,
                 NULL,
                 '',
                 '',
                 0,
                 0,
                 0,
                 0,
                 R_TRIBUTOS.ID_PERSONA,
                 P_USR_ING, -- 'USR_MASIVA_AUUNQ' , --'USR_MASIVA_AU'
                 SYSDATE,
                 NULL,
                 NULL,
                 0,
                 V_ID_JURISDICCION,
                 R_CUOTAS.FECHA_TERCER_VTO);

              V_MONTO_ITEM       := 0;
              V_DESCUENTO_ALDIA  := 0;
              V_FONDO_OMMV       := 0;
              V_FONDO_FDRE       := 0;
              V_FONDO_FDOP       := 0;
              V_GASTO_ADM        := 0;
              V_TASA_BASICA_CTAU := 0;

              FOR R_CONCEPTOS IN C_CONCEPTOS LOOP

               IF R_CONCEPTOS.CONCEPTO = 'AUAUBASI' THEN
                  V_MONTO_ITEM := V_TASA_BASICA;

                  -----------------AGREGADO POR CTA CERO
                  IF R_CUOTAS.NRO_CUOTA = 0 THEN
                    -- SI ES LA CERO ES LA CUOTA UNICA POR LO TANTO LA GENERO POR EL MONTO ANUAL
                    
                      V_MONTO_ITEM := V_TASA_BASICA  * 6;
                      
                      IF R_CUOTAS.DESC_PRIMER_VTO > 0  THEN                                               
                     
                              V_MONTO_ITEM := V_MONTO_ITEM - (V_MONTO_ITEM * (R_CUOTAS.DESC_PRIMER_VTO / 100)); 
                     
                     
                              V_DESC_CUMPLIDOR := F_CUMPLIDOR_MAL(V_ID_TRIBUTO_CONTRIBUYENTE,(V_ANIO - 1)) ;
                                
                                     IF V_DESC_CUMPLIDOR = 0 THEN -- 10%DE DESCUENTO SI ES CUMPLIDOR AL 31/12/ DEL A?O INMEDIATO ANTERIOR
                                        
                                          V_MONTO_ITEM := V_MONTO_ITEM - (V_MONTO_ITEM * ('0,10')); 
                                          
                                     END IF;   
                      END IF;   
                  END IF;
                END IF;

                IF R_CONCEPTOS.CONCEPTO = 'AUAUCOMP' THEN
                  V_GASTO_ADM  := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_GASTOS_ADM(V_TIPO_TIBUTO,
                                                                                  R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
                                                                                  V_ANIO,
                                                                                  P_MSG);
                  V_MONTO_ITEM := V_GASTO_ADM;
                END IF;

                IF V_MONTO_ITEM <> 0 THEN
                  SELECT SQ_T_OBLIGACIONES_DETALLE_SIM.NEXTVAL
                    INTO V_ID_OBLIGACION_DETALLE
                    FROM DUAL;

                  INSERT INTO T_OBLIG_DET_SIMU
                    (ID_OBLIGACION_DETALLE,
                     ID_OBLIGACION,
                     ID_TIPO_CONCEPTO,
                     MONTO_ITEM,
                     --financiacion_item,
                     INTERESES_ITEM,
                     --  iva_item,
                     COBRADO_ITEM,
                     COBRADO_INTERESES_ITEM,
                     USR_ING,
                     FEC_ING,
                     USR_MOD,
                     FEC_MOD)
                  VALUES
                    (V_ID_OBLIGACION_DETALLE,
                     V_ID_OBLIGACION,
                     R_CONCEPTOS.ID_TIPO_CONCEPTO,
                     DECODE(R_CONCEPTOS.IMPACTO,
                            '-',
                            V_MONTO_ITEM * (-1),
                            V_MONTO_ITEM),
                     --  0,
                     0,
                     --   0,
                     0,
                     0,
                     USER, --'USR_MASIVA_AU_UQ', -- USER,
                     SYSDATE,
                     NULL,
                     NULL);

                END IF;

                V_MONTO_ITEM := 0;
              END LOOP;

            END LOOP;

            P_MSG := '';

              ---- INSERTO CONTROL DE INMUEBLES GENERADOS
              INSERT INTO TMP_TRIBUTOS_GENERADOS
                (ID_TRIBUTO_GENERADO,
                 ID_TIPO_TRIBUTO,
                 ID_TRIBUTO_CONTRIBUYENTE,
                 ANIO_EJERCICIO,
                 FECHA,
                 GENERADO,
                 MONTO)
              VALUES
                (SQ_TMP_TRIBUTOS_GENERADOS.NEXTVAL,
                 2,
                 R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
                 V_ANIO,
                 SYSDATE,
                 'S',
                 V_MONTO_ITEM);

          ELSE

            P_MSG := P_MSG; --'AUTOMOTOR LIBRE DE IMPUESTOS.. ' || V_monto_item;

             PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(2,
                                                   4000,
                                                   V_TOTAL,
                                                   V_PROCESADAS,
                                                   P_MSG,
                                                   'E');

            INSERT INTO TMP_TRIBUTOS_GENERADOS
              (ID_TRIBUTO_GENERADO,
               ID_TIPO_TRIBUTO,
               ID_TRIBUTO_CONTRIBUYENTE,
               ANIO_EJERCICIO,
               FECHA,
               GENERADO,
               MENSAJE,
               MONTO)
            VALUES
              (SQ_TMP_TRIBUTOS_GENERADOS.NEXTVAL,
               2,
               V_ID_TRIBUTO_CONTRIBUYENTE,
               V_ANIO,
               SYSDATE,
               'N',
               P_MSG,
               V_MONTO_ITEM);

          END IF;
           V_PROCESADAS := V_PROCESADAS + 1;

        PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(2,
                                               4000,
                                               V_TOTAL,
                                               V_PROCESADAS,
                                               '',
                                               'P');
        END LOOP;

       PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(2,
                                               4000,
                                               V_TOTAL,
                                               V_PROCESADAS,
                                               '',
                                               'T');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      P_MSG := 'Error en GENERA_DEVENGAMIENTO_ANUAL_AUAU .Verifique: ' ||
               SQLERRM || V_ID_TRIBUTO_CONTRIBUYENTE || ' ' || V_PASO;

      INSERT INTO TMP_TRIBUTOS_GENERADOS
        (ID_TRIBUTO_GENERADO,
         ID_TIPO_TRIBUTO,
         ID_TRIBUTO_CONTRIBUYENTE,
         ANIO_EJERCICIO,
         FECHA,
         GENERADO,
         MENSAJE,
         MONTO)
      VALUES
        (SQ_TMP_TRIBUTOS_GENERADOS.NEXTVAL,
         2,
         V_ID_TRIBUTO_CONTRIBUYENTE,
         V_ANIO,
         SYSDATE,
         'N',
         P_MSG,
         V_MONTO_ITEM);

  END GENERA_DEVENGAMIENTO_AUAU_MAL;

  FUNCTION F_GENERA_TASABASICA_AUTOMOTOR_MAL(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                            P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL ,
                                             P_MSG             OUT VARCHAR2
                                            ) RETURN NUMBER IS

    V_ANIO NUMBER;
    --V_ANO_VALUACION   NUMBER(4) ;
    V_MODELO_VALUACION    NUMBER(4) := 0;
    V_BASE_IMPONIBLE      NUMBER(19, 2) := 0;
    V_VALOR_CUOTA_MENSUAL NUMBER(19, 2) := 0;
    V_TIPO_TRIBUTO        VARCHAR2(10);
    V_FIJO                NUMBER(19, 2) := 0;
    V_ALICUOTA            VARCHAR2(10) := 0;
    V_VALOR_DESDE         NUMBER(10) := 0;
    V_VALOR_HASTA         NUMBER(10) := 0;
    V_CUOTAS              NUMBER(10) := 0;
    V_MONTO_MINIMO        NUMBER(10) := 0;
    --V_MONTO_ANUAL         NUMBER(20) := 0; --nicolas 15/07/2025
     V_MONTO_ANUAL          NUMBER(19, 2) := 0; --nicolas 15/07/2025
    V_COMPARAR            NUMBER:=0;


    --p_msg VARCHAR2(100) ;

    CURSOR C_TRIBUTOS IS
    -- TIPO_TRIBUTO : AUAU
      SELECT TT.TIPO_TRIBUTO,
             TC.ID_TRIBUTO_CONTRIBUYENTE,
             TC.ID_TIPO_TRIBUTO,
             TC.ID_PERSONA,
             TC.CLAVE_BIEN,
             LPAD(AU.CIP, 10, 0) CIP,
             --AU.ANO_VALUACION,
             AU.MODELO_AUTOMOTOR,
             AU.NRO_MOTOR,
             AU.NRO_CHASIS,
             AU.PATENTE,
             AU.VALOR_FACTURA,
             AU.PESO_CILINDRADA,
             AC.ID_CATEGORIA_AUTOMOTOR,
             AC.TIPO_CATEGORIA_AUTOMOTOR,
             AC.ALICUOTA,
             AC.MONTO_MINIMO,
             DECODE(AC.ID_JURISDICCION, 4000, NULL, AC.MODELO_MINIMO) MODELO_MINIMO,
             NVL(AU.IMPORTADO, 0) IMPORTADO,
             NVL(AU.CUMPLIDOR, 0) CUMPLIDOR,
             TC.ID_JURISDICCION

        FROM T_TRIBUTOS_CONTRIBUYENTES TC,
             T_TIPOS_TRIBUTOS          TT,
             T_AUTOMOTORES             AU,
             VT_AUTOMOTORES_CATEGORIAS AC
       WHERE TC.ID_TRIBUTO_CONTRIBUYENTE = AU.ID_AUTOMOTOR
         AND TC.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND AU.ID_CATEGORIA_AUTOMOTOR = AC.ID_CATEGORIA_AUTOMOTOR
         AND AU.ID_JURISDICCION = AC.ID_JURISDICCION
         AND TT.TIPO_TRIBUTO = V_TIPO_TRIBUTO
         AND AC.ANIO_VALUACION = V_ANIO
         AND ID_TRIBUTO_CONTRIBUYENTE = P_ID_TRIBUTO_CONTRIBUYENTE;

  BEGIN

    SELECT COUNT(*)
      INTO V_CUOTAS
      FROM T_VENCIMIENTOS VE
     WHERE VE.ID_TIPO_TRIBUTO = 2
       AND VE.EJERCICIO = P_EJERCICIO_LIQ
       AND VE.ID_JURISDICCION = 4000
       AND VE.NRO_CUOTA <> 0;

    V_ANIO         := P_EJERCICIO_LIQ;
    V_TIPO_TRIBUTO := 'AUAU';
    --IF P_TIPO_TIBUTO ='AUAU' THEN
    FOR R_TRIBUTOS IN C_TRIBUTOS LOOP

      BEGIN
        SELECT DISTINCT /*AV.ANO_VALUACION,*/ AV.MODELO_VALUACION,
                        AV.BASE_IMPONIBLE
          INTO /*V_ANO_VALUACION  ,*/ V_MODELO_VALUACION, V_BASE_IMPONIBLE
          FROM T_AUTOMOTORES_VALUACION AV,
               (SELECT DISTINCT VA.FECHA_VIGENCIA_HASTA
                  FROM T_AUTOMOTORES_VALUACION VA
                 WHERE VA.ANO_VALUACION = V_ANIO
                   AND ROWNUM = 1
                 ORDER BY VA.FECHA_VIGENCIA_HASTA DESC) VISTA
         WHERE LPAD(AV.CIP, 10, 0) = R_TRIBUTOS.CIP
              -- WHERE AV.ID_TIPO_AUTOMOTOR = R_TRIBUTOS.ID_TIPO_AUTOMOTOR
           AND AV.MODELO_VALUACION = R_TRIBUTOS.MODELO_AUTOMOTOR
           AND AV.ANO_VALUACION = V_ANIO
           AND AV.FEC_BAJA IS NULL
           AND (AV.FECHA_VIGENCIA_HASTA = VISTA.FECHA_VIGENCIA_HASTA OR
                VISTA.FECHA_VIGENCIA_HASTA IS NULL)
         ORDER BY 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- SI NO SE ENCUENTA EL DATO SE USA EL VALOR DE LA FACTURA
          V_BASE_IMPONIBLE := R_TRIBUTOS.VALOR_FACTURA;

      END;

      BEGIN
        SELECT NVL(AE.VALOR,0),NVL( AE.ALICUOTA,0),NVL( AE.PESO_CC_DESDE,0),NVL( AE.PESO_CC_HASTA,0)
          INTO V_FIJO, V_ALICUOTA, V_VALOR_DESDE, V_VALOR_HASTA
          FROM T_AUTOMOTORES_ESCALA AE
         WHERE R_TRIBUTOS.ID_CATEGORIA_AUTOMOTOR =
               AE.ID_CATEGORIA_AUTOMOTOR
           AND AE.ANIO_VALUACION = V_ANIO
           AND AE.FECHA_BAJA IS NULL
           AND AE.USER_BAJA IS NULL
           AND V_BASE_IMPONIBLE BETWEEN AE.PESO_CC_DESDE AND
               AE.PESO_CC_HASTA;
        EXCEPTION 
          WHEN OTHERS THEN
        SELECT NVL(AE.VALOR,0),NVL( AE.ALICUOTA,0),NVL( AE.PESO_CC_DESDE,0),NVL( AE.PESO_CC_HASTA,0)
          INTO V_FIJO, V_ALICUOTA, V_VALOR_DESDE, V_VALOR_HASTA
          FROM T_AUTOMOTORES_ESCALA AE
         WHERE R_TRIBUTOS.ID_CATEGORIA_AUTOMOTOR =
               AE.ID_CATEGORIA_AUTOMOTOR
           AND AE.ANIO_VALUACION = V_ANIO
            ORDER BY AE.PESO_CC_HASTA DESC
FETCH FIRST 1 ROWS ONLY;  
      END;         

        V_MONTO_ANUAL := (V_ALICUOTA / 100) * (V_BASE_IMPONIBLE); --nicolas 15/07/2025
       -- V_MONTO_ANUAL := ((TO_NUMBER(REPLACE(V_ALICUOTA, ',', '.')) / 100) * TO_NUMBER(V_BASE_IMPONIBLE));
        
       /* V_MONTO_ANUAL := (
            (TO_NUMBER(REPLACE(V_ALICUOTA, ',', '.'), '999G999D99', 'NLS_NUMERIC_CHARACTERS = ''.''') / 100)
            * TO_NUMBER(V_BASE_IMPONIBLE)
          );*/


        

        IF R_TRIBUTOS.ID_CATEGORIA_AUTOMOTOR IN (20,21,23,35,36,1989,918272) THEN
      --SI ES MOTO COMPARA POR CILINDRADA
      V_COMPARAR := R_TRIBUTOS.PESO_CILINDRADA;
      ELSE
        V_COMPARAR :=  R_TRIBUTOS.MODELO_AUTOMOTOR; 
        END IF;
      
        
      SELECT AA.MONTO_MINIMO
        INTO V_MONTO_MINIMO
        FROM T_AUTOMOTORES_ALICUOTAS AA
       WHERE AA.ID_CATEGORIA_AUTOMOTOR = R_TRIBUTOS.ID_CATEGORIA_AUTOMOTOR
         AND AA.ANIO_VALUACION = P_EJERCICIO_LIQ
         AND AA.RANGO_MINIMO <= V_COMPARAR 
         AND AA.RANGO_MAXIMO >= V_COMPARAR
         AND AA.ID_JURISDICCION =4000;

      IF V_MONTO_MINIMO > V_MONTO_ANUAL THEN
        V_MONTO_ANUAL := V_MONTO_MINIMO;
      END IF;

      V_VALOR_CUOTA_MENSUAL := V_MONTO_ANUAL / V_CUOTAS;

    END LOOP;
    --END IF;

    ----------------------

    RETURN V_VALOR_CUOTA_MENSUAL;

  EXCEPTION
    WHEN OTHERS THEN
      P_MSG := 'Error en GENERA_TRIBUTO_ANUAL .Verifique: ' ||sqlerrm;
      RETURN V_VALOR_CUOTA_MENSUAL;
       

  END F_GENERA_TASABASICA_AUTOMOTOR_MAL;

     PROCEDURE GENERA_DEVENGAMIENTO_ININ_MAL(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                         P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL,
                                         P_USR_ING                  IN VARCHAR2,
                                         P_CUOTAS                   IN VARCHAR2 DEFAULT NULL,
                                         P_MODO                     IN VARCHAR2,
                                         P_MSG                      OUT VARCHAR2) IS
    /*contempla devengamiento multianual
    CONTEMPLA CUOTA UNICA
    CONTEMPLA DESCUENTO CUOTA UNICA
    
    */
    V_TIPO_TIBUTO              VARCHAR2(10) := 'ININ';
    V_MONTO_ITEM               NUMBER(19, 5) := 0;
    V_ID_OBLIGACION            VARCHAR2(10);
    V_ID_OBLIGACION_DETALLE    VARCHAR2(10);
    V_TASA_BASICA              NUMBER(19, 5) := 0;
    V_ZONA                     VARCHAR2(50);
    P_ID_COMPROBANTE           NUMBER(10);
    V_FECHA_ALTA               DATE;
    V_ID_JURISDICCION          NUMBER(10);
    V_ANIO_DESDE               NUMBER(4);
    V_ANIO                     NUMBER(4);
    V_ANIO_HASTA               NUMBER(4);
    V_ID_TRIBUTO_CONTRIBUYENTE VARCHAR2(50);
    V_DESCUENTO_ALDIA          NUMBER(19, 5) := 0;
    V_CODIGO_BARRA             VARCHAR2(100);
    V_PASILLO                  NUMBER(4) := 0;
    V_PASILLO_POR              NUMBER(19, 5) := 0;
    V_PASILLO_MONTO            NUMBER(19, 5) := 0;
    V_TASA_BASICAPA            NUMBER(19, 5) := 0;
    V_TASA_RURAL               NUMBER(19, 5) := 0;
    V_ID_INMUEBLE              VARCHAR2(50);
    V_TASA_BASICA_ORI          NUMBER(19, 5) := 0;
    V_IMPORTE_CUOTA_CERO       NUMBER;
    V_SQL                      VARCHAR2(20000);
    C_TRIBUTOS                 SYS_REFCURSOR;
    V_ID_IN                    VARCHAR2(20);
    V_ID_TRIBUTO_CONTRIB       VARCHAR2(20);
    V_ID_PERSONA               VARCHAR2(20);
    V_ID_TIPO_TRIBUTO          NUMBER := 6;
    V_ID_TIPO_INMUEBLE         NUMBER;
    V_ID_ZONA                  NUMBER;
    V_CONCEPTO_ABREVIADO       VARCHAR2(20);
    V_CUMPLIDOR                NUMBER;
    V_FEC_ALTA                 DATE;
    V_ID_JUR                   NUMBER;
    V_ID_BIEN_TRIB_PGM         VARCHAR2(20);
    V_SQL_TOTAL                VARCHAR2(20000);
    V_MENSAJE                  VARCHAR2(200);
    V_TIENE_OBLIGACIONES       NUMBER(10);
    V_CONTADOR_ROLLBACK        NUMBER(10);
    V_TIENE_CUOTA              NUMBER;
    V_OBLIGACION               NUMBER;
    V_DESC_CUMPLIDOR           NUMBER;
    ----------------- barra carga ----------------------
    V_CONTADOR      NUMBER := 0;
    V_PROCESADAS    NUMBER := 0;
    V_TOTAL         NUMBER := 0;
    V_MENSAJE_ERROR VARCHAR2(1000);
  
    CURSOR C_CUOTAS IS
    
      SELECT NRO_CUOTA, FECHA_PRIMER_VTO, FECHA_SEGUNDO_VTO, DESC_PRIMER_VTO
        FROM T_VENCIMIENTOS VTO, T_TIPOS_TRIBUTOS TT
       WHERE VTO.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND TT.TIPO_TRIBUTO = V_TIPO_TIBUTO
         AND N_TIPO = 'CUOTA'
         AND (VTO.NRO_CUOTA IN
             (SELECT TO_NUMBER(REGEXP_SUBSTR(P_CUOTAS, '[^,]+', 1, LEVEL)) AS LIST
                 FROM DUAL
               CONNECT BY REGEXP_SUBSTR(P_CUOTAS, '[^,]+', 1, LEVEL) IS NOT NULL))
         AND VTO.EJERCICIO = V_ANIO
         AND (VTO.ID_JURISDICCION = V_ID_JURISDICCION OR
             V_ID_JURISDICCION IS NULL)
         AND VTO.FECHA_PRIMER_VTO > V_FECHA_ALTA
         AND VTO.FEC_BAJA IS NULL
         AND VTO.USR_BAJA IS NULL
       ORDER BY NRO_CUOTA;
  
    CURSOR C_CONCEPTOS IS
    
      SELECT TC.ID_TIPO_CONCEPTO,
             TC.CONCEPTO,
             TC.DESCRIPCION,
             TC.IMPACTO,
             TC.PORCENTAJE,
             TC.VALOR,
             TC.OBJETO_REF
        FROM T_TIPOS_CONCEPTOS TC, T_TIPOS_TRIBUTOS TT
       WHERE TC.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND TT.TIPO_TRIBUTO = V_TIPO_TIBUTO
         AND OBJETO_REF IS NOT NULL
         AND TC.FEC_BAJA IS NULL
            --AND TC.ID_TIPO_CONCEPTO <> '2269' --- PARA QUE NO INCLUYA EL CONCEPTO PASILLO
         AND (TC.ID_JURISDICCION = V_ID_JURISDICCION OR
             V_ID_JURISDICCION IS NULL)
       ORDER BY ORDEN;
  
    V_SENTENCIA VARCHAR2(100);
  BEGIN
    V_SENTENCIA := '  ALTER SESSION SET NLS_DATE_FORMAT=' || '''' ||
                   ' DD/MM/RRRR' || '''';
    EXECUTE IMMEDIATE V_SENTENCIA;
    V_ID_INMUEBLE := P_ID_TRIBUTO_CONTRIBUYENTE;
    V_ANIO_DESDE  := P_EJERCICIO_LIQ;
    V_ANIO_HASTA  := P_EJERCICIO_LIQ;
  
    --- AGREGUE ESTA CONDICION PARA CUANDO LIQUIDO A FIN DE A?O. PARA EL A?O SIGUIENTE
  
    IF V_ANIO_HASTA < V_ANIO_DESDE THEN
      V_ANIO_HASTA := P_EJERCICIO_LIQ;
    END IF;
  
    V_ANIO := V_ANIO_DESDE;
  
    IF P_MODO = 'G' THEN
      FOR I IN V_ANIO_DESDE .. V_ANIO_HASTA LOOP
        -----------------------------------------------------------------------------------
        V_SQL := '  select id_inmueble,
         tc.id_tributo_contribuyente,
         id_persona,
         ID_TIPO_TRIBUTO,
         I.ID_TIPO_INMUEBLE,
        TC.FECHA_ALTA, -- ALTA D LAS RELACIONES CONLAS OBLIGACIONES
         TC.ID_JURISDICCION,
         tc.id_bien_trib_pgm

    from t_inmuebles i,
         t_tributos_contribuyentes tc
       
     where i.id_inmueble = tc.id_tributo_contribuyente ';
        IF V_ID_INMUEBLE IS NOT NULL THEN
          V_SQL := V_SQL || ' and tc.id_tributo_contribuyente = ''' ||
                   V_ID_INMUEBLE || '''';
        END IF;
        V_SQL := V_SQL || ' AND I.FEC_BAJA IS NULL
     and activo = 1
     AND I.ID_JURISDICCION = 4000
     --AND I.ID_TIPO_INMUEBLE <> 99
     --AND I.ID_TIPO_INMUEBLE = 3
     
    /* AND NOT EXISTS (SELECT 1
            FROM T_OBLIGACIONES
           WHERE id_tipos_tributos = 6
             and ID_TRIBUTO_CONTRIBUYENTE = ID_INMUEBLE
             and ano_cuota = ' || V_ANIO || ' --P_EJERCICIO_LIQ
             and estado_deuda <> ''CA''
             and fec_baja is null)*/

   order by 1 ';
      
        V_SQL_TOTAL := 'SELECT COUNT(*) FROM (' || V_SQL || ')';
      
        EXECUTE IMMEDIATE V_SQL_TOTAL
          INTO V_TOTAL;
      
        BEGIN
        
          PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                                 4000,
                                                 V_TOTAL,
                                                 1,
                                                 '',
                                                 'P');
        
        END;
        OPEN C_TRIBUTOS FOR V_SQL;
      
        LOOP
          FETCH C_TRIBUTOS
            INTO V_ID_IN,
                 V_ID_TRIBUTO_CONTRIB,
                 V_ID_PERSONA,
                 V_ID_TIPO_TRIBUTO,
                 V_ID_TIPO_INMUEBLE,
                 V_FEC_ALTA,
                 V_ID_JUR,
                 V_ID_BIEN_TRIB_PGM;
        
          EXIT WHEN C_TRIBUTOS%NOTFOUND;
        
          -- FOR R_TRIBUTOS IN C_TRIBUTOS LOOP
          V_ID_TRIBUTO_CONTRIBUYENTE := V_ID_TRIBUTO_CONTRIB;
          V_ID_JURISDICCION          := V_ID_JUR;
          V_FECHA_ALTA               := V_FEC_ALTA;
          -- V_ZONA:=R_TRIBUTOS.concepto_abreviado;
          -- COMO PUEDO TENER MAS DE UNA ZONA PARA ARMAR EL CURSOS DE LAS CUOTAS SOLO ME INTERESA LA ALGUNA 
          --POR ESO EL ROWNUM             
          SELECT IZ.CONCEPTO_ABREVIADO
            INTO V_ZONA
            FROM T_INMUEBLES_ZONAS_ANIO IZA, T_INMUEBLES_ZONAS IZ
           WHERE IZA.ID_ZONA = IZ.ID_ZONAS
             AND ID_INMUEBLE = V_ID_TRIBUTO_CONTRIB
             AND V_ANIO >= ANIO_DESDE
             AND V_ANIO <= ANIO_HASTA
             AND ROWNUM = 1;
        
          V_MONTO_ITEM := F_TASABASICA_INMUEBLE_MAL(V_ANIO,
                                                   V_ID_TRIBUTO_CONTRIB,
                                                   1);
          IF V_MONTO_ITEM <> 0 THEN
          
            FOR R_CUOTAS IN C_CUOTAS LOOP
              V_PASILLO_MONTO := 0;
            
       SELECT COUNT(TOB.ID_OBLIGACION)
                    INTO V_TIENE_OBLIGACIONES
              FROM T_OBLIGACIONES TOB
             WHERE TOB.ID_TRIBUTO_CONTRIBUYENTE =V_ID_TRIBUTO_CONTRIBUYENTE
               AND TOB.ANO_CUOTA = V_ANIO
               AND TOB.ID_JURISDICCION = V_ID_JURISDICCION
               AND TOB.NRO_CUOTA = R_CUOTAS.NRO_CUOTA
               AND TOB.FEC_BAJA IS NULL
               AND TOB.USR_BAJA IS NULL
               AND TOB.ESTADO_DEUDA NOT IN ('PP','CA');
          
            IF V_TIENE_OBLIGACIONES > 0 THEN
              V_CONTADOR_ROLLBACK := V_CONTADOR_ROLLBACK + 1;
             
              P_MSG               := '. Ya hay obligaciones pagadas para el periodo seleccionado';
              EXIT;
              
              ELSE            
                 V_OBLIGACION := 0;
            SELECT  count(distinct (O.ID_OBLIGACION)) 
            INTO V_OBLIGACION
            FROM T_OBLIGACIONES O
            JOIN T_OBLIGACIONES_DETALLE OD
            ON O.ID_OBLIGACION = OD.ID_OBLIGACION 
            WHERE O.ID_TRIBUTO_CONTRIBUYENTE = V_ID_TRIBUTO_CONTRIBUYENTE
            AND O.ID_JURISDICCION = 4000
            AND O.ESTADO_DEUDA = 'PP'
            AND O.ANO_CUOTA = V_ANIO
            AND O.NRO_CUOTA = R_CUOTAS.NRO_CUOTA
            AND O.ID_OBLIGACION  NOT IN (SELECT OD.ID_OBLIGACION  
                                         FROM T_OBLIGACIONES_DETALLE OD
                                         WHERE OD.ID_OBLIGACION = O.ID_OBLIGACION 
                                         AND OD.ID_TIPO_CONCEPTO IN (SELECT TC.ID_TIPO_CONCEPTO
                                                                     FROM T_TIPOS_CONCEPTOS TC
                                                                     WHERE TC.ID_TIPO_CONCEPTO = OD.ID_TIPO_CONCEPTO 
                                                                     AND TC.ID_TIPO_TRIBUTO = 6
                                                                     AND TC.ID_JURISDICCION  = 4000
                                                                     AND TC.DESCRIPCION LIKE 'AJUSTE DE LIQUIDACI%'))
            AND O.FEC_BAJA IS NULL
            AND O.USR_BAJA IS NULL;
            

            IF V_OBLIGACION > 0 THEN 
            UPDATE T_OBLIGACIONES OBL
               SET OBL.FEC_BAJA     = SYSDATE,
                   OBL.USR_BAJA     = P_USR_ING,
                   OBL.ESTADO_DEUDA = 'CA'
             WHERE OBL.ID_TRIBUTO_CONTRIBUYENTE =V_ID_TRIBUTO_CONTRIBUYENTE
               AND OBL.ANO_CUOTA = V_ANIO
               AND OBL.NRO_CUOTA = LPAD(R_CUOTAS.NRO_CUOTA,3,0)
               AND OBL.ESTADO_DEUDA = 'PP'
               AND OBL.ID_JURISDICCION = 4000
               AND OBL.FEC_BAJA IS NULL
               AND OBL.USR_BAJA IS NULL;            
            END IF;
            END IF; 
            
              SELECT SQ_T_OBLIGACIONES.NEXTVAL
                INTO V_ID_OBLIGACION
                FROM DUAL;
            
              INSERT INTO T_OBLIGACIONES
                (ID_OBLIGACION,
                 ID_TRIBUTO_CONTRIBUYENTE,
                 ID_TIPOS_TRIBUTOS,
                 TIPO_PLAN,
                 TIPO_CUOTA,
                 ANO_CUOTA,
                 NRO_CUOTA,
                 ESTADO_DEUDA,
                 SITUACION_DEUDA,
                 FECHA_ESTADO_DEUDA,
                 FECHA_GENERACION_DEUDA,
                 FECHA_PRIMER_VENCIMIENTO,
                 FECHA_SEGUNDO_VENCIMIENTO,
                 FECHA_ACTUALIZACION_DEUDA,
                 CAPITAL_FACTURADO,
                 INTERESES_FACTURADOS,
                 FECHA_COBRADO,
                 FECHA_CONTABILIZACION,
                 ENTE_RECA,
                 NRO_OPERACION,
                 CAPITAL_COBRADO,
                 INTERESES_COBRADOS,
                 CAPITAL_FINANCIADO,
                 INTERESES_FINANCIADOS,
                 ID_PERSONA,
                 USR_ING,
                 FEC_ING,
                 USR_MOD,
                 FEC_MOD,
                 DIAS_MORA,
                 ID_JURISDICCION)
              VALUES
                (V_ID_OBLIGACION,
                 V_ID_TRIBUTO_CONTRIB,
                 V_ID_TIPO_TRIBUTO,
                 F_BUSCA_IDPLAN_DEVENGAMIENTO(V_ID_TIPO_TRIBUTO,
                                              V_ID_JURISDICCION,
                                              2025),-- ESTO LO HARCODEO PARA QUE FUNCIONE
                 'BA',
                 V_ANIO,
                 LPAD(R_CUOTAS.NRO_CUOTA, 3, 0),
                 'PP',
                 'DN',
                 SYSDATE,
                 SYSDATE,
                 R_CUOTAS.FECHA_PRIMER_VTO,
                 R_CUOTAS.FECHA_SEGUNDO_VTO,
                 SYSDATE,
                 0,
                 0,
                 NULL,
                 NULL,
                 '',
                 '',
                 0,
                 0,
                 0,
                 0,
                 V_ID_PERSONA,
                 P_USR_ING,
                 SYSDATE,
                 NULL,
                 NULL,
                 0,
                 V_ID_JURISDICCION);
            
              FOR R_CONCEPTOS IN C_CONCEPTOS LOOP
              
                IF R_CONCEPTOS.CONCEPTO = 'ININBASI' THEN
                  V_MONTO_ITEM := F_TASABASICA_INMUEBLE_MAL(V_ANIO,
                                                           V_ID_TRIBUTO_CONTRIB,
                                                           R_CUOTAS.NRO_CUOTA);
                  IF R_CUOTAS.NRO_CUOTA = 0 THEN
                    
                  IF V_ANIO >= 2025 THEN
                    
                   V_MONTO_ITEM := V_MONTO_ITEM * 12;
                   
                         IF R_CUOTAS.DESC_PRIMER_VTO > 0  AND NOT (V_ID_TIPO_INMUEBLE = 1 AND V_ZONA IN ('A1', 'A2')) THEN
                     
                                V_MONTO_ITEM := V_MONTO_ITEM - (V_MONTO_ITEM * (R_CUOTAS.DESC_PRIMER_VTO / 100));  
                                
                                V_DESC_CUMPLIDOR := F_CUMPLIDOR_MAL(V_ID_TRIBUTO_CONTRIB,(V_ANIO - 1)) ;
                                
                                     IF V_DESC_CUMPLIDOR = 0 THEN -- 10%DE DESCUENTO SI ES CUMPLIDOR AL 31/12/ DEL A?O INMEDIATO ANTERIOR
                                        
                                          V_MONTO_ITEM := V_MONTO_ITEM - (V_MONTO_ITEM * ('0,10')); 
                                          
                                     END IF;                                                   
                         
                         END IF;
                   
                   ELSE
                     V_MONTO_ITEM         := V_MONTO_ITEM * 6;
                     END IF;
                    -- SI ES LA CERO ES LA CUOTA UNICA POR LO TANTO LA GENERO POR EL MONTO ANUAL
                  /*  V_MONTO_ITEM         := V_MONTO_ITEM *
                                            F_BUSCA_CUOTAS_A_DEVENGAR(V_ID_TIPO_TRIBUTO,
                                                                      V_ID_JURISDICCION,
                                                                      V_ANIO);*/ --LO COMENTE PARA LA COUTA 07/01/2024 --NICOLAS
                    V_IMPORTE_CUOTA_CERO := V_MONTO_ITEM;
                  END IF;
                
                  V_TASA_BASICA     := V_MONTO_ITEM;
                  V_TASA_BASICAPA   := V_MONTO_ITEM;
                  V_TASA_BASICA_ORI := V_MONTO_ITEM;
                  IF V_ZONA = 'RU' THEN
                    --- si es rural hago el 48 de la tasa basica 
                    V_TASA_RURAL         := V_TASA_BASICA /*+
                                            (V_TASA_BASICA * 0.48)*/;
                    V_MONTO_ITEM         := V_TASA_RURAL;
                    V_TASA_BASICA        := V_MONTO_ITEM;
                    V_TASA_BASICA_ORI    := V_MONTO_ITEM;
                    V_IMPORTE_CUOTA_CERO := V_MONTO_ITEM;
                  END IF;
                END IF;
              
                IF R_CONCEPTOS.CONCEPTO = 'ININADMI' THEN
                  V_MONTO_ITEM := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_CONCEPTO(V_TIPO_TIBUTO,
                                                                                V_ID_TRIBUTO_CONTRIB,
                                                                                R_CONCEPTOS.CONCEPTO,
                                                                                V_ANIO,
                                                                                P_MSG);
                
                  V_TASA_BASICA := V_TASA_BASICA + V_MONTO_ITEM; -- NUEVO PARA UNQUILLO %  (contribucion basica + fondo + gasto administrativo)
                END IF;
              
             
              
                IF V_MONTO_ITEM <> 0 THEN
                  
                  SELECT SQ_T_OBLIGACIONES_DETALLE.NEXTVAL
                    INTO V_ID_OBLIGACION_DETALLE
                    FROM DUAL;
                
                  INSERT INTO T_OBLIGACIONES_DETALLE
                    (ID_OBLIGACION_DETALLE,
                     ID_OBLIGACION,
                     ID_TIPO_CONCEPTO,
                     MONTO_ITEM,
                     INTERESES_ITEM,
                     COBRADO_ITEM,
                     COBRADO_INTERESES_ITEM,
                     USR_ING,
                     FEC_ING,
                     USR_MOD,
                     FEC_MOD)
                  VALUES
                    (V_ID_OBLIGACION_DETALLE,
                     V_ID_OBLIGACION,
                     R_CONCEPTOS.ID_TIPO_CONCEPTO,
                     ROUND(DECODE(R_CONCEPTOS.IMPACTO,
                                  '-',
                                  V_MONTO_ITEM * (-1),
                                  V_MONTO_ITEM),
                           2),
                     --  0,
                     0,
                     --   0,
                     0,
                     0,
                     P_USR_ING,
                     SYSDATE,
                     NULL,
                     NULL);
                
                END IF;
              END LOOP;
              
                  ---------------------INSERTO ADCIONAL DE FACTURACION SI LOS TIENE-----------------------------------
              PRC_INSERTA_ADICIONAL_FACT(V_ID_OBLIGACION, USER, P_MSG);
              --------------------INSERTO LAS EXENCIONES------------------------                     
            /*  BEGIN
              \*
                PRC_INSERTA_EXENCION_DEVENGO(V_ID_TIPO_TRIBUTO,
                                             V_ID_TRIBUTO_CONTRIB,
                                             V_ANIO,
                                             R_CUOTAS.NRO_CUOTA,
                                             P_MSG);*\
              
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;*/
              ------------------------------------------------------------------                 
            
              -- genero la tabla comporbantes que es el reporte de liquidacion
              PKG_TRIBUTOS_CONTRIBUYENTES.GENERA_COMPROBANTES_CAB(V_ID_TRIBUTO_CONTRIB,
                                                                  1, -- masivo
                                                                  0,
                                                                  P_ID_COMPROBANTE,
                                                                  P_MSG);
              PKG_TRIBUTOS_CONTRIBUYENTES.GENERA_COMPROBANTES_DET(P_ID_COMPROBANTE,
                                                                  1,
                                                                  V_ID_OBLIGACION,
                                                                  0,
                                                                  P_MSG);
            
              IF R_CUOTAS.NRO_CUOTA = 0 THEN
                SELECT F_GENERA_CODIGO_BARRA_UNQ(P_ID_COMPROBANTE)
                  INTO V_CODIGO_BARRA
                  FROM DUAL;
              ELSE
                SELECT F_GENERA_CODIGO_BARRA(P_ID_COMPROBANTE)
                  INTO V_CODIGO_BARRA
                  FROM DUAL;
              END IF;
            
              IF V_CODIGO_BARRA = '-' THEN
                UPDATE T_COMPROBANTES C
                   SET COGIDO_BARRA_BANCO  = P_ID_COMPROBANTE,
                       MONTO_DEUDA_A_PAGAR =
                       (SELECT SUM(MONTO_DEUDA_ORIG + INTERESES)
                          FROM T_COMPROBANTES_DETALLE
                         WHERE ID_COMPROBANTE = P_ID_COMPROBANTE),
                       C.USR_ING           = DECODE(P_USR_ING,
                                                    NULL,
                                                    USER,
                                                    P_USR_ING)
                
                 WHERE ID_COMPROBANTE = P_ID_COMPROBANTE;
              
              ELSE
              
                UPDATE T_COMPROBANTES C
                   SET COGIDO_BARRA_BANCO  = V_CODIGO_BARRA,
                       MONTO_DEUDA_A_PAGAR =
                       (SELECT SUM(MONTO_DEUDA_ORIG + INTERESES)
                          FROM T_COMPROBANTES_DETALLE
                         WHERE ID_COMPROBANTE = P_ID_COMPROBANTE),
                       C.USR_ING           = DECODE(P_USR_ING,
                                                    NULL,
                                                    USER,
                                                    P_USR_ING)
                
                 WHERE ID_COMPROBANTE = P_ID_COMPROBANTE;
              
              END IF;
            
              IF R_CUOTAS.NRO_CUOTA = 0 THEN
                SELECT F_GENERA_CODIGO_BARRA_UNQ(P_ID_COMPROBANTE)
                  INTO V_CODIGO_BARRA
                  FROM DUAL;
              
                UPDATE T_COMPROBANTES C
                   SET COGIDO_BARRA_BANCO  = V_CODIGO_BARRA,
                       MONTO_DEUDA_A_PAGAR =
                       (SELECT SUM(MONTO_DEUDA_ORIG + INTERESES)
                          FROM T_COMPROBANTES_DETALLE
                         WHERE ID_COMPROBANTE = P_ID_COMPROBANTE),
                       USR_ING             = P_USR_ING
                
                 WHERE ID_COMPROBANTE = P_ID_COMPROBANTE;
              
              ELSE
                SELECT F_GENERA_CODIGO_BARRA(P_ID_COMPROBANTE)
                  INTO V_CODIGO_BARRA
                  FROM DUAL;
              
                UPDATE T_COMPROBANTES C
                   SET COGIDO_BARRA_BANCO  = V_CODIGO_BARRA,
                       MONTO_DEUDA_A_PAGAR =
                       (SELECT SUM(MONTO_DEUDA_ORIG + INTERESES)
                          FROM T_COMPROBANTES_DETALLE
                         WHERE ID_COMPROBANTE = P_ID_COMPROBANTE),
                       USR_ING             = P_USR_ING
                
                 WHERE ID_COMPROBANTE = P_ID_COMPROBANTE;
              
              END IF;
            
            END LOOP;
          
            P_MSG := '';
          
          ELSE
            P_MSG := 'NO SE PUDO CALCULAR EL MONTO MENSUAL. ' ||
                     V_MONTO_ITEM;
            PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                                   4000,
                                                   V_TOTAL,
                                                   V_PROCESADAS,
                                                   P_MSG,
                                                   'E');
          END IF;
        
          --------------------------------------------------------------------
          V_PROCESADAS := V_PROCESADAS + 1;
        
          PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                                 4000,
                                                 V_TOTAL,
                                                 V_PROCESADAS,
                                                 '',
                                                 'P');
        END LOOP;
        V_ANIO := V_ANIO + 1;
      
      END LOOP;
       PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(6,
                                               4000,
                                               V_TOTAL,
                                               V_PROCESADAS,
                                               '',
                                               'T');
      
    
    ELSE
    ---------------------////////////////////////////////////////////////////////////////////////////--------------------------------
    ------------------------------------------------ SIMULACION -------------------------------------------------------
    ---------------------////////////////////////////////////////////////////////////////////////////--------------------------------

      BEGIN
        DELETE FROM T_OBLIG_DET_SIMU;
        DELETE FROM T_OBLIGA_SIMU;
        COMMIT;
      END;
    
      FOR I IN V_ANIO_DESDE .. V_ANIO_HASTA LOOP
      
        -----------------------------------------------------------------------------------
        V_SQL := '  select id_inmueble,
         tc.id_tributo_contribuyente,
         id_persona,
         ID_TIPO_TRIBUTO,
         I.ID_TIPO_INMUEBLE,
        TC.FECHA_ALTA, -- ALTA D LAS RELACIONES CONLAS OBLIGACIONES
         TC.ID_JURISDICCION,
         tc.id_bien_trib_pgm

    from t_inmuebles i,
         t_tributos_contribuyentes tc
       
     where i.id_inmueble = tc.id_tributo_contribuyente ';
        IF V_ID_INMUEBLE IS NOT NULL THEN
          V_SQL := V_SQL || ' and tc.id_tributo_contribuyente = ''' ||
                   V_ID_INMUEBLE || '''';
        END IF;
        V_SQL := V_SQL || ' AND I.FEC_BAJA IS NULL
     and activo = 1
     AND I.ID_JURISDICCION = 4000
     AND I.ID_TIPO_INMUEBLE <> 99
    /* AND NOT EXISTS (SELECT 1
            FROM T_OBLIGACIONES
           WHERE id_tipos_tributos = 6
             and ID_TRIBUTO_CONTRIBUYENTE = ID_INMUEBLE
             and ano_cuota = ' || V_ANIO || ' --P_EJERCICIO_LIQ
             and estado_deuda <> ''CA''
             and fec_baja is null)*/
   order by 1 ';
        DBMS_OUTPUT.PUT_LINE(V_SQL);
        V_SQL_TOTAL := 'SELECT COUNT(*) FROM (' || V_SQL || ')';
      
        EXECUTE IMMEDIATE V_SQL_TOTAL
          INTO V_TOTAL;
      
        BEGIN
        
          PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                                 4000,
                                                 V_TOTAL,
                                                 1,
                                                 '',
                                                 'P');
        
        END;
      
        OPEN C_TRIBUTOS FOR V_SQL;
      
        LOOP
          FETCH C_TRIBUTOS
            INTO V_ID_IN,
                 V_ID_TRIBUTO_CONTRIB,
                 V_ID_PERSONA,
                 V_ID_TIPO_TRIBUTO,
                 V_ID_TIPO_INMUEBLE,
                 V_FEC_ALTA,
                 V_ID_JUR,
                 V_ID_BIEN_TRIB_PGM;
        
          EXIT WHEN C_TRIBUTOS%NOTFOUND;
        
          -- FOR R_TRIBUTOS IN C_TRIBUTOS LOOP
          V_ID_TRIBUTO_CONTRIBUYENTE := V_ID_TRIBUTO_CONTRIB;
          V_ID_JURISDICCION          := V_ID_JUR;
          V_FECHA_ALTA               := V_FEC_ALTA;
          -- V_ZONA:=R_TRIBUTOS.concepto_abreviado;
          -- COMO PUEDO TENER MAS DE UNA ZONA PARA ARMAR EL CURSOS DE LAS CUOTAS SOLO ME INTERESA LA ALGUNA 
          --POR ESO EL ROWNUM             
          SELECT IZ.CONCEPTO_ABREVIADO
            INTO V_ZONA
            FROM T_INMUEBLES_ZONAS_ANIO IZA, T_INMUEBLES_ZONAS IZ
           WHERE IZA.ID_ZONA = IZ.ID_ZONAS
             AND ID_INMUEBLE = V_ID_TRIBUTO_CONTRIB
             AND V_ANIO >= ANIO_DESDE
             AND V_ANIO <= ANIO_HASTA
             AND ROWNUM = 1;
        
          V_MONTO_ITEM := F_TASABASICA_INMUEBLE_MAL(V_ANIO,
                                                   V_ID_TRIBUTO_CONTRIB,
                                                   1);
          IF V_MONTO_ITEM <> 0 THEN
          
            FOR R_CUOTAS IN C_CUOTAS LOOP
              V_PASILLO_MONTO := 0;
            
              SELECT SQ_T_OBLIGACIONES_SIM.NEXTVAL
                INTO V_ID_OBLIGACION
                FROM DUAL;
            
              INSERT INTO T_OBLIGA_SIMU
                (ID_OBLIGACION,
                 ID_TRIBUTO_CONTRIBUYENTE,
                 ID_TIPOS_TRIBUTOS,
                 TIPO_PLAN,
                 TIPO_CUOTA,
                 ANO_CUOTA,
                 NRO_CUOTA,
                 ESTADO_DEUDA,
                 SITUACION_DEUDA,
                 FECHA_ESTADO_DEUDA,
                 FECHA_GENERACION_DEUDA,
                 FECHA_PRIMER_VENCIMIENTO,
                 FECHA_SEGUNDO_VENCIMIENTO,
                 FECHA_ACTUALIZACION_DEUDA,
                 CAPITAL_FACTURADO,
                 INTERESES_FACTURADOS,
                 FECHA_COBRADO,
                 FECHA_CONTABILIZACION,
                 ENTE_RECA,
                 NRO_OPERACION,
                 CAPITAL_COBRADO,
                 INTERESES_COBRADOS,
                 CAPITAL_FINANCIADO,
                 INTERESES_FINANCIADOS,
                 ID_PERSONA,
                 USR_ING,
                 FEC_ING,
                 USR_MOD,
                 FEC_MOD,
                 DIAS_MORA,
                 ID_JURISDICCION)
              VALUES
                (V_ID_OBLIGACION,
                 V_ID_TRIBUTO_CONTRIB,
                 V_ID_TIPO_TRIBUTO,
                 F_BUSCA_IDPLAN_DEVENGAMIENTO(V_ID_TIPO_TRIBUTO,
                                              V_ID_JURISDICCION,
                                              2025),-- ESTO LO HARCODEO PARA QUE FUNCIONE
                 'BA',
                 V_ANIO,
                 LPAD(R_CUOTAS.NRO_CUOTA, 3, 0),
                 'PP',
                 'DN',
                 SYSDATE,
                 SYSDATE,
                 R_CUOTAS.FECHA_PRIMER_VTO,
                 R_CUOTAS.FECHA_SEGUNDO_VTO,
                 SYSDATE,
                 0,
                 0,
                 NULL,
                 NULL,
                 '',
                 '',
                 0,
                 0,
                 0,
                 0,
                 V_ID_PERSONA,
                 P_USR_ING,
                 SYSDATE,
                 NULL,
                 NULL,
                 0,
                 V_ID_JURISDICCION);
            
              FOR R_CONCEPTOS IN C_CONCEPTOS LOOP
              
                    IF R_CONCEPTOS.CONCEPTO = 'ININBASI' THEN
                  V_MONTO_ITEM := F_TASABASICA_INMUEBLE_MAL(V_ANIO,
                                                           V_ID_TRIBUTO_CONTRIB,
                                                           R_CUOTAS.NRO_CUOTA);
                  IF R_CUOTAS.NRO_CUOTA = 0 THEN
                    
                  IF V_ANIO >= 2025 THEN
                    
                   V_MONTO_ITEM := V_MONTO_ITEM * 12;
                   
                         IF R_CUOTAS.DESC_PRIMER_VTO > 0  AND NOT (V_ID_TIPO_INMUEBLE = 1 AND V_ZONA IN ('A1', 'A2')) THEN
                     
                                V_MONTO_ITEM := V_MONTO_ITEM - (V_MONTO_ITEM * (R_CUOTAS.DESC_PRIMER_VTO / 100));  
                                
                                V_DESC_CUMPLIDOR := F_CUMPLIDOR_MAL(V_ID_TRIBUTO_CONTRIB,(V_ANIO - 1)) ;
                                
                                     IF V_DESC_CUMPLIDOR = 0 THEN -- 10%DE DESCUENTO SI ES CUMPLIDOR AL 31/12/ DEL A?O INMEDIATO ANTERIOR
                                        
                                          V_MONTO_ITEM := V_MONTO_ITEM - (V_MONTO_ITEM * ('0,10')); 
                                          
                                     END IF;                                                   
                         
                         END IF;
                   
                   ELSE
                     V_MONTO_ITEM         := V_MONTO_ITEM * 6;
                     END IF;
                    -- SI ES LA CERO ES LA CUOTA UNICA POR LO TANTO LA GENERO POR EL MONTO ANUAL
                  /*  V_MONTO_ITEM         := V_MONTO_ITEM *
                                            F_BUSCA_CUOTAS_A_DEVENGAR(V_ID_TIPO_TRIBUTO,
                                                                      V_ID_JURISDICCION,
                                                                      V_ANIO);*/ --LO COMENTE PARA LA COUTA 07/01/2024 --NICOLAS
                    V_IMPORTE_CUOTA_CERO := V_MONTO_ITEM;
                  END IF;
                
                  V_TASA_BASICA     := V_MONTO_ITEM;
                  V_TASA_BASICAPA   := V_MONTO_ITEM;
                  V_TASA_BASICA_ORI := V_MONTO_ITEM;
                  IF V_ZONA = 'RU' THEN
                    --- si es rural hago el 48 de la tasa basica 
                    V_TASA_RURAL         := V_TASA_BASICA /*+
                                            (V_TASA_BASICA * 0.48)*/;
                    V_MONTO_ITEM         := V_TASA_RURAL;
                    V_TASA_BASICA        := V_MONTO_ITEM;
                    V_TASA_BASICA_ORI    := V_MONTO_ITEM;
                    V_IMPORTE_CUOTA_CERO := V_MONTO_ITEM;
                  END IF;
                END IF;
              
                IF R_CONCEPTOS.CONCEPTO = 'ININADMI' THEN
                  V_MONTO_ITEM := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_CONCEPTO(V_TIPO_TIBUTO,
                                                                                V_ID_TRIBUTO_CONTRIB,
                                                                                R_CONCEPTOS.CONCEPTO,
                                                                                V_ANIO,
                                                                                P_MSG);
                
                  V_TASA_BASICA := V_TASA_BASICA + V_MONTO_ITEM; -- NUEVO PARA UNQUILLO %  (contribucion basica + fondo + gasto administrativo)
                END IF;
              
                IF V_MONTO_ITEM <> 0 THEN
                
                  SELECT SQ_T_OBLIGACIONES_DETALLE_SIM.NEXTVAL
                    INTO V_ID_OBLIGACION_DETALLE
                    FROM DUAL;
                
                  INSERT INTO T_OBLIG_DET_SIMU
                    (ID_OBLIGACION_DETALLE,
                     ID_OBLIGACION,
                     ID_TIPO_CONCEPTO,
                     MONTO_ITEM,
                     INTERESES_ITEM,
                     COBRADO_ITEM,
                     COBRADO_INTERESES_ITEM,
                     USR_ING,
                     FEC_ING,
                     USR_MOD,
                     FEC_MOD)
                  VALUES
                    (V_ID_OBLIGACION_DETALLE,
                     V_ID_OBLIGACION,
                     R_CONCEPTOS.ID_TIPO_CONCEPTO,
                     ROUND(DECODE(R_CONCEPTOS.IMPACTO,
                                  '-',
                                  V_MONTO_ITEM * (-1),
                                  V_MONTO_ITEM),
                           2),
                     0,
                     0,
                     0,
                     P_USR_ING,
                     SYSDATE,
                     NULL,
                     NULL);
                
                END IF;
              END LOOP;
              --------------------INSERTO LAS EXENCIONES------------------------                     
              BEGIN
              
                PKG_SIMULACIONES.PRC_INSERTA_EXENCION_SIM(V_ID_TIPO_TRIBUTO,
                                                          V_ID_TRIBUTO_CONTRIB,
                                                          V_ANIO,
                                                          R_CUOTAS.NRO_CUOTA,
                                                          P_MSG);
              
              EXCEPTION
                WHEN OTHERS THEN
                  /*                  DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
                                    DBMS_OUTPUT.PUT_LINE('Error at line: ' ||
                                                         DBMS_UTILITY.FORMAT_ERROR_STACK);
                  */
                  NULL;
              END;
            END LOOP;
          
            P_MSG := '';
          
          ELSE
            P_MSG := 'NO SE PUDO CALCULAR EL MONTO MENSUAL. ' ||
                     V_MONTO_ITEM;
            PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                                   4000,
                                                   V_TOTAL,
                                                   V_PROCESADAS,
                                                   P_MSG,
                                                   'E');
          END IF;
        
          --------------------------------------------------------------------
          V_PROCESADAS := V_PROCESADAS + 1;
        
          PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                                 4000,
                                                 V_TOTAL,
                                                 V_PROCESADAS,
                                                 '',
                                                 'P');
        END LOOP;
        V_ANIO := V_ANIO + 1;
      
      END LOOP;
    
    END IF;
  
    IF P_MSG IS NULL THEN
      --Si no hubo errores se termina el devengamiento 
      PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                             4000,
                                             V_TOTAL,
                                             V_PROCESADAS,
                                             P_MSG,
                                             'T');
    
    ELSE
      PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                             4000,
                                             V_TOTAL,
                                             V_PROCESADAS,
                                             P_MSG,
                                             'E');
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      P_MSG := 'Error en GENERA_DEVENGAMIENTO_ININ_MAL .Verifique: ' ||
               SQLERRM || V_ID_TRIBUTO_CONTRIBUYENTE;
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      DBMS_OUTPUT.PUT_LINE('Error at line: ' ||
                           DBMS_UTILITY.FORMAT_ERROR_STACK);
    
      PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                             4000,
                                             V_TOTAL,
                                             V_PROCESADAS,
                                             P_MSG,
                                             'E');
  END GENERA_DEVENGAMIENTO_ININ_MAL;

  FUNCTION F_TASABASICA_INMUEBLE_MAL(P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL,
                                    P_ID_TRIBUTO_CONTRIBUYENTE IN VARCHAR2 DEFAULT NULL,
                                    P_NRO_CUOTA                IN NUMBER)
    RETURN NUMBER IS
  
    V_VALOR_CUOTA_MENSUAL NUMBER(19, 5) := 0;
    V_ID_JURISDICCION     NUMBER(10);
    V_COEFICIENTE         NUMBER(10, 2);
    V_ALICUOTA            NUMBER(19, 2) := 0;
    V_VALOR_M2            NUMBER(19, 2) := 0;
    V_SUP_DESDE           NUMBER(19, 2) := 0;
    V_VALOR_CUOTA_ANUAL   NUMBER(19, 2) := 0;
    V_MONTO_MINIMO_ANUAL  NUMBER(19, 2) := 0;
    V_ID_ZONA             NUMBER(10);
    V_ID_TIPO_INMUEBLE    NUMBER(10);
    V_SUPERFICIE          NUMBER(19, 2) := 0;
    V_MONTO_RURAL         NUMBER(19, 2) := 0;
    V_NRO_CUOTA           VARCHAR2(6);
    V_BASE_IMPONIBLE_2024 NUMBER(19, 5) := 0; 
    V_BASE_IMPONIBLE_2025 NUMBER(19, 5) := 0;
  
    CURSOR C_INMUEBLE IS
    
      SELECT I.ID_INMUEBLE,          
             I.ID_TIPO_INMUEBLE,
             IT.DESCRIPCION,
             ESQUINA_MEDIAL, --ubicacion del terreno 04 = medial  / 01= esquina
           
             
             CAST(  (CASE
               WHEN SUBSTR(I.NOMENCLATURA, 17, 5) = '00000' THEN
                NVL(SUPERFICIE_TERRENO, 0)
               ELSE /*nvl(i.porcentaje_copropiedad,0) > 0  then*/
                (NVL(SUPERFICIE_TERRENO, 0) *
                (I.PORCENTAJE_COPROPIEDAD / 100))
             END) AS INT)SUPERFICIE_TERRENO,
             NVL(I.UNIDADES_LOCATIVAS, 0) UNIDADES_LOCATIVAS,
             PH, --- 0= no es un ph , 1= si es ph
             NVL(CANT_PH, 0) CANT_PH,
             I.ID_JURISDICCION,
             I.ID_TIPOSERVICIO,
             I.ID_CATASTRO,
             I.NRO_CUENTA,
             UNIDADES_LOCATIVAS_COM,
             UNIDADES_LOCATIVAS_HAB,
             IZ.ID_ZONA
      
        FROM T_INMUEBLES              I,
             T_INMUEBLES_ZONAS_ANIO   IZ,
             T_INMUEBLES_TIPOS        IT,
             T_INMUEBLES_TIPOSERVICIO ITS
       WHERE I.ID_INMUEBLE = IZ.ID_INMUEBLE
         AND I.ID_TIPO_INMUEBLE = IT.ID_TIPO_INMUEBLE
         AND I.ID_TIPOSERVICIO = ITS.ID_TIPOSERVICIO
         AND I.ID_TIPO_INMUEBLE <> 99
         AND I.ID_JURISDICCION = 4000 
         AND I.ID_INMUEBLE = P_ID_TRIBUTO_CONTRIBUYENTE;
  
    CURSOR C_ZONAS IS
      SELECT C.ALICUOTA, C.VALOR_M2, C.SUP_DESDE, C.SUP_HASTA
        FROM T_INMUEBLES_ESCALA_mal C
       WHERE C.ID_JURISDICCION = 4000
         AND C.ID_TIPO_INMUEBLE = V_ID_TIPO_INMUEBLE
         AND C.ID_ZONAS = V_ID_ZONA
         AND C.ANIO_EJERCICIO = P_EJERCICIO_LIQ;
  
    V_SENTENCIA VARCHAR2(100);
  BEGIN
    V_SENTENCIA := '  ALTER SESSION SET NLS_DATE_FORMAT=' || '''' ||
                   ' DD/MM/RRRR' || '''';
    EXECUTE IMMEDIATE V_SENTENCIA;
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';
  
    SELECT ID_JURISDICCION
      INTO V_ID_JURISDICCION
      FROM T_TRIBUTOS_CONTRIBUYENTES TC
     WHERE TC.ID_TRIBUTO_CONTRIBUYENTE = P_ID_TRIBUTO_CONTRIBUYENTE;
  
    FOR R_INMUEBLE IN C_INMUEBLE LOOP
      V_VALOR_CUOTA_ANUAL := NULL;
      V_ID_ZONA           := R_INMUEBLE.ID_ZONA;
      V_ID_TIPO_INMUEBLE  := R_INMUEBLE.ID_TIPO_INMUEBLE;
      -------------------
      IF R_INMUEBLE.ID_TIPO_INMUEBLE IN (1, 2) THEN
        SELECT C.ALICUOTA, C.VALOR_M2, C.SUP_DESDE
          INTO V_ALICUOTA, V_VALOR_M2, V_SUP_DESDE
          FROM T_INMUEBLES_ESCALA_MAL C
         WHERE C.ID_JURISDICCION = V_ID_JURISDICCION
           AND C.ID_TIPO_INMUEBLE = R_INMUEBLE.ID_TIPO_INMUEBLE
           AND C.ID_ZONAS = R_INMUEBLE.ID_ZONA
           AND C.ANIO_EJERCICIO = P_EJERCICIO_LIQ
           AND CAST(R_INMUEBLE.SUPERFICIE_TERRENO AS INT)
               BETWEEN C.SUP_DESDE AND
               C.SUP_HASTA;
               
           IF  R_INMUEBLE.ID_ZONA = '7' 
             AND  R_INMUEBLE.SUPERFICIE_TERRENO>100000 THEN
             V_VALOR_M2 := V_VALOR_M2 + (0.05*(R_INMUEBLE.SUPERFICIE_TERRENO -100000));
            END IF; 
               
             
           IF  R_INMUEBLE.ID_ZONA = '3' 
             AND  R_INMUEBLE.SUPERFICIE_TERRENO>100000 THEN
             V_VALOR_M2 := V_VALOR_M2 + (0.05*(R_INMUEBLE.SUPERFICIE_TERRENO -100000));
            END IF; 
               
               
               
      END IF;
    
      FOR R_ZONAS IN C_ZONAS LOOP
        IF R_INMUEBLE.SUPERFICIE_TERRENO >= R_ZONAS.SUP_DESDE AND
           R_INMUEBLE.SUPERFICIE_TERRENO <= R_ZONAS.SUP_HASTA THEN
           
           
         V_VALOR_CUOTA_MENSUAL := /*R_INMUEBLE.SUPERFICIE_TERRENO **/ V_VALOR_M2;
       
        END IF;
      END LOOP;
     
   
   --aca agregamos if de los calculos
        
       
    
    END LOOP;
  
    RETURN V_VALOR_CUOTA_MENSUAL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END F_TASABASICA_INMUEBLE_MAL;
  
  FUNCTION F_TASABASICA_CECE_MAL(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                 P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL --A= ALQUILER / M= MANTENIMIENTO
                                 --  P_MSG             OUT VARCHAR2
                                 ) RETURN NUMBER IS
  
    V_VALOR               NUMBER(19, 2);
    V_MONTO_CUOTA_MENSUAL NUMBER(19, 2);
    V_ID_CEME_TIPO        NUMBER(10);
    V_ID_TIPO_ALTA        NUMBER(10);
    V_FECHA_VENCE         NUMBER;
    V_ID_JURISDICCION     NUMBER;
    V_FECHA_ACTUAL        NUMBER := TO_CHAR(SYSDATE, 'yyyy');
    V_MESES_ATRASO        NUMBER := 0;
  
  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';
    V_FECHA_VENCE := NULL;
  
    SELECT CE.ID_CEME_TIPO,
           /*     (SELECT CTV.VALOR
            FROM T_CEMENTERIO_CATE_VALOR CTV
           WHERE CTV.ID_CEME_CATEGORIA = CE.ID_CEME_CATEGORIA
             AND CE.ID_JURISDICCION = CTV.ID_JURISDICCION
             AND CTV.EJERCICIO = 2024) VALOR,*/
           CTV.VALOR,
           ID_TIPO_ALTA,
           TO_CHAR(CE.FECHA_VENCE, 'yyyy'),
           CE.ID_JURISDICCION
      INTO V_ID_CEME_TIPO,
           V_VALOR,
           V_ID_TIPO_ALTA,
           V_FECHA_VENCE,
           V_ID_JURISDICCION
      FROM T_CEMENTERIO CE
      JOIN T_CEMENTERIO_TIPOS TCT
        ON CE.ID_CEME_TIPO = TCT.ID_CEME_TIPO
      JOIN T_CEMENTERIO_TIPOS_VALOR CTV
        ON CTV.ID_CEME_TIPO = TCT.ID_CEME_TIPO
     WHERE ID_CEMENTERIO = P_ID_TRIBUTO_CONTRIBUYENTE
       AND CE.FEC_BAJA IS NULL
       AND CTV.ID_JURISDICCION = 4000
       AND CTV.EJERCICIO = P_EJERCICIO_LIQ;
  
    V_MONTO_CUOTA_MENSUAL := V_VALOR /*/ 3*/;
  
    RETURN V_MONTO_CUOTA_MENSUAL;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
      --   p_msg := 'Error en F_GENERA_TASABASICA_CECE .Verifique: ' ||sqlerrm;
  
  END F_TASABASICA_CECE_MAL;
  
   PROCEDURE GENERA_DEVENGAMIENTO_CECE_MAL(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                            P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL,
                                            P_USR_ING                  IN VARCHAR2,
                                            P_CUOTAS                   IN VARCHAR2 DEFAULT NULL,
                                            P_MODO                     IN VARCHAR2,
                                            P_MSG                      OUT VARCHAR2) IS
    V_ANIO                     NUMBER(4);
    V_TIPO_TIBUTO              VARCHAR2(10) := 'CECE';
    V_MONTO_ITEM               NUMBER(19, 5) := 0;
    V_MONTO_ALQUILER           NUMBER(19, 5) := 0;
    V_MONTO_MANTENIMIENTO      NUMBER(19, 5) := 0;
    V_ID_OBLIGACION            VARCHAR2(10);
    V_ID_OBLIGACION_DETALLE    VARCHAR2(10);
    V_TASA_BASICA              NUMBER(19, 5) := 0;
    P_ID_COMPROBANTE           NUMBER(10);
    V_FECHA_ALTA               DATE;
    V_ID_JURISDICCION          NUMBER(10);
    V_CODIGO_BARRA             VARCHAR2(100);
    V_ID_TRIBUTO_CONTRIBUYENTE VARCHAR2(10);
    V_CANT_FALLECIDOS          NUMBER;
    V_SENTENCIA                VARCHAR2(100);
    V_IMPORTE_CUOTA_CERO       NUMBER;
    V_TIENE_OBLIGACIONES       NUMBER;
    V_CONTADOR_ROLLBACK        NUMBER := 0;
    V_ANIO_ALTA                NUMBER;
    V_MENSAJE                  VARCHAR2(1000);
    V_ID_CONTRIBUYENTE         VARCHAR2(25);
    V_TIENE_CUOTA              NUMBER;
    V_OBLIGACION               NUMBER;
    V_NROCUOTA                 NUMBER;
    ----------------- barra carga ----------------------
    V_CONTADOR        NUMBER := 0;
    V_PROCESADAS      NUMBER := 0;
    V_TOTAL           NUMBER := 0;
    V_MENSAJE_ERROR   VARCHAR2(1000);
    V_ID_TIPO_TRIBUTO NUMBER := 4;
    
    V_TIENE_CERO_PAGADA       NUMBER; --NICOLAS 08/04/2025
  
    CURSOR C_TRIBUTOS IS
    
      SELECT TC.ID_TRIBUTO_CONTRIBUYENTE,
             TC.ID_PERSONA,
             NRO_CUENTA,
             TC.ID_TIPO_TRIBUTO,
             TC.FECHA_ALTA,
             CLAVE_CEME_CPAR,
             CE.ID_JURISDICCION,
             ID_TIPO_ALTA
        FROM T_CEMENTERIO CE, T_TRIBUTOS_CONTRIBUYENTES TC
       WHERE CE.ID_CEMENTERIO = TC.ID_TRIBUTO_CONTRIBUYENTE
         AND CE.FEC_BAJA IS NULL
         AND (TC.ID_TRIBUTO_CONTRIBUYENTE = V_ID_CONTRIBUYENTE OR
             V_ID_CONTRIBUYENTE IS NULL)
         AND 1 = F_CORRESPONDE_DEVENGO_CECE(V_ID_CONTRIBUYENTE,
                                            V_ID_JURISDICCION,
                                            V_ANIO)
         AND CE.ID_JURISDICCION = V_ID_JURISDICCION
       ORDER BY 1;
  
    CURSOR C_CUOTAS IS
    
      SELECT VTO.NRO_CUOTA, VTO.FECHA_PRIMER_VTO, VTO.FECHA_SEGUNDO_VTO,  VTO.DESC_PRIMER_VTO/*,
              VTO.INCREMENTO,
              VTO.ACUMULADO,
              VTO.ACTUALIZA*/
        FROM T_VENCIMIENTOS VTO, T_TIPOS_TRIBUTOS TT
       WHERE VTO.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND TT.TIPO_TRIBUTO = V_TIPO_TIBUTO
         AND N_TIPO = 'CUOTA'
         AND (VTO.NRO_CUOTA IN
             (SELECT TO_NUMBER(REGEXP_SUBSTR(P_CUOTAS, '[^,]+', 1, LEVEL)) AS LIST
                 FROM DUAL
               CONNECT BY REGEXP_SUBSTR(P_CUOTAS, '[^,]+', 1, LEVEL) IS NOT NULL))
         AND VTO.EJERCICIO = V_ANIO
         AND (VTO.ID_JURISDICCION = V_ID_JURISDICCION OR
             V_ID_JURISDICCION IS NULL)
         AND VTO.FECHA_PRIMER_VTO > V_FECHA_ALTA
       ORDER BY NRO_CUOTA;
       
       
    CURSOR C_CONCEPTOS IS
    
      SELECT TC.ID_TIPO_CONCEPTO,
             TC.CONCEPTO,
             TC.DESCRIPCION,
             TC.IMPACTO,
             TC.PORCENTAJE,
             TC.VALOR,
             TC.OBJETO_REF,
             MASIVO
        FROM T_TIPOS_CONCEPTOS TC, T_TIPOS_TRIBUTOS TT
       WHERE TC.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND TT.TIPO_TRIBUTO = V_TIPO_TIBUTO
         AND OBJETO_REF IS NOT NULL
         AND TC.FEC_BAJA IS NULL
         AND (TC.ID_JURISDICCION = V_ID_JURISDICCION OR
             V_ID_JURISDICCION IS NULL)
       ORDER BY ORDEN;
       
         CURSOR C_INCREMENTOS IS
    
      SELECT NRO_CUOTA, FECHA_PRIMER_VTO, FECHA_SEGUNDO_VTO/*, VTO.INCREMENTO,VTO.ACUMULADO,VTO.ACTUALIZA*/
        FROM T_VENCIMIENTOS VTO, T_TIPOS_TRIBUTOS TT
       WHERE VTO.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND TT.TIPO_TRIBUTO = V_TIPO_TIBUTO
         AND N_TIPO = 'CUOTA'
         AND VTO.NRO_CUOTA <= V_NROCUOTA
         AND VTO.NRO_CUOTA <> '000'
        -- AND VTO.INCREMENTO > 0
         AND VTO.EJERCICIO = V_ANIO
         AND (VTO.ID_JURISDICCION = V_ID_JURISDICCION OR
             V_ID_JURISDICCION IS NULL)
         AND VTO.FECHA_PRIMER_VTO > V_FECHA_ALTA
         AND VTO.FEC_BAJA IS NULL
         AND VTO.USR_BAJA IS NULL
       ORDER BY NRO_CUOTA;
  
  BEGIN
    V_ANIO                := P_EJERCICIO_LIQ;
    V_CANT_FALLECIDOS     := 0;
    V_MONTO_MANTENIMIENTO := 0;
    V_ID_JURISDICCION     := 4000;
  
    IF P_ID_TRIBUTO_CONTRIBUYENTE = 'null' THEN
      V_ID_CONTRIBUYENTE := NULL;
    ELSE
      V_ID_CONTRIBUYENTE := P_ID_TRIBUTO_CONTRIBUYENTE;
    END IF;
  
    V_SENTENCIA := '  ALTER SESSION SET NLS_DATE_FORMAT=' || '''' ||
                   ' DD/MM/RRRR' || '''';
    EXECUTE IMMEDIATE V_SENTENCIA;
  
    ----------------------------- PARA LA BARRA DE CARGA ---------------------------
  
    SELECT COUNT(*)
      INTO V_TOTAL
      FROM T_CEMENTERIO CE, T_TRIBUTOS_CONTRIBUYENTES TC
     WHERE CE.ID_CEMENTERIO = TC.ID_TRIBUTO_CONTRIBUYENTE
       AND CE.FEC_BAJA IS NULL
       AND (TC.ID_TRIBUTO_CONTRIBUYENTE = V_ID_CONTRIBUYENTE OR
           V_ID_CONTRIBUYENTE IS NULL)
       AND 1 = F_CORRESPONDE_DEVENGO_CECE(V_ID_CONTRIBUYENTE, 4000, V_ANIO)
       AND CE.ID_JURISDICCION = 4000;
  
    IF P_MODO = 'G' THEN
    
      FOR R_TRIBUTOS IN C_TRIBUTOS LOOP
      
        /*        IF R_TRIBUTOS.ID_TIPO_ALTA <> 24 THEN*/
        -- NO ES UNA COMPRA
        V_ID_JURISDICCION          := R_TRIBUTOS.ID_JURISDICCION;
        V_FECHA_ALTA               := R_TRIBUTOS.FECHA_ALTA;
        V_ID_TRIBUTO_CONTRIBUYENTE := R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE;
      
        V_MONTO_ALQUILER := F_TASABASICA_CECE_MAL(V_ID_TRIBUTO_CONTRIBUYENTE,
                                                  V_ANIO); ---POR MANTENIMIENTO
      
        V_MONTO_ITEM := V_MONTO_ALQUILER + V_MONTO_MANTENIMIENTO;
        
      /*  SELECT COUNT(TOB.ID_OBLIGACION) --NICOLAS 09/04/2025
              INTO V_TIENE_CERO_PAGADA
              FROM T_OBLIGACIONES TOB
             WHERE TOB.ID_TRIBUTO_CONTRIBUYENTE = V_ID_TRIBUTO_CONTRIBUYENTE
               AND TOB.ANO_CUOTA = V_ANIO
               AND TOB.ID_JURISDICCION = 4000
               AND TOB.NRO_CUOTA = '000'
               AND TOB.FEC_BAJA IS NULL
               AND TOB.USR_BAJA IS NULL
               AND TOB.ESTADO_DEUDA NOT IN ('PP','CA');
               
               
               IF V_TIENE_CERO_PAGADA > 0 THEN
                 V_MONTO_ITEM := 0;
               END IF;*/
        
        
      
        IF V_MONTO_ITEM <> 0 THEN
        
          FOR R_CUOTAS IN C_CUOTAS LOOP
            
          V_NROCUOTA := R_CUOTAS.NRO_CUOTA;
          
          SELECT COUNT(TOB.ID_OBLIGACION)
              INTO V_TIENE_OBLIGACIONES
              FROM T_OBLIGACIONES TOB
             WHERE TOB.ID_TRIBUTO_CONTRIBUYENTE = V_ID_TRIBUTO_CONTRIBUYENTE
               AND TOB.ANO_CUOTA = V_ANIO
               AND TOB.ID_JURISDICCION = 4000
               AND TOB.NRO_CUOTA = R_CUOTAS.NRO_CUOTA
               AND TOB.FEC_BAJA IS NULL
               AND TOB.USR_BAJA IS NULL
               AND TOB.ESTADO_DEUDA NOT IN ('PP','CA');
               
             /*  SELECT COUNT(TOB.ID_OBLIGACION)
              INTO V_TIENE_CERO_PAGADA
              FROM T_OBLIGACIONES TOB
             WHERE TOB.ID_TRIBUTO_CONTRIBUYENTE = V_ID_TRIBUTO_CONTRIBUYENTE
               AND TOB.ANO_CUOTA = V_ANIO
               AND TOB.ID_JURISDICCION = 4000
               AND TOB.NRO_CUOTA = '000'
               AND TOB.FEC_BAJA IS NULL
               AND TOB.USR_BAJA IS NULL
               AND TOB.ESTADO_DEUDA NOT IN ('PP','CA');
               
               IF V_TIENE_CERO_PAGADA > 0 THEN
              V_CONTADOR_ROLLBACK := V_CONTADOR_ROLLBACK + 1;
              P_MSG               := '. La cuenta tiene couta cero pagada.'||V_ID_TRIBUTO_CONTRIBUYENTE;
              CONTINUE;
              end if;*/
          
            IF V_TIENE_OBLIGACIONES > 0 THEN
              V_CONTADOR_ROLLBACK := V_CONTADOR_ROLLBACK + 1;
              P_MSG               := '. Ya hay obligaciones pagadas para el periodo seleccionado'||V_ID_TRIBUTO_CONTRIBUYENTE;
              CONTINUE;
              
               
              
              ELSE            
                 V_OBLIGACION := 0;
            SELECT  count(distinct (O.ID_OBLIGACION)) 
            INTO V_OBLIGACION
            FROM T_OBLIGACIONES O
            JOIN T_OBLIGACIONES_DETALLE OD
            ON O.ID_OBLIGACION = OD.ID_OBLIGACION 
            WHERE O.ID_TRIBUTO_CONTRIBUYENTE = V_ID_TRIBUTO_CONTRIBUYENTE
            AND O.ID_JURISDICCION = 4000
            AND O.ESTADO_DEUDA = 'PP'
            AND O.ANO_CUOTA = V_ANIO
            AND O.NRO_CUOTA = R_CUOTAS.NRO_CUOTA
            AND O.ID_OBLIGACION  NOT IN (SELECT OD.ID_OBLIGACION  
                                         FROM T_OBLIGACIONES_DETALLE OD
                                         WHERE OD.ID_OBLIGACION = O.ID_OBLIGACION 
                                         AND OD.ID_TIPO_CONCEPTO IN (SELECT TC.ID_TIPO_CONCEPTO
                                                                     FROM T_TIPOS_CONCEPTOS TC
                                                                     WHERE TC.ID_TIPO_CONCEPTO = OD.ID_TIPO_CONCEPTO 
                                                                     AND TC.ID_TIPO_TRIBUTO = 4
                                                                     AND TC.ID_JURISDICCION  = 4000
                                                                     AND TC.DESCRIPCION LIKE 'AJUSTE DE LIQUIDACI%'))
            AND O.FEC_BAJA IS NULL
            AND O.USR_BAJA IS NULL;
            

            IF V_OBLIGACION > 0 THEN 
            UPDATE T_OBLIGACIONES OBL
               SET OBL.FEC_BAJA     = SYSDATE,
                   OBL.USR_BAJA     = P_USR_ING,
                   OBL.ESTADO_DEUDA = 'CA'
             WHERE OBL.ID_TRIBUTO_CONTRIBUYENTE = V_ID_TRIBUTO_CONTRIBUYENTE
               AND OBL.ANO_CUOTA = V_ANIO
               AND OBL.NRO_CUOTA = LPAD(R_CUOTAS.NRO_CUOTA,3,0)
               AND OBL.ESTADO_DEUDA = 'PP'
               AND OBL.ID_JURISDICCION = 4000
               AND OBL.FEC_BAJA IS NULL
               AND OBL.USR_BAJA IS NULL;            
            END IF;
            END IF;   
          
            SELECT SQ_T_OBLIGACIONES.NEXTVAL
              INTO V_ID_OBLIGACION
              FROM DUAL;
          
            INSERT INTO T_OBLIGACIONES
              (ID_OBLIGACION,
               ID_TRIBUTO_CONTRIBUYENTE,
               ID_TIPOS_TRIBUTOS,
               TIPO_PLAN,
               TIPO_CUOTA,
               ANO_CUOTA,
               NRO_CUOTA,
               ESTADO_DEUDA,
               SITUACION_DEUDA,
               FECHA_ESTADO_DEUDA,
               FECHA_GENERACION_DEUDA,
               FECHA_PRIMER_VENCIMIENTO,
               FECHA_SEGUNDO_VENCIMIENTO,
               FECHA_ACTUALIZACION_DEUDA,
               CAPITAL_FACTURADO,
               INTERESES_FACTURADOS,
               FECHA_COBRADO,
               FECHA_CONTABILIZACION,
               ENTE_RECA,
               NRO_OPERACION,
               CAPITAL_COBRADO,
               INTERESES_COBRADOS,
               CAPITAL_FINANCIADO,
               INTERESES_FINANCIADOS,
               ID_PERSONA,
               USR_ING,
               FEC_ING,
               USR_MOD,
               FEC_MOD,
               DIAS_MORA,
               ID_JURISDICCION)
            VALUES
              (V_ID_OBLIGACION,
               V_ID_TRIBUTO_CONTRIBUYENTE,
               R_TRIBUTOS.ID_TIPO_TRIBUTO,
               14, -- TIPO_PLAN_POR DEFECTO 2 ctas
               DECODE(P_EJERCICIO_LIQ, 1, 'MA', 'AL'), --'BA',
               V_ANIO,
               LPAD(R_CUOTAS.NRO_CUOTA, 3, 0),
               'PP',
               'DN',
               SYSDATE,
               SYSDATE,
               R_CUOTAS.FECHA_PRIMER_VTO,
               R_CUOTAS.FECHA_SEGUNDO_VTO,
               SYSDATE,
               0,
               0,
               NULL,
               NULL,
               '',
               '',
               0,
               0,
               0,
               0,
               R_TRIBUTOS.ID_PERSONA,
               P_USR_ING,
               SYSDATE,
               NULL,
               NULL,
               0,
               V_ID_JURISDICCION);
          
            V_PROCESADAS := V_PROCESADAS + 1;
          
            PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(R_TRIBUTOS.ID_TIPO_TRIBUTO,
                                                   4000,
                                                   V_TOTAL,
                                                   V_PROCESADAS,
                                                   '',
                                                   'P');
          
            V_TASA_BASICA        := 0;
            V_MONTO_ITEM         := 0;
            V_IMPORTE_CUOTA_CERO := 0;
            FOR R_CONCEPTOS IN C_CONCEPTOS LOOP
            
              IF R_CONCEPTOS.CONCEPTO = 'CECEBASI' THEN
                -- mantenimiento
              
                V_MONTO_ITEM := F_TASABASICA_CECE_MAL(V_ID_TRIBUTO_CONTRIBUYENTE,
                                                      V_ANIO /*, p_msg*/);
                                                      
              /* IF P_EJERCICIO_LIQ >= 2024 THEN
                                                                                        
                IF R_CUOTAS.ACTUALIZA = 'N' THEN                  
                       
                    FOR R_INCREMENTOS IN C_INCREMENTOS LOOP
                      
                    V_MONTO_ITEM := V_MONTO_ITEM + (V_MONTO_ITEM * (R_INCREMENTOS.INCREMENTO / 100));
                    
                    END LOOP;  
                    
                 ELSE 
                    V_MONTO_ITEM :=V_MONTO_ITEM + (V_MONTO_ITEM * (R_CUOTAS.ACUMULADO / 100)); 
                 END IF;
                    
               END IF;*/
                                                      
                                                      
              /*  IF R_CUOTAS.NRO_CUOTA = 0 THEN
                  -- SI ES LA CERO ES LA CUOTA UNICA POR LO TANTO LA GENERO POR EL MONTO ANUAL
                  V_MONTO_ITEM         := ROUND(V_MONTO_ITEM *
                                                F_BUSCA_CUOTAS_A_DEVENGAR(R_TRIBUTOS.ID_TIPO_TRIBUTO,
                                                                          V_ID_JURISDICCION,
                                                                          V_ANIO));
                  V_IMPORTE_CUOTA_CERO := V_MONTO_ITEM;
                END IF;*/
              END IF;
            
              IF R_CONCEPTOS.CONCEPTO = 'CECECTAU' THEN
                --SI ES CUOTA 0 CALCULA EL DESCUENTO
                IF R_CUOTAS.NRO_CUOTA = 0 THEN
                  V_MONTO_ITEM := PKG_DEVENGAMIENTO.F_GENERA_DTO_CTAUNICA(V_TIPO_TIBUTO,
                                                                          R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
                                                                          V_IMPORTE_CUOTA_CERO,
                                                                          V_ANIO);
                ELSE
                  V_MONTO_ITEM := 0;
                END IF;
              END IF;
              
            /*  IF R_CONCEPTOS.CONCEPTO = 'CECECOMP' THEN
                  V_MONTO_ITEM := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_CONCEPTO(V_TIPO_TIBUTO,
                                                                                R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
                                                                                R_CONCEPTOS.CONCEPTO,
                                                                                V_ANIO,
                                                                                P_MSG);
                
                  V_TASA_BASICA := V_TASA_BASICA + V_MONTO_ITEM; -- NUEVO PARA UNQUILLO %  (contribucion basica + fondo + gasto administrativo)
                END IF;*/
            
              -- NO TIENE DESCUENTO AL DIA
            
              IF R_CONCEPTOS.CONCEPTO = 'CECECOMP' THEN
                V_MONTO_ITEM := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_GASTOS_ADM(V_TIPO_TIBUTO,
                                                                                V_ID_TRIBUTO_CONTRIBUYENTE,
                                                                                V_ANIO,
                                                                                P_MSG);
              END IF;
            
              IF V_MONTO_ITEM <> 0 THEN
                SELECT SQ_T_OBLIGACIONES_DETALLE.NEXTVAL
                  INTO V_ID_OBLIGACION_DETALLE
                  FROM DUAL;
              
                INSERT INTO T_OBLIGACIONES_DETALLE
                  (ID_OBLIGACION_DETALLE,
                   ID_OBLIGACION,
                   ID_TIPO_CONCEPTO,
                   MONTO_ITEM,
                   --financiacion_item,
                   INTERESES_ITEM,
                   --  iva_item,
                   COBRADO_ITEM,
                   COBRADO_INTERESES_ITEM,
                   USR_ING,
                   FEC_ING,
                   USR_MOD,
                   FEC_MOD)
                VALUES
                  (V_ID_OBLIGACION_DETALLE,
                   V_ID_OBLIGACION,
                   R_CONCEPTOS.ID_TIPO_CONCEPTO,
                   DECODE(R_CONCEPTOS.IMPACTO,
                          '-',
                          V_MONTO_ITEM * (-1),
                          V_MONTO_ITEM),
                   --  0,
                   0,
                   --   0,
                   0,
                   0,
                   USER,
                   SYSDATE,
                   NULL,
                   NULL);
              
              END IF;
              V_MONTO_ITEM := 0;
            
            END LOOP; -- en for conceptos
          
            -- genero la tabla comporbantes que es el reporte de liquidacion
            PKG_TRIBUTOS_CONTRIBUYENTES.GENERA_COMPROBANTES_CAB(R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
                                                                1, -- masivo
                                                                0,
                                                                P_ID_COMPROBANTE,
                                                                P_MSG);
            PKG_TRIBUTOS_CONTRIBUYENTES.GENERA_COMPROBANTES_DET(P_ID_COMPROBANTE,
                                                                1,
                                                                V_ID_OBLIGACION,
                                                                0,
                                                                P_MSG);
          
            SELECT F_GENERA_CODIGO_BARRA(P_ID_COMPROBANTE)
              INTO V_CODIGO_BARRA
              FROM DUAL;
            UPDATE T_COMPROBANTES C
               SET COGIDO_BARRA_BANCO  = V_CODIGO_BARRA,
                   MONTO_DEUDA_A_PAGAR =
                   (SELECT SUM(MONTO_DEUDA_ORIG + INTERESES)
                      FROM T_COMPROBANTES_DETALLE
                     WHERE ID_COMPROBANTE = P_ID_COMPROBANTE)
             WHERE ID_COMPROBANTE = P_ID_COMPROBANTE;
          END LOOP;
          IF V_CONTADOR_ROLLBACK > 0 THEN
            --ROLLBACK;
           --EXIT;
           CONTINUE;
          END IF;
        ELSE
          P_MSG := 'NO SE PUDO CALCULAR EL MONTO MENSUAL. ' || V_MONTO_ITEM;
        
          PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(R_TRIBUTOS.ID_TIPO_TRIBUTO,
                                                 4000,
                                                 V_TOTAL,
                                                 V_PROCESADAS,
                                                 P_MSG,
                                                 'E');
        END IF;
        /*        END IF;*/
      END LOOP;
    ELSE
    
      BEGIN
        DELETE FROM T_OBLIG_DET_SIMU;
        DELETE FROM T_OBLIGA_SIMU;
        COMMIT;
      
      EXCEPTION
        WHEN OTHERS THEN
        
          P_MSG := 'Error en GENERA_DEVENGAMIENTO_CECE_DES_C .Verifique: ' ||
                   SQLERRM || V_ID_TRIBUTO_CONTRIBUYENTE;
      END;
    
      FOR R_TRIBUTOS IN C_TRIBUTOS LOOP
      
        V_ID_JURISDICCION          := R_TRIBUTOS.ID_JURISDICCION;
        V_FECHA_ALTA               := R_TRIBUTOS.FECHA_ALTA;
        V_ID_TRIBUTO_CONTRIBUYENTE := R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE;
      
        V_MONTO_ALQUILER := F_TASABASICA_CECE_MAL(V_ID_TRIBUTO_CONTRIBUYENTE,
                                                  V_ANIO); ---POR MANTENIMIENTO
      
        V_MONTO_ITEM := V_MONTO_ALQUILER + V_MONTO_MANTENIMIENTO;
        
         SELECT COUNT(TOB.ID_OBLIGACION) --NICOLAS 09/04/2025 --ESTO SI FUNCIONA PERO TE TIRA UN MENSAJE DE QUE NO SE PUDO CALCULAR LA COUTA TAL. Y POR PANTALLA NO TE DEJA SACAR LA SIM
              INTO V_TIENE_CERO_PAGADA
              FROM T_OBLIGACIONES TOB
             WHERE TOB.ID_TRIBUTO_CONTRIBUYENTE = V_ID_TRIBUTO_CONTRIBUYENTE
               AND TOB.ANO_CUOTA = V_ANIO
               AND TOB.ID_JURISDICCION = 4000
               AND TOB.NRO_CUOTA = '000'
               AND TOB.FEC_BAJA IS NULL
               AND TOB.USR_BAJA IS NULL
               AND TOB.ESTADO_DEUDA NOT IN ('PP','CA');
               
               
               IF V_TIENE_CERO_PAGADA > 0 THEN
                 V_MONTO_ITEM := 0;
               END IF;
      
        IF V_MONTO_ITEM <> 0 THEN
        
          FOR R_CUOTAS IN C_CUOTAS LOOP
            
               /*SELECT COUNT(TOB.ID_OBLIGACION)
              INTO V_TIENE_CERO_PAGADA
              FROM T_OBLIGACIONES TOB
             WHERE TOB.ID_TRIBUTO_CONTRIBUYENTE = V_ID_TRIBUTO_CONTRIBUYENTE
               AND TOB.ANO_CUOTA = V_ANIO
               AND TOB.ID_JURISDICCION = 4000
               AND TOB.NRO_CUOTA = '000'
               AND TOB.FEC_BAJA IS NULL
               AND TOB.USR_BAJA IS NULL
               AND TOB.ESTADO_DEUDA NOT IN ('PP','CA');
               
               IF V_TIENE_CERO_PAGADA > 0 THEN
              V_CONTADOR_ROLLBACK := V_CONTADOR_ROLLBACK + 1;
              P_MSG               := '. La cuenta tiene couta cero pagada.'||V_ID_TRIBUTO_CONTRIBUYENTE;
              CONTINUE;
              end if;*/
          
            V_NROCUOTA := R_CUOTAS.NRO_CUOTA;
          
            SELECT SQ_T_OBLIGACIONES_SIM.NEXTVAL
              INTO V_ID_OBLIGACION
              FROM DUAL;
          
            INSERT INTO T_OBLIGA_SIMU
              (ID_OBLIGACION,
               ID_TRIBUTO_CONTRIBUYENTE,
               ID_TIPOS_TRIBUTOS,
               TIPO_PLAN,
               TIPO_CUOTA,
               ANO_CUOTA,
               NRO_CUOTA,
               ESTADO_DEUDA,
               SITUACION_DEUDA,
               FECHA_ESTADO_DEUDA,
               FECHA_GENERACION_DEUDA,
               FECHA_PRIMER_VENCIMIENTO,
               FECHA_SEGUNDO_VENCIMIENTO,
               FECHA_ACTUALIZACION_DEUDA,
               CAPITAL_FACTURADO,
               INTERESES_FACTURADOS,
               FECHA_COBRADO,
               FECHA_CONTABILIZACION,
               ENTE_RECA,
               NRO_OPERACION,
               CAPITAL_COBRADO,
               INTERESES_COBRADOS,
               CAPITAL_FINANCIADO,
               INTERESES_FINANCIADOS,
               ID_PERSONA,
               USR_ING,
               FEC_ING,
               USR_MOD,
               FEC_MOD,
               DIAS_MORA,
               ID_JURISDICCION)
            VALUES
              (V_ID_OBLIGACION,
               V_ID_TRIBUTO_CONTRIBUYENTE,
               R_TRIBUTOS.ID_TIPO_TRIBUTO,
               14, -- TIPO_PLAN_POR DEFECTO 2 ctas
               DECODE(P_EJERCICIO_LIQ, 1, 'MA', 'AL'), --'BA',
               V_ANIO,
               LPAD(R_CUOTAS.NRO_CUOTA, 3, 0),
               'PP',
               'DN',
               SYSDATE,
               SYSDATE,
               R_CUOTAS.FECHA_PRIMER_VTO,
               R_CUOTAS.FECHA_SEGUNDO_VTO,
               SYSDATE,
               0,
               0,
               NULL,
               NULL,
               '',
               '',
               0,
               0,
               0,
               0,
               R_TRIBUTOS.ID_PERSONA,
               P_USR_ING,
               SYSDATE,
               NULL,
               NULL,
               0,
               V_ID_JURISDICCION);
          
            V_PROCESADAS := V_PROCESADAS + 1;
          
            PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(R_TRIBUTOS.ID_TIPO_TRIBUTO,
                                                   4000,
                                                   V_TOTAL,
                                                   V_PROCESADAS,
                                                   '',
                                                   'P');
          
            V_TASA_BASICA        := 0;
            V_MONTO_ITEM         := 0;
            V_IMPORTE_CUOTA_CERO := 0;
            FOR R_CONCEPTOS IN C_CONCEPTOS LOOP
            
              IF R_CONCEPTOS.CONCEPTO = 'CECEMANT' THEN
                -- mantenimiento
              
                V_MONTO_ITEM := F_TASABASICA_CECE_MAL(V_ID_TRIBUTO_CONTRIBUYENTE,
                                                      V_ANIO /*, p_msg*/);                                                     
                
                                                   
              /* IF P_EJERCICIO_LIQ >= 2024 THEN
                                                                                        
                IF R_CUOTAS.ACTUALIZA = 'N' THEN                  
                       
                    FOR R_INCREMENTOS IN C_INCREMENTOS LOOP
                      
                    V_MONTO_ITEM := V_MONTO_ITEM + (V_MONTO_ITEM * (R_INCREMENTOS.INCREMENTO / 100));
                    
                    END LOOP;  
                    
                 ELSE 
                    V_MONTO_ITEM :=V_MONTO_ITEM + (V_MONTO_ITEM * (R_CUOTAS.ACUMULADO / 100)); 
                 END IF;
                    
               END IF;*/
                
                
                
                IF R_CUOTAS.NRO_CUOTA = 0 THEN
                  -- SI ES LA CERO ES LA CUOTA UNICA POR LO TANTO LA GENERO POR EL MONTO ANUAL
                  V_MONTO_ITEM         := ROUND(V_MONTO_ITEM *
                                                F_BUSCA_CUOTAS_A_DEVENGAR(R_TRIBUTOS.ID_TIPO_TRIBUTO,
                                                                          V_ID_JURISDICCION,
                                                                          V_ANIO));
                  V_IMPORTE_CUOTA_CERO := V_MONTO_ITEM; 
                END IF;
              END IF;
            
              IF R_CONCEPTOS.CONCEPTO = 'CECECTAU' THEN
                --SI ES CUOTA 0 CALCULA EL DESCUENTO
                IF R_CUOTAS.NRO_CUOTA = 0 THEN
                  V_MONTO_ITEM := PKG_DEVENGAMIENTO.F_GENERA_DTO_CTAUNICA(V_TIPO_TIBUTO,
                                                                          R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
                                                                          V_IMPORTE_CUOTA_CERO,
                                                                          V_ANIO);
                ELSE
                  V_MONTO_ITEM := 0;
                END IF;
              END IF;
            
              -- NO TIENE DESCUENTO AL DIA
            
              IF R_CONCEPTOS.CONCEPTO = 'CECECOMP' THEN
                V_MONTO_ITEM := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_GASTOS_ADM(V_TIPO_TIBUTO,
                                                                                V_ID_TRIBUTO_CONTRIBUYENTE,
                                                                                V_ANIO,
                                                                                P_MSG);
              END IF;
            
              IF V_MONTO_ITEM <> 0 THEN
                SELECT SQ_T_OBLIGACIONES_DETALLE_SIM.NEXTVAL
                  INTO V_ID_OBLIGACION_DETALLE
                  FROM DUAL;
              
                INSERT INTO T_OBLIG_DET_SIMU
                  (ID_OBLIGACION_DETALLE,
                   ID_OBLIGACION,
                   ID_TIPO_CONCEPTO,
                   MONTO_ITEM,
                   --financiacion_item,
                   INTERESES_ITEM,
                   --  iva_item,
                   COBRADO_ITEM,
                   COBRADO_INTERESES_ITEM,
                   USR_ING,
                   FEC_ING,
                   USR_MOD,
                   FEC_MOD)
                VALUES
                  (V_ID_OBLIGACION_DETALLE,
                   V_ID_OBLIGACION,
                   R_CONCEPTOS.ID_TIPO_CONCEPTO,
                   DECODE(R_CONCEPTOS.IMPACTO,
                          '-',
                          V_MONTO_ITEM * (-1),
                          V_MONTO_ITEM),
                   --  0,
                   0,
                   --   0,
                   0,
                   0,
                   USER,
                   SYSDATE,
                   NULL,
                   NULL);
              
              END IF;
              V_MONTO_ITEM := 0;
            
            END LOOP; -- en for conceptos
          
          /*            -- genero la tabla comporbantes que es el reporte de liquidacion
                                                                                                                                              PKG_TRIBUTOS_CONTRIBUYENTES.GENERA_COMPROBANTES_CAB(R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
                                                                                                                                                                                                  1, -- masivo
                                                                                                                                                                                                  0,
                                                                                                                                                                                                  P_ID_COMPROBANTE,
                                                                                                                                                                                                  P_MSG);
                                                                                                                                              PKG_TRIBUTOS_CONTRIBUYENTES.GENERA_COMPROBANTES_DET(P_ID_COMPROBANTE,
                                                                                                                                                                                                  1,
                                                                                                                                                                                                  V_ID_OBLIGACION,
                                                                                                                                                                                                  0,
                                                                                                                                                                                                  P_MSG);
                                                                                                                                            
                                                                                                                                              SELECT F_GENERA_CODIGO_BARRA(P_ID_COMPROBANTE)
                                                                                                                                                INTO V_CODIGO_BARRA
                                                                                                                                                FROM DUAL;
                                                                                                                                              UPDATE T_COMPROBANTES C
                                                                                                                                                 SET COGIDO_BARRA_BANCO  = V_CODIGO_BARRA,
                                                                                                                                                     MONTO_DEUDA_A_PAGAR =
                                                                                                                                                     (SELECT SUM(MONTO_DEUDA_ORIG + INTERESES)
                                                                                                                                                        FROM T_COMPROBANTES_DETALLE
                                                                                                                                                       WHERE ID_COMPROBANTE = P_ID_COMPROBANTE)
                                                                                                                                               WHERE ID_COMPROBANTE = P_ID_COMPROBANTE;*/
          END LOOP;
          IF V_CONTADOR_ROLLBACK > 0 THEN
            ROLLBACK;
            EXIT;
          END IF;
        ELSE
          P_MSG := 'NO SE PUDO CALCULAR EL MONTO MENSUAL. ' || V_MONTO_ITEM || ' ' ||
                   V_ID_TRIBUTO_CONTRIBUYENTE;
        
          PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(R_TRIBUTOS.ID_TIPO_TRIBUTO,
                                                 4000,
                                                 V_TOTAL,
                                                 V_PROCESADAS,
                                                 P_MSG,
                                                 'E');
        END IF;
        /*        END IF;*/
      END LOOP;
    END IF;
  
    PKG_DEVENGAMIENTO.LOG_DEVENGAMIENTO(P_MODO,
                                        V_ID_TIPO_TRIBUTO,
                                        4000,
                                        P_EJERCICIO_LIQ,
                                        P_CUOTAS,
                                        P_USR_ING);
    IF P_MSG IS NULL THEN
      PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                             4000,
                                             V_TOTAL,
                                             V_PROCESADAS,
                                             P_MSG,
                                             'T');
    
    END IF;
  
    --COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    
      P_MSG := 'Error en GENERA_DEVENGAMIENTO_CECE_MAL .Verifique: ' ||
               SQLERRM || V_ID_TRIBUTO_CONTRIBUYENTE;
    
      PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(4, --id_tipo_tributo
                                             4000,
                                             V_TOTAL,
                                             V_PROCESADAS,
                                             P_MSG,
                                             'E');
    
  END GENERA_DEVENGAMIENTO_CECE_MAL;
  
  
   PROCEDURE GENERA_DEVENGAMIENTO_CLOACA_MAL(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                         P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL,
                                         P_USR_ING                  IN VARCHAR2,
                                         P_CUOTAS                   IN VARCHAR2 DEFAULT NULL,
                                         P_MODO                     IN VARCHAR2,
                                         P_MSG                      OUT VARCHAR2) IS
    /*contempla devengamiento multianual
    CONTEMPLA CUOTA UNICA
    CONTEMPLA DESCUENTO CUOTA UNICA
    
    */
    V_TIPO_TIBUTO              VARCHAR2(10) := 'ININ';
    V_MONTO_ITEM               NUMBER(19, 5) := 0;
    V_ID_OBLIGACION            VARCHAR2(10);
    V_ID_OBLIGACION_DETALLE    VARCHAR2(10);
    V_TASA_BASICA              NUMBER(19, 5) := 0;
    V_ZONA                     VARCHAR2(50);
    P_ID_COMPROBANTE           NUMBER(10);
    V_FECHA_ALTA               DATE;
    V_ID_JURISDICCION          NUMBER(10);
    V_ANIO_DESDE               NUMBER(4);
    V_ANIO                     NUMBER(4);
    V_ANIO_HASTA               NUMBER(4);
    V_ID_TRIBUTO_CONTRIBUYENTE VARCHAR2(50);
    V_DESCUENTO_ALDIA          NUMBER(19, 5) := 0;
    V_CODIGO_BARRA             VARCHAR2(100);
    V_PASILLO                  NUMBER(4) := 0;
    V_PASILLO_POR              NUMBER(19, 5) := 0;
    V_PASILLO_MONTO            NUMBER(19, 5) := 0;
    V_TASA_BASICAPA            NUMBER(19, 5) := 0;
    V_TASA_RURAL               NUMBER(19, 5) := 0;
    V_ID_INMUEBLE              VARCHAR2(50);
    V_TASA_BASICA_ORI          NUMBER(19, 5) := 0;
    V_IMPORTE_CUOTA_CERO       NUMBER;
    V_SQL                      VARCHAR2(20000);
    C_TRIBUTOS                 SYS_REFCURSOR;
    V_ID_IN                    VARCHAR2(20);
    V_ID_TRIBUTO_CONTRIB       VARCHAR2(20);
    V_ID_PERSONA               VARCHAR2(20);
    V_ID_TIPO_TRIBUTO          NUMBER := 6;
    V_ID_TIPO_INMUEBLE         NUMBER;
    V_ID_ZONA                  NUMBER;
    V_CONCEPTO_ABREVIADO       VARCHAR2(20);
    V_CUMPLIDOR                NUMBER;
    V_FEC_ALTA                 DATE;
    V_ID_JUR                   NUMBER;
    V_ID_BIEN_TRIB_PGM         VARCHAR2(20);
    V_SQL_TOTAL                VARCHAR2(20000);
    V_MENSAJE                  VARCHAR2(200);
    V_TIENE_OBLIGACIONES       NUMBER(10);
    V_CONTADOR_ROLLBACK        NUMBER(10);
    V_TIENE_CUOTA              NUMBER;
    V_OBLIGACION               NUMBER;
    ----------------- barra carga ----------------------
    V_CONTADOR      NUMBER := 0;
    V_PROCESADAS    NUMBER := 0;
    V_TOTAL         NUMBER := 0;
    V_MENSAJE_ERROR VARCHAR2(1000);
  
    CURSOR C_CUOTAS IS
    
      SELECT NRO_CUOTA, FECHA_PRIMER_VTO, FECHA_SEGUNDO_VTO
        FROM T_VENCIMIENTOS VTO, T_TIPOS_TRIBUTOS TT
       WHERE VTO.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND TT.TIPO_TRIBUTO = V_TIPO_TIBUTO
         AND N_TIPO = 'CUOTA'
         AND (VTO.NRO_CUOTA IN
             (SELECT TO_NUMBER(REGEXP_SUBSTR(P_CUOTAS, '[^,]+', 1, LEVEL)) AS LIST
                 FROM DUAL
               CONNECT BY REGEXP_SUBSTR(P_CUOTAS, '[^,]+', 1, LEVEL) IS NOT NULL))
         AND VTO.EJERCICIO = V_ANIO
         AND (VTO.ID_JURISDICCION = 4000)
         AND VTO.FECHA_PRIMER_VTO > V_FECHA_ALTA
         AND VTO.FEC_BAJA IS NULL
         AND VTO.USR_BAJA IS NULL
       ORDER BY NRO_CUOTA;
  
    CURSOR C_CONCEPTOS IS
    
      SELECT TC.ID_TIPO_CONCEPTO,
             TC.CONCEPTO,
             TC.DESCRIPCION,
             TC.IMPACTO,
             TC.PORCENTAJE,
             TC.VALOR,
             TC.OBJETO_REF
        FROM T_TIPOS_CONCEPTOS TC, T_TIPOS_TRIBUTOS TT
       WHERE TC.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND TT.TIPO_TRIBUTO = V_TIPO_TIBUTO
         AND OBJETO_REF IS NOT NULL
         AND TC.FEC_BAJA IS NULL
            --AND TC.ID_TIPO_CONCEPTO <> '2269' --- PARA QUE NO INCLUYA EL CONCEPTO PASILLO
         AND (TC.ID_JURISDICCION = 4000)
       ORDER BY ORDEN;
  
    V_SENTENCIA VARCHAR2(100);
  BEGIN
    V_SENTENCIA := '  ALTER SESSION SET NLS_DATE_FORMAT=' || '''' ||
                   ' DD/MM/RRRR' || '''';
    EXECUTE IMMEDIATE V_SENTENCIA;
    V_ID_INMUEBLE := P_ID_TRIBUTO_CONTRIBUYENTE;
    V_ANIO_DESDE  := P_EJERCICIO_LIQ;
    V_ANIO_HASTA  := P_EJERCICIO_LIQ;
  
    --- AGREGUE ESTA CONDICION PARA CUANDO LIQUIDO A FIN DE A?O. PARA EL A?O SIGUIENTE
  
    IF V_ANIO_HASTA < V_ANIO_DESDE THEN
      V_ANIO_HASTA := P_EJERCICIO_LIQ;
    END IF;
  
    V_ANIO := V_ANIO_DESDE;
  
    IF P_MODO = 'G' THEN
      FOR I IN V_ANIO_DESDE .. V_ANIO_HASTA LOOP
        -----------------------------------------------------------------------------------
        V_SQL := '  select c.id_inmueble,
         tc.id_tributo_contribuyente,
         tc.id_persona,
         ID_TIPO_TRIBUTO,
         c.ID_TIPO_INMUEBLE,
        TC.FECHA_ALTA, -- ALTA D LAS RELACIONES CONLAS OBLIGACIONES
         TC.ID_JURISDICCION,
         tc.id_bien_trib_pgm

    from T_CLOACAS c,
         t_tributos_contribuyentes tc
       
     where c.id_obsa = tc.id_tributo_contribuyente ';
        IF V_ID_INMUEBLE IS NOT NULL THEN
          V_SQL := V_SQL || ' and tc.id_tributo_contribuyente = ''' ||
                   V_ID_INMUEBLE || '''';
        END IF;
        V_SQL := V_SQL || ' AND tc.FEC_BAJA IS NULL
     and activo = 1
     AND tc.ID_JURISDICCION = 4000
     --AND I.ID_TIPO_INMUEBLE <> 99
     --AND I.ID_TIPO_INMUEBLE = 3
     
    /* AND NOT EXISTS (SELECT 1
            FROM T_OBLIGACIONES
           WHERE id_tipos_tributos = 46
             and ID_TRIBUTO_CONTRIBUYENTE = ID_INMUEBLE
             and ano_cuota = ' || V_ANIO || ' --P_EJERCICIO_LIQ
             and estado_deuda <> ''CA''
             and fec_baja is null)*/

   order by 1 ';
      
        V_SQL_TOTAL := 'SELECT COUNT(*) FROM (' || V_SQL || ')';
      
        EXECUTE IMMEDIATE V_SQL_TOTAL
          INTO V_TOTAL;
      
        BEGIN
        
          PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                                 4000,
                                                 V_TOTAL,
                                                 1,
                                                 '',
                                                 'P');
        
        END;
        OPEN C_TRIBUTOS FOR V_SQL;
      
        LOOP
          FETCH C_TRIBUTOS
            INTO V_ID_IN,
                 V_ID_TRIBUTO_CONTRIB,
                 V_ID_PERSONA,
                 V_ID_TIPO_TRIBUTO,
                 V_ID_TIPO_INMUEBLE,
                 V_FEC_ALTA,
                 V_ID_JUR,
                 V_ID_BIEN_TRIB_PGM;
        
          EXIT WHEN C_TRIBUTOS%NOTFOUND;
        
          -- FOR R_TRIBUTOS IN C_TRIBUTOS LOOP
          V_ID_TRIBUTO_CONTRIBUYENTE := V_ID_TRIBUTO_CONTRIB;
          V_ID_JURISDICCION          := V_ID_JUR;
          V_FECHA_ALTA               := V_FEC_ALTA;
          -- V_ZONA:=R_TRIBUTOS.concepto_abreviado;
          -- COMO PUEDO TENER MAS DE UNA ZONA PARA ARMAR EL CURSOS DE LAS CUOTAS SOLO ME INTERESA LA ALGUNA 
          --POR ESO EL ROWNUM             
          SELECT IZ.CONCEPTO_ABREVIADO
            INTO V_ZONA
            FROM T_INMUEBLES_ZONAS_ANIO IZA, T_INMUEBLES_ZONAS IZ
           WHERE IZA.ID_ZONA = IZ.ID_ZONAS
             AND ID_INMUEBLE = V_ID_IN
             AND V_ANIO >= ANIO_DESDE
             AND V_ANIO <= ANIO_HASTA
             AND ROWNUM = 1;
        
          V_MONTO_ITEM := F_TASABASICA_INMUEBLE_MAL(V_ANIO,
                                                   V_ID_IN,
                                                   1);
          IF V_MONTO_ITEM <> 0 THEN
          
            FOR R_CUOTAS IN C_CUOTAS LOOP
              V_PASILLO_MONTO := 0;
            
       SELECT COUNT(TOB.ID_OBLIGACION)
                    INTO V_TIENE_OBLIGACIONES
              FROM T_OBLIGACIONES TOB
             WHERE TOB.ID_TRIBUTO_CONTRIBUYENTE =V_ID_TRIBUTO_CONTRIBUYENTE
               AND TOB.ANO_CUOTA = V_ANIO
               AND TOB.ID_JURISDICCION = V_ID_JURISDICCION
               AND TOB.NRO_CUOTA = R_CUOTAS.NRO_CUOTA
               AND TOB.FEC_BAJA IS NULL
               AND TOB.USR_BAJA IS NULL
               AND TOB.ESTADO_DEUDA NOT IN ('PP','CA');
          
            IF V_TIENE_OBLIGACIONES > 0 THEN
              V_CONTADOR_ROLLBACK := V_CONTADOR_ROLLBACK + 1;
             
              P_MSG               := '. Ya hay obligaciones pagadas para el periodo seleccionado';
              EXIT;
              
              ELSE            
                 V_OBLIGACION := 0;
            SELECT  count(distinct (O.ID_OBLIGACION)) 
            INTO V_OBLIGACION
            FROM T_OBLIGACIONES O
            JOIN T_OBLIGACIONES_DETALLE OD
            ON O.ID_OBLIGACION = OD.ID_OBLIGACION 
            WHERE O.ID_TRIBUTO_CONTRIBUYENTE = V_ID_TRIBUTO_CONTRIBUYENTE
            AND O.ID_JURISDICCION = 4000
            AND O.ESTADO_DEUDA = 'PP'
            AND O.ANO_CUOTA = V_ANIO
            AND O.NRO_CUOTA = R_CUOTAS.NRO_CUOTA
            AND O.ID_OBLIGACION  NOT IN (SELECT OD.ID_OBLIGACION  
                                         FROM T_OBLIGACIONES_DETALLE OD
                                         WHERE OD.ID_OBLIGACION = O.ID_OBLIGACION 
                                         AND OD.ID_TIPO_CONCEPTO IN (SELECT TC.ID_TIPO_CONCEPTO
                                                                     FROM T_TIPOS_CONCEPTOS TC
                                                                     WHERE TC.ID_TIPO_CONCEPTO = OD.ID_TIPO_CONCEPTO 
                                                                     AND TC.ID_TIPO_TRIBUTO = 6
                                                                     AND TC.ID_JURISDICCION  = 4000
                                                                     AND TC.DESCRIPCION LIKE 'AJUSTE DE LIQUIDACI%'))
            AND O.FEC_BAJA IS NULL
            AND O.USR_BAJA IS NULL;
            

            IF V_OBLIGACION > 0 THEN 
            UPDATE T_OBLIGACIONES OBL
               SET OBL.FEC_BAJA     = SYSDATE,
                   OBL.USR_BAJA     = P_USR_ING,
                   OBL.ESTADO_DEUDA = 'CA'
             WHERE OBL.ID_TRIBUTO_CONTRIBUYENTE =V_ID_TRIBUTO_CONTRIBUYENTE
               AND OBL.ANO_CUOTA = V_ANIO
               AND OBL.NRO_CUOTA = LPAD(R_CUOTAS.NRO_CUOTA,3,0)
               AND OBL.ESTADO_DEUDA = 'PP'
               AND OBL.ID_JURISDICCION = 4000
               AND OBL.FEC_BAJA IS NULL
               AND OBL.USR_BAJA IS NULL;            
            END IF;
            END IF; 
            
              SELECT SQ_T_OBLIGACIONES.NEXTVAL
                INTO V_ID_OBLIGACION
                FROM DUAL;
            
              INSERT INTO T_OBLIGACIONES
                (ID_OBLIGACION,
                 ID_TRIBUTO_CONTRIBUYENTE,
                 ID_TIPOS_TRIBUTOS,
                 TIPO_PLAN,
                 TIPO_CUOTA,
                 ANO_CUOTA,
                 NRO_CUOTA,
                 ESTADO_DEUDA,
                 SITUACION_DEUDA,
                 FECHA_ESTADO_DEUDA,
                 FECHA_GENERACION_DEUDA,
                 FECHA_PRIMER_VENCIMIENTO,
                 FECHA_SEGUNDO_VENCIMIENTO,
                 FECHA_ACTUALIZACION_DEUDA,
                 CAPITAL_FACTURADO,
                 INTERESES_FACTURADOS,
                 FECHA_COBRADO,
                 FECHA_CONTABILIZACION,
                 ENTE_RECA,
                 NRO_OPERACION,
                 CAPITAL_COBRADO,
                 INTERESES_COBRADOS,
                 CAPITAL_FINANCIADO,
                 INTERESES_FINANCIADOS,
                 ID_PERSONA,
                 USR_ING,
                 FEC_ING,
                 USR_MOD,
                 FEC_MOD,
                 DIAS_MORA,
                 ID_JURISDICCION)
              VALUES
                (V_ID_OBLIGACION,
                 V_ID_TRIBUTO_CONTRIB,
                 V_ID_TIPO_TRIBUTO,
                 F_BUSCA_IDPLAN_DEVENGAMIENTO(V_ID_TIPO_TRIBUTO,
                                              V_ID_JURISDICCION,
                                              V_ANIO),
                 'BA',
                 V_ANIO,
                 LPAD(R_CUOTAS.NRO_CUOTA, 3, 0),
                 'PP',
                 'DN',
                 SYSDATE,
                 SYSDATE,
                 R_CUOTAS.FECHA_PRIMER_VTO,
                 R_CUOTAS.FECHA_SEGUNDO_VTO,
                 SYSDATE,
                 0,
                 0,
                 NULL,
                 NULL,
                 '',
                 '',
                 0,
                 0,
                 0,
                 0,
                 V_ID_PERSONA,
                 P_USR_ING,
                 SYSDATE,
                 NULL,
                 NULL,
                 0,
                 V_ID_JURISDICCION);
            
              FOR R_CONCEPTOS IN C_CONCEPTOS LOOP
              
                IF R_CONCEPTOS.CONCEPTO = 'ININBASI' THEN
                  V_MONTO_ITEM := F_TASABASICA_INMUEBLE_MAL(V_ANIO,
                                                           V_ID_IN,
                                                           R_CUOTAS.NRO_CUOTA);
                                                           
                                                           
                   --cloacas es el 80 % del calculo del inmueble
                   V_MONTO_ITEM := (V_MONTO_ITEM * 0.80);
                   
                                                          
                  IF R_CUOTAS.NRO_CUOTA = 0 THEN
                    
                   V_MONTO_ITEM         := V_MONTO_ITEM * 12;
                   
                    V_MONTO_ITEM := (V_MONTO_ITEM * 0.80);
                    
                    -- SI ES LA CERO ES LA CUOTA UNICA POR LO TANTO LA GENERO POR EL MONTO ANUAL
                  /*  V_MONTO_ITEM         := V_MONTO_ITEM *
                                            F_BUSCA_CUOTAS_A_DEVENGAR(V_ID_TIPO_TRIBUTO,
                                                                      V_ID_JURISDICCION,
                                                                      V_ANIO);*/ --LO COMENTE PARA LA COUTA 07/01/2024 --NICOLAS
                    V_IMPORTE_CUOTA_CERO := V_MONTO_ITEM;
                  END IF;
                
                  V_TASA_BASICA     := V_MONTO_ITEM;
                  V_TASA_BASICAPA   := V_MONTO_ITEM;
                  V_TASA_BASICA_ORI := V_MONTO_ITEM;
                  IF V_ZONA = 'RU' THEN
                    --- si es rural hago el 48 de la tasa basica 
                    V_TASA_RURAL         := V_TASA_BASICA /*+
                                            (V_TASA_BASICA * 0.48)*/;
                    V_MONTO_ITEM         := V_TASA_RURAL;
                    V_TASA_BASICA        := V_MONTO_ITEM;
                    V_TASA_BASICA_ORI    := V_MONTO_ITEM;
                    V_IMPORTE_CUOTA_CERO := V_MONTO_ITEM;
                  END IF;
                END IF;
              
                IF R_CONCEPTOS.CONCEPTO = 'ININADMI' THEN
                  V_MONTO_ITEM := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_CONCEPTO(V_TIPO_TIBUTO,
                                                                                V_ID_TRIBUTO_CONTRIB,
                                                                                R_CONCEPTOS.CONCEPTO,
                                                                                V_ANIO,
                                                                                P_MSG);
                
                  V_TASA_BASICA := V_TASA_BASICA + V_MONTO_ITEM; -- NUEVO PARA UNQUILLO %  (contribucion basica + fondo + gasto administrativo)
                END IF;
              
              /*  IF R_CONCEPTOS.CONCEPTO = 'ININEXEN' THEN
                  -- V_monto_item := pkg_tributos_contribuyentes.F_CALCULA_EXENCION( R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,V_TASA_BASICA ,V_ANIO,p_msg) ;
                  --V_TASA_BASICA:=V_monto_item;
                  V_MONTO_ITEM := 0; -- MOMENTANEAMENTE HASTA PROBAR ALTA DE EXENCIONES
                END IF;*/
              
            /*    IF R_CONCEPTOS.CONCEPTO = 'ININHOSP' THEN
                  V_MONTO_ITEM := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_CONCEPTO(V_TIPO_TIBUTO,
                                                                                V_ID_TRIBUTO_CONTRIB,
                                                                                R_CONCEPTOS.CONCEPTO,
                                                                                V_ANIO,
                                                                                P_MSG);
                                                                                
                                                                            
                
                  V_TASA_BASICA := V_TASA_BASICA + V_MONTO_ITEM; -- NUEVO PARA UNQUILLO %  (contribucion basica + fondo + gasto administrativo)
                  IF R_CUOTAS.NRO_CUOTA = 0 THEN
                    -- SI ES LA CERO ES LA CUOTA UNICA POR LO TANTO LA GENERO POR EL MONTO ANUAL
                    V_MONTO_ITEM := V_MONTO_ITEM * 12;
                                   \* F_BUSCA_CUOTAS_A_DEVENGAR(V_ID_TIPO_TRIBUTO,
                                                              V_ID_JURISDICCION,
                                                              V_ANIO);*\
                  END IF;
                END IF;*/
              
              /*  IF R_CONCEPTOS.CONCEPTO IN ('ININBOMB', 'ININTURI') THEN
                
                  V_MONTO_ITEM := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_CONCEPTO(V_TIPO_TIBUTO,
                                                                                V_ID_TRIBUTO_CONTRIB,
                                                                                R_CONCEPTOS.CONCEPTO,
                                                                                V_ANIO,
                                                                                P_MSG);
                
                  V_MONTO_ITEM := (V_TASA_BASICA_ORI * V_MONTO_ITEM / 100); -- NUEVO PARA UNQUILLO %  (contribucion basica + fondo + gasto administrativo)
                END IF;*/
              
           /*     IF R_CONCEPTOS.CONCEPTO IN ('ININALUM') AND
                   V_ID_TIPO_INMUEBLE = 1 THEN
                  V_MONTO_ITEM := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_CONCEPTO(V_TIPO_TIBUTO,
                                                                                V_ID_TRIBUTO_CONTRIB,
                                                                                R_CONCEPTOS.CONCEPTO,
                                                                                V_ANIO,
                                                                                P_MSG);
                
                  V_MONTO_ITEM := (V_TASA_BASICA_ORI * V_MONTO_ITEM / 100); -- NUEVO PARA UNQUILLO %  (contribucion basica + fondo + gasto administrativo)
                END IF;*/
              
           /*     IF R_CONCEPTOS.CONCEPTO = 'ININCTAU' THEN
                  IF R_CUOTAS.NRO_CUOTA = 0 THEN
                   \* SELECT F_CONTRIBUYENTE_CUMPLIDOR_CM(V_ID_TRIBUTO_CONTRIB,
                                                        V_ANIO)
                      INTO V_CUMPLIDOR
                      FROM DUAL;*\
                    -- SE COMENTA EL DESCUENTO SOLO PARA CUMPLIDOR YA QUE SE INDICA QUE EN CM APLICA A TODOS LOS QUE PAGAN CUOTA UNICA
                    IF V_CUMPLIDOR = 1 THEN
                      V_MONTO_ITEM := PKG_DEVENGAMIENTO.F_GENERA_DTO_CTAUNICA(V_TIPO_TIBUTO,
                                                                              V_ID_TRIBUTO_CONTRIB,
                                                                              V_IMPORTE_CUOTA_CERO,
                                                                              V_ANIO);
                    ELSE
                      V_MONTO_ITEM := 0;
                    END IF;
                  ELSE
                    V_MONTO_ITEM := 0;
                  
                  END IF;
                END IF;*/
              /* IF P_EJERCICIO_LIQ >= 2025 THEN
             \*   IF R_CONCEPTOS.CONCEPTO = 'ININGIRSU'  THEN
                  --EN REALIDAD LA FUNCION ESTA MAL SOLO SIRVE PARA EL A?O EN CURSO.
                  V_MONTO_ITEM := F_CALCULA_GIRSU(R_CUOTAS.NRO_CUOTA);
                  
                  IF V_ANIO < 2025 THEN
                    V_MONTO_ITEM := 1600;
                  END IF;
                  
                  
                  
                END IF;*\
                END IF;*/
              
                IF V_MONTO_ITEM <> 0 THEN
                  SELECT SQ_T_OBLIGACIONES_DETALLE.NEXTVAL
                    INTO V_ID_OBLIGACION_DETALLE
                    FROM DUAL;
                
                  INSERT INTO T_OBLIGACIONES_DETALLE
                    (ID_OBLIGACION_DETALLE,
                     ID_OBLIGACION,
                     ID_TIPO_CONCEPTO,
                     MONTO_ITEM,
                     INTERESES_ITEM,
                     COBRADO_ITEM,
                     COBRADO_INTERESES_ITEM,
                     USR_ING,
                     FEC_ING,
                     USR_MOD,
                     FEC_MOD)
                  VALUES
                    (V_ID_OBLIGACION_DETALLE,
                     V_ID_OBLIGACION,
                     R_CONCEPTOS.ID_TIPO_CONCEPTO,
                     ROUND(DECODE(R_CONCEPTOS.IMPACTO,
                                  '-',
                                  V_MONTO_ITEM * (-1),
                                  V_MONTO_ITEM),
                           2),
                     --  0,
                     0,
                     --   0,
                     0,
                     0,
                     P_USR_ING,
                     SYSDATE,
                     NULL,
                     NULL);
                
                END IF;
              END LOOP;
              --------------------INSERTO LAS EXENCIONES------------------------                     
            /*  BEGIN
              \*
                PRC_INSERTA_EXENCION_DEVENGO(V_ID_TIPO_TRIBUTO,
                                             V_ID_TRIBUTO_CONTRIB,
                                             V_ANIO,
                                             R_CUOTAS.NRO_CUOTA,
                                             P_MSG);*\
              
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;*/
              ------------------------------------------------------------------                 
            
              -- genero la tabla comporbantes que es el reporte de liquidacion
              PKG_TRIBUTOS_CONTRIBUYENTES.GENERA_COMPROBANTES_CAB(V_ID_TRIBUTO_CONTRIB,
                                                                  1, -- masivo
                                                                  0,
                                                                  P_ID_COMPROBANTE,
                                                                  P_MSG);
              PKG_TRIBUTOS_CONTRIBUYENTES.GENERA_COMPROBANTES_DET(P_ID_COMPROBANTE,
                                                                  1,
                                                                  V_ID_OBLIGACION,
                                                                  0,
                                                                  P_MSG);
            
              IF R_CUOTAS.NRO_CUOTA = 0 THEN
                SELECT F_GENERA_CODIGO_BARRA_UNQ(P_ID_COMPROBANTE)
                  INTO V_CODIGO_BARRA
                  FROM DUAL;
              ELSE
                SELECT F_GENERA_CODIGO_BARRA(P_ID_COMPROBANTE)
                  INTO V_CODIGO_BARRA
                  FROM DUAL;
              END IF;
            
              IF V_CODIGO_BARRA = '-' THEN
                UPDATE T_COMPROBANTES C
                   SET COGIDO_BARRA_BANCO  = P_ID_COMPROBANTE,
                       MONTO_DEUDA_A_PAGAR =
                       (SELECT SUM(MONTO_DEUDA_ORIG + INTERESES)
                          FROM T_COMPROBANTES_DETALLE
                         WHERE ID_COMPROBANTE = P_ID_COMPROBANTE),
                       C.USR_ING           = DECODE(P_USR_ING,
                                                    NULL,
                                                    USER,
                                                    P_USR_ING)
                
                 WHERE ID_COMPROBANTE = P_ID_COMPROBANTE;
              
              ELSE
              
                UPDATE T_COMPROBANTES C
                   SET COGIDO_BARRA_BANCO  = V_CODIGO_BARRA,
                       MONTO_DEUDA_A_PAGAR =
                       (SELECT SUM(MONTO_DEUDA_ORIG + INTERESES)
                          FROM T_COMPROBANTES_DETALLE
                         WHERE ID_COMPROBANTE = P_ID_COMPROBANTE),
                       C.USR_ING           = DECODE(P_USR_ING,
                                                    NULL,
                                                    USER,
                                                    P_USR_ING)
                
                 WHERE ID_COMPROBANTE = P_ID_COMPROBANTE;
              
              END IF;
            
              IF R_CUOTAS.NRO_CUOTA = 0 THEN
                SELECT F_GENERA_CODIGO_BARRA_UNQ(P_ID_COMPROBANTE)
                  INTO V_CODIGO_BARRA
                  FROM DUAL;
              
                UPDATE T_COMPROBANTES C
                   SET COGIDO_BARRA_BANCO  = V_CODIGO_BARRA,
                       MONTO_DEUDA_A_PAGAR =
                       (SELECT SUM(MONTO_DEUDA_ORIG + INTERESES)
                          FROM T_COMPROBANTES_DETALLE
                         WHERE ID_COMPROBANTE = P_ID_COMPROBANTE),
                       USR_ING             = P_USR_ING
                
                 WHERE ID_COMPROBANTE = P_ID_COMPROBANTE;
              
              ELSE
                SELECT F_GENERA_CODIGO_BARRA(P_ID_COMPROBANTE)
                  INTO V_CODIGO_BARRA
                  FROM DUAL;
              
                UPDATE T_COMPROBANTES C
                   SET COGIDO_BARRA_BANCO  = V_CODIGO_BARRA,
                       MONTO_DEUDA_A_PAGAR =
                       (SELECT SUM(MONTO_DEUDA_ORIG + INTERESES)
                          FROM T_COMPROBANTES_DETALLE
                         WHERE ID_COMPROBANTE = P_ID_COMPROBANTE),
                       USR_ING             = P_USR_ING
                
                 WHERE ID_COMPROBANTE = P_ID_COMPROBANTE;
              
              END IF;
            
            END LOOP;
          
            P_MSG := '';
          
          ELSE
            P_MSG := 'NO SE PUDO CALCULAR EL MONTO MENSUAL. ' ||
                     V_MONTO_ITEM;
            PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                                   4000,
                                                   V_TOTAL,
                                                   V_PROCESADAS,
                                                   P_MSG,
                                                   'E');
          END IF;
        
          --------------------------------------------------------------------
          V_PROCESADAS := V_PROCESADAS + 1;
        
          PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                                 4000,
                                                 V_TOTAL,
                                                 V_PROCESADAS,
                                                 '',
                                                 'P');
        END LOOP;
        V_ANIO := V_ANIO + 1;
      
      END LOOP;
    
    ELSE
    ---------------------////////////////////////////////////////////////////////////////////////////--------------------------------
    ------------------------------------------------ SIMULACION -------------------------------------------------------
    ---------------------////////////////////////////////////////////////////////////////////////////--------------------------------

      BEGIN
        DELETE FROM T_OBLIG_DET_SIMU;
        DELETE FROM T_OBLIGA_SIMU;
        COMMIT;
      END;
    
      FOR I IN V_ANIO_DESDE .. V_ANIO_HASTA LOOP
      
        -----------------------------------------------------------------------------------
        V_SQL := '  select id_inmueble,
         tc.id_tributo_contribuyente,
         id_persona,
         ID_TIPO_TRIBUTO,
         I.ID_TIPO_INMUEBLE,
        TC.FECHA_ALTA, -- ALTA D LAS RELACIONES CONLAS OBLIGACIONES
         TC.ID_JURISDICCION,
         tc.id_bien_trib_pgm

    from t_inmuebles i,
         t_tributos_contribuyentes tc
       
     where i.id_inmueble = tc.id_tributo_contribuyente ';
        IF V_ID_INMUEBLE IS NOT NULL THEN
          V_SQL := V_SQL || ' and tc.id_tributo_contribuyente = ''' ||
                   V_ID_INMUEBLE || '''';
        END IF;
        V_SQL := V_SQL || ' AND I.FEC_BAJA IS NULL
     and activo = 1
     AND I.ID_JURISDICCION = 4000
     AND I.ID_TIPO_INMUEBLE <> 99
    /* AND NOT EXISTS (SELECT 1
            FROM T_OBLIGACIONES
           WHERE id_tipos_tributos = 6
             and ID_TRIBUTO_CONTRIBUYENTE = ID_INMUEBLE
             and ano_cuota = ' || V_ANIO || ' --P_EJERCICIO_LIQ
             and estado_deuda <> ''CA''
             and fec_baja is null)*/
   order by 1 ';
        DBMS_OUTPUT.PUT_LINE(V_SQL);
        V_SQL_TOTAL := 'SELECT COUNT(*) FROM (' || V_SQL || ')';
      
        EXECUTE IMMEDIATE V_SQL_TOTAL
          INTO V_TOTAL;
      
        BEGIN
        
          PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                                 4000,
                                                 V_TOTAL,
                                                 1,
                                                 '',
                                                 'P');
        
        END;
      
        OPEN C_TRIBUTOS FOR V_SQL;
      
        LOOP
          FETCH C_TRIBUTOS
            INTO V_ID_IN,
                 V_ID_TRIBUTO_CONTRIB,
                 V_ID_PERSONA,
                 V_ID_TIPO_TRIBUTO,
                 V_ID_TIPO_INMUEBLE,
                 V_FEC_ALTA,
                 V_ID_JUR,
                 V_ID_BIEN_TRIB_PGM;
        
          EXIT WHEN C_TRIBUTOS%NOTFOUND;
        
          -- FOR R_TRIBUTOS IN C_TRIBUTOS LOOP
          V_ID_TRIBUTO_CONTRIBUYENTE := V_ID_TRIBUTO_CONTRIB;
          V_ID_JURISDICCION          := V_ID_JUR;
          V_FECHA_ALTA               := V_FEC_ALTA;
          -- V_ZONA:=R_TRIBUTOS.concepto_abreviado;
          -- COMO PUEDO TENER MAS DE UNA ZONA PARA ARMAR EL CURSOS DE LAS CUOTAS SOLO ME INTERESA LA ALGUNA 
          --POR ESO EL ROWNUM             
          SELECT IZ.CONCEPTO_ABREVIADO
            INTO V_ZONA
            FROM T_INMUEBLES_ZONAS_ANIO IZA, T_INMUEBLES_ZONAS IZ
           WHERE IZA.ID_ZONA = IZ.ID_ZONAS
             AND ID_INMUEBLE = V_ID_TRIBUTO_CONTRIB
             AND V_ANIO >= ANIO_DESDE
             AND V_ANIO <= ANIO_HASTA
             AND ROWNUM = 1;
        
          V_MONTO_ITEM := F_TASABASICA_INMUEBLE_MAL(V_ANIO,
                                                   V_ID_TRIBUTO_CONTRIB,
                                                   1);
          IF V_MONTO_ITEM <> 0 THEN
          
            FOR R_CUOTAS IN C_CUOTAS LOOP
              V_PASILLO_MONTO := 0;
            
              SELECT SQ_T_OBLIGACIONES_SIM.NEXTVAL
                INTO V_ID_OBLIGACION
                FROM DUAL;
            
              INSERT INTO T_OBLIGA_SIMU
                (ID_OBLIGACION,
                 ID_TRIBUTO_CONTRIBUYENTE,
                 ID_TIPOS_TRIBUTOS,
                 TIPO_PLAN,
                 TIPO_CUOTA,
                 ANO_CUOTA,
                 NRO_CUOTA,
                 ESTADO_DEUDA,
                 SITUACION_DEUDA,
                 FECHA_ESTADO_DEUDA,
                 FECHA_GENERACION_DEUDA,
                 FECHA_PRIMER_VENCIMIENTO,
                 FECHA_SEGUNDO_VENCIMIENTO,
                 FECHA_ACTUALIZACION_DEUDA,
                 CAPITAL_FACTURADO,
                 INTERESES_FACTURADOS,
                 FECHA_COBRADO,
                 FECHA_CONTABILIZACION,
                 ENTE_RECA,
                 NRO_OPERACION,
                 CAPITAL_COBRADO,
                 INTERESES_COBRADOS,
                 CAPITAL_FINANCIADO,
                 INTERESES_FINANCIADOS,
                 ID_PERSONA,
                 USR_ING,
                 FEC_ING,
                 USR_MOD,
                 FEC_MOD,
                 DIAS_MORA,
                 ID_JURISDICCION)
              VALUES
                (V_ID_OBLIGACION,
                 V_ID_TRIBUTO_CONTRIB,
                 V_ID_TIPO_TRIBUTO,
                 F_BUSCA_IDPLAN_DEVENGAMIENTO(V_ID_TIPO_TRIBUTO,
                                              V_ID_JURISDICCION,
                                              V_ANIO),
                 'BA',
                 V_ANIO,
                 LPAD(R_CUOTAS.NRO_CUOTA, 3, 0),
                 'PP',
                 'DN',
                 SYSDATE,
                 SYSDATE,
                 R_CUOTAS.FECHA_PRIMER_VTO,
                 R_CUOTAS.FECHA_SEGUNDO_VTO,
                 SYSDATE,
                 0,
                 0,
                 NULL,
                 NULL,
                 '',
                 '',
                 0,
                 0,
                 0,
                 0,
                 V_ID_PERSONA,
                 P_USR_ING,
                 SYSDATE,
                 NULL,
                 NULL,
                 0,
                 V_ID_JURISDICCION);
            
              FOR R_CONCEPTOS IN C_CONCEPTOS LOOP
              
                IF R_CONCEPTOS.CONCEPTO = 'ININBASI' THEN
                  V_MONTO_ITEM := F_TASABASICA_INMUEBLE_MAL(V_ANIO,
                                                           V_ID_IN,
                                                           R_CUOTAS.NRO_CUOTA);
                                                           
                   V_MONTO_ITEM := (V_MONTO_ITEM * 0.80);                                                                                                    
                  IF R_CUOTAS.NRO_CUOTA = 0 THEN
                    -- SI ES LA CERO ES LA CUOTA UNICA POR LO TANTO LA GENERO POR EL MONTO ANUAL
                    V_MONTO_ITEM         := V_MONTO_ITEM * 12; 
                                            /*F_BUSCA_CUOTAS_A_DEVENGAR(V_ID_TIPO_TRIBUTO,
                                                                      V_ID_JURISDICCION,
                                                                      V_ANIO);*/
                                                                      
                     V_MONTO_ITEM := (V_MONTO_ITEM * 0.80);                                                                                                                        
                    V_IMPORTE_CUOTA_CERO := V_MONTO_ITEM;
                  END IF;
                
                  V_TASA_BASICA     := V_MONTO_ITEM;
                  V_TASA_BASICAPA   := V_MONTO_ITEM;
                  V_TASA_BASICA_ORI := V_MONTO_ITEM;
                  IF V_ZONA = 'RU' THEN
                    --- si es rural hago el 48 de la tasa basica 
                    V_TASA_RURAL         := V_TASA_BASICA +
                                            (V_TASA_BASICA * 0.48);
                    V_MONTO_ITEM         := V_TASA_RURAL;
                    V_TASA_BASICA        := V_MONTO_ITEM;
                    V_TASA_BASICA_ORI    := V_MONTO_ITEM;
                    V_IMPORTE_CUOTA_CERO := V_MONTO_ITEM;
                  END IF;
                END IF;
              
                IF R_CONCEPTOS.CONCEPTO = 'ININADMI' THEN
                  V_MONTO_ITEM := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_CONCEPTO(V_TIPO_TIBUTO,
                                                                                V_ID_TRIBUTO_CONTRIB,
                                                                                R_CONCEPTOS.CONCEPTO,
                                                                                V_ANIO,
                                                                                P_MSG);
                
                  V_TASA_BASICA := V_TASA_BASICA + V_MONTO_ITEM; -- NUEVO PARA UNQUILLO %  (contribucion basica + fondo + gasto administrativo)
                END IF;
              
                IF R_CONCEPTOS.CONCEPTO = 'ININEXEN' THEN
                  -- V_monto_item := pkg_tributos_contribuyentes.F_CALCULA_EXENCION( R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,V_TASA_BASICA ,V_ANIO,p_msg) ;
                  --V_TASA_BASICA:=V_monto_item;
                  V_MONTO_ITEM := 0; -- MOMENTANEAMENTE HASTA PROBAR ALTA DE EXENCIONES
                END IF;
              
                IF R_CONCEPTOS.CONCEPTO = 'ININHOSP' THEN --HOSPITAL ININHOSP
                  V_MONTO_ITEM := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_CONCEPTO(V_TIPO_TIBUTO,
                                                                                V_ID_TRIBUTO_CONTRIB,
                                                                                R_CONCEPTOS.CONCEPTO,
                                                                                V_ANIO,
                                                                                P_MSG);
                                                                                                
                  V_TASA_BASICA := V_TASA_BASICA + V_MONTO_ITEM; -- 
                  IF R_CUOTAS.NRO_CUOTA = 0 THEN
                     -- SI ES LA CERO ES LA CUOTA UNICA POR LO TANTO LA GENERO POR EL MONTO ANUAL
                    V_MONTO_ITEM := V_MONTO_ITEM * 12;
                                   
                  
                  /*ELSE
                    -- SI ES LA CERO ES LA CUOTA UNICA POR LO TANTO LA GENERO POR EL MONTO ANUAL
                    V_MONTO_ITEM := V_MONTO_ITEM *
                                    F_BUSCA_CUOTAS_A_DEVENGAR(V_ID_TIPO_TRIBUTO,
                                                              V_ID_JURISDICCION,
                                                              V_ANIO);*/
                  END IF;
                END IF;
              
                IF R_CONCEPTOS.CONCEPTO IN ('ININBOMB', 'ININTURI') THEN -- BOMBEROS Y FONDO DE TURISMO Y GESTION SUSTENTABLE
                
                  V_MONTO_ITEM := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_CONCEPTO(V_TIPO_TIBUTO,
                                                                                V_ID_TRIBUTO_CONTRIB,
                                                                                R_CONCEPTOS.CONCEPTO,
                                                                                V_ANIO,
                                                                                P_MSG);
                
                  V_MONTO_ITEM := (V_TASA_BASICA_ORI * V_MONTO_ITEM / 100); -- NUEVO PARA UNQUILLO %  (contribucion basica + fondo + gasto administrativo)
                END IF;
              
                IF R_CONCEPTOS.CONCEPTO IN ('ININALUM') AND
                   V_ID_TIPO_INMUEBLE = 1 THEN
                  V_MONTO_ITEM := PKG_TRIBUTOS_CONTRIBUYENTES.F_GENERA_CONCEPTO(V_TIPO_TIBUTO,
                                                                                V_ID_TRIBUTO_CONTRIB,
                                                                                R_CONCEPTOS.CONCEPTO,
                                                                                V_ANIO,
                                                                                P_MSG);
                
                  V_MONTO_ITEM := (V_TASA_BASICA_ORI * V_MONTO_ITEM / 100); -- NUEVO PARA UNQUILLO %  (contribucion basica + fondo + gasto administrativo)
                END IF;
              
                /*IF R_CONCEPTOS.CONCEPTO = 'ININCTAU' THEN
                  IF R_CUOTAS.NRO_CUOTA = 0 THEN
                    SELECT F_CONTRIBUYENTE_CUMPLIDOR_CM(V_ID_TRIBUTO_CONTRIB,
                                                        V_ANIO)
                      INTO V_CUMPLIDOR
                      FROM DUAL;
                  
                    -- SE COMENTA EL DESCUENTO SOLO PARA CUMPLIDOR YA QUE SE INDICA QUE EN CM APLICA A TODOS LOS QUE PAGAN CUOTA UNICA
                    IF V_CUMPLIDOR = 1 THEN
                      V_MONTO_ITEM := PKG_DEVENGAMIENTO.F_GENERA_DTO_CTAUNICA(V_TIPO_TIBUTO,
                                                                              V_ID_TRIBUTO_CONTRIB,
                                                                              V_IMPORTE_CUOTA_CERO,
                                                                              V_ANIO);
                    ELSE
                      V_MONTO_ITEM := 0;
                    END IF;
                  ELSE
                    V_MONTO_ITEM := 0;
                  END IF;
                END IF;*/
            /*  IF P_EJERCICIO_LIQ >= 2024 THEN
                IF R_CONCEPTOS.CONCEPTO = 'ININGIRSU' THEN
                  V_MONTO_ITEM := F_CALCULA_GIRSU(R_CUOTAS.NRO_CUOTA);
                END IF;
               END IF;*/
              
                IF V_MONTO_ITEM <> 0 THEN
                
                  SELECT SQ_T_OBLIGACIONES_DETALLE_SIM.NEXTVAL
                    INTO V_ID_OBLIGACION_DETALLE
                    FROM DUAL;
                
                  INSERT INTO T_OBLIG_DET_SIMU
                    (ID_OBLIGACION_DETALLE,
                     ID_OBLIGACION,
                     ID_TIPO_CONCEPTO,
                     MONTO_ITEM,
                     INTERESES_ITEM,
                     COBRADO_ITEM,
                     COBRADO_INTERESES_ITEM,
                     USR_ING,
                     FEC_ING,
                     USR_MOD,
                     FEC_MOD)
                  VALUES
                    (V_ID_OBLIGACION_DETALLE,
                     V_ID_OBLIGACION,
                     R_CONCEPTOS.ID_TIPO_CONCEPTO,
                     ROUND(DECODE(R_CONCEPTOS.IMPACTO,
                                  '-',
                                  V_MONTO_ITEM * (-1),
                                  V_MONTO_ITEM),
                           2),
                     0,
                     0,
                     0,
                     P_USR_ING,
                     SYSDATE,
                     NULL,
                     NULL);
                
                END IF;
              END LOOP;
              --------------------INSERTO LAS EXENCIONES------------------------                     
              BEGIN
              
                PKG_SIMULACIONES.PRC_INSERTA_EXENCION_SIM(V_ID_TIPO_TRIBUTO,
                                                          V_ID_TRIBUTO_CONTRIB,
                                                          V_ANIO,
                                                          R_CUOTAS.NRO_CUOTA,
                                                          P_MSG);
              
              EXCEPTION
                WHEN OTHERS THEN
                  /*                  DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
                                    DBMS_OUTPUT.PUT_LINE('Error at line: ' ||
                                                         DBMS_UTILITY.FORMAT_ERROR_STACK);
                  */
                  NULL;
              END;
            END LOOP;
          
            P_MSG := '';
          
          ELSE
            P_MSG := 'NO SE PUDO CALCULAR EL MONTO MENSUAL. ' ||
                     V_MONTO_ITEM;
            PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                                   4000,
                                                   V_TOTAL,
                                                   V_PROCESADAS,
                                                   P_MSG,
                                                   'E');
          END IF;
        
          --------------------------------------------------------------------
          V_PROCESADAS := V_PROCESADAS + 1;
        
          PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                                 4000,
                                                 V_TOTAL,
                                                 V_PROCESADAS,
                                                 '',
                                                 'P');
        END LOOP;
        V_ANIO := V_ANIO + 1;
      
      END LOOP;
    
    END IF;
  
    IF P_MSG IS NULL THEN
      --Si no hubo errores se termina el devengamiento 
      PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                             4000,
                                             V_TOTAL,
                                             V_PROCESADAS,
                                             P_MSG,
                                             'T');
    
    ELSE
      PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                             4000,
                                             V_TOTAL,
                                             V_PROCESADAS,
                                             P_MSG,
                                             'E');
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      P_MSG := 'Error en GENERA_DEVENGAMIENTO_ININ_CM .Verifique: ' ||
               SQLERRM || V_ID_TRIBUTO_CONTRIBUYENTE;
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      DBMS_OUTPUT.PUT_LINE('Error at line: ' ||
                           DBMS_UTILITY.FORMAT_ERROR_STACK);
    
      PKG_DEVENGAMIENTO.LOG_PORCENTAJE_CARGA(V_ID_TIPO_TRIBUTO,
                                             4000,
                                             V_TOTAL,
                                             V_PROCESADAS,
                                             P_MSG,
                                             'E');
  END GENERA_DEVENGAMIENTO_CLOACA_MAL;
  
  PROCEDURE GENERA_DEVENGAMIENTO_CICI_FIJO(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                                         P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL,
                                         P_ID_JURISDICCION          IN NUMBER DEFAULT NULL,
                                         P_USR_ING                  IN VARCHAR2 DEFAULT NULL,
                                         P_ID_CATEGORIA             IN NUMBER DEFAULT NULL,
                                         P_MES                      IN VARCHAR2 DEFAULT NULL,
                                         P_ID_SITUACION_IMPOSITIVA  IN VARCHAR2 DEFAULT NULL,
                                         P_MSG                      OUT VARCHAR2,
                                         P_CUOTA_CERO               OUT NUMBER,
                                         P_CUENTAS_DEVENGADAS       OUT NUMBER,
                                         P_CUOTAS_GENERADAS         OUT NUMBER,
                                         P_VARIABLE                 OUT VARCHAR2) IS
    /*AUTOR:LOZADA TOMAS 8/3/2022
    ESTE PROCEDIMIENTO CALCULA LA TASA BASICA POR EL MINIMO DE LA ACTIVIDAD
    ESTE PROCEDIMIENTO EXIME DE PRESENTAR DDJJ*/
    V_TIPO_TIBUTO              VARCHAR2(10) := 'CICI';
    V_MONTO_ITEM               NUMBER(19, 5) := 0;
    V_MONTO_MINIMO_CATEGORIA   NUMBER(19, 5);
    V_ID_COMERCIO_DDJJ         NUMBER;
    V_ID_COMPROBANTE           VARCHAR2(10);
    V_ID_COMPROBANTE_DETALLE   VARCHAR2(10);
    V_TASA_BASICA              NUMBER(19, 5) := 0;
    V_FECHA_PRIMER_VTO         DATE;
    V_FECHA_SEGUNDO_VTO        DATE;
    V_ID_TIPO_TRIBUTO          NUMBER(10);
    V_ID_PERSONA               VARCHAR2(10);
    V_TIPO_TRIBUTO             VARCHAR2(10);
    V_CUMPLIDOR                VARCHAR2(1);
    V_FECHA_ALTA               DATE;
    V_ID_JURISDICCION          NUMBER(10) := P_ID_JURISDICCION;
    V_ANIO_DESDE               NUMBER(4);
    V_ANIO                     NUMBER(4);
    V_ANIO_HASTA               NUMBER(4);
    V_CODIGO_BARRA             VARCHAR2(100);
    V_ID_TRIBUTO_CONTRIBUYENTE VARCHAR2(50);
    P_ID_COMPROBANTE           NUMBER(10);
    V_CONTROL                  NUMBER(4);
    V_MINIMO                   NUMBER(10);
    V_TIENE_DDJJ               NUMBER;
    V_TIENE_OBLIGACIONES       NUMBER;
    V_CONTADOR_ROLLBACK        NUMBER := 0;
    V_ID_CATEGORIA             NUMBER;
    V_OBLIGACION               NUMBER :=0;
    V_MINIMO_MENSUAL           NUMBER :=0;
    CURSOR C_TRIBUTOS IS
    
      SELECT TC.ID_TRIBUTO_CONTRIBUYENTE,
             TT.TIPO_TRIBUTO,
             TT.ID_TIPO_TIBUTO           ID_TIPO_TRIBUTO,
             TC.CLAVE_BIEN,
             TC.ID_PERSONA,
             CCT.CONCEPTO                CATEGORIA,
             CCT.MINIMO_ANUAL,
             CI.CUMPLIDOR,
             TC.FECHA_ALTA,
             TC.ID_JURISDICCION
        FROM T_TRIBUTOS_CONTRIBUYENTES   TC,
             T_COMERCIO_INDUSTRIA        CI,
             T_COMERCIO_CATEGORIAS       CC,
             T_COMERCIO_CATEGORIAS_TIPOS CCT,
             T_TIPOS_TRIBUTOS            TT
      
       WHERE CI.ID_COMERCIO_INDUSTRIA = TC.ID_TRIBUTO_CONTRIBUYENTE
         AND CC.ID_COMERCIO_INDUSTRIA = CI.ID_COMERCIO_INDUSTRIA
         AND CC.ANO_CATEGORIA = V_ANIO --A?O DEL COMBO
         AND CC.ID_CODIGO_CATEGORIA = CCT.ID_CODIGO_CATEGORIA
         AND TC.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND TT.TIPO_TRIBUTO = V_TIPO_TIBUTO
         AND (CI.ID_COMERCIO_SITIMP IN
             (SELECT TO_NUMBER(REGEXP_SUBSTR(P_ID_SITUACION_IMPOSITIVA,
                                              '[^,]+',
                                              1,
                                              LEVEL)) AS LIST
                 FROM DUAL
               CONNECT BY REGEXP_SUBSTR(P_ID_SITUACION_IMPOSITIVA,
                                        '[^,]+',
                                        1,
                                        LEVEL) IS NOT NULL) OR
             P_ID_SITUACION_IMPOSITIVA IS NULL)
         AND (TC.ID_TRIBUTO_CONTRIBUYENTE = P_ID_TRIBUTO_CONTRIBUYENTE OR
             P_ID_TRIBUTO_CONTRIBUYENTE IS NULL) --P_TRIBUTO_CONTRIBUYENTE
         AND CCT.ID_CODIGO_CATEGORIA = /*P_ID_CATEGORIA */
             V_ID_CATEGORIA --P_CATEGORIA
         AND TC.ID_JURISDICCION = V_ID_JURISDICCION --P_JURISDICCION
         AND CI.FEC_BAJA IS NULL;
    CURSOR C_CUOTAS IS
    
      SELECT NRO_CUOTA, FECHA_PRIMER_VTO, FECHA_SEGUNDO_VTO
        FROM T_VENCIMIENTOS VTO, T_TIPOS_TRIBUTOS TT
       WHERE VTO.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND TT.TIPO_TRIBUTO = V_TIPO_TIBUTO
         AND N_TIPO = 'CUOTA'
         AND VTO.EJERCICIO = V_ANIO
         AND (VTO.NRO_CUOTA IN
             (SELECT TO_NUMBER(REGEXP_SUBSTR(P_MES, '[^,]+', 1, LEVEL)) AS LIST
                 FROM DUAL
               CONNECT BY REGEXP_SUBSTR(P_MES, '[^,]+', 1, LEVEL) IS NOT NULL))
         AND VTO.ID_JURISDICCION = V_ID_JURISDICCION
         AND VTO.NRO_CUOTA >= TO_NUMBER(TO_CHAR(TO_DATE(V_FECHA_ALTA, 'DD/MM/YYYY'), 'MM'))
         AND VTO.FEC_BAJA IS NULL
       ORDER BY NRO_CUOTA;
  
    CURSOR C_CONCEPTOS IS
      SELECT TC.ID_TIPO_CONCEPTO,
             TC.CONCEPTO,
             TC.DESCRIPCION,
             TC.IMPACTO,
             TC.PORCENTAJE,
             TC.VALOR,
             TC.OBJETO_REF
        FROM T_TIPOS_CONCEPTOS TC, T_TIPOS_TRIBUTOS TT
       WHERE TC.ID_TIPO_TRIBUTO = TT.ID_TIPO_TIBUTO
         AND TT.TIPO_TRIBUTO = 'CICI'
         AND OBJETO_REF IS NOT NULL
         AND TC.ID_JURISDICCION = 4000
       ORDER BY ORDEN;
       
       CURSOR C_RUBROS IS 
        SELECT CR.MINIMO_MENSUAL
          FROM T_COMERCIO_RUBROS CR
          JOIN T_COMERCIO_RUBROS_ANO CRA
            ON CR.ID_COMERCIO_RUBRO = CRA.ID_RUBROS_COMERCIO
         WHERE CRA.ID_COMERCIO_INDUSTRIA = P_VARIABLE
           AND CRA.ANO_RUBROS = V_ANIO
           AND (CRA.FEC_BAJA > SYSDATE OR CRA.FEC_BAJA IS NULL)
           AND CRA.USR_BAJA IS NULL;
  
  BEGIN
  
    V_ANIO_DESDE := P_EJERCICIO_LIQ;
    V_ANIO_HASTA := TO_CHAR(SYSDATE, 'YYYY');
  
    IF V_ANIO_HASTA < V_ANIO_DESDE THEN
      V_ANIO_HASTA := P_EJERCICIO_LIQ;
    END IF;
  
    V_ANIO := V_ANIO_DESDE;
  
    FOR I IN V_ANIO_DESDE .. V_ANIO_HASTA LOOP
    
      P_CUOTA_CERO         := 0; --CONTROL
      P_CUENTAS_DEVENGADAS := 0; --CONTROL
      P_CUOTAS_GENERADAS   := 0; --CONTROL
    
      SELECT CT.ID_CODIGO_CATEGORIA
        INTO V_ID_CATEGORIA
        FROM T_COMERCIO_CATEGORIAS_TIPOS CT
       WHERE CT.CONCEPTO = 'FIJO'
       AND CT.ANIO_EJERCICIO = V_ANIO;
       
      FOR R_TRIBUTOS IN C_TRIBUTOS LOOP
        
        V_ID_JURISDICCION := R_TRIBUTOS.ID_JURISDICCION;
        V_FECHA_ALTA      := R_TRIBUTOS.FECHA_ALTA;
      
        P_VARIABLE := R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE; --CONTROL
      
        BEGIN
          SELECT CR.ID_COMERCIO_RUBRO --SUM(CR.MINIMO_MENSUAL)
            INTO V_MINIMO
            FROM T_COMERCIO_RUBROS CR
            JOIN T_COMERCIO_RUBROS_ANO CRA
              ON CR.ID_COMERCIO_RUBRO = CRA.ID_RUBROS_COMERCIO
           WHERE CRA.ID_COMERCIO_INDUSTRIA = P_VARIABLE
             AND CRA.ANO_RUBROS = V_ANIO
             AND ROWNUM = 1;
        
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            P_MSG := 'No hay rubro este a?o';
            CONTINUE;
        END;
      
        SELECT SUM(CR.MINIMO_MENSUAL)
          INTO V_MINIMO
          FROM T_COMERCIO_RUBROS CR
          JOIN T_COMERCIO_RUBROS_ANO CRA
            ON CR.ID_COMERCIO_RUBRO = CRA.ID_RUBROS_COMERCIO
         WHERE CRA.ID_COMERCIO_INDUSTRIA = P_VARIABLE
           AND CRA.ANO_RUBROS = V_ANIO
           AND CRA.FEC_BAJA IS NULL
           AND CRA.USR_BAJA IS NULL
           AND CRA.ID_JURISDICCION = P_ID_JURISDICCION;
      
        P_CUENTAS_DEVENGADAS := P_CUENTAS_DEVENGADAS + 1; --CONTROL
      
        --COMENTAMOS LA FUNCION POR Q NO NECESITA HACER EL CALCULO DE LA ALICUOTA VA A TOMAR EL MINIMOMENSUAL
        
        -- GENERO IMPUESTO POR COMERCIO, Y GENERO LA OBLIGACION
        -- CUANDO EL COMERCIO PRESENTA LA DDJJ SE INCORPORARN LSO DEBITOS EN  LA OBLIGACION DETALLE
        IF V_MINIMO <> 0 THEN
        
          FOR R_CUOTAS IN C_CUOTAS LOOP
          
            V_TIENE_OBLIGACIONES := 0; --CONTROL
            SELECT COUNT(TOB.ID_OBLIGACION)
              INTO V_TIENE_OBLIGACIONES
              FROM T_OBLIGACIONES TOB
             WHERE TOB.ID_TRIBUTO_CONTRIBUYENTE =
                   P_ID_TRIBUTO_CONTRIBUYENTE
               AND TOB.ANO_CUOTA = V_ANIO
               AND TOB.ID_JURISDICCION = V_ID_JURISDICCION
               AND TOB.NRO_CUOTA = R_CUOTAS.NRO_CUOTA
               AND TOB.FEC_BAJA IS NULL
               AND TOB.USR_BAJA IS NULL
               AND TOB.ESTADO_DEUDA NOT IN ('PP','CA');

            IF V_TIENE_OBLIGACIONES > 0 THEN
              V_CONTADOR_ROLLBACK := V_CONTADOR_ROLLBACK + 1;
              P_MSG               := '. Ya hay obligaciones pagadas para el periodo seleccionado';
              EXIT;

              ELSE
                 V_OBLIGACION := 0;
            SELECT  count(distinct (O.ID_OBLIGACION))
            INTO V_OBLIGACION
            FROM T_OBLIGACIONES O
            JOIN T_OBLIGACIONES_DETALLE OD
            ON O.ID_OBLIGACION = OD.ID_OBLIGACION
            WHERE O.ID_TRIBUTO_CONTRIBUYENTE = P_ID_TRIBUTO_CONTRIBUYENTE
            AND O.ID_JURISDICCION = 4000
            AND O.ESTADO_DEUDA = 'PP'
            AND O.ANO_CUOTA = V_ANIO
            AND O.NRO_CUOTA = R_CUOTAS.NRO_CUOTA
            AND O.ID_OBLIGACION  NOT IN (SELECT OD.ID_OBLIGACION
                                         FROM T_OBLIGACIONES_DETALLE OD
                                         WHERE OD.ID_OBLIGACION = O.ID_OBLIGACION
                                         AND OD.ID_TIPO_CONCEPTO IN (SELECT TC.ID_TIPO_CONCEPTO
                                                                     FROM T_TIPOS_CONCEPTOS TC
                                                                     WHERE TC.ID_TIPO_CONCEPTO = OD.ID_TIPO_CONCEPTO
                                                                     AND TC.ID_TIPO_TRIBUTO = 5
                                                                     AND TC.ID_JURISDICCION  = 4000
                                                                     AND TC.DESCRIPCION LIKE 'AJUSTE DE LIQUIDACI%'))
            AND O.FEC_BAJA IS NULL
            AND O.USR_BAJA IS NULL;


            IF V_OBLIGACION > 0 THEN
            UPDATE T_OBLIGACIONES OBL
               SET OBL.FEC_BAJA     = SYSDATE,
                   OBL.USR_BAJA     = P_USR_ING,
                   OBL.ESTADO_DEUDA = 'CA'
             WHERE OBL.ID_TRIBUTO_CONTRIBUYENTE =
                   P_ID_TRIBUTO_CONTRIBUYENTE
               AND OBL.ANO_CUOTA = V_ANIO
               AND OBL.NRO_CUOTA = LPAD(R_CUOTAS.NRO_CUOTA,3,0)
               AND OBL.ESTADO_DEUDA = 'PP'
               AND OBL.ID_JURISDICCION = 4000
               AND OBL.FEC_BAJA IS NULL
               AND OBL.USR_BAJA IS NULL;
            END IF;
            END IF;
          
            P_CUOTAS_GENERADAS := P_CUOTAS_GENERADAS + 1; --CONTROL
          
            SELECT SQ_T_OBLIGACIONES.NEXTVAL
              INTO V_ID_COMPROBANTE
              FROM DUAL;
          
            INSERT INTO T_OBLIGACIONES
              (ID_OBLIGACION,
               ID_TRIBUTO_CONTRIBUYENTE,
               ID_TIPOS_TRIBUTOS,
               TIPO_PLAN,
               TIPO_CUOTA,
               ANO_CUOTA,
               NRO_CUOTA,
               ESTADO_DEUDA,
               SITUACION_DEUDA,
               FECHA_ESTADO_DEUDA,
               FECHA_GENERACION_DEUDA,
               FECHA_PRIMER_VENCIMIENTO,
               FECHA_SEGUNDO_VENCIMIENTO,
               FECHA_ACTUALIZACION_DEUDA,
               CAPITAL_FACTURADO,
               INTERESES_FACTURADOS,
               FECHA_COBRADO,
               FECHA_CONTABILIZACION,
               ENTE_RECA,
               NRO_OPERACION,
               CAPITAL_COBRADO,
               INTERESES_COBRADOS,
               CAPITAL_FINANCIADO,
               INTERESES_FINANCIADOS,
               ID_PERSONA,
               USR_ING,
               FEC_ING,
               USR_MOD,
               FEC_MOD,
               DIAS_MORA,
               ID_JURISDICCION)
            VALUES
              (V_ID_COMPROBANTE,
               R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
               R_TRIBUTOS.ID_TIPO_TRIBUTO,
               319, -- TIPO_PLAN_POR DEFECTO 12 CTAS
               'BA',
               V_ANIO,
               LPAD(R_CUOTAS.NRO_CUOTA, 3, 0),
               'PP',
               'DN',
               SYSDATE,
               SYSDATE,
               R_CUOTAS.FECHA_PRIMER_VTO,
               R_CUOTAS.FECHA_SEGUNDO_VTO,
               SYSDATE,
               0,
               0,
               NULL,
               NULL,
               '',
               '',
               0,
               0,
               0,
               0,
               R_TRIBUTOS.ID_PERSONA,
               P_USR_ING, --USER,
               SYSDATE,
               NULL,
               NULL,
               0,
               V_ID_JURISDICCION);
               
               
               
          
            FOR R_CONCEPTOS IN C_CONCEPTOS LOOP
            V_MONTO_ITEM :=0;
            
            
              IF R_CONCEPTOS.CONCEPTO = 'CICIBASI' THEN
              V_MINIMO:=0;
              V_MINIMO_MENSUAL :=0; 
                FOR R_RUBROS IN C_RUBROS LOOP
                  
                  V_MINIMO := R_RUBROS.MINIMO_MENSUAL;
                  
                  IF V_MINIMO > V_MINIMO_MENSUAL THEN
                    V_MINIMO_MENSUAL := V_MINIMO;
                    V_MONTO_ITEM := V_MINIMO_MENSUAL;
                   ELSE 
                    V_MONTO_ITEM := V_MINIMO_MENSUAL;
                   END IF;
                 
                END LOOP;
                 
              END IF;
              
               IF R_CONCEPTOS.CONCEPTO = 'CICIADMI' THEN
                     CASE P_EJERCICIO_LIQ
                       WHEN 2025 THEN V_MONTO_ITEM := 430;
                       WHEN 2024 THEN V_MONTO_ITEM := 150;
                       WHEN 2023 THEN V_MONTO_ITEM := 80;
                       WHEN 2022 THEN V_MONTO_ITEM := 50;
                       WHEN 2021 THEN V_MONTO_ITEM := 30;
                       WHEN 2020 THEN V_MONTO_ITEM := 20;
                       WHEN 2019 THEN V_MONTO_ITEM := 15;
                       END CASE;
                 END IF;
                 
                
               IF P_EJERCICIO_LIQ = 2019 AND R_CONCEPTOS.CONCEPTO = 'CICIENVI' THEN
                      V_MONTO_ITEM := 18;
                      END IF;   
            
              IF V_MONTO_ITEM <> 0 THEN
                SELECT SQ_T_OBLIGACIONES_DETALLE.NEXTVAL
                  INTO V_ID_COMPROBANTE_DETALLE
                  FROM DUAL;
              
                INSERT INTO T_OBLIGACIONES_DETALLE
                  (ID_OBLIGACION_DETALLE,
                   ID_OBLIGACION,
                   ID_TIPO_CONCEPTO,
                   MONTO_ITEM,
                   INTERESES_ITEM,
                   COBRADO_ITEM,
                   COBRADO_INTERESES_ITEM,
                   USR_ING,
                   FEC_ING,
                   USR_MOD,
                   FEC_MOD)
                VALUES
                  (V_ID_COMPROBANTE_DETALLE,
                   V_ID_COMPROBANTE,
                   R_CONCEPTOS.ID_TIPO_CONCEPTO,
                   DECODE(R_CONCEPTOS.IMPACTO,
                          '-',
                          V_MONTO_ITEM * (-1),
                          V_MONTO_ITEM),
                   0,
                   0,
                   0,
                   P_USR_ING, --USER,  CAMBIAR
                   SYSDATE,
                   NULL,
                   NULL);
              
              END IF;
            END LOOP;
          
            -------------------- genero la tabla comporbantes que es el reporte de liquidacion
            PKG_TRIBUTOS_CONTRIBUYENTES.GENERA_COMPROBANTES_CAB(R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
                                                                1, -- masivo
                                                                0,
                                                                P_ID_COMPROBANTE,
                                                                P_MSG);
            PKG_TRIBUTOS_CONTRIBUYENTES.GENERA_COMPROBANTES_DET(P_ID_COMPROBANTE,
                                                                1,
                                                                V_ID_COMPROBANTE, -- ID_OBLIGACION
                                                                0,
                                                                P_MSG);
          
            SELECT F_GENERA_CODIGO_BARRA(P_ID_COMPROBANTE)
              INTO V_CODIGO_BARRA
              FROM DUAL;
          
            UPDATE T_COMPROBANTES C
               SET COGIDO_BARRA_BANCO  = V_CODIGO_BARRA,
                   MONTO_DEUDA_A_PAGAR =
                   (SELECT SUM(MONTO_DEUDA_ORIG + INTERESES)
                      FROM T_COMPROBANTES_DETALLE
                     WHERE ID_COMPROBANTE = P_ID_COMPROBANTE)
            
             WHERE ID_COMPROBANTE = P_ID_COMPROBANTE;
          
          END LOOP;
        ELSE
          P_MSG := 'NO SE PUDO CALCULAR EL MONTO MENSUAL. ' || V_MONTO_ITEM;
        END IF;
      
        ---- INSERTO CONTROL DE INMUEBLES GENERADOS
        INSERT INTO TMP_TRIBUTOS_GENERADOS
          (ID_TRIBUTO_GENERADO,
           ID_TIPO_TRIBUTO,
           ID_TRIBUTO_CONTRIBUYENTE,
           ANIO_EJERCICIO,
           FECHA,
           GENERADO,
           MONTO)
        VALUES
          (SQ_TMP_TRIBUTOS_GENERADOS.NEXTVAL,
           5,
           R_TRIBUTOS.ID_TRIBUTO_CONTRIBUYENTE,
           V_ANIO,
           SYSDATE,
           'S',
           V_TASA_BASICA);
      
      END LOOP;
      V_ANIO := V_ANIO + 1;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_MSG := 'Error en GENERA_DEVENGAMIENTO_CICI_CM .Verifique: ' ||
               SQLERRM;
    
      INSERT INTO TMP_TRIBUTOS_GENERADOS
        (ID_TRIBUTO_GENERADO,
         ID_TIPO_TRIBUTO,
         ID_TRIBUTO_CONTRIBUYENTE,
         ANIO_EJERCICIO,
         FECHA,
         GENERADO,
         MENSAJE,
         MONTO)
      VALUES
        (SQ_TMP_TRIBUTOS_GENERADOS.NEXTVAL,
         5,
         V_ID_TRIBUTO_CONTRIBUYENTE,
         V_ANIO,
         SYSDATE,
         'N',
         P_MSG,
         V_TASA_BASICA);
  END GENERA_DEVENGAMIENTO_CICI_FIJO;
  

   FUNCTION F_CUMPLIDOR_MAL(P_ID_TRIBUTO_CONTRIBUYENTE IN T_TRIBUTOS_CONTRIBUYENTES.ID_TRIBUTO_CONTRIBUYENTE%TYPE DEFAULT NULL,
                             P_EJERCICIO_LIQ            IN NUMBER DEFAULT NULL) RETURN NUMBER IS
  
    V_CANT    NUMBER:=0;
  
  BEGIN
  
    SELECT COUNT(*)
    INTO V_CANT
    FROM T_OBLIGACIONES O
    WHERE O.ID_TRIBUTO_CONTRIBUYENTE = P_ID_TRIBUTO_CONTRIBUYENTE
    AND O.ESTADO_DEUDA IN ('PP')
    AND O.FEC_BAJA IS NULL
    AND O.FECHA_PRIMER_VENCIMIENTO <= TO_DATE('31/12/' || P_EJERCICIO_LIQ, 'DD/MM/YYYY');
     
  
    RETURN V_CANT;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  
  END F_CUMPLIDOR_MAL;

END PKG_DEVENGAMIENTO_MAL;
/
