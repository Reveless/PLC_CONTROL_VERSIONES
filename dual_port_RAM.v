// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 12, 2026
// Module Name:   dual_port_RAM
// Description:   128-entry Dual-Port Synchronous Register Array RAM with hardware reset.
//                Provides scalable, deterministic zero-state initialization for
//                both 32-bit Word and 1-bit Bit storage.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module dual_port_RAM(iclk, iRESET, iPORT_WORD_INPUT, iPORT_BIT_INPUT, iPORT_WORD_ADDR, iPORT_BIT_ADDR,
                     iPORT_WORD_WR_EN, iPORT_BIT_WR_EN, oPORT_WORD_OUT, oPORT_BIT_OUT);

    // Port declarations
    input iclk, iRESET;
    input iPORT_WORD_WR_EN, iPORT_BIT_WR_EN;
    input [6:0] iPORT_WORD_ADDR, iPORT_BIT_ADDR;
    input [31:0] iPORT_WORD_INPUT;
    input iPORT_BIT_INPUT;

    output reg oPORT_BIT_OUT;
    output reg [31:0] oPORT_WORD_OUT;

    // Memory arrays: 128 registers of 32 bits, and 128 registers of 1 bit
    reg [31:0] RAM_w[127:0];
    reg        RAM_b[127:0];

    integer i;

    // ------------------------------------------------------------------------
    // Port A: 32-bit Word Memory Access with Reset Initialization
    // ------------------------------------------------------------------------
    always @(posedge iclk or posedge iRESET) begin
        if (iRESET) begin
            oPORT_WORD_OUT <= 32'd0;
            for (i = 0; i < 128; i = i + 1) begin
                RAM_w[i] <= 32'd0;
            end
        end
        else if (iPORT_WORD_WR_EN) begin
            RAM_w[iPORT_WORD_ADDR] <= iPORT_WORD_INPUT;
            oPORT_WORD_OUT         <= iPORT_WORD_INPUT; // Write-through output
        end 
        else begin
            oPORT_WORD_OUT         <= RAM_w[iPORT_WORD_ADDR]; // Registered read output
        end
    end

    // ------------------------------------------------------------------------
    // Port B: 1-bit Bit Memory Access with Reset Initialization
    // ------------------------------------------------------------------------
    always @(posedge iclk or posedge iRESET) begin
        if (iRESET) begin
            oPORT_BIT_OUT <= 1'b0;
            for (i = 0; i < 128; i = i + 1) begin
                RAM_b[i] <= 1'b0;
            end
        end
        else if (iPORT_BIT_WR_EN) begin
            RAM_b[iPORT_BIT_ADDR] <= iPORT_BIT_INPUT;
            oPORT_BIT_OUT         <= iPORT_BIT_INPUT; // Write-through output
        end 
        else begin
            oPORT_BIT_OUT         <= RAM_b[iPORT_BIT_ADDR]; // Registered read output
        end
    end

endmodule