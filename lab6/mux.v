module mux #(parameter f_no = 4) (and_in , or_in , nand_in , nor_in , f_sel , f_out);
input and_in , or_in , nand_in , nor_in;
input [$clog2(f_no) - 1 :0] f_sel;
output reg f_out;

/*
reg [$clog2(f_no) - 1 :0] f_sel_reg;


always @(posedge clk , negedge rst) begin
    if(!rst)
        f_sel_reg <= 0;
    else
        f_sel_reg <= f_sel;
end
*/
always @(*) begin
    case(f_sel) 
        2'b00: f_out = and_in;
        2'b01: f_out = or_in;
        2'b10: f_out = nand_in;
        2'b11: f_out = nor_in;
        default: f_out = and_in;
    endcase
end


endmodule
