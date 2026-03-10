module DFF_rg #(parameter WIDTH = 18) (input [WIDTH-1:0] a, input clk, input reset, output reg [WIDTH-1:0] y); 


    always @(posedge clk) begin 
        if (reset) begin
            y <= {WIDTH{1'b0}};
        end else begin
             y <= a;
        end
    end 

endmodule