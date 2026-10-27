// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 12, 2026
// Module Name:   ALU_Word_Decoder
// Description:   Decodes instruction opcode to 32-Bit Word ALU operation selector.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module ALU_Word_Decoder(iINSTR37_32, oOP_SIG_W);

    // Port declarations
    input [5:0] iINSTR37_32;
    output reg [4:0] oOP_SIG_W;

    // Combinational opcode decoding logic
    always @(*) begin
        case (iINSTR37_32)
            6'b100111: oOP_SIG_W = 5'b00000; // ADD_I
            6'b101000: oOP_SIG_W = 5'b00001; // SUB_I
            6'b101001: oOP_SIG_W = 5'b00010; // MUL_I
            6'b101010: oOP_SIG_W = 5'b00011; // DIV_I
            6'b101011: oOP_SIG_W = 5'b10000; // ADD_R (FP)
            6'b101100: oOP_SIG_W = 5'b10001; // SUB_R (FP)
            6'b101101: oOP_SIG_W = 5'b10010; // MUL_R (FP)
            6'b101110: oOP_SIG_W = 5'b10011; // Greater-than (FP)
            6'b100110: oOP_SIG_W = 5'b10100; // ST_W
            6'b100101: oOP_SIG_W = 5'b10101; // LD_W
            6'b101111: oOP_SIG_W = 5'b00100; // Shift Left
            6'b110000: oOP_SIG_W = 5'b00101; // Shift Right
            6'b110001: oOP_SIG_W = 5'b00110; // Rotate Left
            6'b110010: oOP_SIG_W = 5'b00111; // Rotate Right
            6'b110011: oOP_SIG_W = 5'b01000; // AND
            6'b110100: oOP_SIG_W = 5'b01001; // OR
            6'b110101: oOP_SIG_W = 5'b01010; // XOR
            6'b110110: oOP_SIG_W = 5'b01011; // NOR
            6'b110111: oOP_SIG_W = 5'b01100; // NAND
            6'b111000: oOP_SIG_W = 5'b01101; // XNOR
            6'b111001: oOP_SIG_W = 5'b01110; // Greater-than (Word)
            6'b111010: oOP_SIG_W = 5'b01111; // Equal-to (Word)
            6'b111011: oOP_SIG_W = 5'b10110; // Less-than (Word)
            default:   oOP_SIG_W = 5'b00000;
        endcase
    end

endmodule