// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 12, 2026
// Module Name:   ALU_Word
// Description:   32-bit Word ALU Top wrapper for Integer & Floating Point Unit (FPU).
//                Uses single-clock domain execution for Synopsys synthesis.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module ALU_Word(iRESET, iclk, iEXEC, iInstr_fetch, iDEC, iVAL_CC, iA, iB, iALU_SEL, oALU_OUT, oCARRY_OUT, oComparison);

    // Port declarations
    input iRESET, iclk;
    input iEXEC, iInstr_fetch, iDEC;
    input [2:0] iVAL_CC;
    input [31:0] iA, iB;
    input [4:0] iALU_SEL;

    output [31:0] oALU_OUT;
    output reg oCARRY_OUT;
    output reg oComparison;

    // Internal interconnect wires
    wire umbral;
    wire oComparison1;
    wire [31:0] ALU_result;
    wire [31:0] out_fpu;
    wire [31:0] out_ALu_enteros;
    wire [1:0] iopcode;
    wire oSEL, oSEL_2;
    wire comparacion;
    wire [32:0] sum_tmp;

    // Opcode mapping for Floating Point Unit (FPU)
    assign iopcode = (iALU_SEL == 5'b10000) ? 2'b00 : // FP Addition
                     (iALU_SEL == 5'b10001) ? 2'b01 : // FP Subtraction
                     (iALU_SEL == 5'b10010) ? 2'b10 : // FP Multiplication
                     (iALU_SEL == 5'b10011) ? 2'b11 : // FP Greater-than comparison
                     2'b00;

    assign oSEL = (iALU_SEL == 5'b10000) ? 1'b1 : // FP Addition
                  (iALU_SEL == 5'b10001) ? 1'b1 : // FP Subtraction
                  (iALU_SEL == 5'b10010) ? 1'b1 : // FP Multiplication
                  (iALU_SEL == 5'b10011) ? 1'b1 : // FP Greater-than
                  oSEL_2;

    // Instantiate Integer ALU Submodule
    integer_operation enteros(
        .iA(iA),
        .iB(iB),
        .iALU_Sel(iALU_SEL),
        .oAlu_result(out_ALu_enteros),
        .oSEL(oSEL_2),
        .oComparison(oComparison1)
    );

    // Instantiate Floating Point Unit (FPU) Submodule
    FPU_Unit floating_point(
        .iclk(iclk),
        .iA(iA),
        .iB(iB),
        .iOpcode(iopcode),
        .oOut(out_fpu),
        .umbral(umbral)
    );

    // Multiplex between Floating Point and Integer ALU results
    assign ALU_result  = (oSEL == 1'b1) ? out_fpu : out_ALu_enteros;
    assign comparacion = (oSEL == 1'b1) ? umbral  : oComparison1;

    // Direct combinational 32-bit Word ALU result output
    assign oALU_OUT = ALU_result;

    // 33-bit temporary sum for accurate Carry-Out generation
    assign sum_tmp = {1'b0, iA} + {1'b0, iB};

    // Synchronous execution status flags
    always @(posedge iclk or posedge iRESET) begin
        if (iRESET) begin
            oCARRY_OUT  <= 1'b0;
            oComparison <= 1'b0;
        end
        else if (iEXEC) begin
            oComparison <= comparacion;
            if (iVAL_CC == 3'b000) begin
                oCARRY_OUT <= (iALU_SEL == 5'b00000 || iALU_SEL == 5'b00001) ? sum_tmp[32] : 1'b0;
            end
        end
    end

endmodule