
`include "../include/defines.svh"
module FPRegFile (
	input logic clk,               
 	input logic rst,
	input logic fwb_en,
	input logic [`DATA_WIDTH-1:0] fwb_data,
	input logic [`ADDR_WIDTH-1:0] rd_idx,
	input logic [`ADDR_WIDTH-1:0] rs1_idx,
	input logic [`ADDR_WIDTH-1:0] rs2_idx,
	output logic [`DATA_WIDTH-1:0] rs1_data_out,
	output logic [`DATA_WIDTH-1:0] rs2_data_out
);

logic [`DATA_WIDTH-1:0] registers [0:`NUM_REGS-1];   
integer i;

assign rs1_data_out = registers[rs1_idx];
assign rs2_data_out = registers[rs2_idx];

always_ff @(posedge clk) begin
	if (rst) begin
		for (i = 0; i < `NUM_REGS; i = i + 1) begin
			registers[i] <= 'd0;
		end
	end else if (fwb_en && (rd_idx!= `ZERO_REG)) begin
		registers[rd_idx] <= fwb_data;
	end
end

endmodule
