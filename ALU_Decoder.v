// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 12, 2026
// Module Name:   ALU_Decoder
// Description:   Top-level ALU Decoder wrapper connecting Bit and Word decoders.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module ALU_Decoder(iINSTR37_32, oOP_SIG_W, oOP_SIG_B);

    // Port declarations
    input [5:0] iINSTR37_32;
    output [4:0] oOP_SIG_W;
    output [3:0] oOP_SIG_B;

    // Instantiate Word ALU Decoder
    ALU_Word_Decoder ALU_W_decode(
        .iINSTR37_32(iINSTR37_32),
        .oOP_SIG_W(oOP_SIG_W)
    );

    // Instantiate Bit ALU Decoder
    ALU_Bit_Decoder ALU_b_decode(
        .iINSTR37_32(iINSTR37_32),
        .oOP_SIG_b(oOP_SIG_B)
    );

endmodule