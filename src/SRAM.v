module SRAM(
    input clk,
    input [3:0] w_en,
    input [15:0] address,
    input [31:0] write_data,
    output [31:0] read_data
);
    reg [7:0] mem[0:65535]; // register array

    // main part
    always@(posedge clk) begin
        if(w_en == 4'b1111) begin
            mem[address] <= write_data[7:0];
            mem[address + 1] <= write_data[15:8];
            mem[address + 2] <= write_data[23:16];
            mem[address + 3] <= write_data[31:24];
        end
        else if (w_en == 4'b0011) begin
            mem[address] <= write_data[7:0];
            mem[address + 1] <= write_data[15:8];
        end
        else if (w_en == 4'b0001) begin
            mem[address] <= write_data[7:0];
        end
    end

    // assign memory read data
    assign read_data = {mem[address + 3], mem[address + 2], mem[address + 1], mem[address]};
endmodule