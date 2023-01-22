`include "./src/ALU.v"
`include "./src/Controller.v"
`include "./src/Decoder.v"
`include "./src/BranchComp.v"
`include "./src/Imme_Ext.v"
`include "./src/LD_Filter.v"
`include "./src/RegFile.v"
`include "./src/Reg_PC.v"
`include "./src/Reg_D.v"
`include "./src/Reg_E.v"
`include "./src/Reg_M.v"
`include "./src/Reg_W.v"
`include "./src/SRAM.v"

module Top(
    input clk,
    input rst
);
    //! wires between modules
    // IF stage
    wire [31:0] IF_current_pc, IF_next_pc, IF_pc_plus_4, IF_inst; 
    // ID stage
    wire [31:0] ID_pc, ID_inst, ID_sext_imme, ID_rs1_data, ID_rs2_data, ID_newest_rs1_data, ID_newest_rs2_data;
    wire [4:0] ID_rs1_index, ID_rs2_index, ID_rd_index, ID_op;
    wire [2:0] ID_func3;
    wire ID_func7;
    // EXE stage
    wire [31:0] EXE_pc, EXE_rs1_data, EXE_rs2_data, EXE_newest_rs1_data, EXE_newest_rs2_data, EXE_sext_imme;
    wire [31:0] alu_op1_or_zero, alu_op1, alu_op2, alu_out;
    // MEM stage
    wire [31:0] MEM_pc, MEM_alu_out, MEM_rs2_data, MEM_ld_data;
    // WB stage
    wire [31:0] WB_pc, WB_pc_plus_4, WB_alu_out, WB_ld_data, WB_ld_data_f, WB_wb_data;
    wire [4:0] WB_rd_index;
    wire [2:0] WB_func3;
    // control signals
    wire    stall,
            jb, // is also next_pc_sel
            ID_rs1_data_sel,
            ID_rs2_data_sel,
            EXE_BrUn,
            EXE_BrEq,
            EXE_BrLT,
            EXE_alu_op1_sel,
            EXE_alu_op2_sel,
            EXE_isLui,
            WB_w_en;
    wire [3:0] IF_im_w_en, EXE_alu_op, MEM_dm_w_en;
    wire [1:0] WB_wb_data_sel, EXE_rs1_data_sel, EXE_rs2_data_sel;

    // module declaration and wiring
    Controller controller(
        .clk(clk),
        .rst(rst),
        .op(ID_op),
        .func3(ID_func3),
        .func7(ID_func7),
        .rs1_index(ID_rs1_index),
        .rs2_index(ID_rs2_index),
        .rd_index(ID_rd_index),
        .EXE_BrEq(EXE_BrEq),
        .EXE_BrLT(EXE_BrLT),
        .IF_im_w_en(IF_im_w_en),
        .EXE_alu_op(EXE_alu_op),
        .EXE_alu_op1_sel(EXE_alu_op1_sel),
        .EXE_alu_op2_sel(EXE_alu_op2_sel),
        .EXE_BrUn(EXE_BrUn),
        .EXE_isLui(EXE_isLui),
        .MEM_dm_w_en(MEM_dm_w_en),
        .WB_w_en(WB_w_en),
        .WB_rd_index(WB_rd_index),
        .WB_func3(WB_func3),
        .WB_wb_data_sel(WB_wb_data_sel),
        .jb(jb),
        .ID_rs1_data_sel(ID_rs1_data_sel),
        .ID_rs2_data_sel(ID_rs2_data_sel),
        .EXE_rs1_data_sel(EXE_rs1_data_sel),
        .EXE_rs2_data_sel(EXE_rs2_data_sel),
        .stall(stall)
    );

    Reg_PC reg_pc(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .next_pc(IF_next_pc),
        .current_pc(IF_current_pc)
    );

    assign IF_pc_plus_4 = IF_current_pc + 32'd4;
    // Mux in IF stage
    assign IF_next_pc = jb ? alu_out : IF_pc_plus_4;
    
    SRAM im(
        .clk(clk),
        .w_en(IF_im_w_en),
        .address(IF_current_pc[15:0]),
        .write_data(32'd0),
        .read_data(IF_inst) 
    );

    Reg_D reg_d(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .jb(jb),
        .in_pc(IF_current_pc),
        .in_inst(IF_inst),
        .out_pc(ID_pc),
        .out_inst(ID_inst)
    );

    Decoder decoder(
        .inst(ID_inst),
        .dc_out_opcode(ID_op),
        .dc_out_func3(ID_func3),
        .dc_out_func7(ID_func7),
        .dc_out_rs1_index(ID_rs1_index),
        .dc_out_rs2_index(ID_rs2_index),
        .dc_out_rd_index(ID_rd_index) 
    );

    Imme_Ext imme_ext(
        .inst(ID_inst),
        .imme_ext_out(ID_sext_imme)
    );

    RegFile regfile(
        .clk(clk),
        .rst(rst),
        .wb_en(WB_w_en),
        .wb_data(WB_wb_data),
        .rs1_index(ID_rs1_index),
        .rs2_index(ID_rs2_index),
        .rd_index(WB_rd_index),
        .rs1_out_data(ID_rs1_data),
        .rs2_out_data(ID_rs2_data)
    );

    // Mux in ID stage
    assign ID_newest_rs1_data = ID_rs1_data_sel ? WB_wb_data : ID_rs1_data;
    assign ID_newest_rs2_data = ID_rs2_data_sel ? WB_wb_data : ID_rs2_data;

    Reg_E reg_exe(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .jb(jb),
        .in_pc(ID_pc),
        .in_rs1_data(ID_newest_rs1_data),
        .in_rs2_data(ID_newest_rs2_data),
        .in_sext_imme(ID_sext_imme),
        .out_pc(EXE_pc),
        .out_rs1_data(EXE_rs1_data),
        .out_rs2_data(EXE_rs2_data),
        .out_sext_imme(EXE_sext_imme)
    );

    // Mux in EXE stage
    assign EXE_newest_rs1_data = (EXE_rs1_data_sel == 2'd1) ? MEM_alu_out : (EXE_rs1_data_sel == 2'd0) ? WB_wb_data : EXE_rs1_data;
    assign EXE_newest_rs2_data = (EXE_rs2_data_sel == 2'd1) ? MEM_alu_out : (EXE_rs2_data_sel == 2'd0) ? WB_wb_data : EXE_rs2_data;
    assign alu_op1 = EXE_alu_op1_sel ? EXE_pc : EXE_newest_rs1_data;
    assign alu_op1_or_zero = EXE_isLui ? 32'd0 : alu_op1;
    assign alu_op2 = EXE_alu_op2_sel ? EXE_sext_imme : EXE_newest_rs2_data;

    ALU alu(
        .alu_op(EXE_alu_op),
        .operand1(alu_op1_or_zero),
        .operand2(alu_op2),
        .alu_out(alu_out)
    );

    BranchComp branch_comp(
        .operand1(EXE_newest_rs1_data),
        .operand2(EXE_newest_rs2_data),
        .BrUn(EXE_BrUn),
        .BrEq(EXE_BrEq),
        .BrLT(EXE_BrLT)
    );

    Reg_M reg_mem(
        .clk(clk),
        .rst(rst),
        .in_pc(EXE_pc),
        .in_alu_out(alu_out),
        .in_rs2_data(EXE_newest_rs2_data),
        .out_pc(MEM_pc),
        .out_alu_out(MEM_alu_out),
        .out_rs2_data(MEM_rs2_data)
    );

    SRAM dm(
        .clk(clk),
        .w_en(MEM_dm_w_en),
        .address(MEM_alu_out[15:0]),
        .write_data(MEM_rs2_data),
        .read_data(MEM_ld_data)
    );

    Reg_W reg_wb(
        .clk(clk),
        .rst(rst),
        .in_pc(MEM_pc),
        .in_alu_out(MEM_alu_out),
        .in_ld_data(MEM_ld_data),
        .out_pc(WB_pc),
        .out_alu_out(WB_alu_out),
        .out_ld_data(WB_ld_data)
    );

    LD_Filter ld_filter(
        .func3(WB_func3),
        .in_data(WB_ld_data),
        .out_data(WB_ld_data_f)
    );

    // Mux in WB stage
    assign WB_pc_plus_4 = WB_pc + 32'd4;
    assign WB_wb_data = (WB_wb_data_sel == 2'd2) ? WB_pc_plus_4 : (WB_wb_data_sel == 2'd1) ? WB_ld_data_f : WB_alu_out;
endmodule