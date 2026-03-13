
module FIFO (data_in , wr_en , rd_en , full , empty , data_out , clk_w , clk_r , rst);
parameter fifo_width = 8;
parameter fifo_depth = 16;

input [fifo_width -1 : 0] data_in; 
input wr_en , rd_en;
input clk_w , clk_r , rst;
output full , empty;
output reg [fifo_width -1 : 0] data_out;

reg [fifo_width-1:0] mem [fifo_depth-1:0];

localparam max_fifo_addr = $clog2(fifo_depth);

reg [max_fifo_addr-1:0] wr_ptr_b, rd_ptr_b , wr_ptr_g , rd_ptr_g ; //use extra bit for the gray coding

wire [max_fifo_addr-1:0] wr_ptr_g_sync , rd_ptr_g_sync;

//sync on the other clock
FF2 #(max_fifo_addr) sync_ff_w (clk_r , rst ,wr_ptr_g , wr_ptr_g_sync);
FF2 #(max_fifo_addr) sync_ff_r (clk_w , rst ,rd_ptr_g , rd_ptr_g_sync);

//writing is sync , reading is async
always @(posedge clk_w) begin
    if(!rst) begin
        wr_ptr_b <= 0;
		wr_ptr_g <= 0;
    end
    else if (wr_en && !full) begin
		mem[wr_ptr_b] <= data_in;
		
		if(wr_ptr_b == fifo_depth - 1)begin
			wr_ptr_b <= 0;
			wr_ptr_g <= 0;
		end
		else begin
		
			wr_ptr_b <= wr_ptr_b + 1;
			wr_ptr_g <= (wr_ptr_b + 1) ^ ((wr_ptr_b + 1) >> 1);
		end
	end
end

always @(posedge clk_r) begin
	if (!rst) begin
		rd_ptr_b <= 0;
		rd_ptr_g <= 0;
        data_out <= 0;
	end
	else if (rd_en && !empty) begin
		data_out <= mem[rd_ptr_b];
		
		if(rd_ptr_b == fifo_depth - 1) begin
			rd_ptr_b <= 0;
			rd_ptr_g <= 0;
		end
		else begin
		
			rd_ptr_b <= rd_ptr_b + 1;
			rd_ptr_g <=  (rd_ptr_b + 1) ^ ((rd_ptr_b + 1) >> 1);
		end
	end
    else if(!rd_en && !empty) begin //in case of stalling i want to read without popping
        data_out <= mem[rd_ptr_b];
    end
end

//assign full  = ((wr_ptr_b == (fifo_depth-1)) && (rd_ptr_b==0))|| (((wr_ptr_b+1) == rd_ptr_b));
assign full  = (wr_ptr_g[max_fifo_addr-1]   != rd_ptr_g_sync[max_fifo_addr-1]) &&
               (wr_ptr_g[max_fifo_addr-2:0] == rd_ptr_g_sync[max_fifo_addr-2:0]);

assign empty = (wr_ptr_g_sync == rd_ptr_g);



`ifdef FORMAL

//ASSUMES
always @(posedge clk_w) begin
    assume_no_wen_when_full  : assume (!(wr_en && full));
end

always @(posedge clk_r) begin
    assume_no_ren_when_empty : assume (!(rd_en && empty));
end


//ASSERTIONS
always @(posedge clk_w) begin
    no_overflow : assert (!(wr_en && full));
    ptr_in_range: assert (wr_ptr_b <= fifo_depth);
end


always @(posedge clk_r) begin
    no_underflow : assert (!(rd_en && empty));
end

//COVER

always @(posedge clk_w) 
	c_full: cover ((full==1) && ($past(full)==0));


always @(posedge clk_r)
	c_empty: cover((empty ==1) && ($past(empty) == 0));


`endif
endmodule