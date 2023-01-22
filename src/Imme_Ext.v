module Imme_Ext(
    input [31:0] inst,
    output [31:0] imme_ext_out
);
    // OPCODE map
    parameter   LOAD = 5'b00000,
                STORE = 5'b01000,
                BRANCH = 5'b11000,
                JALR = 5'b11001,
                JAL = 5'b11011,
                OP_IMM = 5'b00100,
                OP = 5'b01100,
                AUIPC = 5'b00101,
                LUI = 5'b01101;
                
    // wire
    wire [4:0] opcode = inst[6:2];
    // temp reg
    reg [31:0] temp_out;
    
    // main part
    assign imme_ext_out = temp_out;
    always@(*) begin
        if(opcode == OP) // R-type
            temp_out = 32'b0;
        else if(opcode == OP_IMM || opcode == LOAD || opcode == JALR) // I-type
            temp_out = {{20{inst[31]}}, inst[31:20]};
        else if(opcode == STORE) // S-type
            temp_out = {{20{inst[31]}}, inst[30:25], inst[11:7]};
        else if(opcode == BRANCH) // B-type
            temp_out = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        else if(opcode == LUI || opcode == AUIPC) // U-type
            temp_out = {inst[31:12], 12'b0};
        else // J-type
            temp_out = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
    end
endmodule