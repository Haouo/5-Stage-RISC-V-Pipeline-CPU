module RegFile(
    input clk,
    input rst,
    input wb_en,
    input [31:0] wb_data,
    input [4:0] rd_index,
    input [4:0] rs1_index,
    input [4:0] rs2_index,
    output [31:0] rs1_out_data,
    output [31:0] rs2_out_data
);
    reg [31:0] regFile[31:0]; // register array
    assign regFile[0] = 32'd0; // register x0 is always zero

    // main part
    always@ (posedge clk) begin
        if(rst == 1'b1) begin
            for(int i = 1; i < 32; i = i + 1) begin
                regFile[i] <= 32'd0;
            end
        end
        else if(wb_en == 1 && rd_index != 5'd0) begin
            regFile[rd_index] <= wb_data;
        end
    end

    // assign rs1 data and rs2 data
    assign rs1_out_data = regFile[rs1_index];
    assign rs2_out_data = regFile[rs2_index];
endmodule