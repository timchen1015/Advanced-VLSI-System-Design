
//Signals
`define StartAddress        32'h0000_0000
`define ZeroWord            32'h0000_0000
`define INACTIVE            32'hffff_ffff

`define WriteEnable         1'b1
`define WriteDisable        1'b0

//Bus Width
`define InstructionBus      31:0
`define InstructionAddrBus  31:0
`define DataBus             31:0
`define DataAddrBus         31:0
`define BWEBBus             31:0

`define PCTypeBus           1:0

`define DataWidth           32
`define Mult_DataWidth      64
`define CSR_REG_WIDTH       64
`define RegNum              32
`define RegNumLog2          5

`define RegBus              `DataWidth-1:0 //31:0
`define RegAddrBus          `RegNumLog2-1:0 //4:0

`define ImmTypeBus          2:0
`define ALUTypeBus          2:0
`define BranchTypeBus       1:0
`define ForwardSelectBus    1:0

// NOP (bubble) //
`define NOP                 32'h0000_0013      // addi x0, x0, 0

`define OPCODE              7
`define FUNCTION_3          3
`define FUNCTION_7          7

//IEEE 754 32-bit single-precision
`define EXPONENT            8
`define FRACTION            23


// Cache
`define CACHE_BLOCK_BITS 2
`define CACHE_INDEX_BITS 5
`define CACHE_TAG_BITS 23
`define CACHE_DATA_BITS 128
`define CACHE_LINES 2**(`CACHE_INDEX_BITS)
`define CACHE_WRITE_BITS 16
`define CACHE_TYPE_BITS 3
`define CACHE_BYTE `CACHE_TYPE_BITS'b000
`define CACHE_HWORD `CACHE_TYPE_BITS'b001
`define CACHE_WORD `CACHE_TYPE_BITS'b010
`define CACHE_BYTE_U `CACHE_TYPE_BITS'b100
`define CACHE_HWORD_U `CACHE_TYPE_BITS'b101


// CPU
`define DATA_BITS 32
`define INS_SIZE 32


