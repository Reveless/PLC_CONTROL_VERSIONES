// ============================================================================
// Module Name:   Program_counter
// Description:   Program Counter for the PLC Microprocessor.
//                Manages sequential instruction fetching and branch/jump
//                address loading in a synchronous single-clock design.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module Program_counter(iCLK, iRESET, iINCR_PC, iJUMP_ADDR, iWR_PC, oADDR);

    // Port declarations
    input iCLK, iRESET;
    input iINCR_PC, iWR_PC;
    input [7:0] iJUMP_ADDR;
    output [7:0] oADDR;

    // Internal register declaration
    reg [7:0] counter;

    // Synchronous program counter control process
    always @(posedge iCLK or posedge iRESET) begin
        if (iRESET) begin
            // Reset program counter to address 0x00 upon system reset
            counter <= 8'd0;
        end 
        else if (iWR_PC) begin
            // Highest priority: Load branch/jump target address (JMP instruction)
            counter <= iJUMP_ADDR;
        end 
        else if (iINCR_PC) begin
            // Sequential execution: Increment program counter during fetch phase
            counter <= counter + 8'd1;
        end
        // Default implicit behavior: Hold current address value when idle
    end

    // Assign internal counter register to output address bus
    assign oADDR = counter;

endmodule