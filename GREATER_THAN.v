// ============================================================================
// Project:       PLC Microprocessor Core (Version 3.0)
// Developer:     Carlos Hernández
// Date:          August 13, 2026
// Module Name:   GREATER_THAN
// Description:   32-bit IEEE-754 Floating Point Greater-Than Comparator (A > B).
// Target Flow:   Synopsys Design Compiler (DC) / Fusion Compiler (FC)
// ============================================================================

module GREATER_THAN(resultado, umbral, resultado_supera_umbral);

    // Port declarations
    input [31:0] resultado;
    input [31:0] umbral;
    output resultado_supera_umbral;

    // Internal registers
    reg signo_resultado;
    reg signo_umbral;
    reg [23:0] mantisa_resultado;
    reg [23:0] mantisa_umbral;
    reg [7:0] exponente_resultado;
    reg [7:0] exponente_umbral;
    reg resultado_absoluto_supera_umbral;
    reg [7:0] dif_exponentes;
    reg [23:0] tmp_mantisa;

    // Combinational IEEE-754 Floating Point Comparison
    always @(*) begin
        // Default assignments to prevent inferred latches
        resultado_absoluto_supera_umbral = 1'b0;
        dif_exponentes                    = 8'd0;
        tmp_mantisa                       = 24'd0;
        signo_resultado                   = 1'b0;
        signo_umbral                      = 1'b0;
        mantisa_resultado                 = 24'd0;
        mantisa_umbral                    = 24'd0;
        exponente_resultado               = 8'd0;
        exponente_umbral                  = 8'd0;

        // Extract sign, exponent, and mantissa for Operand A (resultado)
        signo_resultado = resultado[31];
        if (resultado[30:23] == 8'd0) begin
            exponente_resultado = 8'b00000001;
            mantisa_resultado   = {1'b0, resultado[22:0]};
        end else begin
            exponente_resultado = resultado[30:23];
            mantisa_resultado   = {1'b1, resultado[22:0]};
        end

        // Extract sign, exponent, and mantissa for Operand B (umbral)
        signo_umbral = umbral[31];
        if (umbral[30:23] == 8'd0) begin
            exponente_umbral = 8'b00000001;
            mantisa_umbral   = {1'b0, umbral[22:0]};
        end else begin
            exponente_umbral = umbral[30:23];
            mantisa_umbral   = {1'b1, umbral[22:0]};
        end

        // Compare operands based on exponents and signs
        if (exponente_resultado == exponente_umbral) begin
            if (signo_resultado == signo_umbral) begin
                resultado_absoluto_supera_umbral = ((signo_resultado) && (mantisa_resultado < mantisa_umbral)) ||
                                                  ((!signo_resultado) && (mantisa_resultado > mantisa_umbral));
            end else begin
                resultado_absoluto_supera_umbral = (signo_resultado) ? 1'b0 :
                                                  ((!signo_resultado) && (mantisa_resultado > mantisa_umbral));
            end
        end
        else if (exponente_resultado > exponente_umbral) begin
            dif_exponentes = exponente_resultado - exponente_umbral;
            tmp_mantisa    = mantisa_umbral >> dif_exponentes;

            if (signo_resultado == signo_umbral) begin
                resultado_absoluto_supera_umbral = ((signo_resultado) && (mantisa_resultado < tmp_mantisa)) ||
                                                  ((!signo_resultado) && (mantisa_resultado > tmp_mantisa));
            end else begin
                resultado_absoluto_supera_umbral = (signo_resultado) ? 1'b0 :
                                                  ((!signo_resultado) && (mantisa_resultado > tmp_mantisa));
            end
        end
        else begin
            dif_exponentes = exponente_umbral - exponente_resultado;
            tmp_mantisa    = mantisa_resultado >> dif_exponentes;

            if (signo_resultado == signo_umbral) begin
                resultado_absoluto_supera_umbral = ((signo_resultado) && (mantisa_umbral < tmp_mantisa)) ||
                                                  ((!signo_resultado) && (tmp_mantisa > mantisa_umbral));
            end else begin
                resultado_absoluto_supera_umbral = (signo_resultado) ? 1'b0 :
                                                  (((!signo_resultado) && (tmp_mantisa > mantisa_umbral)) || (signo_umbral));
            end
        end
    end

    // Output assignment
    assign resultado_supera_umbral = resultado_absoluto_supera_umbral;

endmodule