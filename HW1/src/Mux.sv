`include "../include/defines.svh"
module Mux(
    input logic [`DATA_WIDTH-1:0] in0,
    input logic [`DATA_WIDTH-1:0] in1,
    input logic sel,
    output logic [`DATA_WIDTH-1:0] out
);
    assign out = (sel == 1'd1) ? in1 : in0;
endmodule