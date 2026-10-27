// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 13, 2026
// Module Name:   Control_Unit
// Description:   Top Control Unit module for the PLC Microprocessor.
//                Interconnects Instruction Decoder, Command Counter,
//                and ALU Control Decoders.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module Control_Unit(iCLK, iRESET, iINSTR_opcode, iINSTR7_0, oINCR_PC, oWR_PC, oDEC, oALU2_CONTROL_B,
                    oALU1_CONTROL_W, oEXEC, oVAL_CC, oWR_BIT_PORT, oCR_BIT_PORT, oWR_WORD_PORT,
                    oCR_WORD_PORT, oInstr_fetch);

    // Port declarations
    input iCLK, iRESET;
    input [5:0] iINSTR_opcode;
    input [7:0] iINSTR7_0;

    output oINCR_PC, oWR_PC, oDEC, oInstr_fetch;
    output [3:0] oALU2_CONTROL_B;
    output [4:0] oALU1_CONTROL_W;
    output oEXEC, oWR_BIT_PORT, oWR_WORD_PORT;
    output [6:0] oCR_BIT_PORT, oCR_WORD_PORT;
    output [2:0] oVAL_CC;

    // Internal interconnect wires
    wire WR_CC_en;

    // Instantiate Instruction Decoder
    Decoder Decode(
        .iCLK(iCLK),
        .iINSTR37_32(iINSTR_opcode),
        .iINSTR7_0(iINSTR7_0),
        .iRESET(iRESET),
        .iVAL_CC(oVAL_CC),
        .oWR_CC_en(WR_CC_en),
        .oWR_W(oWR_WORD_PORT),
        .oWR_b(oWR_BIT_PORT),
        .oWR_PC(oWR_PC),
        .oINC_PC(oINCR_PC),
        .odec(oDEC),
        .oexe(oEXEC),
        .oCRb_CH(oCR_BIT_PORT),
        .oCRW_CH(oCR_WORD_PORT),
        .oInstr_fetch(oInstr_fetch)
    );

    // Instantiate Command Counter with Reset Connection
    Command_counter Comand_count(
        .iclk(iCLK),
        .iRESET(iRESET),
        .iINSTR37_32(iINSTR_opcode),
        .iWR_CC_en(WR_CC_en),
        .oVAL_CC(oVAL_CC)
    );

    // Instantiate ALU Decoder
    ALU_Decoder ALU_Decode(
        .iINSTR37_32(iINSTR_opcode),
        .oOP_SIG_W(oALU1_CONTROL_W),
        .oOP_SIG_B(oALU2_CONTROL_B)
    );

endmodule