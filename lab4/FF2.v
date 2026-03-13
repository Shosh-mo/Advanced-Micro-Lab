module FF2 #(parameter max_fifo_addr = 4) (clk ,rst , d , q);
input clk , rst;
input [max_fifo_addr:0] d;
output [max_fifo_addr:0] q;

reg [max_fifo_addr:0] ff1 , ff2;


assign q = ff2;
always @(posedge clk) begin
    if(!rst)begin
        ff1 <= 0;
        ff2 <= 0; 
    end
    else begin
        ff1 <= d;
        ff2 <= ff1;
    end
end 
endmodule