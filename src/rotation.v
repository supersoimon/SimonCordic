module rotation (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire signed [16:0] angle,
    input wire signed [16:0] anglestep,
    output reg signed [16:0] x_pos,
    output reg signed [16:0] y_pos,
    output reg [3:0] step,
    output wire busy
);
    reg busybee;
    reg oldstart;
    reg signed [16:0] xnew;
    reg signed [16:0] ynew;
    reg signed [16:0] znew;
    assign busy = busybee;
    always @(posedge clk) begin
        if (!rst_n) begin
            busybee <= 0;
            oldstart <= 0;
            step <= 0;
            xnew <= 0;
            ynew <= 0;
            znew <= 0;
            x_pos <= 0;
            y_pos <= 0;
        end
        else begin
            oldstart <= start;
            if (start && !oldstart && !busybee) begin
                xnew <= 17'd9949;
                ynew <= 17'd0;
                znew <= 17'd0;
                step <= 4'b0000;
                busybee <= 1'b1;
                oldstart <= start;
            end
            else if (busybee) begin
                if (step < 15) begin
                    if (znew < angle) begin
                        znew <= znew + anglestep;
                        xnew <= xnew - (ynew >>> step);
                        ynew <= ynew + (xnew >>> step);
                    end
                    else begin
                        znew <= znew - anglestep;
                        xnew <= xnew + (ynew >>> step);
                        ynew <= ynew - (xnew >>> step);
                    end
                    step <= step + 1;
                end
                else begin
                    x_pos <= xnew;
                    y_pos <= ynew;
                    step <= 0;
                    busybee <= 0;
                end
            end
        end
    end

endmodule