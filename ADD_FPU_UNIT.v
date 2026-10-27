// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 13, 2026
// Module Name:   ADD_FPU_UNIT
// Description:   32-bit IEEE-754 Floating Point Adder/Subtractor Unit (A +/- B).
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module ADD_FPU_UNIT(iA, iB, out);

    // Port declarations
    input [31:0] iA, iB;
    output [31:0] out;

    // Internal registers
    reg a_signo;
    reg [7:0] a_exponente;
    reg [23:0] a_mantisa;

    reg b_signo;
    reg [7:0] b_exponente;
    reg [23:0] b_mantisa;

    reg o_signo;
    reg [7:0] o_exponente;
    reg [24:0] o_mantisa;

    reg [7:0] dif_exponentes;
    reg [23:0] tmp_mantisa;
    reg [7:0] tmp_exponente;

    reg [7:0] i_e;
    reg [24:0] i_m;
    wire [7:0] o_e;
    wire [24:0] o_m;

    // Output assignment
    assign out[31]    = o_signo;
    assign out[30:23] = o_exponente;
    assign out[22:0]  = o_mantisa[22:0];

    // Instantiate Mantissa Normalizer Unit
    normalize_ADD_FPU_Unit Normalize_add(
        .iexpo(i_e),
        .imantisa(i_m),
        .oexpo(o_e),
        .omantisa(o_m)
    );

    // Combinational IEEE-754 Floating Point Addition / Subtraction
    always @(*) begin
        // Default initializations to prevent inferred latches
        a_signo        = 1'b0;
        a_exponente    = 8'd0;
        a_mantisa      = 24'd0;
        b_signo        = 1'b0;
        b_exponente    = 8'd0;
        b_mantisa      = 24'd0;
        o_signo        = 1'b0;
        o_exponente    = 8'd0;
        o_mantisa      = 25'd0;
        dif_exponentes = 8'd0;
        tmp_mantisa    = 24'd0;
        tmp_exponente  = 8'd0;
        i_e            = 8'd0;
        i_m            = 25'd0;

        // Extract sign, exponent, and mantissa for Operand A
        a_signo = iA[31];
        if (iA[30:23] == 8'd0) begin
            a_exponente = 8'b00000001;
            a_mantisa   = {1'b0, iA[22:0]};
        end else begin
            a_exponente = iA[30:23];
            a_mantisa   = {1'b1, iA[22:0]};
        end

        // Extract sign, exponent, and mantissa for Operand B
        b_signo = iB[31];
        if (iB[30:23] == 8'd0) begin
            b_exponente = 8'b00000001;
            b_mantisa   = {1'b0, iB[22:0]};
        end else begin
            b_exponente = iB[30:23];
            b_mantisa   = {1'b1, iB[22:0]};
        end

        // Equal Exponents Case
        if (a_exponente == b_exponente) begin
            o_exponente = a_exponente;
            if (a_signo == b_signo) begin
                o_mantisa     = a_mantisa + b_mantisa;
                o_mantisa[24] = 1'b1;
                o_signo       = a_signo;
            end else begin
                if (a_mantisa > b_mantisa) begin
                    o_mantisa = a_mantisa - b_mantisa;
                    o_signo   = a_signo;
                end else begin
                    o_mantisa = b_mantisa - a_mantisa;
                    o_signo   = b_signo;
                end
            end
        end
        // Unequal Exponents Case
        else begin
            if (a_exponente > b_exponente) begin
                o_exponente    = a_exponente;
                o_signo        = a_signo;
                dif_exponentes = a_exponente - b_exponente;
                tmp_mantisa    = b_mantisa >> dif_exponentes;

                if (a_signo == b_signo)
                    o_mantisa = a_mantisa + tmp_mantisa;
                else
                    o_mantisa = a_mantisa - tmp_mantisa;
            end else begin
                o_exponente    = b_exponente;
                o_signo        = b_signo;
                dif_exponentes = b_exponente - a_exponente;
                tmp_mantisa    = a_mantisa >> dif_exponentes;

                if (a_signo == b_signo)
                    o_mantisa = b_mantisa + tmp_mantisa;
                else
                    o_mantisa = b_mantisa - tmp_mantisa;
            end
        end

        // Overflow & Normalization Check
        if (o_mantisa[24] == 1'b1) begin
            o_exponente = o_exponente + 8'd1;
            o_mantisa   = o_mantisa >> 1;
        end
        else if ((o_mantisa[23] != 1'b1) && (o_exponente != 8'd0)) begin
            i_e         = o_exponente;
            i_m         = o_mantisa;
            o_exponente = o_e;
            o_mantisa   = o_m;
        end
    end

endmodule