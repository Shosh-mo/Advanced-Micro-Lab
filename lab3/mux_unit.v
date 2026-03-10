module mux_unit(
    input [17:0] A,
    input [17:0] B,
    input S,
    output [17:0] Y
);

assign Y = S ? B : A;

endmodule