module ALU(
    // for operation
    input [3:0] alu_op,
    input [31:0] operand1,
    input [31:0] operand2,
    output [31:0] alu_out
);
    // map of ALU operation code
    parameter   ADD = 4'd0,
                SLL = 4'd1,
                SLT = 4'd2,
                SLTU = 4'd3,
                XOR = 4'd4,
                SRL = 4'd5,
                OR = 4'd6,
                AND = 4'd7,
                SUB = 4'd8,
                SRA = 4'd13;
    // temp reg 
    reg [31:0] temp_result;
    reg temp_BrLT;

    // main part
    assign alu_out = temp_result;
    always@(*) begin
        case(alu_op)
            ADD: temp_result = operand1 + operand2;
            SLL: temp_result = operand1 << operand2[4:0];
            SLT: temp_result = ($signed(operand1) < $signed(operand2)) ? 32'b1 : 32'b0; 
            SLTU: temp_result = (operand1 < operand2) ? 32'b1 : 32'b0;
            XOR: temp_result = operand1 ^ operand2;
            SRL: temp_result = operand1 >> operand2[4:0];
            OR: temp_result = operand1 | operand2;
            AND: temp_result = operand1 & operand2;
            SUB: temp_result = operand1 - operand2;
            SRA: temp_result = $signed(operand1) >>> operand2[4:0];
            default: temp_result = 32'd0; // avoid latch
        endcase
    end
endmodule