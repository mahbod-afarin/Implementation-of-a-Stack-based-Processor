module SevenSeg(
    input [3:0] out,
    output reg [0:6] HEX
);
    // Segment encoding:
    //      0
    //     ---
    //   5|   |1
    //    | 6 |
    //   4|___|2
    //      3

    always @(*) begin
        case (out)
            4'h0: HEX = 7'b100_0000;
            4'h1: HEX = 7'b111_1001;
            4'h2: HEX = 7'b010_0100;
            4'h3: HEX = 7'b011_0000;
            4'h4: HEX = 7'b001_1001;
            4'h5: HEX = 7'b001_0010;
            4'h6: HEX = 7'b000_0010;
            4'h7: HEX = 7'b111_1000;
            4'h8: HEX = 7'b000_0000;
            4'h9: HEX = 7'b001_0000;
            4'hA: HEX = 7'b000_1000;
            4'hB: HEX = 7'b000_0011;
            4'hC: HEX = 7'b100_0110;
            4'hD: HEX = 7'b010_0001;
            4'hE: HEX = 7'b000_0110;
            4'hF: HEX = 7'b000_1110;
            default: HEX = 7'b111_1111; // all off (or all on if active low)
        endcase
    end
endmodule
