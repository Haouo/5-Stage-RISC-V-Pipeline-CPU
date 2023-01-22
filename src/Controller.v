module Controller(
    //! input signals
    // general
    input clk,
    input rst,
    // ID stage
    input [4:0] op,
    input [2:0] func3,
    input func7,
    input [4:0] rs1_index,
    input [4:0] rs2_index,
    input [4:0] rd_index,
    // EXE stage
    input EXE_BrEq,
    input EXE_BrLT,
    //! output signals
    // IF stage
    output [3:0] IF_im_w_en,
    // EXE stage
    output [3:0] EXE_alu_op,
    output EXE_alu_op1_sel,
    output EXE_alu_op2_sel,
    output EXE_BrUn,
    output EXE_isLui, // for Lui inst. to select alu_op1
    // MEM stage
    output [3:0] MEM_dm_w_en,
    // WB stage
    output WB_w_en,
    output reg [4:0] WB_rd_index,
    output reg [2:0] WB_func3,
    output [1:0] WB_wb_data_sel,
    // jb signal
    output jb,
    // for data forwarding
    output ID_rs1_data_sel,
    output ID_rs2_data_sel,
    output [1:0] EXE_rs1_data_sel,
    output [1:0] EXE_rs2_data_sel,
    // stall signal
    output stall
);
    // define ALU OP map
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
    
    // func3 map for branch inst.
    parameter   EQ = 3'b000,
                NE = 3'b001,
                LT = 3'b100,
                GE = 3'b101,
                LTU = 3'b110,
                GEU = 3'b111;

    // pipeline registers
    reg [4:0] EXE_op, EXE_rs1_index, EXE_rs2_index, EXE_rd_index, MEM_op, MEM_rd_index, WB_op;
    reg [2:0] EXE_func3, MEM_func3;
    reg EXE_func7;

    // pipeline regs control
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            // reset registers
            EXE_op <= 5'd0;
            EXE_rs1_index <= 5'd0;
            EXE_rs2_index <= 5'd0;
            EXE_rd_index <= 5'd0;
            MEM_op <= 5'd0;
            MEM_rd_index <= 5'd0;
            WB_rd_index <= 5'd0;
            WB_op <= 5'd0;
            EXE_func3 <= 3'd0;
            MEM_func3 <= 3'd0;
            WB_func3 <= 3'd0;
            EXE_func7 <= 1'd0;
        end 
        else begin
            // update registers as normal
            EXE_op <= (jb || stall) ? 5'b00100 : op;
            EXE_func3 <= (jb || stall) ? 3'b000 : func3;
            EXE_func7 <= func7;
            EXE_rs1_index <= (jb || stall) ? 5'd0 : rs1_index;
            EXE_rs2_index <= rs2_index;
            EXE_rd_index <= (jb || stall) ? 5'd0 : rd_index;
            MEM_op <= EXE_op;
            MEM_func3 <= EXE_func3;
            MEM_rd_index <= EXE_rd_index;
            WB_op <= MEM_op;
            WB_func3 <= MEM_func3;
            WB_rd_index <= MEM_rd_index;
        end
    end

    //! forwarding control
    // wires
    wire is_ID_use_rs1, is_ID_use_rs2, is_EXE_use_rs1, is_EXE_use_rs2, is_MEM_use_rd, is_WB_use_rd;
    wire is_ID_rs1_WB_rd_overlap, is_ID_rs2_WB_rd_overlap, is_EXE_rs1_WB_rd_overlap, is_EXE_rs2_WB_rd_overlap, is_EXE_rs1_MEM_rd_overlap, is_EXE_rs2_MEM_rd_overlap;
    // ID_rs1_WB_rd_overlap and ID_rs2_WB_rd_overlap
    assign is_ID_rs1_WB_rd_overlap = is_ID_use_rs1 & is_WB_use_rd & (rs1_index == WB_rd_index) & (WB_rd_index != 5'd0);
    assign is_ID_rs2_WB_rd_overlap = is_ID_use_rs2 & is_WB_use_rd & (rs2_index == WB_rd_index) & (WB_rd_index != 5'd0);
    // EXE_rs1_WB_rd_overlap and EXE_rs2_WB_rd_overlap
    assign is_EXE_rs1_WB_rd_overlap = is_EXE_use_rs1 & is_WB_use_rd & (EXE_rs1_index == WB_rd_index) & (WB_rd_index != 5'd0);
    assign is_EXE_rs2_WB_rd_overlap = is_EXE_use_rs2 & is_WB_use_rd & (EXE_rs2_index == WB_rd_index) & (WB_rd_index != 5'd0);
    assign is_EXE_rs1_MEM_rd_overlap = is_EXE_use_rs1 & is_MEM_use_rd & (EXE_rs1_index == MEM_rd_index) & (MEM_rd_index != 5'd0);
    assign is_EXE_rs2_MEM_rd_overlap = is_EXE_use_rs2 & is_MEM_use_rd & (EXE_rs2_index == MEM_rd_index) & (MEM_rd_index != 5'd0);
    // ID_use_rs1 and ID_use_rs2
    reg temp_is_ID_use_rs1;
    assign is_ID_use_rs1 = temp_is_ID_use_rs1;
    assign is_ID_use_rs2 = (op == OP || op == STORE || op == BRANCH) ? 1'b1 : 1'b0;
    always@(*) begin
        if(op == JAL || op == LUI || op ==  AUIPC) begin
            temp_is_ID_use_rs1 = 1'b0;
        end
        else begin
            temp_is_ID_use_rs1 = (rs1_index == 5'd0) ? 1'b0 : 1'b1;
        end
    end
    // EXE_use_rs1 and EXE_use_rs2
    reg temp_is_EXE_use_rs1;
    assign is_EXE_use_rs1 = temp_is_EXE_use_rs1;
    assign is_EXE_use_rs2 = (EXE_op == OP || EXE_op == STORE || EXE_op == BRANCH) ? 1'b1 : 1'b0;
    always@(*) begin
        if(EXE_op == JAL || EXE_op == LUI || EXE_op == AUIPC) begin
            temp_is_EXE_use_rs1 = 1'b0;
        end
        else begin
            temp_is_EXE_use_rs1 = (EXE_rs1_index == 1'b0) ? 1'b0 : 1'b1;
        end
    end
    // MEM_rd
    reg temp_is_MEM_use_rd;
    assign is_MEM_use_rd = temp_is_MEM_use_rd;
    always @(*) begin
        if(MEM_op == STORE || MEM_op == BRANCH) begin
            temp_is_MEM_use_rd = 1'b0;
        end
        else begin
            temp_is_MEM_use_rd = (MEM_rd_index == 5'd0) ? 1'b0 : 1'b1;
        end
    end
    // WB_rd
    reg temp_is_WB_use_rd;
    assign is_WB_use_rd = temp_is_WB_use_rd;
    always@(*) begin
        if(WB_op == STORE || WB_op == BRANCH) begin
            temp_is_WB_use_rd = 1'b0;
        end
        else begin
            temp_is_WB_use_rd = (WB_rd_index == 5'd0) ? 1'b0 : 1'b1;
        end
    end
    // ID_rs1_data_sel and ID_rs2_data_sel
    assign ID_rs1_data_sel = is_ID_rs1_WB_rd_overlap ? 1'b1 : 1'b0; // true for forwarding data
    assign ID_rs2_data_sel = is_ID_rs2_WB_rd_overlap ? 1'b1 : 1'b0;
    // EXE_rs1_data_sel and EXE_rs2_data_sel
    assign EXE_rs1_data_sel = is_EXE_rs1_MEM_rd_overlap ? 2'd1 : is_EXE_rs1_WB_rd_overlap ? 2'd0 : 2'd2; // MEM forward is prior to WB forward
    assign EXE_rs2_data_sel = is_EXE_rs2_MEM_rd_overlap ? 2'd1 : is_EXE_rs2_WB_rd_overlap ? 2'd0 : 2'd2;
    // stall signal
    wire is_ID_rs1_EXE_rd_overlap, is_ID_rs2_EXE_rd_overlap;
    assign is_ID_rs1_EXE_rd_overlap = is_ID_use_rs1 & (rs1_index == EXE_rd_index) & (EXE_rd_index != 5'd0);
    assign is_ID_rs2_EXE_rd_overlap = is_ID_use_rs2 & (rs2_index == EXE_rd_index) & (EXE_rd_index != 5'd0);
    assign stall = (EXE_op == LOAD) & (is_ID_rs1_EXE_rd_overlap | is_ID_rs2_EXE_rd_overlap);

    //! IF stage
    assign IF_im_w_en = 4'd0; // do not change inst. memory

    //! EXE stage
    // alu opcode
    reg [3:0] temp_alu_op;
    assign EXE_alu_op = temp_alu_op;
    always @(*) begin
        if(EXE_op == OP) begin
            if(EXE_func7 == 1'b0) begin
                case(EXE_func3)
                    3'b000: temp_alu_op = ADD;
                    3'b001: temp_alu_op = SLL;
                    3'b010: temp_alu_op = SLT;
                    3'b011: temp_alu_op = SLTU;
                    3'b100: temp_alu_op = XOR;
                    3'b101: temp_alu_op = SRL;
                    3'b110: temp_alu_op = OR;
                    3'b111: temp_alu_op = AND;
                    default: temp_alu_op = ADD;
                endcase
            end
            else begin
                temp_alu_op = (EXE_func3 == 3'b000) ? SUB : SRA;
            end
        end
        else if(EXE_op == OP_IMM) begin
            case(EXE_func3)
                3'b000: temp_alu_op = ADD;
                3'b001: temp_alu_op = SLL;
                3'b010: temp_alu_op = SLT;
                3'b011: temp_alu_op = SLTU;
                3'b100: temp_alu_op = XOR;
                3'b101: begin
                    if(EXE_func7 == 1'b0)
                        temp_alu_op = SRL;
                    else
                        temp_alu_op = SRA;
                end
                3'b110: temp_alu_op = OR;
                3'b111: temp_alu_op = AND;
                default: temp_alu_op = ADD;
            endcase
        end
        else begin
            // LOAD, STORE, LUI, AUIPC, JAL, JALR, BRANCH
            temp_alu_op = ADD;
        end
    end
    // alu_op1_sel and alu_op2_sel
    assign EXE_alu_op1_sel = (EXE_op == JAL || EXE_op == BRANCH || EXE_op == AUIPC) ? 1'b1 : 1'b0;
    assign EXE_alu_op2_sel = (EXE_op == OP) ? 1'b0 : 1'b1; // 1 for imm, 0 for rs2
    // BrUn
    assign EXE_BrUn = (EXE_func3 == LTU || EXE_func3 == GEU) ? 1'b1 : 1'b0;
    // isLui
    assign EXE_isLui = (EXE_op == LUI) ? 1'b1 : 1'b0;
    // jb signal
    // our pipeline CPU is always-not taken scheme
    // jb is HIGH when BRNACH is taken or EXE_op = JAL or JALR
    reg branch_is_taken;
    always @(*) begin
        if(EXE_op == BRANCH) begin
            case(EXE_func3)
                EQ: branch_is_taken = EXE_BrEq;
                NE: branch_is_taken = ~EXE_BrEq;
                LT: branch_is_taken = EXE_BrLT;
                GE: branch_is_taken = ~EXE_BrLT;
                LTU: branch_is_taken = EXE_BrLT;
                GEU: branch_is_taken = ~EXE_BrLT;
                default: branch_is_taken = 1'b0;
            endcase
        end 
        else begin
            branch_is_taken = 1'b0;
        end
    end
    assign jb = ((EXE_op == BRANCH && branch_is_taken) || EXE_op == JAL || EXE_op == JALR) ? 1'b1 : 1'b0;

    //! MEM stage
    // MEM_dm_w_en
    reg [3:0] temp_dm_w_en;
    assign MEM_dm_w_en = temp_dm_w_en;
    always @(*) begin
        if(MEM_op == STORE) begin
            case(MEM_func3)
                3'b000: temp_dm_w_en = 4'b0001;
                3'b001: temp_dm_w_en = 4'b0011;
                3'b010: temp_dm_w_en = 4'b1111;
                default: temp_dm_w_en = 4'd0;
            endcase
        end
        else begin
            temp_dm_w_en = 4'd0;
        end
    end

    //! WB stage
    assign WB_w_en = (WB_op == STORE || WB_op == BRANCH) ? 1'b0 : 1'b1;
    reg [1:0] temp_wb_data_sel;
    assign WB_wb_data_sel = temp_wb_data_sel;
    always @(*) begin
        if(WB_op == JAL || WB_op == JALR) begin
            temp_wb_data_sel = 2'd2; // chose PC + 4
        end
        else if(WB_op == LOAD) begin
            temp_wb_data_sel = 2'd1; // chose ld_data_f
        end
        else begin
            temp_wb_data_sel = 1'd0; // chose alu_out
        end
    end
endmodule