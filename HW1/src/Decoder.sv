`include "../include/defines.svh"
module Decoder (
input logic [`INSTR_WIDTH-1:0] inst,
output logic [`MAJOR_OPCODE_WIDTH-1:0] opcode,
output logic [`ADDR_WIDTH-1:0] rd_idx,
output logic [`FUNCT3_WIDTH-1:0] funct3,
output logic [`ADDR_WIDTH-1:0] rs1_idx,
output logic [`ADDR_WIDTH-1:0] rs2_idx,
output logic [`FUNCT7_WIDTH-1:0] funct7,
output logic [`FUNCT5_WIDTH-1:0] funct5,
output logic cs_high_bit
);

assign opcode = inst[6:2];
assign rd_idx = inst[11:7];
assign funct3 = inst[14:12];
assign rs1_idx = inst[19:15];
assign rs2_idx = inst[24:20];
assign funct7 = inst[31:25];
assign funct5 = inst[31:27];
assign cs_high_bit = inst[27];


endmodule