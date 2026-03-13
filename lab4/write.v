module write #(parameter fifo_width = 8) (clk , rst ,full , data_out , wr_en , data_write , en);
input clk , rst , full , en;
input [fifo_width - 1: 0] data_write;
output reg [fifo_width -1 : 0] data_out;
output reg wr_en;

always @(posedge clk) begin
    if (!rst) begin
        data_out <= 0;
        wr_en <= 0;
    end
    else if (en) begin
        if (!full) begin
            wr_en   <= 1;
            data_out <= data_write;  
        end else
            wr_en <= 0;            // back off when full
    end
    else
        wr_en <= 0;
end

endmodule