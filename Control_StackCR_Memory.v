// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 13, 2026
// Module Name:   Control_StackCR_Memory
// Description:   Memory pointer counter module for RAM word and bit channels.
//                Synchronous single-clock domain design for ASIC synthesis.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module Control_StackCR_Memory(iclk, iRESET, iWR_CC_en_sig, iINSTR37_32, iINSTR7_0, oCRW_CH, oCRb_CH);

    // Port declarations
    input iclk, iRESET;
    input iWR_CC_en_sig;
    input [5:0] iINSTR37_32;
    input [7:0] iINSTR7_0;

    output [6:0] oCRW_CH, oCRb_CH;

    // Internal pointer counters
    reg [6:0] CRw_CH_COUNTER;
    reg [6:0] CRb_CH_COUNTER;

    // ------------------------------------------------------------------------
    // Synchronous Memory Pointer Counter Process
    // ------------------------------------------------------------------------
    always @(posedge iclk or posedge iRESET) begin
        if (iRESET) begin
            CRw_CH_COUNTER <= 7'd0;
            CRb_CH_COUNTER <= 7'd0;
        end
        else if (iWR_CC_en_sig) begin
            // Reset counters on Jump to address 0 (JMP 0x00)
            if (iINSTR37_32 == 6'b111101 && iINSTR7_0 == 8'd0) begin
                CRw_CH_COUNTER <= 7'd0;
                CRb_CH_COUNTER <= 7'd0;
            end
            // Increment Bit pointer for comparison instructions with bit outputs
            else if (iINSTR37_32 == 6'b111001 || // Word Greater-than comparison
                     iINSTR37_32 == 6'b111010 || // Word Equal-to comparison
                     iINSTR37_32 == 6'b111011 || // Word Less-than comparison
                     iINSTR37_32 == 6'b101110)   // FPU Greater-than comparison
            begin
                CRb_CH_COUNTER <= CRb_CH_COUNTER + 7'd1;
            end
            // Increment Word pointer for Word instructions
            else if (iINSTR37_32[5] == 1'b1) begin
                CRw_CH_COUNTER <= CRw_CH_COUNTER + 7'd1;
            end
            // Increment Bit pointer for Bit instructions
            else begin
                CRb_CH_COUNTER <= CRb_CH_COUNTER + 7'd1;
            end
        end
    end

    // Continuous assignment outputs
    assign oCRW_CH = CRw_CH_COUNTER;
    assign oCRb_CH = CRb_CH_COUNTER;

endmodule