// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 13, 2026
// Module Name:   Decoder
// Description:   Instruction Decoder module for the PLC Microprocessor.
//                Instantiates the Finite State Machine (FS_machine) and
//                Control Stack CR Memory, routing control signals to PC and ALU.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module Decoder(iCLK, iINSTR37_32, iINSTR7_0, iRESET, iVAL_CC, oWR_CC_en, oWR_W, oWR_b, oWR_PC,
               oINC_PC, odec, oexe, oCRb_CH, oCRW_CH, oInstr_fetch);

    // Port declarations
    input iCLK, iRESET;
    input [5:0] iINSTR37_32;
    input [7:0] iINSTR7_0;
    input [2:0] iVAL_CC;

    output oWR_CC_en, oWR_W, oWR_b, oWR_PC, oINC_PC, odec, oexe, oInstr_fetch;
    output [6:0] oCRb_CH, oCRW_CH;

    // Internal interconnect wires
    wire WR_PC_wire, INC_PC_wire;
    wire WR_CC_en_sig;

    // Instantiate Finite State Machine (FSM)
    FS_machine FSM(
        .iclk(iCLK),
        .ireset(iRESET),
        .iVAL_CC(iVAL_CC),
        .iINSTR37_32(iINSTR37_32),
        .oINC_PC(INC_PC_wire),
        .oWR_CC_en(oWR_CC_en), 
        .oWR_CC_en_sig(WR_CC_en_sig),
        .oWR_W(oWR_W),
        .oWR_b(oWR_b),
        .oexe(oexe),
        .odec(odec),
        .oWR_PC(WR_PC_wire)
    );

    // Instantiate Control Stack Register Memory with Reset Connection
    Control_StackCR_Memory Stack_current_registers(
        .iclk(iCLK),
        .iRESET(iRESET),
        .iWR_CC_en_sig(WR_CC_en_sig),
        .iINSTR37_32(iINSTR37_32),
        .iINSTR7_0(iINSTR7_0),
        .oCRW_CH(oCRW_CH),
        .oCRb_CH(oCRb_CH)
    );

    // Direct routing of Program Counter write enable from FSM
    assign oWR_PC = WR_PC_wire;
    assign oINC_PC = (odec) ? 1'b0 : INC_PC_wire;
    assign oInstr_fetch = WR_CC_en_sig;

endmodule