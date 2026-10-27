// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 12, 2026
// Module Name:   M0_x
// Description:   32-entry x 1-bit Synchronous Bit Scratchpad Memory (M0).
//                Synthesizes clean Flip-Flops in Synopsys Design Compiler.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module M0_x(iclk, iRESET, iADDR, iWrite, iDATA, oDATA);

    // Port declarations
    input iclk, iRESET;
    input iWrite;
    input iDATA;
    input [4:0] iADDR;
    output reg oDATA;

    // 32 x 1-bit memory array
    reg RAM_b[31:0];

    integer i;

    // Synchronous Read/Write and Hardware Reset Process
    always @(posedge iclk or posedge iRESET) begin
        if (iRESET) begin
            oDATA <= 1'b0;
            for (i = 0; i < 32; i = i + 1) begin
                RAM_b[i] <= 1'b0;
            end
        end
        else if (iWrite) begin
            RAM_b[iADDR] <= iDATA;
            oDATA        <= iDATA; // Write-through output
        end
        else begin
            oDATA        <= RAM_b[iADDR]; // Registered read output
        end
    end

endmodule