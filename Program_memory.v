// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 13, 2026
// Module Name:   Program_memory
// Description:   Zero-latency combinational Instruction ROM for PLC.
//                FPU Edge-Case Test Suite:
//                1. FP Subtraction: 5.0 - 2.0 = 3.0  (ST_W %MW0 = 32'h40400000)
//                2. FP Zero Mul   : 5.0 * 0.0 = 0.0  (ST_W %MW1 = 32'h00000000)
//                3. FP Neg Sub    : 1.0 - 3.0 = -2.0 (ST_W %MW2 = 32'hC0000000)
//                4. HALT loop at address 0x06.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module Program_memory(iADDR, iclk, oINSTR);

    // Port declarations
    input iclk;
    input [7:0] iADDR;
    output reg [39:0] oINSTR;

    // Combinational Instruction ROM
    always @(*) begin
        case (iADDR)
            8'h00: oINSTR = 40'b00_101100_01000000101000000000000000000000; // SUB_R 5.0 (5.0 - 2.0 = 3.0)
            8'h01: oINSTR = 40'b11_100110_00000000000000000000000000000000; // ST_W  %MW0 (Store 3.0 in M1[0])
            8'h02: oINSTR = 40'b00_101101_01000000101000000000000000000000; // MUL_R 5.0 (5.0 * 0.0 = 0.0)
            8'h03: oINSTR = 40'b11_100110_00000000000000000000000000000001; // ST_W  %MW1 (Store 0.0 in M1[1])
            8'h04: oINSTR = 40'b00_101100_00111111100000000000000000000000; // SUB_R 1.0 (1.0 - 3.0 = -2.0)
            8'h05: oINSTR = 40'b11_100110_00000000000000000000000000000010; // ST_W  %MW2 (Store -2.0 in M1[2])
            8'h06: oINSTR = 40'b00_111101_00000000000000000000000000000110; // JMP   0x06 (HALT loop)
            default: oINSTR = 40'b00_000000_00000000000000000000000000000000;
        endcase
    end

endmodule