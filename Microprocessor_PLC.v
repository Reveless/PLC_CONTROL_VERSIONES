// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 12, 2026
// Module Name:   Microprocessor_PLC
// Description:   Top-Level structural module for the PLC Microprocessor.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module Microprocessor_PLC(iCLK, iRESET, iI0_X, oQ0_X);

    input iCLK, iRESET;
    input [7:0] iI0_X;
    output [7:0] oQ0_X;
	
    // Interconnection wires
    wire [7:0] PM_ADDR;
    wire [39:0] INSTRUCTION;
	
    // RAM Word Port
    wire [6:0] PORT_W_ADDR;
    wire [31:0] PORT_W_INPUT;
    wire PORT_W_WR_EN;
    wire [31:0] PORT_W_OUT;

    // RAM Bit Port
    wire [6:0] PORT_B_ADDR;
    wire PORT_B_INPUT;
    wire PORT_B_WR_EN;
    wire PORT_B_OUT;

    // Instantiate Datapath
    datapath Datapath
    (
        .iclk(iCLK),
        .ireset(iRESET),
        .iI0_X(iI0_X),
        .iInstruccion(INSTRUCTION),
        .iPORT_WORD_OUT(PORT_W_OUT),
        .iPORT_BIT_OUT(PORT_B_OUT),
        .oQ0_X(oQ0_X), 
        .oCR_WORD_PORT(PORT_W_ADDR),
        .oCR_BIT_PORT(PORT_B_ADDR),
        .oALU_OUT_WORD(PORT_W_INPUT),
        .oALU_OUT_BIT(PORT_B_INPUT),
        .oWR_WORD_PORT(PORT_W_WR_EN),
        .oWR_BIT_PORT(PORT_B_WR_EN),
        .oPM_ADDR(PM_ADDR)
    );

    // Instantiate Program Memory ROM
    Program_memory Memory_inst
    (
        .iADDR(PM_ADDR), 
        .iclk(iCLK),
        .oINSTR(INSTRUCTION)
    );

    // Instantiate Dual-Port RAM with Reset Connection
    dual_port_RAM RAM_2P
    (
        .iclk(iCLK), 
        .iRESET(iRESET),
        .iPORT_WORD_INPUT(PORT_W_INPUT), 
        .iPORT_BIT_INPUT(PORT_B_INPUT), 
        .iPORT_WORD_ADDR(PORT_W_ADDR), 
        .iPORT_BIT_ADDR(PORT_B_ADDR),
        .iPORT_WORD_WR_EN(PORT_W_WR_EN), 
        .iPORT_BIT_WR_EN(PORT_B_WR_EN), 
        .oPORT_WORD_OUT(PORT_W_OUT), 
        .oPORT_BIT_OUT(PORT_B_OUT)
    );

endmodule