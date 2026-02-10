`include "../include/defines.svh"
`include "Reg_IFID.sv"
`include "Reg_IDEX.sv"
`include "Reg_EXMEM.sv"
`include "Reg_MEMWB.sv"
`include "Reg_CS.sv"
`include "Decoder.sv"
`include "Imm_Gen.sv"
`include "JB_Unit.sv"
`include "LD_Filter.sv"
`include "ST_Filter.sv"
`include "RegFile.sv"
`include "FPRegFile.sv"
`include "Controller.sv"
`include "HazardUnit.sv"
`include "ALU.sv"
`include "FPU.sv"
`include "Reg_PC.sv"
`include "Mux.sv"
`include "Mux_3.sv"
`include "FetchPredictor.sv"
`include "Adder.sv"

module CPU(
  input logic clk,
  input logic rst,
  input logic [`DATA_WIDTH-1:0] ld_data,
  input logic [`INSTR_WIDTH-1:0] F_inst,
  output logic [`PC_WIDTH-1:0] F_pc,
  output logic [`MEM_WRITE_ENABLE-1:0] dm_byte_w_en,
  output logic [`DATA_WIDTH-1:0] M_alu_out,
  output logic [`DATA_WIDTH-1:0] data_to_dm
);

logic [`PC_WIDTH-1:0] next_pc;
logic [`PC_WIDTH-1:0] E_pc;
logic [`PC_WIDTH-1:0] D_pc;

logic [`INSTR_WIDTH-1:0] fd_inst_out;
logic [`INSTR_WIDTH-1:0] D_inst;

logic [`MAJOR_OPCODE_WIDTH-1:0] opcode;
logic [`MAJOR_OPCODE_WIDTH-1:0] E_opcode;
logic [`MAJOR_OPCODE_WIDTH-1:0] M_opcode;
logic [`MAJOR_OPCODE_WIDTH-1:0] W_opcode;

logic [`FUNCT3_WIDTH-1:0] funct3;
logic [`FUNCT3_WIDTH-1:0] E_funct3;
logic [`FUNCT3_WIDTH-1:0] W_funct3;
logic [`FUNCT3_WIDTH-1:0] M_funct3;
logic [`FUNCT5_WIDTH-1:0] funct5;
logic [`FUNCT5_WIDTH-1:0] E_funct5;
logic [`FUNCT7_WIDTH-1:0] funct7;
logic [`FUNCT7_WIDTH-1:0] E_funct7;

logic [`ADDR_WIDTH-1:0] rs1_idx;
logic [`ADDR_WIDTH-1:0] rs2_idx;
logic [`ADDR_WIDTH-1:0] rd_idx;
logic [`ADDR_WIDTH-1:0] W_rd_idx;
logic [`DATA_WIDTH-1:0] rs1_data;
logic [`DATA_WIDTH-1:0] rs2_data;
logic [`DATA_WIDTH-1:0] f_rs1_data;
logic [`DATA_WIDTH-1:0] f_rs2_data;

logic [`IMM_WIDTH-1:0] D_imme;
logic [`IMM_WIDTH-1:0] E_imme;

logic [`DATA_WIDTH-1:0] E_alu_out;
logic [`DATA_WIDTH-1:0] E_fpu_out;
logic [`DATA_WIDTH-1:0] E_alu_fpu_out;

logic [`DATA_WIDTH-1:0] ld_filtered_data;
logic [`DATA_WIDTH-1:0] wb_data;
logic [`PC_WIDTH-1:0] jb_pc;
logic wb_en;
logic fwb_en;
logic flush;
logic decode_inst_sel;
logic [1:0] wb_sel;
logic [`DATA_WIDTH-1:0] op1;
logic [`DATA_WIDTH-1:0] op2;
logic [`DATA_WIDTH-1:0] jb_op1;
logic [`DATA_WIDTH-1:0] rs1_data_out;
logic [`DATA_WIDTH-1:0] rs2_data_out;
logic [`DATA_WIDTH-1:0] f_rs1_data_out;
logic [`DATA_WIDTH-1:0] f_rs2_data_out;
logic [`DATA_WIDTH-1:0] D_rs1_out;
logic [`DATA_WIDTH-1:0] D_rs2_out;
logic D_rs1_data_sel;
logic D_rs2_data_sel;
logic [1:0]E_rs1_data_sel;
logic [1:0]E_rs2_data_sel;
logic [1:0] decode_fp_mux_sel;
logic hazard_D_use_rs1;
logic hazard_D_use_rs2;
logic hazard_D_use_rd;
logic hazard_D_rs1_float;
logic hazard_D_rs2_float;
logic hazard_D_rd_float;
logic hazard_E_use_rd;
logic hazard_E_use_rs1;
logic hazard_E_use_rs2;
logic hazard_E_rs1_float;
logic hazard_E_rs2_float;
logic hazard_E_rd_float;
logic [`ADDR_WIDTH-1:0] hazard_E_rs1_idx;
logic [`ADDR_WIDTH-1:0] hazard_E_rs2_idx;
logic [`ADDR_WIDTH-1:0] hazard_E_rd_idx;
logic hazard_M_use_rd;
logic hazard_M_use_rs2;
logic hazard_M_rd_float;
logic hazard_M_rs2_float;
logic [`ADDR_WIDTH-1:0] hazard_M_rd_idx;
logic [`ADDR_WIDTH-1:0] hazard_M_rs2_idx;
logic [`ADDR_WIDTH-1:0] hazard_M_rs1_idx;
logic [`ADDR_WIDTH-1:0] hazard_W_rs1_idx;
logic [`ADDR_WIDTH-1:0] hazard_W_rs2_idx;
logic hazard_W_use_rd;
logic hazard_W_rd_float;

logic [3:0] exec_mux_sel;
logic [`DATA_WIDTH-1:0]rs1_to_mux;
logic [`DATA_WIDTH-1:0]rs2_to_mux;
logic [`DATA_WIDTH-1:0]E_rs1_forward_data;
logic [`DATA_WIDTH-1:0]E_rs2_forward_data;
logic [`DATA_WIDTH-1:0]W_alu_out;
logic stall;
logic is_instret;
logic instret_en;
logic cs_high_bit;
logic W_cs_bit;
logic [31:0] cs_out;
logic [`DATA_WIDTH-1:0] M_rs2_data;
logic M_rs2_data_sel;
logic [`DATA_WIDTH-1:0] M_rs2;
logic F_pred_taken;
logic F_pred_valid;
logic D_pred_taken;
logic D_pred_valid;
logic E_pred_taken;
logic E_pred_valid;
logic [1:0] next_pc_sel3;
logic [`PC_WIDTH-1:0] predicted_pc;
logic [`PC_WIDTH-1:0] E_pc_plus4;
logic [`PC_WIDTH-1:0] redirect_pc;



/* Fetch stage  */

Reg_PC Reg_PC(  
  .clk(clk),  
  .rst(rst),  
  .stall(stall),  
  .next_pc(next_pc),  
  .current_pc(F_pc)
);
FetchPredictor fetch_predictor(  
  .clk(clk),  
  .rst(rst),  
  .fetch_pc(F_pc),  
  .fetch_inst(F_inst),  
  .resolve_pc(E_pc),  
  .resolve_opcode(E_opcode),  
  .resolve_taken(E_alu_fpu_out[0]),  
  .pred_valid(F_pred_valid),  
  .pred_taken(F_pred_taken),  
  .predicted_pc(predicted_pc)
);

Adder adder(    
  .a(E_pc),    
  .b(32'd4),    
  .sum(E_pc_plus4)
);

Mux_3 next_pc_mux(  
  .in0(predicted_pc),  
  .in1(E_pc_plus4),  
  .in2(jb_pc),  
  .sel(next_pc_sel3),  
  .out(next_pc)
);
Reg_IFID Reg_IFID(
  .clk(clk),  
  .rst(rst),
  .pc(F_pc),
  .inst(F_inst),
  .stall(stall),
  .flush(flush),
  .pred_taken(F_pred_taken),
  .pred_valid(F_pred_valid),
  .pc_out(D_pc),
  .inst_out(fd_inst_out),
  .hold(decode_inst_sel),
  .pred_taken_out(D_pred_taken),
  .pred_valid_out(D_pred_valid)
);

/*  Decode stage  */
Mux decode_inst_mux(  
  .in0(F_inst),  
  .in1(fd_inst_out),  
  .sel(decode_inst_sel),  
  .out(D_inst)
);

Decoder Decoder(
.inst(D_inst),
.opcode(opcode),
.rd_idx(rd_idx),
.funct3(funct3),
.rs1_idx(rs1_idx),       
.rs2_idx(rs2_idx),       
.funct7(funct7),
.funct5(funct5),
.cs_high_bit(cs_high_bit)
);

Imm_Gen Imm_Gen(
.inst(D_inst),
.imm_ext_out(D_imme)
);

RegFile RegFile(
.clk(clk),
.rst(rst),
.wb_en(wb_en),
.wb_data(wb_data),
.rd_idx(W_rd_idx),
.rs1_idx(rs1_idx),
.rs2_idx(rs2_idx),
.rs1_data_out(rs1_data),
.rs2_data_out(rs2_data)
);

FPRegFile FPRegFile(
.clk(clk),
.rst(rst),
.fwb_en(fwb_en),
.fwb_data(wb_data),
.rd_idx(W_rd_idx),
.rs1_idx(rs1_idx),
.rs2_idx(rs2_idx),
.rs1_data_out(f_rs1_data),
.rs2_data_out(f_rs2_data)
);

Mux D_rs1_data_mux(
  .in0(rs1_data),
  .in1(wb_data),
  .sel(D_rs1_data_sel),
  .out(rs1_data_out)
);
Mux D_frs1_data_mux(
  .in0(f_rs1_data),
  .in1(wb_data),
  .sel(D_rs1_data_sel),
  .out(f_rs1_data_out)
);

Mux D_rs2_data_mux(
  .in0(rs2_data),
  .in1(wb_data),
  .sel(D_rs2_data_sel),
  .out(rs2_data_out)
);
Mux D_frs2_data_mux(
  .in0(f_rs2_data),
  .in1(wb_data),
  .sel(D_rs2_data_sel),
  .out(f_rs2_data_out)
);
Mux D_rs1_mux(
  .in0(rs1_data_out),
  .in1(f_rs1_data_out),
  .sel(decode_fp_mux_sel[0]),
  .out(D_rs1_out)
);
Mux D_rs2_mux(
  .in0(rs2_data_out),
  .in1(f_rs2_data_out),
  .sel(decode_fp_mux_sel[1]),
  .out(D_rs2_out)
);

Reg_IDEX Reg_IDEX(
  .clk(clk),
  .rst(rst),
  .pc(D_pc),
  .pc_out(E_pc),
  .rs1_data(D_rs1_out),
  .rs2_data(D_rs2_out),
  .rs1_data_out(rs1_to_mux),
  .rs2_data_out(rs2_to_mux),
  .s_ext_imme(D_imme),
  .s_ext_imme_out(E_imme),
  .stall(stall),
  .flush(flush),
  .pred_taken(D_pred_taken),
  .pred_valid(D_pred_valid),
  .pred_taken_out(E_pred_taken),
  .pred_valid_out(E_pred_valid),
  /* hazard */
  .rs1_idx(rs1_idx),
  .rs2_idx(rs2_idx),
  .rd_idx(rd_idx),
  .D_use_rs1(hazard_D_use_rs1),
  .D_use_rs2(hazard_D_use_rs2),
  .D_use_rd(hazard_D_use_rd),
  .D_rs1_float(hazard_D_rs1_float),
  .D_rs2_float(hazard_D_rs2_float),
  .D_rd_float(hazard_D_rd_float),
  .E_rs1_idx(hazard_E_rs1_idx),
  .E_rs2_idx(hazard_E_rs2_idx),
  .E_rd_idx(hazard_E_rd_idx),
  .E_use_rs1(hazard_E_use_rs1),
  .E_use_rs2(hazard_E_use_rs2),
  .E_use_rd(hazard_E_use_rd),
  .E_rs1_float(hazard_E_rs1_float),
  .E_rs2_float(hazard_E_rs2_float),
  .E_rd_float(hazard_E_rd_float)
);


/*  Execute stage  */

Mux_3 E_rs1_data_mux(
  .in0(rs1_to_mux),
  .in1(M_alu_out),
  .in2(wb_data),
  .sel(E_rs1_data_sel),
  .out(E_rs1_forward_data)
);

Mux_3 E_rs2_data_mux(
  .in0(rs2_to_mux),
  .in1(M_alu_out),
  .in2(wb_data),
  .sel(E_rs2_data_sel),
  .out(E_rs2_forward_data)
);

Mux alu_mux1(
  .in0(E_pc),
  .in1(E_rs1_forward_data),
  .sel(exec_mux_sel[1]),
  .out(op1)
);

Mux alu_mux2(
  .in0(E_imme),
  .in1(E_rs2_forward_data),
  .sel(exec_mux_sel[2]),
  .out(op2)
);

Mux jb_mux(
  .in0(E_pc),
  .in1(E_rs1_forward_data),
  .sel(exec_mux_sel[0]),
  .out(jb_op1)
);

ALU ALU(
  .opcode(E_opcode),
  .funct3(E_funct3),
  .funct7(E_funct7),
  .op1(op1),
  .op2(op2),
  .rd(E_alu_out)
);

FPU FPU(
  .funct5(E_funct5),
  .op1(op1),
  .op2(op2),
  .frd(E_fpu_out)
);

Mux fpu_mux(
  .in0(E_alu_out),
  .in1(E_fpu_out),
  .sel(exec_mux_sel[3]),
  .out(E_alu_fpu_out)
);

JB_Unit JB_Unit(
  .op1(jb_op1),
  .op2(E_imme),
  .jb_out(jb_pc)
);


Reg_EXMEM Reg_EXMEM(
  .clk(clk),
  .rst(rst),
  .alu(E_alu_fpu_out),
  .alu_out(M_alu_out),
  .rs2_data(E_rs2_forward_data),
  .rs2_data_out(M_rs2),
  /* hazard */
  .E_rs1_idx(hazard_E_rs1_idx),
  .E_rs2_idx(hazard_E_rs2_idx),
  .E_rd_idx(hazard_E_rd_idx),
  .E_use_rs2(hazard_E_use_rs2),
  .E_use_rd(hazard_E_use_rd),
  .E_rs2_float(hazard_E_rs2_float),
  .E_rd_float(hazard_E_rd_float),
  .M_rs1_idx(hazard_M_rs1_idx),
  .M_rs2_idx(hazard_M_rs2_idx),
  .M_rd_idx(hazard_M_rd_idx),
  .M_use_rs2(hazard_M_use_rs2),
  .M_use_rd(hazard_M_use_rd),
  .M_rs2_float(hazard_M_rs2_float),
  .M_rd_float(hazard_M_rd_float)
);
/*  MEM stage  */

Mux M_rs2_data_Mux(
  .in0(M_rs2),
  .in1(wb_data),
  .sel(M_rs2_data_sel),
  .out(M_rs2_data)
);

ST_Filter store_filter(
  .opcode(M_opcode),
  .funct3(M_funct3),
  .addr_offset(M_alu_out[1:0]),
  .rs2_data(M_rs2_data),
  .store_data(data_to_dm)
);

Reg_MEMWB Reg_MEMWB(
  .clk(clk),
  .rst(rst),
  .alu(M_alu_out),
  .alu_out(W_alu_out),
  /* hazard */
  .M_rd_idx(hazard_M_rd_idx),
  .M_rs1_idx(hazard_M_rs1_idx),
  .M_rs2_idx(hazard_M_rs2_idx),
  .M_use_rd(hazard_M_use_rd),
  .M_rd_float(hazard_M_rd_float),
  .W_rd_idx(W_rd_idx),
  .W_rs1_idx(hazard_W_rs1_idx),
  .W_rs2_idx(hazard_W_rs2_idx),
  .W_use_rd(hazard_W_use_rd),
  .W_rd_float(hazard_W_rd_float)
);

/* WB stage  */

LD_Filter LD_Filter(
  .funct3(W_funct3),
  .ld_data(ld_data),
  .ld_filtered_data(ld_filtered_data)
);

Mux_3 wb_mux(
  .in0(W_alu_out),
  .in1(ld_filtered_data),
  .in2(cs_out),
  .sel(wb_sel),
  .out(wb_data)
);

Reg_CS Reg_CS(
	.clk(clk),
	.rst(rst),
	.instret_en(instret_en),
  .is_instret(is_instret),
	.cs_high_bit(W_cs_bit),
	.cs_out(cs_out)
);

HazardUnit hazard_unit(
  .D_use_rs1(hazard_D_use_rs1),
  .D_use_rs2(hazard_D_use_rs2),
  .D_rs1_float(hazard_D_rs1_float),
  .D_rs2_float(hazard_D_rs2_float),
  .rs1_idx(rs1_idx),
  .rs2_idx(rs2_idx),
  .E_use_rd(hazard_E_use_rd),
  .E_use_rs1(hazard_E_use_rs1),
  .E_use_rs2(hazard_E_use_rs2),
  .E_rs1_float(hazard_E_rs1_float),
  .E_rs2_float(hazard_E_rs2_float),
  .E_rs1_idx(hazard_E_rs1_idx),
  .E_rs2_idx(hazard_E_rs2_idx),
  .E_rd_idx(hazard_E_rd_idx),
  .E_opcode(E_opcode),
  .M_use_rd(hazard_M_use_rd),
  .M_use_rs2(hazard_M_use_rs2),
  .M_rd_float(hazard_M_rd_float),
  .M_rs2_float(hazard_M_rs2_float),
  .M_rd_idx(hazard_M_rd_idx),
  .M_rs2_idx(hazard_M_rs2_idx),
  .W_use_rd(hazard_W_use_rd),
  .W_rd_float(hazard_W_rd_float),
  .W_rd_idx(W_rd_idx),
  .stall(stall),
  .D_rs1_data_sel(D_rs1_data_sel),
  .D_rs2_data_sel(D_rs2_data_sel),
  .E_rs1_data_sel(E_rs1_data_sel),
  .E_rs2_data_sel(E_rs2_data_sel),
  .M_rs2_data_sel(M_rs2_data_sel)
);
Controller Controller(
  .clk(clk),
  .rst(rst),
  .opcode(opcode),
  .funct3(funct3),
  .funct7(funct7),
  .funct5(funct5),
  .cs_high_bit(cs_high_bit),
  .branch_bit(E_alu_fpu_out[0]),
  .W_rs1_idx(hazard_W_rs1_idx),
  .W_rs2_idx(hazard_W_rs2_idx),
  .W_rd_idx(W_rd_idx),
  .dm_byte_w_en(dm_byte_w_en),
  .D_inst_sel(decode_inst_sel),
  .D_fp_mux_sel(decode_fp_mux_sel),
  .is_D_use_rs1(hazard_D_use_rs1),
  .is_D_use_rs2(hazard_D_use_rs2),
  .is_D_use_rd(hazard_D_use_rd),
  .is_D_rs1_float(hazard_D_rs1_float),
  .is_D_rs2_float(hazard_D_rs2_float),
  .is_D_rd_float(hazard_D_rd_float),
  .E_exec_mux_sel(exec_mux_sel),
  .E_opcode(E_opcode),
  .M_opcode(M_opcode),
  .W_opcode(W_opcode),
  .E_funct3(E_funct3),
  .E_funct7(E_funct7),
  .E_funct5(E_funct5),
  .M_funct3(M_funct3),
  .E_pred_taken(E_pred_taken),
  .E_pred_valid(E_pred_valid),
  .W_wb_sel(wb_sel),
  .W_wb_en(wb_en),
  .W_fwb_en(fwb_en),
  .W_funct3(W_funct3),
  .flush(flush),
  .next_pc_sel3(next_pc_sel3),
  .stall(stall),
  .is_instret(is_instret),
  .W_cs_bit(W_cs_bit),
  .instret_en(instret_en)
);

endmodule







