// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 12, 2026
// Module Name:   datapath
// Description:   Top Datapath module for the PLC Microprocessor.
//                Interconnects Program Counter, Control Unit, ALU units,
//                Data Selector, IO Controller, and Memory interfaces.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module datapath(iclk, ireset, iI0_X, iInstruccion, iPORT_WORD_OUT, iPORT_BIT_OUT, oQ0_X, oCR_WORD_PORT, oCR_BIT_PORT, oALU_OUT_WORD, oALU_OUT_BIT, oWR_WORD_PORT, oWR_BIT_PORT, oPM_ADDR);

    // Port declarations
    input iclk, ireset;
    input [31:0] iPORT_WORD_OUT;
    input iPORT_BIT_OUT;
    input [7:0] iI0_X;
    input [39:0] iInstruccion;

    output [6:0] oCR_WORD_PORT, oCR_BIT_PORT;
    output [31:0] oALU_OUT_WORD;
    output oALU_OUT_BIT;
    output oWR_WORD_PORT, oWR_BIT_PORT;
    output [7:0] oQ0_X;
    output [7:0] oPM_ADDR;

    // Internal interconnect wires
    wire [7:0] oI0_X;
    wire [7:0] iQ0_X;
    wire INCR_PC;
    wire EXE;
    wire DEC;
    wire WR_PC;
    wire [3:0] ALU2_CONTROL_B;
    wire [4:0] ALU1_CONTROL_W;
    wire [2:0] VAL_CC;
    
    wire ALU_BIT;
    wire oComparison_bit;
    wire ALU_BIT_PORTA;
    wire [31:0] ALU_W_PORTA;

    // Scratchpad memory wires
    wire [4:0] ADDR_M0, ADDR_M1;
    wire WRITE_M0, WRITE_M1;
    wire DATA_IN_M0, DATA_OUT_M0;
    wire [31:0] DATA_IN_M1, DATA_OUT_M1;

    wire fetch_new_intruction;

    // Output bit selection multiplexer
    assign oALU_OUT_BIT = (ALU1_CONTROL_W == 5'b01110) ? oComparison_bit : 
                          (ALU1_CONTROL_W == 5'b01111) ? oComparison_bit : 
                          (ALU1_CONTROL_W == 5'b10110) ? oComparison_bit : 
                          (ALU1_CONTROL_W == 5'b10011) ? oComparison_bit : 
                          ALU_BIT;

    // Instantiate Program Counter
    Program_counter PC
    (
        .iCLK(iclk),
        .iRESET(ireset),
        .iINCR_PC(INCR_PC),
        .iJUMP_ADDR(iInstruccion[7:0]),
        .iWR_PC(WR_PC),
        .oADDR(oPM_ADDR)
    );

    // Instantiate Control Unit
    Control_Unit CONTROL_UNIT
    (
        .iCLK(iclk),
        .iRESET(ireset),
        .iINSTR_opcode(iInstruccion[37:32]),
        .iINSTR7_0(iInstruccion[7:0]),
        .oINCR_PC(INCR_PC),
        .oWR_PC(WR_PC),
        .oDEC(DEC),
        .oALU2_CONTROL_B(ALU2_CONTROL_B),
        .oALU1_CONTROL_W(ALU1_CONTROL_W),
        .oEXEC(EXE),
        .oVAL_CC(VAL_CC),
        .oWR_BIT_PORT(oWR_BIT_PORT),
        .oCR_BIT_PORT(oCR_BIT_PORT),
        .oWR_WORD_PORT(oWR_WORD_PORT),
        .oCR_WORD_PORT(oCR_WORD_PORT),
        .oInstr_fetch(fetch_new_intruction)
    );

    // Instantiate 32-bit Word ALU
    ALU_Word ALU_W
    (
        .iRESET(ireset),
        .iclk(iclk),
        .iEXEC(EXE),
        .iInstr_fetch(fetch_new_intruction),
        .iDEC(DEC),
        .iVAL_CC(VAL_CC),
        .iA(ALU_W_PORTA),
        .iB(iPORT_WORD_OUT),
        .iALU_SEL(ALU1_CONTROL_W),
        .oALU_OUT(oALU_OUT_WORD),
        .oCARRY_OUT(),
        .oComparison(oComparison_bit)
    );

    // Instantiate 1-bit Bit ALU
    ALU_Bits ALU_B
    (
        .iA(ALU_BIT_PORTA),
        .iB(iPORT_BIT_OUT),
        .iALU_SEL(ALU2_CONTROL_B),
        .oALU_Out(ALU_BIT)
    );

    // Instantiate Data Selector with Execution State Connection (.iEXEC(EXE))
    Data_select DATA_SELECT
    (
        .iclk(iclk),
        .iRESET(ireset),
        .iDEC(DEC),
        .iEXEC(EXE),
        .iINSTR(iInstruccion),
        .iI0_X(oI0_X),
        .iALU_W_RESULT(oALU_OUT_WORD),
        .iALU_BIT_RESULT(oALU_OUT_BIT),
        .iData_OUT_BIT_M0(DATA_OUT_M0),
        .iData_OUT_W_M1(DATA_OUT_M1),
        .oQ0_X(iQ0_X),
        .oALU_WORD_DATA_A(ALU_W_PORTA),
        .oALU_BIT_DATA_A(ALU_BIT_PORTA),
        .oADDR_M0(ADDR_M0),
        .oADDR_M1(ADDR_M1),
        .oWrite_ena_M0(WRITE_M0),
        .oWrite_ena_M1(WRITE_M1),
        .oData_In_M0(DATA_IN_M0),
        .oData_In_M1(DATA_IN_M1)
    );

    // Instantiate IO Controller
    IO_controller IO_CTRL
    (
        .iRESET(ireset),
        .iCLK(iclk),
        .iQ0_X(iQ0_X),
        .iI0_X(iI0_X),
        .oQ0_X(oQ0_X),
        .oI0_X(oI0_X)
    );

    // Instantiate Scratchpad Memory M0 (Bit Memory)
    M0_x M0X
    (
        .iclk(iclk),
        .iRESET(ireset),
        .iADDR(ADDR_M0),
        .iWrite(WRITE_M0),
        .iDATA(DATA_IN_M0),
        .oDATA(DATA_OUT_M0)
    );

    // Instantiate Scratchpad Memory M1 (Word Memory)
    M1_x M1X
    (
        .iclk(iclk),
        .iRESET(ireset),
        .iADDR(ADDR_M1),
        .iWrite(WRITE_M1),
        .iDATA(DATA_IN_M1),
        .oDATA(DATA_OUT_M1)
    );

endmodule