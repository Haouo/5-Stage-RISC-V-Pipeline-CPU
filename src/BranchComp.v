module BranchComp(
    input [31:0] operand1,
    input [31:0] operand2,
    input BrUn,
    output BrEq,
    output BrLT
);
    // temp reg
    reg temp_BrLT;

    // main part
    assign BrEq = (operand1 == operand2) ? 1'b1 : 1'b0;
    assign BrLT = temp_BrLT;
    always@(*) begin
        if(BrUn == 1'b1) begin
            // unsigned comparasion
            temp_BrLT = (operand1 < operand2) ? 1'b1 : 1'b0;
        end
        else begin
            // signed comparasion
            temp_BrLT = ($signed(operand1) < $signed(operand2)) ? 1'b1 : 1'b0;
        end
    end
endmodule