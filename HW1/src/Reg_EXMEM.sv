`include "../include/defines.svh"
module Reg_EXMEM(
    input logic clk,
    input logic rst,
    input logic [`DATA_WIDTH-1:0] alu,
    input logic [`DATA_WIDTH-1:0] rs2_data,
    input logic [`ADDR_WIDTH-1:0] E_rs1_idx,
    input logic [`ADDR_WIDTH-1:0] E_rs2_idx,
    input logic [`ADDR_WIDTH-1:0] E_rd_idx,
    input logic E_use_rs2,
    input logic E_use_rd,
    input logic E_rs2_float,
    input logic E_rd_float,
    output logic [`DATA_WIDTH-1:0] alu_out,
    output logic [`DATA_WIDTH-1:0] rs2_data_out,
    output logic [`ADDR_WIDTH-1:0] M_rs1_idx,
    output logic [`ADDR_WIDTH-1:0] M_rs2_idx,
    output logic [`ADDR_WIDTH-1:0] M_rd_idx,
    output logic M_use_rs2,
    output logic M_use_rd,
    output logic M_rs2_float,
    output logic M_rd_float
);

always_ff @(posedge clk) begin
    if (rst) begin
        alu_out <= 'd0;
        rs2_data_out <= 'd0;
        M_rs1_idx <= 'd0;
        M_rs2_idx <= 'd0;
        M_rd_idx <= 'd0;
        M_use_rs2 <= 1'b0;
        M_use_rd <= 1'b0;
        M_rs2_float <= 1'b0;
        M_rd_float <= 1'b0;
    end else begin
        alu_out <= alu;
        rs2_data_out <= rs2_data;
        M_rs1_idx <= E_rs1_idx;
        M_rs2_idx <= E_rs2_idx;
        M_rd_idx <= E_rd_idx;
        M_use_rs2 <= E_use_rs2;
        M_use_rd <= E_use_rd;
        M_rs2_float <= E_rs2_float;
        M_rd_float <= E_rd_float;
    end
end

endmodule
