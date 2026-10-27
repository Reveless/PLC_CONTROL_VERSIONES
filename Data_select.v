// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 13, 2026
// Module Name:   Data_select
// Description:   Synchronous Data Selector & Output Register module for PLC.
//                Routes input signals, ALU results, and memory outputs.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module Data_select(iclk, iRESET, iDEC, iEXEC, iINSTR, iI0_X, iALU_W_RESULT, iALU_BIT_RESULT, iData_OUT_BIT_M0,
                    iData_OUT_W_M1, oQ0_X, oALU_WORD_DATA_A,
                    oALU_BIT_DATA_A, oADDR_M0, oADDR_M1, oWrite_ena_M0, oWrite_ena_M1, oData_In_M0, oData_In_M1);

    // Port declarations
    input iclk, iRESET, iDEC, iEXEC;
    input [39:0] iINSTR;
    input [7:0] iI0_X;
    input [31:0] iALU_W_RESULT;
    input iALU_BIT_RESULT;
    input iData_OUT_BIT_M0;
    input [31:0] iData_OUT_W_M1;

    output reg [7:0] oQ0_X;
    output reg [31:0] oALU_WORD_DATA_A;
    output reg oALU_BIT_DATA_A;
    output reg [4:0] oADDR_M0, oADDR_M1;
    output reg oWrite_ena_M0, oWrite_ena_M1;
    output reg oData_In_M0;
    output reg [31:0] oData_In_M1;

    // Internal analog input registers
    reg [11:0] Analog_input[7:0];

    // ------------------------------------------------------------------------
    // Synchronous Data Routing & Output Store Process
    // ------------------------------------------------------------------------
    always @(posedge iclk or posedge iRESET) begin
        if (iRESET) begin
            oQ0_X            <= 8'd0;
            oALU_WORD_DATA_A <= 32'd0;
            oALU_BIT_DATA_A  <= 1'b0;
            oADDR_M0         <= 5'd0;
            oADDR_M1         <= 5'd0;
            oWrite_ena_M0    <= 1'b0;
            oWrite_ena_M1    <= 1'b0;
            oData_In_M0      <= 1'b0;
            oData_In_M1      <= 32'd0;
        end
        else begin
            // Default write enables
            oWrite_ena_M0 <= 1'b0;
            oWrite_ena_M1 <= 1'b0;

            // Operand Routing during Decoding State (iDEC = 1)
            if (iDEC) begin
                if (iINSTR[39:38] == 2'b00) begin
                    // Literal Instruction Format (2'b00): iINSTR[31:0] is Operand A
                    oALU_WORD_DATA_A <= iINSTR[31:0];
                    oALU_BIT_DATA_A  <= iI0_X[iINSTR[2:0]];
                end
                else if (iINSTR[39:38] == 2'b11) begin
                    // Load 32-bit Word Memory M1 (Only on LD_W opcode 6'b100101)
                    oADDR_M1 <= iINSTR[4:0];
                    if (iINSTR[37:32] == 6'b100101) begin
                        oALU_WORD_DATA_A <= iData_OUT_W_M1;
                    end
                end
                else if (iINSTR[39:38] == 2'b01) begin
                    // Load Bit Memory M0 (Only on LD opcode 6'b000000)
                    oADDR_M0 <= iINSTR[4:0];
                    if (iINSTR[37:32] == 6'b000000) begin
                        oALU_BIT_DATA_A <= iData_OUT_BIT_M0;
                    end
                end
                else if (iINSTR[39:38] == 2'b10) begin
                    if (iINSTR[37:32] == 6'b000000) begin
                        // Load Output Port Status
                        oALU_BIT_DATA_A <= oQ0_X[iINSTR[2:0]];
                    end
                end
            end

            // Accumulate Word ALU Result strictly during Execution State (iEXEC = 1)
            if (iEXEC) begin
                if (iINSTR[37:32] >= 6'b100111 && iINSTR[37:32] <= 6'b110011 && iINSTR[37:32] != 6'b100110) begin
                    oALU_WORD_DATA_A <= iALU_W_RESULT;
                end

                // Accumulate Bit ALU Result strictly during Execution State (iEXEC = 1)
                if (iINSTR[37:32] >= 6'b000001 && iINSTR[37:32] <= 6'b000110) begin
                    oALU_BIT_DATA_A <= iALU_BIT_RESULT;
                end
            end

            // Store Bit Result to Physical Output Port (ST %Q0.X)
            if (iINSTR[39:38] == 2'b10 && iINSTR[37:32] == 6'b000111) begin
                oQ0_X[iINSTR[2:0]] <= iALU_BIT_RESULT;
            end

            // Store Word Result to Scratchpad M1 (ST_W %MWX)
            if (iINSTR[39:38] == 2'b11 && iINSTR[37:32] == 6'b100110) begin
                oADDR_M1      <= iINSTR[4:0];
                oData_In_M1   <= iALU_W_RESULT;
                oWrite_ena_M1 <= 1'b1;
            end

            // Store Bit Result to Scratchpad M0 (ST_b %M0.X)
            if (iINSTR[39:38] == 2'b01 && iINSTR[37:32] == 6'b000111) begin
                oADDR_M0      <= iINSTR[4:0];
                oData_In_M0   <= iALU_BIT_RESULT;
                oWrite_ena_M0 <= 1'b1;
            end
        end
    end

endmodule