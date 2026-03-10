module NRD #(parameter WIDTH = 18)(
    input  [WIDTH-1:0] D,
    input  clk, rst, start,
    output [WIDTH-1:0] xf
);

    wire [35:0] mult0_out, mult1_out, mult2_out;
    wire [WIDTH-1:0] add0_out;
    wire [WIDTH-1:0] reg_out2; 
    wire [WIDTH-1:0] reg_out3; 
    wire [WIDTH-1:0] reg_out4; 
    wire [WIDTH-1:0] mux_out;   
    wire [WIDTH-1:0] adsub_out;
    wire Q_out;

    assign mult0_out = D * 10'h3c3;
    assign add0_out  = 18'h5a5 - mult0_out[26:9]; 

    assign mult1_out = mux_out * D;

    assign adsub_out = 18'h400 - mult1_out[26:9]; 

    assign mult2_out = reg_out2 * adsub_out;

    assign xf = reg_out4;

    DFF_rg #(WIDTH) reg3 (.a(add0_out), .clk(clk), .reset(rst), .y(reg_out3));

    DFF_rg #(WIDTH) reg2 (.a(mux_out), .clk(clk), .reset(rst), .y(reg_out2));

    DFF_rg #(WIDTH) reg4 (.a(mult2_out[26:9]),.clk(clk), .reset(rst), .y(reg_out4));

    start1_reg start_insta (.D(1'b1), .clk(clk), .SCLR(~start), .Q(Q_out));

    // mux: S=0 → x0 (first cycle), S=1 → feedback (iterations)
    mux_unit mx (.A(reg_out3), .B(reg_out4), .S(Q_out), .Y(mux_out));

endmodule