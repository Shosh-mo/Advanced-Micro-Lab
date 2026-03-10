// prescaler.v
// Scales divisor D into valid NRD range: 0x101 <= D_scaled <= 0x200
// (0.5 < D <= 1.0 in Q7.9, scale factor = 512)
//
// If D > 0x200 (> 1.0): shift RIGHT until in range  → shift_count is NEGATIVE
// If D <= 0x100 (<= 0.5): shift LEFT until in range  → shift_count is POSITIVE
// If already in range: no shift                       → shift_count = 0
//
// Post-scaling rule for quotient:
//   shift_count > 0 → quotient << shift_count  (D was shifted left,   quotient was halved)
//   shift_count < 0 → quotient >> shift_count  (D was shifted right,  quotient was doubled)
//   shift_count = 0 → no correction needed
/*
module prescaler #(parameter WIDTH = 18)(
    input  [WIDTH-1:0] D_in,
    output reg [WIDTH-1:0] D_scaled,
    output reg signed [4:0] shift_count  // signed: + means shifted left, - means shifted right
);

    integer i;
    reg [WIDTH-1:0] temp;

    always @(*) begin
        temp        = D_in;
        shift_count = 0;

        if (temp == 0) begin
            // division by zero — output 0, no shift
            D_scaled    = 0;
            shift_count = 0;
        end
        else if (temp > 18'h200) begin
            // D > 1.0 → shift RIGHT until D <= 1.0
            while (temp > 18'h200) begin
                temp        = temp >> 1;
                shift_count = shift_count - 1;
            end
            D_scaled = temp;
        end
        else if (temp <= 18'h100) begin
            // D <= 0.5 → shift LEFT until D > 0.5
            while (temp <= 18'h100) begin
                temp        = temp << 1;
                shift_count = shift_count + 1;
            end
            D_scaled = temp;
        end
        else begin
            // already in range (0.5 < D <= 1.0)
            D_scaled    = temp;
            shift_count = 0;
        end
    end

endmodule
*/
module prescaler #(parameter WIDTH = 18)(
    input  [WIDTH-1:0]      D_in,
    output reg [WIDTH-1:0]  D_scaled,
    output reg signed [4:0] shift_count
);

    always @(*) begin
        // default
        D_scaled    = D_in;
        shift_count = 0;

        casex (D_in)
            // ── D in valid range: 0x101 to 0x200 ──────────────
            // highest bit at position 8 (0x100 to 0x1FF)
            // or exactly 0x200
            18'b00_0000_0001_xxxx_xxxx: begin   // 0x100 to 0x1FF
                // check if exactly 0x100 (= 0.5, boundary, shift left 1)
                if (D_in == 18'h100) begin
                    D_scaled    = D_in << 1;    // 0x200
                    shift_count = 1;
                end else begin
                    D_scaled    = D_in;         // already in (0.5, 1.0]
                    shift_count = 0;
                end
            end
            18'b00_0000_0010_0000_0000: begin   // exactly 0x200 = 1.0
                D_scaled    = D_in;
                shift_count = 0;
            end

            // ── D too large: shift RIGHT ───────────────────────
            18'b00_0000_0010_xxxx_xxxx: begin   // 0x201 to 0x2FF → /2
                D_scaled    = D_in >> 1;
                shift_count = -1;
            end
            18'b00_0000_001x_xxxx_xxxx: begin   // 0x200 to 0x3FF → /2
                D_scaled    = D_in >> 1;
                shift_count = -1;
            end
            18'b00_0000_01xx_xxxx_xxxx: begin   // 0x400 to 0x7FF → /4
                D_scaled    = D_in >> 2;
                shift_count = -2;
            end
            18'b00_0000_1xxx_xxxx_xxxx: begin   // 0x800 to 0xFFF → /8
                D_scaled    = D_in >> 3;
                shift_count = -3;
            end
            18'b00_0001_xxxx_xxxx_xxxx: begin   // 0x1000 to 0x1FFF → /16
                D_scaled    = D_in >> 4;
                shift_count = -4;
            end
            18'b00_001x_xxxx_xxxx_xxxx: begin   // /32
                D_scaled    = D_in >> 5;
                shift_count = -5;
            end
            18'b00_01xx_xxxx_xxxx_xxxx: begin   // /64
                D_scaled    = D_in >> 6;
                shift_count = -6;
            end
            18'b00_1xxx_xxxx_xxxx_xxxx: begin   // /128
                D_scaled    = D_in >> 7;
                shift_count = -7;
            end
            18'b01_xxxx_xxxx_xxxx_xxxx: begin   // /256
                D_scaled    = D_in >> 8;
                shift_count = -8;
            end
            18'b1x_xxxx_xxxx_xxxx_xxxx: begin   // /512
                D_scaled    = D_in >> 9;
                shift_count = -9;
            end

            // ── D too small: shift LEFT ────────────────────────
            18'b00_0000_0000_1xxx_xxxx: begin   // 0x080 to 0x0FF → ×2
                D_scaled    = D_in << 1;
                shift_count = 1;
            end
            18'b00_0000_0000_01xx_xxxx: begin   // 0x040 to 0x07F → ×4
                D_scaled    = D_in << 2;
                shift_count = 2;
            end
            18'b00_0000_0000_001x_xxxx: begin   // ×8
                D_scaled    = D_in << 3;
                shift_count = 3;
            end
            18'b00_0000_0000_0001_xxxx: begin   // ×16
                D_scaled    = D_in << 4;
                shift_count = 4;
            end
            18'b00_0000_0000_0000_1xxx: begin   // ×32
                D_scaled    = D_in << 5;
                shift_count = 5;
            end
            18'b00_0000_0000_0000_01xx: begin   // ×64
                D_scaled    = D_in << 6;
                shift_count = 6;
            end
            18'b00_0000_0000_0000_001x: begin   // ×128
                D_scaled    = D_in << 7;
                shift_count = 7;
            end
            18'b00_0000_0000_0000_0001: begin   // ×256
                D_scaled    = D_in << 8;
                shift_count = 8;
            end

            default: begin                       // D = 0, undefined
                D_scaled    = 18'h200;           // default to 1.0
                shift_count = 0;
            end
        endcase
    end

endmodule