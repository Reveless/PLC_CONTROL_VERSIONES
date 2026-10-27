// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 12, 2026
// Module Name:   integer_operation
// Description:   32-bit Integer Arithmetic and Logic Unit (ALU) for PLC.
//                Supports addition, subtraction, multiplication, division,
//                shifts, rotates, bitwise operations, and comparisons.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module integer_operation #(parameter iN = 32'd1) (iA, iB, iALU_Sel, oAlu_result, oSEL, oComparison);

    // Port declarations
    input [31:0] iA, iB;
    input [4:0] iALU_Sel;
    output reg [31:0] oAlu_result;
    output reg oSEL;
    output reg oComparison;

    // Combinational integer operations
    always @(*) begin
        // Default assignments to prevent inferred latches
        oAlu_result = iA;
        oSEL        = 1'b0; // 0 = Integer operation, 1 = FPU operation
        oComparison = 1'b0;

        case (iALU_Sel)
            5'b00000: oAlu_result = iB + iA;                                // ADD
            5'b00001: oAlu_result = iB - iA;                                // SUB
            5'b00010: oAlu_result = iB * iA;                                // MUL
            5'b00011: oAlu_result = (iA != 32'd0) ? (iB / iA) : 32'd0;      // DIV (Zero-check safe)
            5'b00100: oAlu_result = iB << iN;                               // Logical Shift Left
            5'b00101: oAlu_result = iB >> iN;                               // Logical Shift Right
            5'b00110: oAlu_result = (iB << iN) | (iB >> (32 - iN));          // Rotate Left
            5'b00111: oAlu_result = (iB >> iN) | (iB << (32 - iN));          // Rotate Right
            5'b01000: oAlu_result = iB & iA;                                // AND
            5'b01001: oAlu_result = iB | iA;                                // OR
            5'b01010: oAlu_result = iB ^ iA;                                // XOR
            5'b01011: oAlu_result = ~(iB | iA);                             // NOR
            5'b01100: oAlu_result = ~(iB & iA);                             // NAND
            5'b01101: oAlu_result = ~(iB ^ iA);                             // XNOR
            5'b01110: begin                                                 // Greater-than comparison
                oComparison = (iB > iA) ? 1'b1 : 1'b0;
                oAlu_result = {31'd0, oComparison};
            end
            5'b01111: begin                                                 // Equal-to comparison
                oComparison = (iB == iA) ? 1'b1 : 1'b0;
                oAlu_result = {31'd0, oComparison};
            end
            5'b10100: oAlu_result = iA;                                     // ST_W (Store word: transfer accumulator iA to output)
            5'b10101: oAlu_result = iA;                                     // LD_W (Load word accumulator iA)
            default:  oAlu_result = iA;
        endcase
    end

endmodule