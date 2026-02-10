`include "../include/defines.svh"
module BranchPredictor (
  input  logic        clk,
  input  logic        rst,
  input  logic        [`PC_WIDTH-1:0] fetch_pc,
  output logic        predict_taken,
  input  logic        update_en,
  input  logic        [`PC_WIDTH-1:0] update_pc,
  input  logic        update_taken
);

  logic [1:0] predict_table [`BP_TABLE_SIZE-1:0];
  logic [`BP_TABLE_ADDR-1:0] fetch_idx;
  logic [`BP_TABLE_ADDR-1:0] update_idx;

  assign fetch_idx  = fetch_pc[`BP_TABLE_ADDR+1:2];
  assign update_idx = update_pc[`BP_TABLE_ADDR+1:2];

  assign predict_taken = predict_table[fetch_idx][1];

  integer i;
  always_ff @(posedge clk) begin
    if (rst) begin
      for (i = 0; i < `BP_TABLE_SIZE; i++) begin
        predict_table[i] <= 2'b01;   // weakly not taken
      end
    end else if (update_en) begin
      case (predict_table[update_idx])
        2'b00: predict_table[update_idx] <= update_taken ? 2'b01 : 2'b00;
        2'b01: predict_table[update_idx] <= update_taken ? 2'b10 : 2'b00;
        2'b10: predict_table[update_idx] <= update_taken ? 2'b11 : 2'b01;
        2'b11: predict_table[update_idx] <= update_taken ? 2'b11 : 2'b10;
      endcase
    end
  end

endmodule
