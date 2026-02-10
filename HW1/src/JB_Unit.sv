`include "../include/defines.svh"
module JB_Unit(
	input logic [`DATA_WIDTH-1:0] op1,
	input logic [`DATA_WIDTH-1:0] op2,
	output logic [`INSTR_WIDTH-1:0] jb_out
);

assign jb_out = (op1 + op2) & (~`DATA_WIDTH'd1);

endmodule