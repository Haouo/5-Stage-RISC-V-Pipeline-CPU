module Reg_E(
    input clk,
    input rst,
    input stall,
    input jb,
    input [31:0] in_pc,
    input [31:0] in_rs1_data,
    input [31:0] in_rs2_data,
    input [31:0] in_sext_imme,
    output reg [31:0] out_pc,
    output reg [31:0] out_rs1_data,
    output reg [31:0] out_rs2_data,
    output reg [31:0] out_sext_imme
);
    // main part
    always @(posedge clk) begin
        if(rst == 1'b1 || stall == 1'b1 || jb == 1'b1) begin
            out_pc <= 32'd0;
            out_rs1_data <= 32'd0;
            out_rs2_data <= 32'd0;
            out_sext_imme <= 32'd0;
        end
        else begin
            out_pc <= in_pc;
            out_rs1_data <= in_rs1_data;
            out_rs2_data <= in_rs2_data;
            out_sext_imme <= in_sext_imme;
        end
    end
endmodule