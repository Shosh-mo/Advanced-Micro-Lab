module read #(parameter fifo_width = 8) (clk , rst ,empty , data_in , rd_en , data_read , en);
input clk , rst , empty , en;
input [fifo_width -1 : 0] data_in;
output reg rd_en;
output reg [fifo_width -1 : 0] data_read; //just to send the data to the tb

always @(posedge clk) begin
    if (!rst)
        rd_en <= 0;
    else if(en) begin
        if(!empty) begin
            rd_en <= 1;
            data_read <= data_in;
        end
        else 
            rd_en <= 0;
    end
    else 
        rd_en <= 0;
end
endmodule