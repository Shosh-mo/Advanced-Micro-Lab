/*
module Newton_Raphson_Divider( input [35:0] dividend, input start, input [17:0] divider, input clk, input rst, output [17:0] quotient); 

    parameter width1 = 36; 
    parameter width2 = 18; 
    parameter width3 = 18; 

    wire [width1-1:0] reg_out1;
    wire [width2-1:0] reg_out2;
    wire [width3-1:0] reg_out3;
    wire [width3-1:0] In_reg3; 
    wire [width3-1:0] NRD_out;
    wire Q_out;

wire [53:0] mult_full;

    DFF_rg #(.WIDTH(width1)) reg1 (.a(dividend), .clk(clk), .reset(rst), .y(reg_out1)); 
    DFF_rg #(.WIDTH(width2)) reg2 (.a(divider),  .clk(clk), .reset(rst), .y(reg_out2)); 
    DFF_rg #(.WIDTH(width3)) reg3 (.a(In_reg3),  .clk(clk), .reset(rst), .y(reg_out3)); 

    start1_reg start_insta (.D((1'b1)), .clk(clk), .SCLR(~start), .Q(Q_out));

    NRD NRD_inst (.D(reg_out2), .clk(clk), .rst(rst), .start(Q_out), .xf(NRD_out)); 

    assign mult_full   = reg_out1 * NRD_out; 
    assign In_reg3   = mult_full[26:9];
    assign quotient = reg_out3; 

endmodule
*/


module Newton_Raphson_Divider(
    input  [35:0] dividend,
    input  [17:0] divider,
    input         clk,
    input         rst,
    input         start,
    output [17:0] quotient
);

    parameter width1 = 36;
    parameter width2 = 18;
    parameter width3 = 18;

   
    wire [width1-1:0] reg_out1;          
    wire [width2-1:0] reg_out2;          
    wire [width3-1:0] reg_out3;          
    wire [width3-1:0] In_reg3;           

    wire [width2-1:0] D_scaled;          
    wire signed [4:0] shift_count;       

    wire [width3-1:0] NRD_out;           
    wire [width3-1:0] quotient_raw;    
    wire [width3-1:0] quotient_scaled;   

    wire [53:0]       mult_full;         
    wire              Q_out;             

    DFF_rg #(.WIDTH(width1)) reg1 (.a(dividend),  .clk(clk), .reset(rst), .y(reg_out1));
    DFF_rg #(.WIDTH(width2)) reg2 (.a(divider),   .clk(clk), .reset(rst), .y(reg_out2));
    DFF_rg #(.WIDTH(width3)) reg3 (.a(In_reg3),   .clk(clk), .reset(rst), .y(reg_out3));


    start1_reg start_insta (
        .D    (1'b1),
        .clk  (clk),
        .SCLR (~start),
        .Q    (Q_out)
    );

    prescaler #(.WIDTH(width2)) pre (
        .D_in       (reg_out2),
        .D_scaled   (D_scaled),
        .shift_count(shift_count)
    );

    NRD NRD_inst (
        .D    (D_scaled),
        .clk  (clk),
        .rst  (rst),
        .start(Q_out),
        .xf   (NRD_out)
    );

    assign mult_full    = reg_out1 * NRD_out;
    assign quotient_raw = mult_full[26:9];

    postscaler #(.WIDTH(width3)) post (
        .quotient_in  (quotient_raw),
        .shift_count  (shift_count),
        .quotient_out (quotient_scaled)
    );

    assign In_reg3  = quotient_scaled;
    assign quotient = reg_out3;

endmodule
