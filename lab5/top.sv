module top();
    import uvm_pkg::*;
    import pack1_FIFO::*;
    `include "my_test.svh"
    `include "uvm_macros.svh"

    bit clk_w;
    bit clk_r;

    FIFO_if_write FIFOifwrite (clk_w);
    FIFO_if_read FIFOifread (clk_r);


    FIFO DUT (FIFOifwrite.data_in , FIFOifwrite.wr_en , FIFOifread.rd_en , FIFOifwrite.full , FIFOifread.empty , FIFOifread.data_out , FIFOifwrite.clk_w , FIFOifread.clk_r , FIFOifwrite.rst);



    initial begin
        forever begin
            #2 clk_r = ~clk_r;
        end
    end

    initial begin
        forever begin
            #1 clk_w = ~clk_w;
        end
    end
    
    initial begin
        uvm_config_db#(virtual FIFO_if_write)::set(null , "uvm_test_top" , "FIFO_if_write" , FIFOifwrite);

        uvm_config_db#(virtual FIFO_if_read)::set(null , "uvm_test_top" , "FIFO_if_read" , FIFOifread);

        run_test("my_test");
    end
endmodule