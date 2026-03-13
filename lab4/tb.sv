

module tb();

parameter fifo_width = 8;
parameter fifo_depth = 16;

reg              clk_w, clk_r, rst;
reg  [fifo_width-1:0] data_write;
reg   en_reading , en_writing;
wire [fifo_width-1:0] data_read;

logic [fifo_width-1:0] ref_queue [$];

int pass_count = 0;
int fail_count = 0;

top #(.fifo_depth(fifo_depth), .fifo_width(fifo_width)) dut (
    .clk_w      (clk_w),
    .clk_r      (clk_r),
    .rst        (rst),
    .data_write (data_write),
    .data_read  (data_read),
    .en_reading (en_reading),
    .en_writing (en_writing)
);

initial begin
    clk_w = 0;
    forever begin
        #5 clk_w = ~clk_w ;
    end 
end

initial begin
    clk_r = 0;
    forever begin
        #10 clk_r = ~clk_r ;
    end 
end


wire full  = dut.full;
wire empty = dut.empty;
wire wr_en = dut.wr_en;
wire rd_en = dut.rd_en;
wire [fifo_width-1:0] data_in = dut.data_in;


logic [fifo_width-1:0] val;


task apply_reset;
    rst        = 0;
    data_write = 0;
    ref_queue.delete();
    repeat(4) @(posedge clk_w);
    rst = 1;
    repeat(4) @(posedge clk_w); 
endtask


task write_data(input [fifo_width-1:0] val);
    if(!full)begin
        en_writing = 1;
        data_write = val;
        ref_queue.push_back(val);
        @(posedge clk_w);          
        @(posedge clk_w);          // FIFO samples here
    end
    else
        en_writing = 0;
        
endtask

/*
task check_read;
    static logic [fifo_width-1:0] expected;
    logic [fifo_width-1:0] expected_delayed;
    logic [fifo_width-1:0] got;
    en_reading = 1;
    // wait until read module actually reads
    @(posedge clk_r);
    #1;
    if (rd_en && !empty && ref_queue.size() > 0) begin
        expected = ref_queue.pop_front();

        @(posedge clk_r);      // data_read valid one cycle after rd_en

        #1;
        got = data_read;

            if (got === expected_delayed) begin
                $display("[PASS] Expected: %0d | Got: %0d", expected_delayed, got);
                pass_count++;
            end else begin
                $display("[FAIL] Expected: %0d | Got: %0d", expected_delayed, got);
                fail_count++;
            end
        end
    expected_delayed = expected;
endtask
*/

task check_read;
    logic [fifo_width-1:0] expected;
    en_reading = 1;
    @(posedge clk_r);
    #1;
    if (rd_en && !empty && ref_queue.size() > 0) begin
        expected = ref_queue.pop_front();
        check(expected);
        end
endtask

task check(input logic [fifo_width-1:0] expected);
    static logic [fifo_width-1:0] expected_delayed;
    logic [fifo_width-1:0] got;
        @(posedge clk_r);      

        #1;
        got = data_read;
        if(en_reading) begin
            if (got === expected_delayed) begin
                $display("[PASS] Expected: %0d | Got: %0d", expected_delayed, got);
                pass_count++;
            end else begin
                $display("[FAIL] Expected: %0d | Got: %0d", expected_delayed, got);
                fail_count++;
            end

        end
        expected_delayed = expected;
endtask



initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);

    $display("\n===== SCENARIO 1: Write until full, read until empty =====");

    apply_reset;

    repeat(fifo_depth) begin
        val = $random;
        en_reading = 0;
        write_data(val);
    end

    repeat(2) @(posedge clk_w);
    if (full)
        $display("[PASS] FIFO correctly FULL after %0d writes", fifo_depth , $time);
    else
        $display("[FAIL] FIFO should be FULL but full=%0b", full , $time);

    repeat(10) @(posedge clk_w);

    if (!empty)
        $display("[PASS] FIFO not empty before reads");

    check(ref_queue[0]);

    // read all entries
    repeat(fifo_depth) begin
        check_read;
        en_writing = 0;
    end

    repeat(2) @(posedge clk_r);

    if (empty)
        $display("[PASS] FIFO correctly EMPTY after all reads");
    else
        $display("[FAIL] FIFO should be EMPTY but empty=%0b", empty);


    $display("\n===== SCENARIO 2: Simultaneous read and write =====");

    apply_reset;

    fork
        begin : writer
            repeat(fifo_depth) begin
                val = $random;
                write_data(val);
            end
        end
        begin : reader
            @(posedge clk_r)
            wait(ref_queue.size() > 0);
            en_reading = 0;
            check(ref_queue[0]);
            repeat(fifo_depth) begin
                check_read;
            end
        end
    join

    repeat(2) @(posedge clk_r);


    $display("\n===== SCENARIO 3: Write when full — check no corruption =====");

    apply_reset;

    // fill completely
    repeat(fifo_depth) begin
        val = $random;
        write_data(val);
        en_reading = 0;
    end

    repeat(2) @(posedge clk_r);

    if (full)
        $display("[PASS] FIFO full before overflow test");
    else
        $display("[FAIL] FIFO should be full");

    // attempt writes while full — should all be rejected
    repeat(4) begin
        write_data(8'hFF);
    end

    if (full)
        $display("[PASS] full correctly asserted during overflow attempts");

    check(ref_queue[0]);

    // read everything and verify
    repeat(fifo_depth) begin
        en_writing = 0;
        check_read;
    end

    repeat(2) @(posedge clk_r);


    $display("\n===== SCENARIO 4: Read when empty — check no underflow =====");

    apply_reset;

    repeat(4) @(posedge clk_r);

    if (empty)
        $display("[PASS] FIFO empty after reset");
    else
        $display("[FAIL] FIFO should be empty after reset");

    // check rd_en stays low when empty
    repeat(4) begin
        @(posedge clk_r); #1;
        if (!rd_en)
            $display("[PASS] rd_en correctly deasserted when empty");
        else
            $display("[FAIL] rd_en high while empty — underflow");
    end

    // write a few then read 
    repeat(4) begin
        val = $random;
        write_data(val);
        en_reading = 0;
    end

    repeat(6) @(posedge clk_w);

    check(ref_queue[0]);

    repeat(4) begin
        en_writing = 0;
        check_read;
    end


    repeat(2) @(posedge clk_r);
    $display("\nssssssssssssssssssssssssssssssssssssssss");
    $display("  TOTAL PASS: %0d", pass_count);
    $display("  TOTAL FAIL: %0d", fail_count);
    $display("ssssssssssssssssssssssssssssssssssssssss\n");

    $finish;
end


endmodule