`include "../include/defines.svh"
module Controller(
    input logic clk,
    input logic rst,
    input logic [`MAJOR_OPCODE_WIDTH-1:0] opcode,
    input logic [`FUNCT3_WIDTH-1:0] funct3,
    input logic [`FUNCT7_WIDTH-1:0] funct7,
    input logic [`FUNCT5_WIDTH-1:0] funct5,
    input logic branch_bit,
    input logic E_pred_taken,
    input logic E_pred_valid,
    input logic [`ADDR_WIDTH-1:0] W_rs1_idx,
    input logic [`ADDR_WIDTH-1:0] W_rs2_idx,
    input logic [`ADDR_WIDTH-1:0] W_rd_idx,
    input logic cs_high_bit,
    output logic D_inst_sel,
    output logic [1:0] D_fp_mux_sel,
    output logic is_D_use_rs1,
    output logic is_D_use_rs2,
    output logic is_D_use_rd,
    output logic is_D_rs1_float,
    output logic is_D_rs2_float,
    output logic is_D_rd_float,
    output logic [3:0] E_exec_mux_sel,
    output logic [`MAJOR_OPCODE_WIDTH-1:0] E_opcode,
    output logic [`MAJOR_OPCODE_WIDTH-1:0] M_opcode,
    output logic [`MAJOR_OPCODE_WIDTH-1:0] W_opcode,
    output logic [`FUNCT3_WIDTH-1:0] E_funct3,
    output logic [`FUNCT7_WIDTH-1:0] E_funct7,
    output logic [`FUNCT5_WIDTH-1:0] E_funct5,
    output logic [`MEM_WRITE_ENABLE-1:0] dm_byte_w_en,
    output logic [1:0] W_wb_sel,
    output logic W_wb_en,
    output logic W_fwb_en,
    output logic [`FUNCT3_WIDTH-1:0] W_funct3,
    output logic flush,
    output logic [1:0] next_pc_sel3,
    input logic stall,
    output logic is_instret,
    output logic W_cs_bit,
    output logic instret_en,
    output logic [`FUNCT3_WIDTH-1:0] M_funct3
);

logic [`FUNCT7_WIDTH-1:0] M_funct7;
logic [`FUNCT7_WIDTH-1:0] W_funct7;
logic E_cs_bit;
logic M_cs_bit;

logic pipe_ready;
logic branch_inst_E;
logic branch_taken_E;
logic predicted_taken_E;
logic branch_mispredict;

logic opcode_is_fp_store;

logic E_uses_pc_op1;
logic E_uses_rs2_op2;

logic w_stage_is_nop;
logic next_pc_plus4_sel;
logic unused_controller_inputs;

logic hold_decode;
assign hold_decode = stall || flush || ~pipe_ready;

// Fetch stage control
assign branch_inst_E     = (E_opcode == `B_TYPE);
assign branch_taken_E    = branch_inst_E && branch_bit;
assign predicted_taken_E = E_pred_valid && E_pred_taken;
assign branch_mispredict = branch_inst_E && (branch_taken_E ^ predicted_taken_E);

assign flush     = (E_opcode == `J_TYPE) || (E_opcode == `I_TYPE_JALR) || branch_mispredict;
assign next_pc_plus4_sel = branch_mispredict && ~branch_taken_E;
assign next_pc_sel3    = (!flush) ? 2'b00 :
                         (next_pc_plus4_sel) ? 2'b01 : 2'b10;

// Decode stage control
assign is_D_use_rs1 = ~((opcode == `U_TYPE_LUI) || (opcode == `U_TYPE_AUIPC) || (opcode == `J_TYPE));
assign is_D_use_rs2 = (opcode == `B_TYPE) || (opcode == `S_TYPE) || (opcode == `R_TYPE) ||
                      (opcode == `F_TYPE_STORE) || (opcode == `F_TYPE_ALU);
assign is_D_use_rd  = ~((opcode == `B_TYPE) || (opcode == `S_TYPE) || (opcode == `F_TYPE_STORE));
assign opcode_is_fp_store = (opcode == `F_TYPE_STORE);
assign is_D_rs1_float = (opcode == `F_TYPE_ALU);
assign is_D_rs2_float = (opcode == `F_TYPE_ALU) || (opcode == `F_TYPE_STORE);
assign is_D_rd_float  = (opcode == `F_TYPE_LOAD) || (opcode == `F_TYPE_ALU);

assign D_fp_mux_sel   = {(opcode_is_fp_store || (opcode == `F_TYPE_ALU)), (opcode == `F_TYPE_ALU)};

// Execute stage control
assign E_uses_pc_op1 = (E_opcode == `U_TYPE_AUIPC) || (E_opcode == `J_TYPE) || (E_opcode == `I_TYPE_JALR);
assign E_uses_rs2_op2 = (E_opcode == `R_TYPE) || (E_opcode == `B_TYPE) || (E_opcode == `F_TYPE_ALU);
assign E_exec_mux_sel = {(E_opcode == `F_TYPE_ALU), E_uses_rs2_op2, ~E_uses_pc_op1, (E_opcode == `I_TYPE_JALR)};

// Memory stage control
assign dm_byte_w_en = ((M_opcode == `S_TYPE) || (M_opcode == `F_TYPE_STORE)) ? 4'd0 : 4'd15;

// Writeback stage control
assign W_wb_sel = (W_opcode == `CSR) ? 2'b10 :
                  ((W_opcode == `I_TYPE_LOAD) || (W_opcode == `F_TYPE_LOAD)) ? 2'b01 :
                  2'b00;
assign W_wb_en  = (W_opcode == `I_TYPE_ALU) || (W_opcode == `R_TYPE) || (W_opcode == `J_TYPE) ||
                  (W_opcode == `I_TYPE_JALR) || (W_opcode == `U_TYPE_LUI) || (W_opcode == `U_TYPE_AUIPC) ||
                  (W_opcode == `I_TYPE_LOAD) || (W_opcode == `CSR);
assign W_fwb_en = (W_opcode == `F_TYPE_LOAD) || (W_opcode == `F_TYPE_ALU);

assign is_instret = (W_opcode == `CSR) && (W_rs2_idx == 5'b00010);

assign w_stage_is_nop = (W_opcode == `OPCODE_NOP) &&
                        (W_funct3 == `FUNCT3_NOP) &&
                        (W_rd_idx == `ZERO_REG) &&
                        (W_rs1_idx == `ZERO_REG);
assign instret_en = ~w_stage_is_nop;

always_ff@(posedge clk)begin
    if (rst) begin
        E_opcode <= 'd0;
        M_opcode <= 'd0;
        W_opcode <= 'd0;
        E_funct3 <= 'd0;
        M_funct3 <= 'd0;
        W_funct3 <= 'd0;
        E_funct7 <= 'd0;
        M_funct7 <= 'd0;
        W_funct7 <= 'd0;
        E_funct5 <= 'd0;
        E_cs_bit <= 'd0;
        M_cs_bit <= 'd0;
        W_cs_bit <= 'd0;
        pipe_ready <= 1'b0;
        D_inst_sel <= 1'b1;
    end
    else begin
        M_opcode <= E_opcode;
        W_opcode <= M_opcode;
        M_funct3 <= E_funct3;
        W_funct3 <= M_funct3;
        M_funct7 <= E_funct7;
        W_funct7 <= M_funct7;
        M_cs_bit <= E_cs_bit;
        W_cs_bit <= M_cs_bit;
        pipe_ready <= 1'b1;
        D_inst_sel <= hold_decode;

        if(stall == 1'b0 && flush == 1'b0)begin
            E_opcode <= opcode;
            E_funct3 <= funct3;
            E_funct7 <= funct7;
            E_funct5 <= funct5;
            E_cs_bit <= cs_high_bit;
        end
        else begin
            E_opcode <= `OPCODE_NOP;
            E_funct3 <= `FUNCT3_NOP;
            E_funct7 <= `FUNCT7_NOP;
            E_funct5 <= `FUNCT5_NOP;
            E_cs_bit <= 1'd0;
        end
    end
end

endmodule


