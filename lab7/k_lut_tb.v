`timescale 1ns/1ps

module k_lut_tb;
    reg clk, rst;
    reg in0, in1, in2, in3;
    reg [3:0] input_combination;   
    reg [1:0] f_sel;               // 00=AND, 01=OR, 10=NAND, 11=NOR
    reg is_synced;                 
    reg wr_en;
    wire out;
    wire out_ff;
    integer correct_count , errors_count;

    LUT dut (
        .clk(clk), .rst(rst),
        .in0(in0), .in1(in1), .in2(in2), .in3(in3),
        .input_combination(input_combination),
        .f_sel(f_sel),
        .is_synced(is_synced),
        .wr_en(wr_en),
        .out(out),
        .out_ff(out_ff)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task load_truth_tables;
        input [15:0] and_tt;   // AND  truth table
        input [15:0] or_tt;    // OR   truth table
        input [15:0] nand_tt;  // NAND truth table
        input [15:0] nor_tt;   // NOR  truth table
        integer b;
        begin
            wr_en = 1;

            correct_count = 0;
            errors_count = 0;

           for (b = 0; b < 16; b = b + 1) begin
                in0 = and_tt[b];
                in1 = or_tt[b];
                in2 = nand_tt[b];
                in3 = nor_tt[b];
                @(posedge clk);
            end
            wr_en = 0;

            $display("Truth tables loaded.");
        end

    endtask

    task test_combo;
        input [3:0] combo;
        input [1:0] func;
        input expected_comb;
        input [30:0] func_name;   // for display
        begin
            input_combination = combo;
            f_sel             = func;
            is_synced         = 0;          // combinational mode
            @(posedge clk);
            #1;
            $display("%s | input_combination=%b | out=%b (exp %b) | %s",
                     func_name, combo, out, expected_comb,
                     (out === expected_comb) ? "PASS" : "FAIL");
            if(out ==expected_comb) begin
                correct_count = correct_count +1 ;
            end
            else begin
                errors_count = errors_count + 1;
            end

            // registered mode
            is_synced = 1;
            @(posedge clk); //#1;
            @(posedge clk);
            #1;
            $display("%s | input_combination=%b | out_ff=%b (exp %b) | %s [FF]",
                     func_name, combo, out_ff, expected_comb,
                     (out_ff === expected_comb) ? "PASS" : "FAIL");

            if(out_ff == expected_comb) begin
                correct_count = correct_count +1 ;
            end
            else begin
                errors_count = errors_count + 1;
            end
        end
    endtask

    integer i;
    reg exp_and, exp_or, exp_nand, exp_nor;

    initial begin
        $dumpfile("k_lut_tb.vcd");
        $dumpvars(0, k_lut_tb);

        rst = 0; in0=0; in1=0; in2=0; in3=0;
        input_combination = 0; f_sel = 0; is_synced = 0;
        #12; rst = 1;   // release reset

        load_truth_tables(
        16'b0000_0000_0000_0001,   // AND  (bit-reversed)
        16'b0111_1111_1111_1111,   // OR   (bit-reversed)
        16'b1111_1111_1111_1110,   // NAND (bit-reversed)
        16'b1000_0000_0000_0000    // NOR  (bit-reversed)
    );


        #10;

        //Test all 16 input combinations for each function for both sync and async mode
        $display("\n=== AND ===");
        for (i = 0; i < 16; i = i + 1) begin
            exp_and = (i == 4'b1111) ? 1 : 0;
            test_combo(i[3:0], 2'b00, exp_and, "AND ");
        end

        $display("\n=== OR ===");
        for (i = 0; i < 16; i = i + 1) begin
            exp_or = (i == 4'b0000) ? 0 : 1;
            test_combo(i[3:0], 2'b01, exp_or, "OR  ");
        end

        $display("\n=== NAND ===");
        for (i = 0; i < 16; i = i + 1) begin
            exp_nand = (i == 4'b1111) ? 0 : 1;
            test_combo(i[3:0], 2'b10, exp_nand, "NAND");
        end

        $display("\n=== NOR ===");
        for (i = 0; i < 16; i = i + 1) begin
            exp_nor = (i == 4'b0000) ? 1 : 0;
            test_combo(i[3:0], 2'b11, exp_nor, "NOR ");
        end

        $display("\nAll tests done.");
        $display("correct count = %d", correct_count);
        $display("errors count = %d", errors_count);

        $finish;
    end

endmodule