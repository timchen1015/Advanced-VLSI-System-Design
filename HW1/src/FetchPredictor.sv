`include "../include/defines.svh"
`include "BranchPredictor.sv"
module FetchPredictor (
  input  logic                            clk,
  input  logic                            rst,
  input  logic [`PC_WIDTH-1:0]            fetch_pc,
  input  logic [`INSTR_WIDTH-1:0]         fetch_inst,
  input  logic [`PC_WIDTH-1:0]            resolve_pc,
  input  logic [`MAJOR_OPCODE_WIDTH-1:0]  resolve_opcode,
  input  logic                            resolve_taken,
  output logic                            pred_valid,
  output logic                            pred_taken,
  output logic [`PC_WIDTH-1:0]            predicted_pc
);

  logic predictor_taken;
  logic is_branch;
  logic [12:0] branch_imm13;
  logic [`IMM_WIDTH-1:0] branch_offset;
  logic [`IMM_WIDTH-1:0] branch_target;

  BranchPredictor u_predictor (
    .clk(clk),
    .rst(rst),
    .fetch_pc(fetch_pc),
    .predict_taken(predictor_taken),
    .update_en(resolve_opcode == `B_TYPE),
    .update_pc(resolve_pc),
    .update_taken((resolve_opcode == `B_TYPE) && resolve_taken)
  );

  assign is_branch      = (fetch_inst[6:2] == `B_TYPE);
  assign pred_valid     = is_branch;
  assign pred_taken     = pred_valid && predictor_taken;

  assign branch_imm13   = {fetch_inst[31], fetch_inst[7], fetch_inst[30:25], fetch_inst[11:8], 1'b0};
  assign branch_offset  = {{19{branch_imm13[12]}}, branch_imm13};
  assign branch_target  = fetch_pc + branch_offset;

  assign predicted_pc   = pred_taken ? branch_target : fetch_pc + 'd4;

endmodule
