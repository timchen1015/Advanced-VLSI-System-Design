`include "../include/defines.svh"
module Adder(
    input logic [`DATA_WIDTH-1:0] a,
    input logic [`DATA_WIDTH-1:0] b,
    output logic [`DATA_WIDTH-1:0] sum
);
    assign sum = a + b;
endmodule