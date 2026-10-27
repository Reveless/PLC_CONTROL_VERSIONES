// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 12, 2026
// Module Name:   M1_x
// Description:   32-entry x 32-bit Synchronous Word Scratchpad Memory (M1).
//                Synthesizes clean Flip-Flops in Synopsys Design Compiler.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module M1_x(iclk, iRESET, iADDR, iWrite, iDATA, oDATA);

    // Port declarations
    input iclk, iRESET;
    input iWrite;
    input [31:0] iDATA;
    input [4:0] iADDR;
    output reg [31:0] oDATA;

    // 32 x 32-bit memory array
    reg [31:0] RAM_w[31:0];

    integer i;

    // Synchronous Read/Write and Hardware Reset Process
    always @(posedge iclk or posedge iRESET) begin
        if (iRESET) begin
            oDATA <= 32'd0;
            for (i = 0; i < 32; i = i + 1) begin
                RAM_w[i] <= 32'd0;
            end
        end
        else if (iWrite) begin
            RAM_w[iADDR] <= iDATA;
            oDATA        <= iDATA; // Write-through output
        end
        else begin
            oDATA        <= RAM_w[iADDR]; // Registered read output
        end
    end

endmodule