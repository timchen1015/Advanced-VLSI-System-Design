`include "../include/defines.svh"
module Reg_PC(
    input  logic                    clk,
    input  logic                    rst,
    input  logic                    stall,
    input  logic  [`PC_WIDTH-1:0]   next_pc,
    output logic  [`PC_WIDTH-1:0]   current_pc
);

always_ff @(posedge clk) begin
    if (rst) begin
        current_pc <= 'd0;
    end else begin
        current_pc <= (stall) ? current_pc : next_pc;
    end
end

endmodule
