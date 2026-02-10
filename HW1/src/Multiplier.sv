`include "../include/defines.svh"
module Multiplier(
    input  logic [`DATA_WIDTH-1:0] op1,
    input  logic [`DATA_WIDTH-1:0] op2,
    input  logic [`FUNCT3_WIDTH-1:0] funct3,
    output logic [`DATA_WIDTH-1:0] mul_out
);
    localparam [2:0] MUL    = 3'b000,
                     MULH   = 3'b001,
                     MULHSU = 3'b010,
                     MULHU  = 3'b011;

    logic signed [32:0] mul1, mul2;     // signed 33 bits
    logic signed [65:0] result;         // signed 66 bits

    always_comb begin
        case (funct3)
            MUL: begin // signed* signed low
                mul1 = {{1{op1[31]}}, op1};
                mul2 = {{1{op2[31]}}, op2};
                mul_out = result[31:0];
            end
            MULH: begin // signed* signed high
                mul1 = {{1{op1[31]}}, op1};
                mul2 = {{1{op2[31]}}, op2};
                mul_out = result[63:32];
            end
            MULHSU: begin // signed * unsigned
                mul1 = {{1{op1[31]}}, op1};
                mul2 = {1'b0, op2};
                mul_out = result[63:32];
            end
            MULHU: begin // unsigned * unsigned
                mul1 = {1'b0, op1};
                mul2 = {1'b0, op2};
                mul_out = result[63:32];
            end
            default: begin
                mul1 = 33'sd0;
                mul2 = 33'sd0;
                mul_out = 64'sd0;
            end
        endcase
    end
    assign result = mul1 * mul2;
endmodule
