module top (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire signed [16:0] angle;
    output wire signed [16:0] x_pos,
    output wire signed [16:0] y_pos,
    output wire [3:0] step,
    output wire busy
);

    wire [15:0] angle_step;

    anglelookup lookup (
        .step(step),
        .angle(angle_step)
    );

    rotation rot (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .angle(angle),
        .anglestep({1'b0, angle_step}),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .step(step),
        .busy(busy)
    );

endmodule