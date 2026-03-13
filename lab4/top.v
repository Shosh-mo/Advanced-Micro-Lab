module top(clk_w , clk_r , rst , data_read , data_write , en_reading , en_writing);
parameter fifo_depth = 16;
parameter fifo_width = 8;

input clk_w , clk_r , rst , en_reading , en_writing;
input [fifo_width -1 : 0] data_write;

output [fifo_width -1 : 0] data_read;

wire full , empty , wr_en , rd_en;
wire [fifo_width -1 : 0] data_out , data_in;

FIFO #(.fifo_depth(fifo_depth), .fifo_width(fifo_width))FIFO_dut 
(data_in , wr_en , rd_en , full , empty , data_out , clk_w , clk_r , rst);

write #(fifo_width) write_dut (clk_w , rst ,full , data_in , wr_en , data_write , en_writing );

read #(fifo_width) read_dut (clk_r , rst ,empty , data_out , rd_en , data_read , en_reading);

endmodule
