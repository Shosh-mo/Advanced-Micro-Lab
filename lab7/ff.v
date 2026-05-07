module ff(clk, rst , D , out_ff);
parameter WIDTH = 1;
input clk , rst;
input [WIDTH - 1: 0] D;
output reg [WIDTH - 1: 0] out_ff;

always @(posedge clk , negedge rst) begin
    if(!rst) begin
        out_ff <= 0;
    end
    else begin
        out_ff <= D;
    end
end
endmodule