// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 13, 2026
// Module Name:   normalize_ADD_FPU_Unit
// Description:   Floating Point Mantissa Normalizer Unit for Addition/Subtraction.
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module normalize_ADD_FPU_Unit(iexpo, imantisa, oexpo, omantisa);

    // Port declarations
    input [7:0] iexpo;
    input [24:0] imantisa;
    output reg [7:0] oexpo;
    output reg [24:0] omantisa;

    // Combinational Normalization Priority Encoder & Shift Logic
    always @(*) begin
        // Default assignments to prevent inferred latches
        oexpo    = iexpo;
        omantisa = imantisa;

        if (imantisa[23:3] == 21'b000000000000000000001) begin
            oexpo    = iexpo - 8'd20;
            omantisa = imantisa << 20;
        end else if (imantisa[23:4] == 20'b00000000000000000001) begin
            oexpo    = iexpo - 8'd19;
            omantisa = imantisa << 19;
        end else if (imantisa[23:5] == 19'b0000000000000000001) begin
            oexpo    = iexpo - 8'd18;
            omantisa = imantisa << 18;
        end else if (imantisa[23:6] == 18'b000000000000000001) begin
            oexpo    = iexpo - 8'd17;
            omantisa = imantisa << 17;
        end else if (imantisa[23:7] == 17'b00000000000000001) begin
            oexpo    = iexpo - 8'd16;
            omantisa = imantisa << 16;
        end else if (imantisa[23:8] == 16'b0000000000000001) begin
            oexpo    = iexpo - 8'd15;
            omantisa = imantisa << 15;
        end else if (imantisa[23:9] == 15'b000000000000001) begin
            oexpo    = iexpo - 8'd14;
            omantisa = imantisa << 14;
        end else if (imantisa[23:10] == 14'b00000000000001) begin
            oexpo    = iexpo - 8'd13;
            omantisa = imantisa << 13;
        end else if (imantisa[23:11] == 13'b0000000000001) begin
            oexpo    = iexpo - 8'd12;
            omantisa = imantisa << 12;
        end else if (imantisa[23:12] == 12'b000000000001) begin
            oexpo    = iexpo - 8'd11;
            omantisa = imantisa << 11;
        end else if (imantisa[23:13] == 11'b00000000001) begin
            oexpo    = iexpo - 8'd10;
            omantisa = imantisa << 10;
        end else if (imantisa[23:14] == 10'b0000000001) begin
            oexpo    = iexpo - 8'd9;
            omantisa = imantisa << 9;
        end else if (imantisa[23:15] == 9'b000000001) begin
            oexpo    = iexpo - 8'd8;
            omantisa = imantisa << 8;
        end else if (imantisa[23:16] == 8'b00000001) begin
            oexpo    = iexpo - 8'd7;
            omantisa = imantisa << 7;
        end else if (imantisa[23:17] == 7'b0000001) begin
            oexpo    = iexpo - 8'd6;
            omantisa = imantisa << 6;
        end else if (imantisa[23:18] == 6'b000001) begin
            oexpo    = iexpo - 8'd5;
            omantisa = imantisa << 5;
        end else if (imantisa[23:19] == 5'b00001) begin
            oexpo    = iexpo - 8'd4;
            omantisa = imantisa << 4;
        end else if (imantisa[23:20] == 4'b0001) begin
            oexpo    = iexpo - 8'd3;
            omantisa = imantisa << 3;
        end else if (imantisa[23:21] == 3'b001) begin
            oexpo    = iexpo - 8'd2;
            omantisa = imantisa << 2;
        end else if (imantisa[23:22] == 2'b01) begin
            oexpo    = iexpo - 8'd1;
            omantisa = imantisa << 1;
        end else begin
            oexpo    = iexpo;
            omantisa = imantisa;
        end
    end

endmodule