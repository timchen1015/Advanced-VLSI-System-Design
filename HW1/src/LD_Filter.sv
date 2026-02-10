`include "../include/defines.svh"
module LD_Filter(
	input logic [`FUNCT3_WIDTH-1:0] funct3,
	input logic [`DATA_WIDTH-1:0] ld_data,
	output logic [`DATA_WIDTH-1:0] ld_filtered_data
);
always_comb begin
    case(funct3)
        3'b000: ld_filtered_data = {{24{ld_data[7]}}, ld_data[7:0]}; //LB
        3'b001: ld_filtered_data = {{16{ld_data[15]}}, ld_data[15:0]}; //LH
        3'b010: ld_filtered_data = ld_data; //LW
        3'b100: ld_filtered_data = {24'd0, ld_data[7:0]}; //LBU
        3'b101: ld_filtered_data = {16'd0, ld_data[15:0]}; //LHU
        default: ld_filtered_data = ld_data; //LW
    endcase
end
endmodule
