// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 13, 2026
// Module Name:   Exeptions_FPU
// Description:   32-bit IEEE-754 Floating Point Exception & Special Case Handler.
//                Evaluates NaN, Infinity, and Zero before arithmetic execution.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module Exeptions_FPU(iclk, iA, iB, iOpcode, iADD_out, iMultiplication_out, oOut, oADD_a_in, oADD_b_in,
                      oMultiplication_a_in, oMultiplication_b_in, oUmbral, oResult);

    // Port declarations
    input iclk;
    input [31:0] iA, iB;
    input [1:0] iOpcode;
    input [31:0] iADD_out;
    input [31:0] iMultiplication_out;

    output [31:0] oOut;
    output reg [31:0] oADD_a_in;
    output reg [31:0] oADD_b_in;
    output reg [31:0] oMultiplication_a_in;
    output reg [31:0] oMultiplication_b_in;
    output reg [31:0] oUmbral;
    output reg [31:0] oResult;

    // Internal interconnect wires
    wire [7:0] a_exponente, b_exponente;
    wire [23:0] a_mantisa, b_mantisa;
    wire a_signo, b_signo;
    wire ADD, SUB, MORE, MUL;

    // Internal result registers
    reg o_signo;
    reg [7:0] o_exponente;
    reg [24:0] o_mantisa;

    // Output assignment
    assign oOut[31]    = o_signo;
    assign oOut[30:23] = o_exponente;
    assign oOut[22:0]  = o_mantisa[22:0];

    // Operand decomposition
    assign a_signo     = iA[31];
    assign a_exponente = iA[30:23];
    assign a_mantisa   = {1'b1, iA[22:0]};

    assign b_signo     = iB[31];
    assign b_exponente = iB[30:23];
    assign b_mantisa   = {1'b1, iB[22:0]};

    // Opcode decoding
    assign ADD  = (!iOpcode[1] && !iOpcode[0]); // 2'b00
    assign SUB  = (!iOpcode[1] &&  iOpcode[0]); // 2'b01
    assign MUL  = ( iOpcode[1] && !iOpcode[0]); // 2'b10
    assign MORE = ( iOpcode[1] &&  iOpcode[0]); // 2'b11

    // Combinational IEEE-754 Exception Handler
    always @(*) begin
        // Default assignments to prevent inferred latches
        oADD_a_in            = iA;
        oADD_b_in            = iB;
        oMultiplication_a_in = iA;
        oMultiplication_b_in = iB;
        oUmbral              = iB;
        oResult              = iA;
        o_signo              = 1'b0;
        o_exponente          = 8'd0;
        o_mantisa            = 25'd0;

        if (ADD) begin
            if ((a_exponente == 8'd255 && a_mantisa[22:0] != 23'd0) || ((b_exponente == 8'd0) && (b_mantisa[22:0] == 23'd0))) begin
                o_signo     = a_signo;
                o_exponente = a_exponente;
                o_mantisa   = {1'b0, a_mantisa};
            end else if ((b_exponente == 8'd255 && b_mantisa[22:0] != 23'd0) || ((a_exponente == 8'd0) && (a_mantisa[22:0] == 23'd0))) begin
                o_signo     = b_signo;
                o_exponente = b_exponente;
                o_mantisa   = {1'b0, b_mantisa};
            end else if ((a_exponente == 8'd255) || (b_exponente == 8'd255)) begin
                o_signo     = a_signo ^ b_signo;
                o_exponente = 8'd255;
                o_mantisa   = 25'd0;
            end else begin
                oADD_a_in   = iA;
                oADD_b_in   = iB;
                o_signo     = iADD_out[31];
                o_exponente = iADD_out[30:23];
                o_mantisa   = {2'b00, iADD_out[22:0]};
            end
        end
        else if (SUB) begin
            if (a_exponente == 8'd255 && a_mantisa[22:0] != 23'd0) begin
                o_signo     = a_signo;
                o_exponente = a_exponente;
                o_mantisa   = {1'b0, a_mantisa};
            end else if (b_exponente == 8'd255 && b_mantisa[22:0] != 23'd0) begin
                o_signo     = ~b_signo;
                o_exponente = b_exponente;
                o_mantisa   = {1'b0, b_mantisa};
            end else if ((a_exponente == 8'd0) && (a_mantisa[22:0] == 23'd0)) begin
                o_signo     = ~b_signo;
                o_exponente = b_exponente;
                o_mantisa   = {1'b0, b_mantisa};
            end else if ((b_exponente == 8'd0) && (b_mantisa[22:0] == 23'd0)) begin
                o_signo     = a_signo;
                o_exponente = a_exponente;
                o_mantisa   = {1'b0, a_mantisa};
            end else if ((a_exponente == 8'd255) || (b_exponente == 8'd255)) begin
                o_signo     = a_signo ^ b_signo;
                o_exponente = 8'd255;
                o_mantisa   = 25'd0;
            end else begin
                oADD_a_in   = iA;
                oADD_b_in   = {~iB[31], iB[30:0]};
                o_signo     = iADD_out[31];
                o_exponente = iADD_out[30:23];
                o_mantisa   = {2'b00, iADD_out[22:0]};
            end
        end
        else if (MUL) begin
            if (a_exponente == 8'd255 && a_mantisa[22:0] != 23'd0) begin
                o_signo     = a_signo;
                o_exponente = 8'd255;
                o_mantisa   = {1'b0, a_mantisa};
            end else if (b_exponente == 8'd255 && b_mantisa[22:0] != 23'd0) begin
                o_signo     = b_signo;
                o_exponente = 8'd255;
                o_mantisa   = {1'b0, b_mantisa};
            end else if (((a_exponente == 8'd0) && (a_mantisa[22:0] == 23'd0)) || ((b_exponente == 8'd0) && (b_mantisa[22:0] == 23'd0))) begin
                o_signo     = 1'b0;
                o_exponente = 8'd0;
                o_mantisa   = 25'd0;
            end else if ((a_exponente == 8'd255) || (b_exponente == 8'd255)) begin
                o_signo     = a_signo;
                o_exponente = 8'd255;
                o_mantisa   = 25'd0;
            end else begin
                oMultiplication_a_in = iA;
                oMultiplication_b_in = iB;
                o_signo              = iMultiplication_out[31];
                o_exponente          = iMultiplication_out[30:23];
                o_mantisa            = {2'b00, iMultiplication_out[22:0]};
            end
        end
        else if (MORE) begin
            if (a_exponente == 8'd255 && a_mantisa[22:0] != 23'd0) begin
                o_signo     = a_signo;
                o_exponente = 8'd255;
                o_mantisa   = {1'b0, a_mantisa};
            end else if (b_exponente == 8'd255 && b_mantisa[22:0] != 23'd0) begin
                o_signo     = b_signo;
                o_exponente = 8'd255;
                o_mantisa   = {1'b0, b_mantisa};
            end else begin
                oUmbral = iB;
                oResult = iA;
            end
        end
    end

endmodule