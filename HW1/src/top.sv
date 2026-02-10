`include "CPU.sv"
`include "SRAM_wrapper.sv"
module top(
    input logic clk,
    input logic rst
);

logic [3:0] dm_byte_w_en;
logic [31:0] dm_bit_w_en;
logic [`PC_WIDTH-1:0] cpu_pc;
logic [`DATA_WIDTH-1:0] cpu_data_to_dm;
logic [`DATA_WIDTH-1:0] cpu_dm_rdata;
logic [`DATA_WIDTH-1:0] cpu_alu_out;
logic [`INSTR_WIDTH-1:0] im_data;

assign dm_bit_w_en = {{8{dm_byte_w_en[3]}}, {8{dm_byte_w_en[2]}}, {8{dm_byte_w_en[1]}}, {8{dm_byte_w_en[0]}}};

CPU CPU(
    .clk(clk),
    .rst(rst),
    .ld_data(cpu_dm_rdata),
    .F_inst(im_data),
    .dm_byte_w_en(dm_byte_w_en),
    .F_pc(cpu_pc),
    .M_alu_out(cpu_alu_out),
    .data_to_dm(cpu_data_to_dm)
);

SRAM_wrapper IM1(
  .CLK(clk),
  .RST(rst),
  .CEB(1'b0),
  .WEB(1'b1),
  .BWEB(32'hFFFF_FFFF),
  .A(cpu_pc[15:2]),
  .DI(32'd0),
  .DO(im_data)
);

SRAM_wrapper DM1(
  .CLK(clk),
  .RST(rst),
  .CEB(1'b0),
  .WEB(&dm_byte_w_en),
  .BWEB(dm_bit_w_en),
  .A(cpu_alu_out[15:2]),
  .DI(cpu_data_to_dm),
  .DO(cpu_dm_rdata)
);

endmodule
