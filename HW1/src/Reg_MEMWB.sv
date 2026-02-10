`include "../include/defines.svh"
module Reg_MEMWB(
    input logic clk,
    input logic rst,
    input logic [`DATA_WIDTH-1:0] alu,
    input logic [`ADDR_WIDTH-1:0] M_rd_idx,
    input logic [`ADDR_WIDTH-1:0] M_rs1_idx,
    input logic [`ADDR_WIDTH-1:0] M_rs2_idx,
    input logic M_use_rd,
    input logic M_rd_float,
    output logic [`DATA_WIDTH-1:0] alu_out,
    output logic [`ADDR_WIDTH-1:0] W_rd_idx,
    output logic [`ADDR_WIDTH-1:0] W_rs1_idx,
    output logic [`ADDR_WIDTH-1:0] W_rs2_idx,
    output logic W_use_rd,
    output logic W_rd_float
);

always_ff @(posedge clk) begin
    if (rst) begin
        alu_out <= 'b0;
        W_rd_idx <= 'd0;
        W_rs1_idx <= 'd0;
        W_rs2_idx <= 'd0;
        W_use_rd <= 1'b0;
        W_rd_float <= 1'b0;
    end else begin
        alu_out <= alu;
        W_rd_idx <= M_rd_idx;
        W_rs1_idx <= M_rs1_idx;
        W_rs2_idx <= M_rs2_idx;
        W_use_rd <= M_use_rd;
        W_rd_float <= M_rd_float;
    end
end

endmodule