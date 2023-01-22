module Reg_PC(
    input clk,
    input rst,
    input stall,
    input [31:0] next_pc,
    output reg [31:0] current_pc
);
    always@ (posedge clk) begin
        if(rst == 1)
            current_pc <= 32'd0;
        else if(stall == 1'b0)
            current_pc <= next_pc;
        // else => stall == 1'b1 => pc remains unchanged
    end
endmodule