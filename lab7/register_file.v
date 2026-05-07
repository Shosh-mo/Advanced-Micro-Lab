module register_file (clk,rst,in0,in1,in2,in3,input_combination,wr_en,out0,out1,out2,out3);
parameter DEPTH = 16 ;
parameter f_no = 4; // how many function

input clk , rst;
input in0, in1 , in2 , in3 , wr_en;
input [$clog2(DEPTH)-1 : 0] input_combination;
output out0 , out1 , out2 , out3;

wire [f_no - 1 :0] in_array , out_array;

assign in_array = {in3 , in2 , in1 , in0};
assign {out3 , out2 , out1 , out0} = out_array;

genvar i;
generate
    for (i = 0; i < f_no  ; i = i + 1) begin                                 
        shift_register #(DEPTH)SH (clk , rst , in_array[i] , input_combination ,wr_en, out_array[i] );
    end
endgenerate
endmodule