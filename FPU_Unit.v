// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 13, 2026
// Module Name:   FPU_Unit
// Description:   32-bit IEEE-754 Floating Point Unit (FPU) Top Structural Wrapper.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module FPU_Unit(iclk, iA, iB, iOpcode, oOut, umbral);

    // Port declarations
    input iclk;
    input [31:0] iA, iB;
    input [1:0] iOpcode;
    output [31:0] oOut;
    output umbral;

    // Internal interconnect wires
    wire [31:0] ADD_a_in;
    wire [31:0] ADD_b_in;
    wire [31:0] ADD_out;

    wire [31:0] MUL_a_in;
    wire [31:0] MUL_b_in;
    wire [31:0] MUL_out;
    wire [31:0] Umbral_Data;
    wire [31:0] Result_more;

    // Instantiate Exception Handler with corrected port mapping (.iA(iA), .iB(iB))
    Exeptions_FPU Exeptions_FPU_unit (
        .iclk(iclk),
        .iA(iA),
        .iB(iB),
        .iOpcode(iOpcode),
        .iADD_out(ADD_out),
        .iMultiplication_out(MUL_out),
        .oOut(oOut),
        .oADD_a_in(ADD_a_in),
        .oADD_b_in(ADD_b_in),
        .oMultiplication_a_in(MUL_a_in),
        .oMultiplication_b_in(MUL_b_in),
        .oUmbral(Umbral_Data),
        .oResult(Result_more)
    );

    // Instantiate Floating Point Adder/Subtractor
    ADD_FPU_UNIT Add_FPU_Unit(
        .iA(ADD_a_in),
        .iB(ADD_b_in),
        .out(ADD_out)
    );

    // Instantiate Floating Point Multiplier
    multiply_FPU_Unit multiply(
        .iA(MUL_a_in),
        .iB(MUL_b_in),
        .oOut(MUL_out)
    );

    // Instantiate Floating Point Greater-Than Comparator
    GREATER_THAN MAYOR_QUE(
        .resultado(Result_more),
        .umbral(Umbral_Data),
        .resultado_supera_umbral(umbral)
    );

endmodule