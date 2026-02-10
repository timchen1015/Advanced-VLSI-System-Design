`include "../include/defines.svh"
module Reg_IDEX(
    input logic clk,
    input logic rst,
    input logic [`PC_WIDTH-1:0] pc,
    input logic [`DATA_WIDTH-1:0] rs1_data,
    input logic [`DATA_WIDTH-1:0] rs2_data,
    input logic [`IMM_WIDTH-1:0] s_ext_imme,
    input logic [`ADDR_WIDTH-1:0] rs1_idx,
    input logic [`ADDR_WIDTH-1:0] rs2_idx,
    input logic [`ADDR_WIDTH-1:0] rd_idx,
    input logic D_use_rs1,
    input logic D_use_rs2,
    input logic D_use_rd,
    input logic D_rs1_float,
    input logic D_rs2_float,
    input logic D_rd_float,
    input logic stall,
    input logic flush,
    input logic pred_taken,
    input logic pred_valid,
    output logic [`PC_WIDTH-1:0] pc_out,
    output logic [`DATA_WIDTH-1:0] rs1_data_out,
    output logic [`DATA_WIDTH-1:0] rs2_data_out,
    output logic [`IMM_WIDTH-1:0] s_ext_imme_out,
    output logic [`ADDR_WIDTH-1:0] E_rs1_idx,
    output logic [`ADDR_WIDTH-1:0] E_rs2_idx,
    output logic [`ADDR_WIDTH-1:0] E_rd_idx,
    output logic E_use_rs1,
    output logic E_use_rs2,
    output logic E_use_rd,
    output logic E_rs1_float,
    output logic E_rs2_float,
    output logic E_rd_float,
    output logic pred_taken_out,
    output logic pred_valid_out
);

always_ff @(posedge clk) begin
    if (rst) begin
        pc_out <= 'd0;
        rs1_data_out <= 'd0;
        rs2_data_out <= 'd0;
        s_ext_imme_out <= 'd0;
        E_rs1_idx <= 'd0;
        E_rs2_idx <= 'd0;
        E_rd_idx <= 'd0;
        E_use_rs1 <= 1'b0;
        E_use_rs2 <= 1'b0;
        E_use_rd <= 1'b0;
        E_rs1_float <= 1'b0;
        E_rs2_float <= 1'b0;
        E_rd_float <= 1'b0;
        pred_taken_out <= 1'b0;
        pred_valid_out <= 1'b0;
    end else if (flush) begin
        pc_out <= 'd0;
        rs1_data_out <= 'd0;
        rs2_data_out <= 'd0;
        s_ext_imme_out <= 'd0;
        E_rs1_idx <= 'd0;
        E_rs2_idx <= 'd0;
        E_rd_idx <= 'd0;
        E_use_rs1 <= 1'b0;
        E_use_rs2 <= 1'b0;
        E_use_rd <= 1'b0;
        E_rs1_float <= 1'b0;
        E_rs2_float <= 1'b0;
        E_rd_float <= 1'b0;
        pred_taken_out <= 1'b0;
        pred_valid_out <= 1'b0;
    end else if (stall) begin
        E_rs1_idx <= 'd0;
        E_rs2_idx <= 'd0;
        E_rd_idx <= 'd0;
        E_use_rs1 <= 1'b0;
        E_use_rs2 <= 1'b0;
        E_use_rd <= 1'b0;
        E_rs1_float <= 1'b0;
        E_rs2_float <= 1'b0;
        E_rd_float <= 1'b0;
    end else begin
        pc_out <= pc;
        rs1_data_out <= rs1_data;
        rs2_data_out <= rs2_data;
        s_ext_imme_out <= s_ext_imme;
        E_rs1_idx <= rs1_idx;
        E_rs2_idx <= rs2_idx;
        E_rd_idx <= rd_idx;
        E_use_rs1 <= D_use_rs1;
        E_use_rs2 <= D_use_rs2;
        E_use_rd <= D_use_rd;
        E_rs1_float <= D_rs1_float;
        E_rs2_float <= D_rs2_float;
        E_rd_float <= D_rd_float;
        pred_taken_out <= pred_taken;
        pred_valid_out <= pred_valid;
    end
end

endmodule