# Documentación del Núcleo del PLC Microprocesador (Versión 3.0)

Esta documentación detalla la arquitectura de hardware, la organización jerárquica y la función de cada uno de los módulos en Verilog que conforman el procesador, diseñado originalmente para flujos de síntesis ASIC (Synopsys Design Compiler / Fusion Compiler) y adaptado para implementación en FPGA.

---

## 1. Módulo Principal y Estructura Top-Level

- **`Microprocessor_PLC.v`**: Módulo raíz (*Top-Level*). Conecta el datapath, la memoria ROM de programa (`Program_memory`) y la memoria RAM de doble puerto (`dual_port_RAM`), además de exponer los pines físicos de reloj, reset, entradas y salidas hacia el exterior.
- **`datapath.v`**: Ruta de datos principal. Interconecta el contador de programa, la unidad de control, las unidades aritméticas (ALU de 32 bits y ALU de 1 bit), el selector de datos y las memorias scratchpad (`M0_x` y `M1_x`).

---

## 2. Unidad de Control y Máquina de Estados

- **`Control_Unit.v`**: Envolvente de control que unifica el decodificador de instrucciones, el contador de comandos y los decodificadores de las ALUs.
- **`Decoder.v`**: Decodificador de instrucciones. Conecta la máquina de estados finitos (`FS_machine`) con el generador de punteros de pila de registros CR (`Control_StackCR_Memory`).
- **`FS_machine.v`**: Máquina de estados finitos (FSM) de 4 etapas (`initialization`, `Instruction_fetch`, `Decoding`, `Execution`) que gobierna el ciclo de vida de cada instrucción del PLC.
- **`Command_counter.v`**: Contador síncrono de ciclos encargado de gestionar la ejecución de instrucciones que requieren múltiples ciclos de reloj.
- **`Control_StackCR_Memory.v`**: Generador síncrono de punteros de canal para la memoria RAM, diferenciando canales de palabras y de bits.

---

## 3. Decodificadores de ALU

- **`ALU_Decoder.v`**: Envolvente (*wrapper*) que agrupa el decodificador de palabra y el decodificador de bit.
- **`ALU_Word_Decoder.v`**: Traduce el código de operación (*opcode*) de 6 bits a un selector de 5 bits para operaciones aritméticas de 32 bits (enteras y punto flotante).
- **`ALU_Bit_Decoder.v`**: Traduce el código de operación a un selector de 4 bits para operaciones lógicas booleanas de 1 bit.

---

## 4. Unidades Aritméticas y Lógicas (ALU)

- **`ALU_Word.v`**: ALU superior de 32 bits. Multiplexa y ejecuta los resultados provenientes de la unidad entera y de la unidad de punto flotante (FPU), generando las banderas de estado (*carry* y comparación).
- **`integer_operation.v`**: ALU entera de 32 bits. Soporta suma, resta, multiplicación, división, desplazamientos lógicos, rotaciones y operaciones lógicas bit a bit.
- **`ALU_Bits.v`**: ALU combinacional de 1 bit para instrucciones lógicas típicas de PLC (`LD`, `AND`, `OR`, `XOR`, `ORN`, `ANDN`, `XNOR`, `ST`, `LD_neg`).

---

## 5. Subsistema de Punto Flotante (FPU IEEE-754)

- **`FPU_Unit.v`**: Envolvente estructural de la FPU de 32 bits bajo el estándar IEEE-754.
- **`ADD_FPU_UNIT.v`**: Unidad combinacional de suma y resta en punto flotante de 32 bits.
- **`multiply_FPU_Unit.v`**: Unidad multiplicadora en punto flotante de 32 bits.
- **`Exeptions_FPU.v`**: Manejador de casos especiales y excepciones IEEE-754 (evaluación previa de ceros, infinitos y `NaN`).
- **`GREATER_THAN.v`**: Comparador combinacional en punto flotante para evaluar si un resultado supera un umbral ($A > B$).
- **`normalize_ADD_FPU_Unit.v`**: Unidad normalizadora de mantisa y exponente mediante un codificador de prioridad para las operaciones de suma y resta.

---

## 6. Sistema de Memoria y E/S

- **`dual_port_RAM.v`**: Memoria RAM síncrona de doble puerto (128 registros de 32 bits y 128 registros de 1 bit) con inicialización por hardware y lectura/escritura *write-through*.
- **`Program_memory.v`**: Memoria ROM combinacional de instrucciones de 40 bits que almacena el programa a ejecutar (incluyendo la suite de pruebas FPU y de control).
- **`Program_counter.v`**: Contador de programa síncrono de 8 bits con soporte para saltos condicionales/incondicionales e incremento secuencial.
- **`M0_x.v`**: Memoria scratchpad síncrona de bits (32 entradas x 1 bit).
- **`M1_x.v`**: Memoria scratchpad síncrona de palabras (32 entradas x 32 bits).
- **`IO_controller.v`**: Controlador de E/S digitales físicas para las entradas (`iI0_X`) y salidas (`oQ0_X`).
- **`Data_select.v`**: Selector síncrono de datos encargado de enrutar operandos, resultados de ALU y accesos hacia los puertos físicos y las memorias scratchpad.

---

## 7. Archivos de Soporte y Restricciones ASIC

- **`testbench.v`**: Banco de pruebas principal en SystemVerilog/Verilog con simulación temporal, verificación de casos de borde FPU y volcado de ondas FSDB.
- **`PLC.cst`**: Archivo de restricciones físicas de pines (*Physical Constraints*) para la asignación de pines en la FPGA Sipeed Tang Nano 20K.
- **`PLC.sdc`**: Archivo de restricciones de temporización (*Synopsys Design Constraints*) para frecuencias y tiempos de propagación en síntesis.