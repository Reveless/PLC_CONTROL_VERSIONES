// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 13, 2026
// Module Name:   multiply_FPU_Unit
// Description:   32-bit IEEE-754 Floating Point Multiplier Unit (A * B).
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module multiply_FPU_Unit(iA, iB, oOut);

    // Port declarations
    input [31:0] iA, iB;
    output [31:0] oOut;

    // Internal registers
    reg a_signo;
    reg [7:0] a_exponente;
    reg [23:0] a_mantisa;

    reg b_signo;
    reg [7:0] b_exponente;
    reg [23:0] b_mantisa;

    reg o_signo;
    reg [7:0] o_exponente;
    reg [24:0] o_mantisa;
    reg [47:0] producto;

    // Connect output register fields to output port
    assign oOut[31]    = o_signo;
    assign oOut[30:23] = o_exponente;
    assign oOut[22:0]  = o_mantisa[22:0];

    // Combinational IEEE-754 Floating Point Multiplication
    always @(*) begin
        // Default assignments to prevent inferred latches
        a_signo     = 1'b0;
        a_exponente = 8'd0;
        a_mantisa   = 24'd0;
        b_signo     = 1'b0;
        b_exponente = 8'd0;
        b_mantisa   = 24'd0;
        o_signo     = 1'b0;
        o_exponente = 8'd0;
        o_mantisa   = 25'd0;
        producto    = 48'd0;

        // Extract sign, exponent, and mantissa for Operand A
        a_signo = iA[31];
        if (iA[30:23] == 8'd0) begin
            a_exponente = 8'b00000001;
            a_mantisa   = {1'b0, iA[22:0]};
        end else begin
            a_exponente = iA[30:23];
            a_mantisa   = {1'b1, iA[22:0]};
        end

        // Extract sign, exponent, and mantissa for Operand B
        b_signo = iB[31];
        if (iB[30:23] == 8'd0) begin
            b_exponente = 8'b00000001;
            b_mantisa   = {1'b0, iB[22:0]};
        end else begin
            b_exponente = iB[30:23];
            b_mantisa   = {1'b1, iB[22:0]};
        end

        // Result Sign: XOR of operand signs
        o_signo = a_signo ^ b_signo;

        // Result Exponent: Sum of exponents minus bias (127)
        o_exponente = a_exponente + b_exponente - 8'd127;

        // Mantissa Product: 24x24 bit unsigned multiplication (1.MA * 1.MB)
        producto = a_mantisa * b_mantisa;

        // IEEE-754 Mantissa Normalization & Extraction
        if (producto[47] == 1'b1) begin
            o_exponente = o_exponente + 8'd1;
            o_mantisa   = {2'b00, producto[46:24]};
        end else begin
            o_mantisa   = {2'b00, producto[45:23]};
        end
    end

endmodule