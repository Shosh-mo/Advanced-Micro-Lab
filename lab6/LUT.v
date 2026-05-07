module LUT(clk,rst,in0,in1,in2,in3,input_combination,wr_en,
f_sel , is_synced , out , out_ff);
parameter DEPTH = 16;
parameter f_no = 4;

input clk , rst , in0 , in1 , in2 , in3 , is_synced,wr_en;
input [$clog2(DEPTH)-1 : 0] input_combination;
input [$clog2(f_no) - 1 :0] f_sel;
output out, out_ff;

wire and_in , or_in , nand_in , nor_in , f_out , D;

wire [$clog2(DEPTH)-1 :0] input_combination_reg;
wire is_synced_reg;
wire [$clog2(f_no) - 1 :0] f_sel_reg;

register_file #(.DEPTH(DEPTH) , .f_no(f_no)) reg_inst(clk,rst,in0,in1,in2,in3,input_combination_reg ,wr_en,and_in , or_in , nand_in , nor_in);
mux #(f_no) mux_inst(and_in , or_in , nand_in , nor_in , f_sel_reg , f_out);
d_mux dmux_inst(f_out , is_synced_reg , out , D);
ff #(1)ff_inst(clk, rst , D , out_ff);



ff #(4) ff_inst2 (clk, rst , input_combination , input_combination_reg);
ff #(1) ff_inst3 (clk, rst , is_synced , is_synced_reg);
ff #(2) ff_inst4 (clk, rst , f_sel , f_sel_reg);


endmodule