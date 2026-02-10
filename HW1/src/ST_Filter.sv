`include "../include/defines.svh"
module ST_Filter(
    input  logic [`MAJOR_OPCODE_WIDTH-1:0] opcode,
    input  logic [`FUNCT3_WIDTH-1:0]       funct3,
    input  logic [1:0]                     addr_offset,
    input  logic [`DATA_WIDTH-1:0]         rs2_data,
    output logic [`DATA_WIDTH-1:0]         store_data
);

always_comb begin
    store_data = rs2_data;
    if ((opcode == `S_TYPE) || (opcode == `F_TYPE_STORE)) begin
        case (funct3)
            3'b000: begin
                case (addr_offset)
                    2'b00: store_data = {{24{1'b0}}, rs2_data[7:0]};
                    2'b01: store_data = {{16{1'b0}}, rs2_data[7:0], 8'd0};
                    2'b10: store_data = {{8{1'b0}},  rs2_data[7:0], 16'd0};
                    default: store_data = {rs2_data[7:0], 24'd0};
                endcase
            end
            3'b001: begin
                case (addr_offset)
                    2'b00: store_data = {{16{1'b0}}, rs2_data[15:0]};
                    2'b01: store_data = {{8{1'b0}},  rs2_data[15:0], 8'd0};
                    2'b10: store_data = {rs2_data[15:0], 16'd0};
                    default: store_data = {rs2_data[7:0], 24'd0};
                endcase
            end
            default: store_data = rs2_data;
        endcase
    end
end

endmodule

