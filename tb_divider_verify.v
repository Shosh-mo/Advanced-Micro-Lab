`timescale 1ns/1ps

module tb_divider_verify();

    reg  clk;
    reg  rst;
    reg  start;
    reg  [35:0] dividend;
    reg  [17:0] divider;

    wire [17:0] nr_quotient;
    wire [17:0] ref_quotient;

    wire [17:0] nr_quotient_int;
    assign nr_quotient_int = (nr_quotient + 18'h100) >> 9;

    Newton_Raphson_Divider dut (
        .clk      (clk),
        .rst      (rst),
        .start    (start),
        .dividend (dividend),
        .divider  (divider),
        .quotient (nr_quotient)
    );

    reference_non_restoring_divider ref_model (
        .dividend (dividend[17:0]),
        .divisor  (divider),
        .quotient (ref_quotient)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("divider_verify.vcd");
        $dumpvars(0, tb_divider_verify);

        clk   = 0;
        rst   = 1;
        start = 0;
        #20;
        rst = 0;
        @(posedge clk); #1;

        // ── Valid range divisors (no prescaling needed) ───────────
        run_test(36'h000000400, 18'h00200, "TC1:  2.0 / 1.0  = 2  [D in range] ");
        run_test(36'h000000300, 18'h00180, "TC2:  1.5 / 0.75 = 2  [D in range] ");
        run_test(36'h000000200, 18'h00100, "TC3:  1.0 / 0.5  = 2  [D boundary] ");
        run_test(36'h000000600, 18'h00200, "TC4:  3.0 / 1.0  = 3  [D in range] ");

        // ── Out-of-range divisors (prescaling required) ───────────
        run_test(36'h000000400, 18'h00400, "TC5:  2.0 / 2.0  = 1  [D too large]");
        run_test(36'h000000800, 18'h00400, "TC6:  4.0 / 2.0  = 2  [D too large]");
        run_test(36'h000000600, 18'h00600, "TC7:  3.0 / 3.0  = 1  [D too large]");
        run_test(36'h000000600, 18'h00300, "TC8:  3.0 / 1.5  = 2  [D too large]");
        run_test(36'h000000400, 18'h00080, "TC9:  2.0 / 0.25 = 8  [D too small]");
        run_test(36'h000000800, 18'h00100, "TC10: 4.0 / 0.5  = 8  [D boundary] ");

        $display("============================================");
        $display("Verification Complete.");
        $finish;
    end

    
    task run_test(
        input [35:0]  d_end,
        input [17:0]  d_er,
        input [255:0] label
    );
        begin
            dividend = d_end;
            divider  = d_er;
            @(posedge clk); #1;
            start = 1; @(posedge clk); #1;
            start = 0;
            repeat(12) @(posedge clk);
            verify_output(label, d_end, d_er);
        end
    endtask

    task verify_output(
        input [255:0] label,
        input [35:0]  d_end,
        input [17:0]  d_er
    );
        reg [17:0] nr_int;
        reg [17:0] ref_int;
        integer    diff;
        begin
            nr_int  = nr_quotient_int;
            ref_int = ref_quotient;
            diff    = (nr_int > ref_int) ?
                      (nr_int - ref_int) : (ref_int - nr_int);

            $display("--------------------------------------------");
            $display("%0s", label);
            $display("  Dividend    = 0x%h  (%0d)",         d_end, d_end);
            $display("  Divisor     = 0x%h  (%0d)",         d_er,  d_er);
            $display("  NR raw Q7.9 = 0x%h  (%0d = %.4f)",
                     nr_quotient, nr_quotient,
                     $itor(nr_quotient)/512.0);
            $display("  NR integer  = %0d  (rounded)",      nr_int);
            $display("  REF integer = %0d",                 ref_int);
            $display("  Diff        = %0d LSB",             diff);

            if (diff == 0)
                $display("  >> PASS (exact match)");
            else if (diff <= 1)
                $display("  >> PASS (within 1 LSB tolerance)");
            else
                $display("  >> FAIL  (error = %0d LSBs)", diff);
        end
    endtask

endmodule
