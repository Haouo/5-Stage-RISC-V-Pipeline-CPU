module Reg_W(
    input clk,
    input rst,
    input [31:0] in_pc,
    input [31:0] in_alu_out,
    input [31:0] in_ld_data,
    output reg [31:0] out_pc,
    output reg [31:0] out_alu_out,
    output reg [31:0] out_ld_data
);
    // main part
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            out_pc <= 32'd0;
            out_alu_out <= 32'd0;
            out_ld_data <= 32'd0;
        end
        else begin
            out_pc <= in_pc;
            out_alu_out <= in_alu_out;
            out_ld_data <= in_ld_data;
        end
    end
endmodule