`timescale 1ns/1ps

module testbench;

    reg clk;
    reg reset;
    reg [7:0] inputs;
    wire [7:0] outputs;

    // Shortreal variables for printing floating point values
    shortreal res1_fp, exp1_fp;
    shortreal res2_fp, exp2_fp;
    shortreal res3_fp, exp3_fp;

    // Instantiate Top PLC Microprocessor
    Microprocessor_PLC uut (
        .iCLK(clk),
        .iRESET(reset),
        .iI0_X(inputs),
        .oQ0_X(outputs)
    );

    // Clock generation: 20ns period (50MHz)
    always #10 clk = ~clk;

    initial begin
        // Setup FSDB waveform dumping for Verdi
        $fsdbDumpfile("inter.fsdb");
        $fsdbDumpvars(0, testbench);

        // Initialize signals
        clk = 0;
        reset = 1;
        inputs = 8'd0;

        // Hold reset for 20ns
        #20;
        reset = 0;

        // Pre-initialize RAM_2P word registers AFTER reset release
        #10;
        uut.RAM_2P.RAM_w[0] = 32'h40000000; // FP 2.0
        uut.RAM_2P.RAM_w[1] = 32'h40000000; // FP 2.0 (For Test 1 Subtraction: 5.0 - 2.0 = 3.0)
        uut.RAM_2P.RAM_w[2] = 32'h00000000; // FP 0.0
        uut.RAM_2P.RAM_w[3] = 32'h00000000; // FP 0.0 (For Test 2 Zero Mul   : 5.0 * 0.0 = 0.0)
        uut.RAM_2P.RAM_w[4] = 32'h40400000; // FP 3.0
        uut.RAM_2P.RAM_w[5] = 32'h40400000; // FP 3.0 (For Test 3 Neg Sub   : 1.0 - 3.0 = -2.0)

        $display("==========================================================");
        $display("  PLC 32-BIT IEEE-754 FPU EDGE-CASE SUITE VERIFICATION");
        $display("  Developer: Carlos Hernández | Version: 3.0");
        $display("==========================================================");
        $display("  [Setup] RAM_2P Pre-loaded: RAM_w[1]=2.0, RAM_w[3]=0.0, RAM_w[5]=3.0");
        $display("  [Setup] Execution Flow: SUB_R(5-2) -> %MW0 | MUL_R(5*0) -> %MW1 | SUB_R(1-3) -> %MW2 -> HALT");
        $display("==========================================================");

        // Wait for complete program execution into HALT loop (420ns total)
        #420;

        // Convert 32-bit IEEE-754 float bit patterns to shortreal numbers
        res1_fp = $bitstoshortreal(uut.Datapath.M1X.RAM_w[0]);
        exp1_fp = $bitstoshortreal(32'h40400000);

        res2_fp = $bitstoshortreal(uut.Datapath.M1X.RAM_w[1]);
        exp2_fp = $bitstoshortreal(32'h00000000);

        res3_fp = $bitstoshortreal(uut.Datapath.M1X.RAM_w[2]);
        exp3_fp = $bitstoshortreal(32'hC0000000);

        $display("");
        $display("--- [EDGE-TEST 1] FLOATING POINT SUBTRACTION: 5.0 - 2.0 = 3.0 ---");
        $display("    Description : Execute SUB_R 5.0 with RAM[1]=2.0 and store result in %%MW0");
        $display("    Readout HEX : Scratchpad M1[0] (%%MW0) = 32'h%h", uut.Datapath.M1X.RAM_w[0]);
        $display("    Readout FP  : Scratchpad M1[0] (%%MW0) = %f", res1_fp);
        $display("    Expected HEX: 32'h40400000 | Expected FP: %f", exp1_fp);
        if (uut.Datapath.M1X.RAM_w[0] == 32'h40400000) begin
            $display("    >>> EDGE-TEST 1 STATUS: PASSED (FP SUBTRACTION SUCCESSFUL: %f == %f) <<<", res1_fp, exp1_fp);
        end else begin
            $display("    >>> EDGE-TEST 1 STATUS: FAILED (Expected %f [32'h40400000], Got %f [32'h%h]) <<<", exp1_fp, res1_fp, uut.Datapath.M1X.RAM_w[0]);
        end

        $display("");
        $display("--- [EDGE-TEST 2] FLOATING POINT MULTIPLICATION BY ZERO: 5.0 * 0.0 = 0.0 ---");
        $display("    Description : Execute MUL_R 5.0 with RAM[3]=0.0, store in %%MW1");
        $display("    Readout HEX : Scratchpad M1[1] (%%MW1) = 32'h%h", uut.Datapath.M1X.RAM_w[1]);
        $display("    Readout FP  : Scratchpad M1[1] (%%MW1) = %f", res2_fp);
        $display("    Expected HEX: 32'h00000000 | Expected FP: %f", exp2_fp);
        if (uut.Datapath.M1X.RAM_w[1] == 32'h00000000) begin
            $display("    >>> EDGE-TEST 2 STATUS: PASSED (FP ZERO-MUL SUCCESSFUL: %f == %f) <<<", res2_fp, exp2_fp);
        end else begin
            $display("    >>> EDGE-TEST 2 STATUS: FAILED (Expected %f [32'h00000000], Got %f [32'h%h]) <<<", exp2_fp, res2_fp, uut.Datapath.M1X.RAM_w[1]);
        end

        $display("");
        $display("--- [EDGE-TEST 3] FLOATING POINT NEGATIVE SUBTRACTION: 1.0 - 3.0 = -2.0 ---");
        $display("    Description : Execute SUB_R 1.0 with RAM[5]=3.0, store in %%MW2");
        $display("    Readout HEX : Scratchpad M1[2] (%%MW2) = 32'h%h", uut.Datapath.M1X.RAM_w[2]);
        $display("    Readout FP  : Scratchpad M1[2] (%%MW2) = %f", res3_fp);
        $display("    Expected HEX: 32'hC0000000 | Expected FP: %f", exp3_fp);
        if (uut.Datapath.M1X.RAM_w[2] == 32'hC0000000) begin
            $display("    >>> EDGE-TEST 3 STATUS: PASSED (FP NEGATIVE SUB SUCCESSFUL: %f == %f) <<<", res3_fp, exp3_fp);
        end else begin
            $display("    >>> EDGE-TEST 3 STATUS: FAILED (Expected %f [32'hC0000000], Got %f [32'h%h]) <<<", exp3_fp, res3_fp, uut.Datapath.M1X.RAM_w[2]);
        end

        $display("==========================================================");
        #40;
        $finish;
    end

endmodule