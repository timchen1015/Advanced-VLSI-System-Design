`include "../include/defines.svh"
module Reg_IFID(
    input logic clk,
    input logic rst,
    //From Reg_PC
    input logic [`PC_WIDTH-1:0] pc,
    //From Controller
    input logic [`INSTR_WIDTH-1:0] inst,
    input logic stall,
    input logic flush,
    input logic pred_taken,
    input logic pred_valid,
    input logic hold,                           // freeze IF/ID instruction
    output logic [`PC_WIDTH-1:0] pc_out,
    output logic [`INSTR_WIDTH-1:0] inst_out,
    output logic pred_taken_out,
    output logic pred_valid_out
);
logic start;

always_ff @(posedge clk) begin
    if (rst) begin
        pc_out <= 'd0;
        inst_out <= 'd0;
        pred_taken_out <= 'b0;
        pred_valid_out <= 'b0;
        start <= 'b0;
    end else if(!start) begin
        pc_out <= 'd0;
        inst_out <= `NOP_INSTR;
        pred_taken_out <= 1'b0;
        pred_valid_out <= 1'b0;
        start <= 'b1;
    end else if (flush) begin
        pc_out <= 'd0;
        inst_out <= `NOP_INSTR;
        pred_taken_out <= 1'b0;
        pred_valid_out <= 1'b0;
    end else begin
        if (!stall) begin
            pc_out <= pc;
            pred_taken_out <= pred_taken;
            pred_valid_out <= pred_valid;
        end
        if (!hold) begin
            inst_out <= inst;
        end
    end
end




endmodule
