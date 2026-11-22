module tt_um_cordic (
    input wire [7:0] ui_in,
    output reg [7:0] uo_out,
    input wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input wire ena,
    input wire clk,
    input wire rst_n
);
    wire signed [16:0] x_pos;
    wire signed [16:0] y_pos;
    wire [3:0] step;
    wire busy;
    assign uio_out = 8'b0;
    assign uio_oe = 8'b0;

    reg old_write;

    reg [7:0] angle_byte_0;
    reg [7:0] angle_byte_1;
    reg [7:0] angle_byte_2;

    wire signed [16:0] angle;

    assign angle = {angle_byte_2[0], angle_byte_1, angle_byte_0};

    top cordic (
        .clk(clk),
        .rst_n(rst_n),
        .start(uio_in[3] & ena),
        .angle(angle),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .step(step),
        .busy(busy)
    );
    always @(*) begin
        case (uio_in[6:4])
            3'b000: uo_out = x_pos[7:0];
            3'b001: uo_out = x_pos[15:8];
            3'b010: uo_out = {7'b0, x_pos[16]};

            3'b011: uo_out = y_pos[7:0];
            3'b100: uo_out = y_pos[15:8];
            3'b101: uo_out = {7'b0, y_pos[16]};

            3'b110: uo_out = {7'b0, busy};
            3'b111: uo_out = {4'b0, step};
            default: uo_out = 8'b0;
        endcase
    end
    always @(posedge clk) begin
            if (!rst_n) begin
                angle_byte_0 <= 8'd0;
                angle_byte_1 <= 8'd0;
                angle_byte_2 <= 8'd0;
                old_write <= 1'b0;
            end
            else begin
                old_write <= uio_in[2];

                if (ena && uio_in[2] && !old_write) begin
                    case (uio_in[1:0])
                        2'b00: angle_byte_0 <= ui_in;
                        2'b01: angle_byte_1 <= ui_in;
                        2'b10: angle_byte_2 <= ui_in;
                        default: ;
                    endcase
                end
            end
    end   

endmodule