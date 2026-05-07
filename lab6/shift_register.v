module shift_register #(parameter DEPTH = 16) (clk,rst,serial_in,sel, wr_en,out);
//depth is 16 as it's 4 input
    input clk;
    input rst;
    input serial_in , wr_en;  // config bits shifted in one by one
    input [$clog2(DEPTH)-1 : 0]sel; 
    output out;

    reg [DEPTH-1:0] sr;
    
    always @(posedge clk or negedge rst) begin
        if (!rst)
            sr <= {DEPTH{1'b0}};
        else if(wr_en) begin 
            sr <= {sr[DEPTH-2:0], serial_in};  // shift left, new bit enters at LSB
        end
    end
    
    assign out = sr[sel];

endmodule