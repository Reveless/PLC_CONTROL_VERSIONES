// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 13, 2026
// Module Name:   Command_counter
// Description:   Multi-cycle command counter for multi-cycle execution steps.
//                Synchronous single-clock domain design for ASIC synthesis.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module Command_counter(iclk, iRESET, iINSTR37_32, iWR_CC_en, oVAL_CC);

    // Port declarations
    input iclk, iRESET;
    input iWR_CC_en;
    input [5:0] iINSTR37_32;
    output [2:0] oVAL_CC;

    // Internal registers and wires
    reg [2:0] counter;
    reg [2:0] WR_CC;

    // ------------------------------------------------------------------------
    // Combinational Command Counter Load Value Decoder
    // ------------------------------------------------------------------------
    always @(*) begin
        case (iINSTR37_32)
            6'b101011: WR_CC = 3'b000; // ADD_R (FP)
            6'b101100: WR_CC = 3'b000; // SUB_R (FP)
            6'b101101: WR_CC = 3'b000; // MUL_R (FP)
            6'b101110: WR_CC = 3'b000; // DIV_R (FP)
            6'b101111: WR_CC = 3'b000; // AND_W
            default:   WR_CC = 3'b000;
        endcase
    end

    // ------------------------------------------------------------------------
    // Synchronous Single-Clock Counter Process
    // ------------------------------------------------------------------------
    always @(posedge iclk or posedge iRESET) begin
        if (iRESET) begin
            counter <= 3'b000;
        end
        else if (iWR_CC_en) begin
            counter <= WR_CC; // Load counter value during Decoding state
        end
        else if (counter != 3'b000) begin
            counter <= counter - 3'b001; // Decrement counter each clock cycle
        end
    end

    // Continuous assignment output
    assign oVAL_CC = counter;

endmodule