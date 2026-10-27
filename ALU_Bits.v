// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 12, 2026
// Module Name:   ALU_Bits
// Description:   1-Bit ALU operations for PLC Bit Logic instructions.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module ALU_Bits(iA, iB, iALU_SEL, oALU_Out);

    // Port declarations
    input iA, iB;
    input [3:0] iALU_SEL;
    output reg oALU_Out;

    // Combinational 1-bit ALU operations
    always @(*) begin
        case (iALU_SEL)
            4'd0: oALU_Out = iA;         // LD (Load accumulator)
            4'd1: oALU_Out = iA & iB;    // AND
            4'd2: oALU_Out = iA | iB;    // OR
            4'd3: oALU_Out = iA ^ iB;    // XOR
            4'd4: oALU_Out = iA | ~iB;   // ORN (Accumulator OR NOT operand iB)
            4'd5: oALU_Out = iA & ~iB;   // ANDN (Accumulator AND NOT operand iB)
            4'd6: oALU_Out = ~(iA ^ iB); // XNOR (Explicit parenthesized syntax)
            4'd7: oALU_Out = iA;         // ST (Store: transfer accumulator value iA to output)
            4'd8: oALU_Out = ~iA;        // LD_neg (Load negated operand)
            default: oALU_Out = iA & iB;
        endcase
    end

endmodule