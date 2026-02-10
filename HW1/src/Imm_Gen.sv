`include "../include/defines.svh"
module Imm_Gen(
	input[`INSTR_WIDTH-1:0] inst,
	output reg[`IMM_WIDTH-1:0] imm_ext_out
);

always_comb begin
    case(inst[6:2])
        //S type
        `S_TYPE:        imm_ext_out = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        `F_TYPE_STORE:  imm_ext_out = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        // I / I-like types
        `I_TYPE_LOAD:   imm_ext_out = {{20{inst[31]}}, inst[31:20]};
        `I_TYPE_ALU:    imm_ext_out = {{20{inst[31]}}, inst[31:20]};
        `I_TYPE_JALR:   imm_ext_out = {{20{inst[31]}}, inst[31:20]};
        `F_TYPE_LOAD:   imm_ext_out = {{20{inst[31]}}, inst[31:20]};
        //B type
        `B_TYPE:        imm_ext_out = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        //U type
        `U_TYPE_LUI:    imm_ext_out = {inst[31:12], 12'd0};
        `U_TYPE_AUIPC:  imm_ext_out = {inst[31:12], 12'd0};
        //J type
        `J_TYPE:        imm_ext_out = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
        default:        imm_ext_out = 'd0;
    endcase
end
endmodule
