module ID_Stage (
    input  logic clk,
    input  logic rst,

    //------------From IF/ID Register------------//
    input  logic [`InstructionBus] ID_instruction,
    //------------From IF/ID Register------------//

    input  logic                   regwrite_gen,
    input  logic                   regwrite_fp,
    input  logic [    `RegAddrBus] reg_rd_addr,
    input  logic [        `RegBus] reg_rd_data,

    output logic [    `RegAddrBus] rs1_addr,    //for (forwarding and hazard) detection
    output logic [        `RegBus] rs1_data,

    output logic [    `RegAddrBus] rs2_addr,    //for (forwarding and hazard) detection
    output logic [        `RegBus] rs2_data,

    output logic [    `RegAddrBus] rd_addr,     //for hazard detection and target store register  

    output logic [           11:0] CSR_addr,

    output logic [`FUNCTION_3-1:0] funct3,
    output logic [`FUNCTION_7-1:0] funct7,
    output logic [        `RegBus] Imm_out,

    //------------Output Control signals------------//
    output logic [    `ALUTypeBus] ALU_mode,
    output logic                   EXE_PC_sel,
    output logic                   ALUSrc,       
    output logic [ `BranchTypeBus] branch_signal,
    output logic                   MEM_rd_sel,
    output logic                   gen_fp_rs1_sel,
    output logic                   gen_fp_rs2_sel,
    output logic                   MemRead,
    output logic                   MemWrite,
    output logic                   gen_reg_write,
    output logic                   fp_reg_write,
    output logic                   WB_data_sel,
    output logic                   CSR_sel 
    //------------Output Control signals------------//
);

assign rs1_addr = ID_instruction[19:15];
assign rs2_addr = ID_instruction[24:20];
assign rd_addr  = ID_instruction[11:7];
assign CSR_addr = ID_instruction[31:20];

assign funct3   = ID_instruction[14:12];
assign funct7   = ID_instruction[31:25];

logic [`OPCODE-1:0] opcode;
logic [`ImmTypeBus] Imm_type;
logic [    `RegBus] rs1_gen_data;
logic [    `RegBus] rs2_gen_data;
logic [    `RegBus] rs1_fp_data;
logic [    `RegBus] rs2_fp_data;

assign opcode   = ID_instruction[6:0];

//----------------------Control----------------------//
Control i_Control(
    .opcode(opcode),
    .Imm_type(Imm_type),
    .ALU_mode(ALU_mode),
    .EXE_PC_sel(EXE_PC_sel),
    .ALUSrc(ALUSrc),       
    .branch_signal(branch_signal),
    .MEM_rd_sel(MEM_rd_sel),
    .gen_fp_rs1_sel(gen_fp_rs1_sel),
    .gen_fp_rs2_sel(gen_fp_rs2_sel),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .gen_reg_write(gen_reg_write),
    .fp_reg_write(fp_reg_write),
    .WB_data_sel(WB_data_sel),
    .CSR_sel(CSR_sel)
);
//----------------------Control----------------------//

//------------------ Register File -------------------//
ID_Gen_RegFile i_ID_Gen_RegFile(
    .clk(clk),
    .rst(rst),

    .regwrite(regwrite_gen),

    .rs1_addr(rs1_addr),
    .rs1_data(rs1_gen_data),

    .rs2_addr(rs2_addr),
    .rs2_data(rs2_gen_data),

    .rd_addr(reg_rd_addr),
    .rd_data(reg_rd_data)
);

ID_FP_RegFile i_ID_FP_RegFile(
    .clk(clk),
    .rst(rst),

    .regwrite(regwrite_fp),

    .rs1_addr(rs1_addr),
    .rs1_data(rs1_fp_data),

    .rs2_addr(rs2_addr),
    .rs2_data(rs2_fp_data),

    .rd_addr(reg_rd_addr),
    .rd_data(reg_rd_data)
);


always_comb
begin
    unique case(gen_fp_rs1_sel)
        1'b0: rs1_data = rs1_gen_data;
        1'b1: rs1_data = rs1_fp_data;
        default : rs1_data = `ZeroWord;
    endcase
end

always_comb
begin
    unique case(gen_fp_rs2_sel)
        1'b0: rs2_data = rs2_gen_data;
        1'b1: rs2_data = rs2_fp_data;
        default: rs2_data = `ZeroWord;
    endcase
end
//------------------ Register File -------------------//

//-----------------ImmediateGenerator-----------------//
ID_ImmediateGenerator i_ID_ImmediateGenerator(
    .Imm_type(Imm_type),
    .instruction(ID_instruction),
    .Imm_out(Imm_out)
);
//-----------------ImmediateGenerator-----------------//

endmodule