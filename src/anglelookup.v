module anglelookup (
    input wire [3:0] step,
    output reg [15:0] angle
);
    always @(*) begin
        case (step)
            4'd0: angle = 16'd8192;
            4'd1: angle = 16'd4836;
            4'd2: angle = 16'd2555;
            4'd3: angle = 16'd1297;
            4'd4: angle = 16'd651;
            4'd5: angle = 16'd326;
            4'd6: angle = 16'd163;
            4'd7: angle = 16'd81;
            4'd8: angle = 16'd41;
            4'd9: angle = 16'd20;
            4'd10: angle = 16'd10;
            4'd11: angle = 16'd5;
            4'd12: angle = 16'd3;
            4'd13: angle = 16'd1;
            4'd14: angle = 16'd1;
            4'd15: angle = 16'd0;
            default: angle = 16'd0;
        endcase
    end
endmodule