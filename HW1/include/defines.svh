// --------------------------------------------------------------------------
// RISC-V CPU Defines
// --------------------------------------------------------------------------

`define DATA_WIDTH          32      // Data width
`define ADDR_WIDTH          5       // Address width
`define NUM_REGS            32      // Number of registers

// Program counter
`define PC_WIDTH           32      // Program counter width

//Instruction  width
`define INSTR_WIDTH        32      // Instruction width
`define FUNCT3_WIDTH       3       // Funct3 field width
`define FUNCT7_WIDTH       7       // Funct7 field width
`define FUNCT5_WIDTH       5       // Funct5 field width

`define MEM_WRITE_ENABLE   4       // Memory write enable width (byte-level)

// Instruction decode
`define OPCODE_WIDTH       7       // Opcode field width
`define FUNCT3_WIDTH       3       // Funct3 field width
`define FUNCT7_WIDTH       7       // Funct7 field width
`define FUNCT5_WIDTH       5       // Funct5 field width
`define IMM_WIDTH          32      // Immediate value width
`define MAJOR_OPCODE_WIDTH  5         // Major opcode width

//opcode types
//opcode[6:2]
`define R_TYPE             5'b01100  // R-type instructions
`define I_TYPE_ALU         5'b00100  // I-type ALU instructions
`define I_TYPE_LOAD        5'b00000  // I-type Load instructions
`define I_TYPE_JALR        5'b11001  // I-type jump and link register
`define S_TYPE             5'b01000  // S-type instructions
`define B_TYPE             5'b11000  // B-type instructions
`define U_TYPE_LUI         5'b01101  // U-type load upper immediate
`define U_TYPE_AUIPC       5'b00101  // U-type add upper
`define J_TYPE             5'b11011  // J-type instructions
`define F_TYPE_LOAD        5'b00001  // F-type load instructions
`define F_TYPE_STORE       5'b01001  // F-type store instructions
`define F_TYPE_ALU         5'b10100  // F-type ALU instructions
`define CSR                5'b11100  // CSR instructions

//FUNCT5
`define FADD_S             5'b00000
`define FSUB_S             5'b00001

// Branch predictor
`define BP_TABLE_SIZE      256     // Branch predictor table size
`define BP_TABLE_ADDR      8       // Branch predictor table address width

// Common values
`define ZERO_REG           5'b00000 // x0 register
`define NOP_INSTR          32'h00000013 // addi x0, x0, 0
`define OPCODE_NOP         5'b00100  
`define FUNCT3_NOP         3'd0
`define FUNCT7_NOP         7'd0
`define FUNCT5_NOP         5'd0
