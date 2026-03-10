// Corrects the quotient after NR division based on how many times the divisor was shifted in the prescaler.
module postscaler #(parameter WIDTH = 18)(
    input  [WIDTH-1:0]      quotient_in,
    input  signed [4:0]     shift_count,
    output reg [WIDTH-1:0]  quotient_out
);

    always @(*) begin
        if (shift_count > 0)
            quotient_out = quotient_in << shift_count;   // D shifted left  → quotient too small
        else if (shift_count < 0)
            quotient_out = quotient_in >> (-shift_count); // D shifted right → quotient too large
        else
            quotient_out = quotient_in;                   // no correction
    end

endmodule
