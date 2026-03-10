module start1_reg (
    input  wire clk,
    input  wire D,
    input  wire SCLR,     
    output reg  Q
);

always @(posedge clk) begin
    if (SCLR)
        Q <= 1'b0;
    else
        Q <= D;
end

endmodule