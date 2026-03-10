module reference_non_restoring_divider (
    input [17:0] dividend,
    input [17:0] divisor,
    output reg [17:0] quotient
);
    integer i;
    reg [18:0] p;
    reg [17:0] acc_dividend;
    
    always @(*) begin
        acc_dividend = dividend;
        p = 0;
        for (i = 17; i >= 0; i = i - 1) begin
            p = {p[17:0], acc_dividend[i]};
            if (p[18] == 0) begin
                p = p - {1'b0, divisor};
            end else begin
                p = p + {1'b0, divisor};
            end
            
            if (p[18] == 0)
                acc_dividend[i] = 1;
            else
                acc_dividend[i] = 0;
        end
        quotient = acc_dividend;
    end
endmodule