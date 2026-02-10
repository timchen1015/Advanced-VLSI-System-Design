`include "../include/defines.svh"
`include "Multiplier.sv"
module ALU (
    input  logic [`MAJOR_OPCODE_WIDTH-1:0] opcode,
    input  logic [`FUNCT3_WIDTH-1:0] funct3,
    input  logic [`FUNCT7_WIDTH-1:0] funct7,
    input  logic [`DATA_WIDTH-1:0] op1,
    input  logic [`DATA_WIDTH-1:0] op2,
    output logic [`DATA_WIDTH-1:0] rd
);

logic signed [`DATA_WIDTH-1:0] mul_result;
Multiplier u_Mul(
    .op1(op1),
    .op2(op2),
    .funct3(funct3),
    .mul_out(mul_result)
);

always_comb begin
    rd = 'd0;  // Default value
    case (opcode)
        `R_TYPE: begin
            if (funct7 == 7'b0000001) begin                                         // MUL
                rd = mul_result;
            end else begin                                                          // Standard R-type
                case (funct3)
                    3'b000: rd = (funct7[5]) ? (op1 - op2) : (op1 + op2);           // SUB : ADD
                    3'b001: rd = op1 << op2[4:0];                                   // SLL
                    3'b010: rd = ($signed(op1) < $signed(op2)) ? 32'd1 : 32'd0;     // SLT
                    3'b011: rd = (op1 < op2) ? 32'd1 : 32'd0;                       // SLTU
                    3'b100: rd = op1 ^ op2;                                         // XOR
                    3'b101: rd = funct7[5] ? ($signed(op1) >>> op2[4:0]) : ($signed(op1) >> op2[4:0]); // SRA($S) : SRL($U)
                    3'b110: rd = op1 | op2;                                         // OR
                    3'b111: rd = op1 & op2;                                         // AND
                endcase
            end
        end
        `I_TYPE_ALU: begin
            case (funct3)
                3'b000: rd = op1 + op2;                                             // ADDI
                3'b001: rd = op1 << op2[4:0];                                       // SLLI
                3'b010: rd = ($signed(op1) < $signed(op2)) ? 'd1 : 'd0;             // SLTI
                3'b011: rd = (op1 < op2) ? 'd1 : 'd0;                               // SLTIU
                3'b100: rd = op1 ^ op2;                                             // XORI
                3'b101: rd = funct7[5] ?  $signed(op1) >>> op2[4:0] : $signed(op1) >> op2[4:0]; //  SRAI($S) : SRLI($U)
                3'b110: rd = op1 | op2;                                             // ORI
                3'b111: rd = op1 & op2;                                             // ANDI
            endcase
        end
        `B_TYPE: begin
            case (funct3)
                3'b000: rd = (op1 == op2) ? 'd1 : 'd0;                              // BEQ
                3'b001: rd = (op1 != op2) ? 'd1 : 'd0;                              // BNE
                3'b100: rd = ($signed(op1) < $signed(op2)) ? 'd1 : 'd0;             // BLT
                3'b101: rd = ($signed(op1) >= $signed(op2)) ? 'd1 : 'd0;            // BGE
                3'b110: rd = (op1 < op2) ? 'd1 : 'd0;                               // BLTU
                3'b111: rd = (op1 >= op2) ? 'd1 : 'd0;                              // BGEU
                default: rd = 'd0;
            endcase
        end
        //ALU Add
        `I_TYPE_LOAD, `S_TYPE,  `F_TYPE_LOAD, `F_TYPE_STORE,  `U_TYPE_AUIPC: rd = op1 + op2;
        // Special cases
        `U_TYPE_LUI: rd = op2;           
        `J_TYPE, `I_TYPE_JALR: rd = op1 + 'd4; 
        default: rd = 'd0;
    endcase
end

endmodule
