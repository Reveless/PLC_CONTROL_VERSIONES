// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 12, 2026
// Module Name:   ALU_Bit_Decoder
// Description:   Decodes instruction opcode to 1-Bit ALU operation selector.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module ALU_Bit_Decoder(iINSTR37_32, oOP_SIG_b);

    // Port declarations
    input [5:0] iINSTR37_32;
    output reg [3:0] oOP_SIG_b;

    // Combinational opcode decoding logic
    always @(*) begin
        case (iINSTR37_32)
            6'b000000: oOP_SIG_b = 4'd0; // LD
            6'b000001: oOP_SIG_b = 4'd1; // AND
            6'b000010: oOP_SIG_b = 4'd2; // OR
            6'b000011: oOP_SIG_b = 4'd3; // XOR
            6'b000100: oOP_SIG_b = 4'd4; // ORN
            6'b000101: oOP_SIG_b = 4'd5; // ANDN
            6'b000110: oOP_SIG_b = 4'd6; // XNOR
            6'b000111: oOP_SIG_b = 4'd7; // ST
            6'b001000: oOP_SIG_b = 4'd8; // LD_neg
            default:   oOP_SIG_b = 4'd0;
        endcase
    end

endmodule