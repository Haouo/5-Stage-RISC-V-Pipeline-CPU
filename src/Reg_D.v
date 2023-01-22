module Reg_D(
    input clk,
    input rst,
    input stall,
    input jb,
    input [31:0] in_pc,
    input [31:0] in_inst,
    output reg [31:0] out_pc,
    output reg [31:0] out_inst
);
    // define NOP hex code
    parameter NOP = 32'h00000013;
    // main part
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            out_pc <= 32'd0;
            out_inst <= 32'd0; 
        end
        else if(jb == 1'b1) begin
            out_pc <= 32'd0;
            out_inst <= NOP;
        end
        else if(stall == 1'b0) begin
            out_pc <= in_pc;
            out_inst <= in_inst;
        end
    end
endmodule