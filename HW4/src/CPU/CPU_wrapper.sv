module CPU_wrapper (
    input logic ACLK,
    input logic ARESETn,
    
    output logic [  `AXI_ID_BITS-1:0] M0_ARID,
    output logic [`AXI_ADDR_BITS-1:0] M0_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] M0_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] M0_ARSIZE,
    output logic [               1:0] M0_ARBURST,
    output logic                      M0_ARVALID,
    input  logic                      M0_ARREADY,

    input  logic [  `AXI_ID_BITS-1:0] M0_RID,
    input  logic [`AXI_DATA_BITS-1:0] M0_RDATA,
    input  logic [               1:0] M0_RRESP,
    input  logic                      M0_RLAST,
    input  logic                      M0_RVALID,
    output logic                      M0_RREADY,

    output logic [  `AXI_ID_BITS-1:0] M1_ARID,
    output logic [`AXI_ADDR_BITS-1:0] M1_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] M1_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] M1_ARSIZE,
    output logic [               1:0] M1_ARBURST,
    output logic                      M1_ARVALID,
    input  logic                      M1_ARREADY,

    input  logic [  `AXI_ID_BITS-1:0] M1_RID,
    input  logic [`AXI_DATA_BITS-1:0] M1_RDATA,
    input  logic [               1:0] M1_RRESP,
    input  logic                      M1_RLAST,
    input  logic                      M1_RVALID,
    output logic                      M1_RREADY,

    output logic [  `AXI_ID_BITS-1:0] M1_AWID,
    output logic [`AXI_ADDR_BITS-1:0] M1_AWADDR,
    output logic [ `AXI_LEN_BITS-1:0] M1_AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] M1_AWSIZE,
    output logic [               1:0] M1_AWBURST,
    output logic                      M1_AWVALID,
    input  logic                      M1_AWREADY,

    output logic [`AXI_DATA_BITS-1:0] M1_WDATA,
    output logic [`AXI_STRB_BITS-1:0] M1_WSTRB,
    output logic                      M1_WLAST,
    output logic                      M1_WVALID,
    input  logic                      M1_WREADY,

    input  logic [  `AXI_ID_BITS-1:0] M1_BID,
    input  logic [               1:0] M1_BRESP,
    input  logic                      M1_BVALID,
    output logic                      M1_BREADY,

    input logic     DMA_interrupt,
    input logic     WDT_timeout
);

// ----------------------------
// Internal connections
// ----------------------------
logic [`InstructionAddrBus] imem_addr;
logic [    `InstructionBus] imem_rdata;

logic [           `BWEBBus] DM_BWEB;
logic [       `DataAddrBus] dmem_addr;
logic [           `DataBus] dmem_wdata;
logic [           `DataBus] dmem_rdata;

logic                       instruction_fetch_sig;
logic                       MEM_MemRead;
logic                       MEM_MemWrite;

logic                       IM_stall;
logic                       DM_stall;

logic [3:0]                 cache_core_write;
logic                       cache_core_req;
logic [           `DataBus] cache_core_out;
logic                       cache_core_wait;

logic                       cache_d_req;
logic [       `DataAddrBus] cache_d_addr;
logic [           `DataBus] cache_d_in;
logic [3:0]                 cache_d_type;

logic                       cache_read_req;
logic                       cache_write_req;
logic [           `BWEBBus] cache_dm_bweb;

logic [           `DataBus] dmaster_data_out;
logic                       dmaster_stall;

logic [`InstructionAddrBus] ic_axi_addr;
logic [    `InstructionBus] ic_axi_data;
logic                       ic_axi_req;
logic                       ic_axi_wait;

// ------------------------------------------------------
// CPU Core instance
// - Provides instruction and data memory access
// - Generates control signals for memory operations
// ------------------------------------------------------
CPU i_CPU(
    .clk                   (ACLK),
    .rst                   (~ARESETn),      //i_CPU reset is active high

    .Instruction_addr      (imem_addr),
    .Instruction_data      (imem_rdata),

    .DM_BWEB               (DM_BWEB),
    .Data_addr             (dmem_addr),
    .Data_out              (dmem_wdata),
    .Data_in               (dmem_rdata),

    .instruction_fetch_sig (instruction_fetch_sig),
    .MEM_MemRead           (MEM_MemRead),
    .MEM_MemWrite          (MEM_MemWrite),

    .IM_stall              (IM_stall),
    .DM_stall              (DM_stall),
    .DMA_interrupt         (DMA_interrupt),
    .WDT_timeout           (WDT_timeout)
);

// ------------------------------------------------------
// Data Cache (L1)
// - Buffers CPU data accesses
// - Issues miss traffic to AXI data master
// ------------------------------------------------------
assign cache_core_req   = MEM_MemRead | MEM_MemWrite;
assign cache_core_write = {&DM_BWEB[31:24], &DM_BWEB[23:16], &DM_BWEB[15:8], &DM_BWEB[7:0]};

assign cache_read_req   = cache_d_req & (cache_d_type == 4'hf);
assign cache_write_req  = cache_d_req & (cache_d_type != 4'hf);
assign cache_dm_bweb    = { {8{cache_d_type[3]}}, {8{cache_d_type[2]}}, {8{cache_d_type[1]}}, {8{cache_d_type[0]}} };

assign dmem_rdata = cache_core_out;
assign DM_stall   = cache_core_wait;

L1C_data i_L1C_data(
    .clk          (ACLK),
    .rstn         (ARESETn),
    .cpu_core_addr  (dmem_addr),
    .cpu_core_req   (cache_core_req),
    .cpu_core_write (cache_core_write),
    .cpu_core_in    (dmem_wdata),
    .D_out        (dmaster_data_out),
    .D_wait       (dmaster_stall),
    .rvalid_m1_i  (M1_RVALID),
    .rready_m1_i  (M1_RREADY),
    .cpu_core_out   (cache_core_out),
    .cpu_core_wait  (cache_core_wait),
    .D_req        (cache_d_req),
    .D_addr       (cache_d_addr),
    .D_in         (cache_d_in),
    .D_type       (cache_d_type)
);

// ------------------------------------------------------
// Instruction Memory Master (M0)
// - Generates AXI read requests for instruction fetch
// - Connects CPU instruction interface to AXI bus
// ------------------------------------------------------
L1C_inst i_L1C_inst(
    .clk        (ACLK),
    .rstn        (ARESETn),
    .cpu_core_addr  (imem_addr),
    .cpu_core_req   (instruction_fetch_sig),
    .I_out      (ic_axi_data),
    .I_wait     (ic_axi_wait),
    .rvalid_m0_i(M0_RVALID),
    .rready_m0_i(M0_RREADY),
    .cpu_core_out   (imem_rdata),
    .cpu_core_wait  (IM_stall),
    .I_req      (ic_axi_req),
    .I_addr     (ic_axi_addr)
);

IM_Master M0( //Instruction Memory Master
    .clk                   (ACLK),
    .rstn                  (ARESETn),

    .read                  (ic_axi_req),
    .addr_in               (ic_axi_addr),

    .data_out              (ic_axi_data),
    .stall                 (ic_axi_wait),

    .ARID_M                (M0_ARID),
    .ARADDR_M              (M0_ARADDR),
    .ARLEN_M               (M0_ARLEN),
    .ARSIZE_M              (M0_ARSIZE),
    .ARBURST_M             (M0_ARBURST),
    .ARVALID_M             (M0_ARVALID),
    .ARREADY_M             (M0_ARREADY),

    .RID_M                 (M0_RID),
    .RDATA_M               (M0_RDATA),
    .RRESP_M               (M0_RRESP),
    .RLAST_M               (M0_RLAST),
    .RVALID_M              (M0_RVALID),
    .RREADY_M              (M0_RREADY)
);

// ------------------------------------------------------
// Data Memory Master (M1)
// - Generates AXI read/write requests for data access
// - Connects CPU data interface to AXI bus
// ------------------------------------------------------
DM_Master M1( //Data Memory Master
    .clk                   (ACLK),
    .rstn                  (ARESETn),

    .read                  (cache_read_req),
    .write                 (cache_write_req),
    .DM_BWEB               (cache_dm_bweb),
    .data_in               (cache_d_in),
    .addr_in               (cache_d_addr),

    .data_out              (dmaster_data_out),
    .stall                 (dmaster_stall),

    .ARID_M                (M1_ARID),
    .ARADDR_M              (M1_ARADDR),
    .ARLEN_M               (M1_ARLEN),
    .ARSIZE_M              (M1_ARSIZE),
    .ARBURST_M             (M1_ARBURST),
    .ARVALID_M             (M1_ARVALID),
    .ARREADY_M             (M1_ARREADY),
        
    .RID_M                 (M1_RID),
    .RDATA_M               (M1_RDATA),
    .RRESP_M               (M1_RRESP),
    .RLAST_M               (M1_RLAST),
    .RVALID_M              (M1_RVALID),
    .RREADY_M              (M1_RREADY),

    .AWID_M                (M1_AWID),
    .AWADDR_M              (M1_AWADDR),
    .AWLEN_M               (M1_AWLEN),
    .AWSIZE_M              (M1_AWSIZE),
    .AWBURST_M             (M1_AWBURST),
    .AWVALID_M             (M1_AWVALID),
    .AWREADY_M             (M1_AWREADY),

    .WDATA_M               (M1_WDATA),
    .WSTRB_M               (M1_WSTRB),
    .WLAST_M               (M1_WLAST),
    .WVALID_M              (M1_WVALID),
    .WREADY_M              (M1_WREADY),

    .BID_M                 (M1_BID),
    .BRESP_M               (M1_BRESP),
    .BVALID_M              (M1_BVALID),
    .BREADY_M              (M1_BREADY)
);

endmodule
