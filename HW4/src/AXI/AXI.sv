module AXI(
    input logic           CPU_CLK,
    input logic           AXI_CLK,
    input logic           ROM_CLK,
    input logic           DRAM_CLK,
    input logic           CPU_RSTn,
    input logic           AXI_RSTn,
    input logic           ROM_RSTn,
    input logic           DRAM_RSTn,

    //M0 IM
    input  logic [  `AXI_ID_BITS-1:0] M0_ARID,
    input  logic [`AXI_ADDR_BITS-1:0] M0_ARADDR,
    input  logic [ `AXI_LEN_BITS-1:0] M0_ARLEN,
    input  logic [`AXI_SIZE_BITS-1:0] M0_ARSIZE,
    input  logic [               1:0] M0_ARBURST,
    input  logic                      M0_ARVALID,
    output logic                      M0_ARREADY,

    output logic [  `AXI_ID_BITS-1:0] M0_RID,
    output logic [`AXI_DATA_BITS-1:0] M0_RDATA,
    output logic [               1:0] M0_RRESP,
    output logic                      M0_RLAST,
    output logic                      M0_RVALID,
    input  logic                      M0_RREADY,

    //M1 DM
    input  logic [  `AXI_ID_BITS-1:0] M1_ARID,
    input  logic [`AXI_ADDR_BITS-1:0] M1_ARADDR,
    input  logic [ `AXI_LEN_BITS-1:0] M1_ARLEN,
    input  logic [`AXI_SIZE_BITS-1:0] M1_ARSIZE,
    input  logic [               1:0] M1_ARBURST,
    input  logic                      M1_ARVALID,
    output logic                      M1_ARREADY,

    output logic [  `AXI_ID_BITS-1:0] M1_RID,
    output logic [`AXI_DATA_BITS-1:0] M1_RDATA,
    output logic [               1:0] M1_RRESP,
    output logic                      M1_RLAST,
    output logic                      M1_RVALID,
    input  logic                      M1_RREADY,

    input  logic [  `AXI_ID_BITS-1:0] M1_AWID,
    input  logic [`AXI_ADDR_BITS-1:0] M1_AWADDR,
    input  logic [ `AXI_LEN_BITS-1:0] M1_AWLEN,
    input  logic [`AXI_SIZE_BITS-1:0] M1_AWSIZE,
    input  logic [               1:0] M1_AWBURST,
    input  logic                      M1_AWVALID,
    output logic                      M1_AWREADY,

    input  logic [`AXI_DATA_BITS-1:0] M1_WDATA,
    input  logic [`AXI_STRB_BITS-1:0] M1_WSTRB,
    input  logic                      M1_WLAST,
    input  logic                      M1_WVALID,
    output logic                      M1_WREADY,

    output logic [  `AXI_ID_BITS-1:0] M1_BID,
    output logic [               1:0] M1_BRESP,
    output logic                      M1_BVALID,
    input  logic                      M1_BREADY,

    //M2 DMA
    input  logic [  `AXI_ID_BITS-1:0] M2_ARID,
    input  logic [`AXI_ADDR_BITS-1:0] M2_ARADDR,
    input  logic [ `AXI_LEN_BITS-1:0] M2_ARLEN,
    input  logic [`AXI_SIZE_BITS-1:0] M2_ARSIZE,
    input  logic [               1:0] M2_ARBURST,
    input  logic                      M2_ARVALID,
    output logic                      M2_ARREADY,

    output logic [  `AXI_ID_BITS-1:0] M2_RID,
    output logic [`AXI_DATA_BITS-1:0] M2_RDATA,
    output logic [               1:0] M2_RRESP,
    output logic                      M2_RLAST,
    output logic                      M2_RVALID,
    input  logic                      M2_RREADY,

    input  logic [  `AXI_ID_BITS-1:0] M2_AWID,
    input  logic [`AXI_ADDR_BITS-1:0] M2_AWADDR,
    input  logic [ `AXI_LEN_BITS-1:0] M2_AWLEN,
    input  logic [`AXI_SIZE_BITS-1:0] M2_AWSIZE,
    input  logic [               1:0] M2_AWBURST,
    input  logic                      M2_AWVALID,
    output logic                      M2_AWREADY,

    input  logic [`AXI_DATA_BITS-1:0] M2_WDATA,
    input  logic [`AXI_STRB_BITS-1:0] M2_WSTRB,
    input  logic                      M2_WLAST,
    input  logic                      M2_WVALID,
    output logic                      M2_WREADY,

    output logic [  `AXI_ID_BITS-1:0] M2_BID,
    output logic [               1:0] M2_BRESP,
    output logic                      M2_BVALID,
    input  logic                      M2_BREADY,

    // S0 ROM
    output logic [ `AXI_IDS_BITS-1:0] S0_ARID,
    output logic [`AXI_ADDR_BITS-1:0] S0_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] S0_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] S0_ARSIZE,
    output logic [               1:0] S0_ARBURST,
    output logic                      S0_ARVALID,
    input  logic                      S0_ARREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S0_RID,
    input  logic [`AXI_DATA_BITS-1:0] S0_RDATA,
    input  logic [               1:0] S0_RRESP,
    input  logic                      S0_RLAST,
    input  logic                      S0_RVALID,
    output logic                      S0_RREADY,

    // S1 IM
    output logic [ `AXI_IDS_BITS-1:0] S1_ARID,
    output logic [`AXI_ADDR_BITS-1:0] S1_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] S1_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] S1_ARSIZE,
    output logic [               1:0] S1_ARBURST,
    output logic                      S1_ARVALID,
    input  logic                      S1_ARREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S1_RID,
    input  logic [`AXI_DATA_BITS-1:0] S1_RDATA,
    input  logic [               1:0] S1_RRESP,
    input  logic                      S1_RLAST,
    input  logic                      S1_RVALID,
    output logic                      S1_RREADY,

    output logic [ `AXI_IDS_BITS-1:0] S1_AWID,
    output logic [`AXI_ADDR_BITS-1:0] S1_AWADDR,
    output logic [ `AXI_LEN_BITS-1:0] S1_AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] S1_AWSIZE,
    output logic [               1:0] S1_AWBURST,
    output logic                      S1_AWVALID,
    input  logic                      S1_AWREADY,

    output logic [`AXI_DATA_BITS-1:0] S1_WDATA,
    output logic [`AXI_STRB_BITS-1:0] S1_WSTRB,
    output logic                      S1_WLAST,
    output logic                      S1_WVALID,
    input  logic                      S1_WREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S1_BID,
    input  logic [               1:0] S1_BRESP,
    input  logic                      S1_BVALID,
    output logic                      S1_BREADY,

    // S2 DM
    output logic [ `AXI_IDS_BITS-1:0] S2_ARID,
    output logic [`AXI_ADDR_BITS-1:0] S2_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] S2_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] S2_ARSIZE,
    output logic [               1:0] S2_ARBURST,
    output logic                      S2_ARVALID,
    input  logic                      S2_ARREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S2_RID,
    input  logic [`AXI_DATA_BITS-1:0] S2_RDATA,
    input  logic [               1:0] S2_RRESP,
    input  logic                      S2_RLAST,
    input  logic                      S2_RVALID,
    output logic                      S2_RREADY,

    output logic [ `AXI_IDS_BITS-1:0] S2_AWID,
    output logic [`AXI_ADDR_BITS-1:0] S2_AWADDR,
    output logic [ `AXI_LEN_BITS-1:0] S2_AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] S2_AWSIZE,
    output logic [               1:0] S2_AWBURST,
    output logic                      S2_AWVALID,
    input  logic                      S2_AWREADY,

    output logic [`AXI_DATA_BITS-1:0] S2_WDATA,
    output logic [`AXI_STRB_BITS-1:0] S2_WSTRB,
    output logic                      S2_WLAST,
    output logic                      S2_WVALID,
    input  logic                      S2_WREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S2_BID,
    input  logic [               1:0] S2_BRESP,
    input  logic                      S2_BVALID,
    output logic                      S2_BREADY,

    // S3 DMA (write-only slave)
    output logic [ `AXI_IDS_BITS-1:0] S3_AWID,
    output logic [`AXI_ADDR_BITS-1:0] S3_AWADDR,
    output logic [ `AXI_LEN_BITS-1:0] S3_AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] S3_AWSIZE,
    output logic [               1:0] S3_AWBURST,
    output logic                      S3_AWVALID,
    input  logic                      S3_AWREADY,

    output logic [`AXI_DATA_BITS-1:0] S3_WDATA,
    output logic [`AXI_STRB_BITS-1:0] S3_WSTRB,
    output logic                      S3_WLAST,
    output logic                      S3_WVALID,
    input  logic                      S3_WREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S3_BID,
    input  logic [               1:0] S3_BRESP,
    input  logic                      S3_BVALID,
    output logic                      S3_BREADY,

    // S4 WDT 
    output logic [ `AXI_IDS_BITS-1:0] S4_ARID,
    output logic [`AXI_ADDR_BITS-1:0] S4_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] S4_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] S4_ARSIZE,
    output logic [               1:0] S4_ARBURST,
    output logic                      S4_ARVALID,
    input  logic                      S4_ARREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S4_RID,
    input  logic [`AXI_DATA_BITS-1:0] S4_RDATA,
    input  logic [               1:0] S4_RRESP,
    input  logic                      S4_RLAST,
    input  logic                      S4_RVALID,
    output logic                      S4_RREADY,

    output logic [ `AXI_IDS_BITS-1:0] S4_AWID,
    output logic [`AXI_ADDR_BITS-1:0] S4_AWADDR,
    output logic [ `AXI_LEN_BITS-1:0] S4_AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] S4_AWSIZE,
    output logic [               1:0] S4_AWBURST,
    output logic                      S4_AWVALID,
    input  logic                      S4_AWREADY,

    output logic [`AXI_DATA_BITS-1:0] S4_WDATA,
    output logic [`AXI_STRB_BITS-1:0] S4_WSTRB,
    output logic                      S4_WLAST,
    output logic                      S4_WVALID,
    input  logic                      S4_WREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S4_BID,
    input  logic [               1:0] S4_BRESP,
    input  logic                      S4_BVALID,
    output logic                      S4_BREADY,

    // S5 DRAM
    output logic [ `AXI_IDS_BITS-1:0] S5_ARID,
    output logic [`AXI_ADDR_BITS-1:0] S5_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] S5_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] S5_ARSIZE,
    output logic [               1:0] S5_ARBURST,
    output logic                      S5_ARVALID,
    input  logic                      S5_ARREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S5_RID,
    input  logic [`AXI_DATA_BITS-1:0] S5_RDATA,
    input  logic [               1:0] S5_RRESP,
    input  logic                      S5_RLAST,
    input  logic                      S5_RVALID,
    output logic                      S5_RREADY,

    output logic [ `AXI_IDS_BITS-1:0] S5_AWID,
    output logic [`AXI_ADDR_BITS-1:0] S5_AWADDR,
    output logic [ `AXI_LEN_BITS-1:0] S5_AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] S5_AWSIZE,
    output logic [               1:0] S5_AWBURST,
    output logic                      S5_AWVALID,
    input  logic                      S5_AWREADY,

    output logic [`AXI_DATA_BITS-1:0] S5_WDATA,
    output logic [`AXI_STRB_BITS-1:0] S5_WSTRB,
    output logic                      S5_WLAST,
    output logic                      S5_WVALID,
    input  logic                      S5_WREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S5_BID,
    input  logic [               1:0] S5_BRESP,
    input  logic                      S5_BVALID,
    output logic                      S5_BREADY
);

// ------------------------------------------------------------
// Local parameters for FIFO bundle widths
// ------------------------------------------------------------
localparam int M_AR_W = `AXI_ID_BITS  + `AXI_ADDR_BITS + `AXI_LEN_BITS + `AXI_SIZE_BITS + 2;
localparam int M_AW_W = `AXI_ID_BITS  + `AXI_ADDR_BITS + `AXI_LEN_BITS + `AXI_SIZE_BITS + 2;
localparam int M_W_W  = `AXI_DATA_BITS + `AXI_STRB_BITS + 1;
localparam int M_R_W  = `AXI_ID_BITS  + `AXI_DATA_BITS + 2 + 1;
localparam int M_B_W  = `AXI_ID_BITS  + 2;

localparam int S_AR_W = `AXI_IDS_BITS + `AXI_ADDR_BITS + `AXI_LEN_BITS + `AXI_SIZE_BITS + 2;
localparam int S_AW_W = `AXI_IDS_BITS + `AXI_ADDR_BITS + `AXI_LEN_BITS + `AXI_SIZE_BITS + 2;
localparam int S_W_W  = `AXI_DATA_BITS + `AXI_STRB_BITS + 1;
localparam int S_R_W  = `AXI_IDS_BITS + `AXI_DATA_BITS + 2 + 1;
localparam int S_B_W  = `AXI_IDS_BITS + 2;

localparam int FIFO_ADDR_SIZE = 3; // 2^3 = 8 depth

// Convert active-low resets for FIFO blocks (expect active-high)
wire cpu_rst  = ~CPU_RSTn;
wire axi_rst  = ~AXI_RSTn;
wire rom_rst  = ~ROM_RSTn;
wire dram_rst = ~DRAM_RSTn;

// ------------------------------------------------------------
// Internal AXI domain AR signals (AXI_CLK/AXI_RSTn)
// ------------------------------------------------------------
logic [  `AXI_ID_BITS-1:0] M0_AR_bus_ARID;
logic [`AXI_ADDR_BITS-1:0] M0_AR_bus_ARADDR;
logic [ `AXI_LEN_BITS-1:0] M0_AR_bus_ARLEN;
logic [`AXI_SIZE_BITS-1:0] M0_AR_bus_ARSIZE;
logic [               1:0] M0_AR_bus_ARBURST;
logic                      M0_AR_bus_ARVALID;
logic                      M0_AR_bus_ARREADY;

logic [  `AXI_ID_BITS-1:0] M1_AR_bus_ARID;
logic [`AXI_ADDR_BITS-1:0] M1_AR_bus_ARADDR;
logic [ `AXI_LEN_BITS-1:0] M1_AR_bus_ARLEN;
logic [`AXI_SIZE_BITS-1:0] M1_AR_bus_ARSIZE;
logic [               1:0] M1_AR_bus_ARBURST;
logic                      M1_AR_bus_ARVALID;
logic                      M1_AR_bus_ARREADY;

logic [  `AXI_ID_BITS-1:0] M2_AR_bus_ARID;
logic [`AXI_ADDR_BITS-1:0] M2_AR_bus_ARADDR;
logic [ `AXI_LEN_BITS-1:0] M2_AR_bus_ARLEN;
logic [`AXI_SIZE_BITS-1:0] M2_AR_bus_ARSIZE;
logic [               1:0] M2_AR_bus_ARBURST;
logic                      M2_AR_bus_ARVALID;
logic                      M2_AR_bus_ARREADY;

logic [ `AXI_IDS_BITS-1:0] S0_AR_bus_ARID;
logic [`AXI_ADDR_BITS-1:0] S0_AR_bus_ARADDR;
logic [ `AXI_LEN_BITS-1:0] S0_AR_bus_ARLEN;
logic [`AXI_SIZE_BITS-1:0] S0_AR_bus_ARSIZE;
logic [               1:0] S0_AR_bus_ARBURST;
logic                      S0_AR_bus_ARVALID;
logic                      S0_AR_bus_ARREADY;

logic [ `AXI_IDS_BITS-1:0] S1_AR_bus_ARID;
logic [`AXI_ADDR_BITS-1:0] S1_AR_bus_ARADDR;
logic [ `AXI_LEN_BITS-1:0] S1_AR_bus_ARLEN;
logic [`AXI_SIZE_BITS-1:0] S1_AR_bus_ARSIZE;
logic [               1:0] S1_AR_bus_ARBURST;
logic                      S1_AR_bus_ARVALID;
logic                      S1_AR_bus_ARREADY;

logic [ `AXI_IDS_BITS-1:0] S2_AR_bus_ARID;
logic [`AXI_ADDR_BITS-1:0] S2_AR_bus_ARADDR;
logic [ `AXI_LEN_BITS-1:0] S2_AR_bus_ARLEN;
logic [`AXI_SIZE_BITS-1:0] S2_AR_bus_ARSIZE;
logic [               1:0] S2_AR_bus_ARBURST;
logic                      S2_AR_bus_ARVALID;
logic                      S2_AR_bus_ARREADY;

logic [ `AXI_IDS_BITS-1:0] S4_AR_bus_ARID;
logic [`AXI_ADDR_BITS-1:0] S4_AR_bus_ARADDR;
logic [ `AXI_LEN_BITS-1:0] S4_AR_bus_ARLEN;
logic [`AXI_SIZE_BITS-1:0] S4_AR_bus_ARSIZE;
logic [               1:0] S4_AR_bus_ARBURST;
logic                      S4_AR_bus_ARVALID;
logic                      S4_AR_bus_ARREADY;

logic [ `AXI_IDS_BITS-1:0] S5_AR_bus_ARID;
logic [`AXI_ADDR_BITS-1:0] S5_AR_bus_ARADDR;
logic [ `AXI_LEN_BITS-1:0] S5_AR_bus_ARLEN;
logic [`AXI_SIZE_BITS-1:0] S5_AR_bus_ARSIZE;
logic [               1:0] S5_AR_bus_ARBURST;
logic                      S5_AR_bus_ARVALID;
logic                      S5_AR_bus_ARREADY;

// ------------------------------------------------------------
// Internal AXI domain R signals (AXI_CLK/AXI_RSTn)
// ------------------------------------------------------------
logic [  `AXI_ID_BITS-1:0] M0_R_bus_RID;
logic [`AXI_DATA_BITS-1:0] M0_R_bus_RDATA;
logic [               1:0] M0_R_bus_RRESP;
logic                      M0_R_bus_RLAST;
logic                      M0_R_bus_RVALID;
logic                      M0_R_bus_RREADY;

logic [  `AXI_ID_BITS-1:0] M1_R_bus_RID;
logic [`AXI_DATA_BITS-1:0] M1_R_bus_RDATA;
logic [               1:0] M1_R_bus_RRESP;
logic                      M1_R_bus_RLAST;
logic                      M1_R_bus_RVALID;
logic                      M1_R_bus_RREADY;

logic [  `AXI_ID_BITS-1:0] M2_R_bus_RID;
logic [`AXI_DATA_BITS-1:0] M2_R_bus_RDATA;
logic [               1:0] M2_R_bus_RRESP;
logic                      M2_R_bus_RLAST;
logic                      M2_R_bus_RVALID;
logic                      M2_R_bus_RREADY;

logic [ `AXI_IDS_BITS-1:0] S0_R_bus_RID;
logic [`AXI_DATA_BITS-1:0] S0_R_bus_RDATA;
logic [               1:0] S0_R_bus_RRESP;
logic                      S0_R_bus_RLAST;
logic                      S0_R_bus_RVALID;
logic                      S0_R_bus_RREADY;

logic [ `AXI_IDS_BITS-1:0] S1_R_bus_RID;
logic [`AXI_DATA_BITS-1:0] S1_R_bus_RDATA;
logic [               1:0] S1_R_bus_RRESP;
logic                      S1_R_bus_RLAST;
logic                      S1_R_bus_RVALID;
logic                      S1_R_bus_RREADY;

logic [ `AXI_IDS_BITS-1:0] S2_R_bus_RID;
logic [`AXI_DATA_BITS-1:0] S2_R_bus_RDATA;
logic [               1:0] S2_R_bus_RRESP;
logic                      S2_R_bus_RLAST;
logic                      S2_R_bus_RVALID;
logic                      S2_R_bus_RREADY;

logic [ `AXI_IDS_BITS-1:0] S4_R_bus_RID;
logic [`AXI_DATA_BITS-1:0] S4_R_bus_RDATA;
logic [               1:0] S4_R_bus_RRESP;
logic                      S4_R_bus_RLAST;
logic                      S4_R_bus_RVALID;
logic                      S4_R_bus_RREADY;

logic [ `AXI_IDS_BITS-1:0] S5_R_bus_RID;
logic [`AXI_DATA_BITS-1:0] S5_R_bus_RDATA;
logic [               1:0] S5_R_bus_RRESP;
logic                      S5_R_bus_RLAST;
logic                      S5_R_bus_RVALID;
logic                      S5_R_bus_RREADY;

// ------------------------------------------------------------
// Internal AXI domain AW signals (AXI_CLK/AXI_RSTn)
// ------------------------------------------------------------
logic [  `AXI_ID_BITS-1:0] M1_AW_bus_AWID;
logic [`AXI_ADDR_BITS-1:0] M1_AW_bus_AWADDR;
logic [ `AXI_LEN_BITS-1:0] M1_AW_bus_AWLEN;
logic [`AXI_SIZE_BITS-1:0] M1_AW_bus_AWSIZE;
logic [               1:0] M1_AW_bus_AWBURST;
logic                      M1_AW_bus_AWVALID;
logic                      M1_AW_bus_AWREADY;

logic [  `AXI_ID_BITS-1:0] M2_AW_bus_AWID;
logic [`AXI_ADDR_BITS-1:0] M2_AW_bus_AWADDR;
logic [ `AXI_LEN_BITS-1:0] M2_AW_bus_AWLEN;
logic [`AXI_SIZE_BITS-1:0] M2_AW_bus_AWSIZE;
logic [               1:0] M2_AW_bus_AWBURST;
logic                      M2_AW_bus_AWVALID;
logic                      M2_AW_bus_AWREADY;

logic [ `AXI_IDS_BITS-1:0] S1_AW_bus_AWID;
logic [`AXI_ADDR_BITS-1:0] S1_AW_bus_AWADDR;
logic [ `AXI_LEN_BITS-1:0] S1_AW_bus_AWLEN;
logic [`AXI_SIZE_BITS-1:0] S1_AW_bus_AWSIZE;
logic [               1:0] S1_AW_bus_AWBURST;
logic                      S1_AW_bus_AWVALID;
logic                      S1_AW_bus_AWREADY;

logic [ `AXI_IDS_BITS-1:0] S2_AW_bus_AWID;
logic [`AXI_ADDR_BITS-1:0] S2_AW_bus_AWADDR;
logic [ `AXI_LEN_BITS-1:0] S2_AW_bus_AWLEN;
logic [`AXI_SIZE_BITS-1:0] S2_AW_bus_AWSIZE;
logic [               1:0] S2_AW_bus_AWBURST;
logic                      S2_AW_bus_AWVALID;
logic                      S2_AW_bus_AWREADY;

logic [ `AXI_IDS_BITS-1:0] S3_AW_bus_AWID;
logic [`AXI_ADDR_BITS-1:0] S3_AW_bus_AWADDR;
logic [ `AXI_LEN_BITS-1:0] S3_AW_bus_AWLEN;
logic [`AXI_SIZE_BITS-1:0] S3_AW_bus_AWSIZE;
logic [               1:0] S3_AW_bus_AWBURST;
logic                      S3_AW_bus_AWVALID;
logic                      S3_AW_bus_AWREADY;

logic [ `AXI_IDS_BITS-1:0] S4_AW_bus_AWID;
logic [`AXI_ADDR_BITS-1:0] S4_AW_bus_AWADDR;
logic [ `AXI_LEN_BITS-1:0] S4_AW_bus_AWLEN;
logic [`AXI_SIZE_BITS-1:0] S4_AW_bus_AWSIZE;
logic [               1:0] S4_AW_bus_AWBURST;
logic                      S4_AW_bus_AWVALID;
logic                      S4_AW_bus_AWREADY;

logic [ `AXI_IDS_BITS-1:0] S5_AW_bus_AWID;
logic [`AXI_ADDR_BITS-1:0] S5_AW_bus_AWADDR;
logic [ `AXI_LEN_BITS-1:0] S5_AW_bus_AWLEN;
logic [`AXI_SIZE_BITS-1:0] S5_AW_bus_AWSIZE;
logic [               1:0] S5_AW_bus_AWBURST;
logic                      S5_AW_bus_AWVALID;
logic                      S5_AW_bus_AWREADY;

// ------------------------------------------------------------
// Internal AXI domain W signals (AXI_CLK/AXI_RSTn)
// ------------------------------------------------------------
logic [`AXI_DATA_BITS-1:0] M1_W_bus_WDATA;
logic [`AXI_STRB_BITS-1:0] M1_W_bus_WSTRB;
logic                      M1_W_bus_WLAST;
logic                      M1_W_bus_WVALID;
logic                      M1_W_bus_WREADY;

logic [`AXI_DATA_BITS-1:0] M2_W_bus_WDATA;
logic [`AXI_STRB_BITS-1:0] M2_W_bus_WSTRB;
logic                      M2_W_bus_WLAST;
logic                      M2_W_bus_WVALID;
logic                      M2_W_bus_WREADY;

logic [`AXI_DATA_BITS-1:0] S1_W_bus_WDATA;
logic [`AXI_STRB_BITS-1:0] S1_W_bus_WSTRB;
logic                      S1_W_bus_WLAST;
logic                      S1_W_bus_WVALID;
logic                      S1_W_bus_WREADY;

logic [`AXI_DATA_BITS-1:0] S2_W_bus_WDATA;
logic [`AXI_STRB_BITS-1:0] S2_W_bus_WSTRB;
logic                      S2_W_bus_WLAST;
logic                      S2_W_bus_WVALID;
logic                      S2_W_bus_WREADY;

logic [`AXI_DATA_BITS-1:0] S3_W_bus_WDATA;
logic [`AXI_STRB_BITS-1:0] S3_W_bus_WSTRB;
logic                      S3_W_bus_WLAST;
logic                      S3_W_bus_WVALID;
logic                      S3_W_bus_WREADY;

logic [`AXI_DATA_BITS-1:0] S4_W_bus_WDATA;
logic [`AXI_STRB_BITS-1:0] S4_W_bus_WSTRB;
logic                      S4_W_bus_WLAST;
logic                      S4_W_bus_WVALID;
logic                      S4_W_bus_WREADY;

logic [`AXI_DATA_BITS-1:0] S5_W_bus_WDATA;
logic [`AXI_STRB_BITS-1:0] S5_W_bus_WSTRB;
logic                      S5_W_bus_WLAST;
logic                      S5_W_bus_WVALID;
logic                      S5_W_bus_WREADY;

// ------------------------------------------------------------
// Internal AXI domain B signals (AXI_CLK/AXI_RSTn)
// ------------------------------------------------------------
logic [  `AXI_ID_BITS-1:0] M1_B_bus_BID;
logic [               1:0] M1_B_bus_BRESP;
logic                      M1_B_bus_BVALID;
logic                      M1_B_bus_BREADY;

logic [  `AXI_ID_BITS-1:0] M2_B_bus_BID;
logic [               1:0] M2_B_bus_BRESP;
logic                      M2_B_bus_BVALID;
logic                      M2_B_bus_BREADY;

logic [ `AXI_IDS_BITS-1:0] S1_B_bus_BID;
logic [               1:0] S1_B_bus_BRESP;
logic                      S1_B_bus_BVALID;
logic                      S1_B_bus_BREADY;

logic [ `AXI_IDS_BITS-1:0] S2_B_bus_BID;
logic [               1:0] S2_B_bus_BRESP;
logic                      S2_B_bus_BVALID;
logic                      S2_B_bus_BREADY;

logic [ `AXI_IDS_BITS-1:0] S3_B_bus_BID;
logic [               1:0] S3_B_bus_BRESP;
logic                      S3_B_bus_BVALID;
logic                      S3_B_bus_BREADY;

logic [ `AXI_IDS_BITS-1:0] S4_B_bus_BID;
logic [               1:0] S4_B_bus_BRESP;
logic                      S4_B_bus_BVALID;
logic                      S4_B_bus_BREADY;

logic [ `AXI_IDS_BITS-1:0] S5_B_bus_BID;
logic [               1:0] S5_B_bus_BRESP;
logic                      S5_B_bus_BVALID;
logic                      S5_B_bus_BREADY;

// ------------------------------------------------------------
// Bundle wires for FIFO crossings
// ------------------------------------------------------------
// Masters
logic [M_AR_W-1:0] M0_AR_wdata, M0_AR_rdata;
logic [M_R_W-1:0]  M0_R_wdata,  M0_R_rdata;

logic [M_AR_W-1:0] M1_AR_wdata, M1_AR_rdata;
logic [M_AW_W-1:0] M1_AW_wdata, M1_AW_rdata;
logic [M_W_W-1:0]  M1_W_wdata,  M1_W_rdata;
logic [M_R_W-1:0]  M1_R_wdata,  M1_R_rdata;
logic [M_B_W-1:0]  M1_B_wdata,  M1_B_rdata;

logic [M_AR_W-1:0] M2_AR_wdata, M2_AR_rdata;
logic [M_AW_W-1:0] M2_AW_wdata, M2_AW_rdata;
logic [M_W_W-1:0]  M2_W_wdata,  M2_W_rdata;
logic [M_R_W-1:0]  M2_R_wdata,  M2_R_rdata;
logic [M_B_W-1:0]  M2_B_wdata,  M2_B_rdata;

// Slaves
logic [S_AR_W-1:0] S0_AR_wdata, S0_AR_rdata;
logic [S_R_W-1:0]  S0_R_wdata,  S0_R_rdata;

logic [S_AR_W-1:0] S1_AR_wdata, S1_AR_rdata;
logic [S_AW_W-1:0] S1_AW_wdata, S1_AW_rdata;
logic [S_W_W-1:0]  S1_W_wdata,  S1_W_rdata;
logic [S_R_W-1:0]  S1_R_wdata,  S1_R_rdata;
logic [S_B_W-1:0]  S1_B_wdata,  S1_B_rdata;

logic [S_AR_W-1:0] S2_AR_wdata, S2_AR_rdata;
logic [S_AW_W-1:0] S2_AW_wdata, S2_AW_rdata;
logic [S_W_W-1:0]  S2_W_wdata,  S2_W_rdata;
logic [S_R_W-1:0]  S2_R_wdata,  S2_R_rdata;
logic [S_B_W-1:0]  S2_B_wdata,  S2_B_rdata;

logic [S_AW_W-1:0] S3_AW_wdata, S3_AW_rdata;
logic [S_W_W-1:0]  S3_W_wdata,  S3_W_rdata;
logic [S_B_W-1:0]  S3_B_wdata,  S3_B_rdata;

logic [S_AR_W-1:0] S4_AR_wdata, S4_AR_rdata;
logic [S_AW_W-1:0] S4_AW_wdata, S4_AW_rdata;
logic [S_W_W-1:0]  S4_W_wdata,  S4_W_rdata;
logic [S_R_W-1:0]  S4_R_wdata,  S4_R_rdata;
logic [S_B_W-1:0]  S4_B_wdata,  S4_B_rdata;

logic [S_AR_W-1:0] S5_AR_wdata, S5_AR_rdata;
logic [S_AW_W-1:0] S5_AW_wdata, S5_AW_rdata;
logic [S_W_W-1:0]  S5_W_wdata,  S5_W_rdata;
logic [S_R_W-1:0]  S5_R_wdata,  S5_R_rdata;
logic [S_B_W-1:0]  S5_B_wdata,  S5_B_rdata;

// ------------------------------------------------------------
// Pack bundled data
// ------------------------------------------------------------
// Masters -> AXI (address/data)
assign M0_AR_wdata = {M0_ARID, M0_ARADDR, M0_ARLEN, M0_ARSIZE, M0_ARBURST};
assign M1_AR_wdata = {M1_ARID, M1_ARADDR, M1_ARLEN, M1_ARSIZE, M1_ARBURST};
assign M1_AW_wdata = {M1_AWID, M1_AWADDR, M1_AWLEN, M1_AWSIZE, M1_AWBURST};
assign M1_W_wdata  = {M1_WDATA, M1_WSTRB, M1_WLAST};

assign M2_AR_wdata = {M2_ARID, M2_ARADDR, M2_ARLEN, M2_ARSIZE, M2_ARBURST};
assign M2_AW_wdata = {M2_AWID, M2_AWADDR, M2_AWLEN, M2_AWSIZE, M2_AWBURST};
assign M2_W_wdata  = {M2_WDATA, M2_WSTRB, M2_WLAST};

// AXI -> Masters (read/resp)
assign M0_R_wdata  = {M0_R_bus_RID, M0_R_bus_RDATA, M0_R_bus_RRESP, M0_R_bus_RLAST};
assign M1_R_wdata  = {M1_R_bus_RID, M1_R_bus_RDATA, M1_R_bus_RRESP, M1_R_bus_RLAST};
assign M1_B_wdata  = {M1_B_bus_BID, M1_B_bus_BRESP};
assign M2_R_wdata  = {M2_R_bus_RID, M2_R_bus_RDATA, M2_R_bus_RRESP, M2_R_bus_RLAST};
assign M2_B_wdata  = {M2_B_bus_BID, M2_B_bus_BRESP};

// AXI -> Slaves
assign S0_AR_wdata = {S0_AR_bus_ARID, S0_AR_bus_ARADDR, S0_AR_bus_ARLEN, S0_AR_bus_ARSIZE, S0_AR_bus_ARBURST};

assign S1_AR_wdata = {S1_AR_bus_ARID, S1_AR_bus_ARADDR, S1_AR_bus_ARLEN, S1_AR_bus_ARSIZE, S1_AR_bus_ARBURST};
assign S1_AW_wdata = {S1_AW_bus_AWID, S1_AW_bus_AWADDR, S1_AW_bus_AWLEN, S1_AW_bus_AWSIZE, S1_AW_bus_AWBURST};
assign S1_W_wdata  = {S1_W_bus_WDATA, S1_W_bus_WSTRB, S1_W_bus_WLAST};

assign S2_AR_wdata = {S2_AR_bus_ARID, S2_AR_bus_ARADDR, S2_AR_bus_ARLEN, S2_AR_bus_ARSIZE, S2_AR_bus_ARBURST};
assign S2_AW_wdata = {S2_AW_bus_AWID, S2_AW_bus_AWADDR, S2_AW_bus_AWLEN, S2_AW_bus_AWSIZE, S2_AW_bus_AWBURST};
assign S2_W_wdata  = {S2_W_bus_WDATA, S2_W_bus_WSTRB, S2_W_bus_WLAST};
assign S3_AW_wdata = {S3_AW_bus_AWID, S3_AW_bus_AWADDR, S3_AW_bus_AWLEN, S3_AW_bus_AWSIZE, S3_AW_bus_AWBURST};
assign S3_W_wdata  = {S3_W_bus_WDATA, S3_W_bus_WSTRB, S3_W_bus_WLAST};

assign S4_AR_wdata = {S4_AR_bus_ARID, S4_AR_bus_ARADDR, S4_AR_bus_ARLEN, S4_AR_bus_ARSIZE, S4_AR_bus_ARBURST};
assign S4_AW_wdata = {S4_AW_bus_AWID, S4_AW_bus_AWADDR, S4_AW_bus_AWLEN, S4_AW_bus_AWSIZE, S4_AW_bus_AWBURST};
assign S4_W_wdata  = {S4_W_bus_WDATA, S4_W_bus_WSTRB, S4_W_bus_WLAST};

assign S5_AR_wdata = {S5_AR_bus_ARID, S5_AR_bus_ARADDR, S5_AR_bus_ARLEN, S5_AR_bus_ARSIZE, S5_AR_bus_ARBURST};
assign S5_AW_wdata = {S5_AW_bus_AWID, S5_AW_bus_AWADDR, S5_AW_bus_AWLEN, S5_AW_bus_AWSIZE, S5_AW_bus_AWBURST};
assign S5_W_wdata  = {S5_W_bus_WDATA, S5_W_bus_WSTRB, S5_W_bus_WLAST};

// Slaves -> AXI
assign S0_R_wdata  = {S0_RID, S0_RDATA, S0_RRESP, S0_RLAST};

assign S1_R_wdata  = {S1_RID, S1_RDATA, S1_RRESP, S1_RLAST};
assign S1_B_wdata  = {S1_BID, S1_BRESP};

assign S2_R_wdata  = {S2_RID, S2_RDATA, S2_RRESP, S2_RLAST};
assign S2_B_wdata  = {S2_BID, S2_BRESP};
assign S3_B_wdata  = {S3_BID, S3_BRESP};

assign S4_R_wdata  = {S4_RID, S4_RDATA, S4_RRESP, S4_RLAST};
assign S4_B_wdata  = {S4_BID, S4_BRESP};

assign S5_R_wdata  = {S5_RID, S5_RDATA, S5_RRESP, S5_RLAST};
assign S5_B_wdata  = {S5_BID, S5_BRESP};

// ------------------------------------------------------------
// FIFO crossings: Masters (CPU/DMA) <-> AXI clock domain
// ------------------------------------------------------------
// M0(IM): AR / R
FIFO_wrapper #(.DATA_WIDTH(M_AR_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AR_M0(
    .wclk    (CPU_CLK),
    .wrst    (cpu_rst),
    .wdata   (M0_AR_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (M0_AR_rdata),
    .VALID_w (M0_ARVALID),
    .READY_w (M0_ARREADY),
    .VALID_r (M0_AR_bus_ARVALID),
    .READY_r (M0_AR_bus_ARREADY)
);

FIFO_wrapper #(.DATA_WIDTH(M_R_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) R_M0(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (M0_R_wdata),
    .rclk    (CPU_CLK),
    .rrst    (cpu_rst),
    .rdata   (M0_R_rdata),
    .VALID_w (M0_R_bus_RVALID),
    .READY_w (M0_R_bus_RREADY),
    .VALID_r (M0_RVALID),
    .READY_r (M0_RREADY)
);

assign {M0_AR_bus_ARID, M0_AR_bus_ARADDR, M0_AR_bus_ARLEN, M0_AR_bus_ARSIZE, M0_AR_bus_ARBURST} = M0_AR_rdata;
assign {M0_RID, M0_RDATA, M0_RRESP, M0_RLAST} = M0_R_rdata;

// M1(DM): AR / AW / W / R / B
FIFO_wrapper #(.DATA_WIDTH(M_AR_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AR_M1(
    .wclk    (CPU_CLK),
    .wrst    (cpu_rst),
    .wdata   (M1_AR_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (M1_AR_rdata),
    .VALID_w (M1_ARVALID),
    .READY_w (M1_ARREADY),
    .VALID_r (M1_AR_bus_ARVALID),
    .READY_r (M1_AR_bus_ARREADY)
);

FIFO_wrapper #(.DATA_WIDTH(M_AW_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AW_M1(
    .wclk    (CPU_CLK),
    .wrst    (cpu_rst),
    .wdata   (M1_AW_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (M1_AW_rdata),
    .VALID_w (M1_AWVALID),
    .READY_w (M1_AWREADY),
    .VALID_r (M1_AW_bus_AWVALID),
    .READY_r (M1_AW_bus_AWREADY)
);

FIFO_wrapper #(.DATA_WIDTH(M_W_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) W_M1(
    .wclk    (CPU_CLK),
    .wrst    (cpu_rst),
    .wdata   (M1_W_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (M1_W_rdata),
    .VALID_w (M1_WVALID),
    .READY_w (M1_WREADY),
    .VALID_r (M1_W_bus_WVALID),
    .READY_r (M1_W_bus_WREADY)
);

FIFO_wrapper #(.DATA_WIDTH(M_R_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) R_M1(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (M1_R_wdata),
    .rclk    (CPU_CLK),
    .rrst    (cpu_rst),
    .rdata   (M1_R_rdata),
    .VALID_w (M1_R_bus_RVALID),
    .READY_w (M1_R_bus_RREADY),
    .VALID_r (M1_RVALID),
    .READY_r (M1_RREADY)
);

FIFO_wrapper #(.DATA_WIDTH(M_B_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) B_M1(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (M1_B_wdata),
    .rclk    (CPU_CLK),
    .rrst    (cpu_rst),
    .rdata   (M1_B_rdata),
    .VALID_w (M1_B_bus_BVALID),
    .READY_w (M1_B_bus_BREADY),
    .VALID_r (M1_BVALID),
    .READY_r (M1_BREADY)
);

assign {M1_AR_bus_ARID, M1_AR_bus_ARADDR, M1_AR_bus_ARLEN, M1_AR_bus_ARSIZE, M1_AR_bus_ARBURST} = M1_AR_rdata;
assign {M1_AW_bus_AWID, M1_AW_bus_AWADDR, M1_AW_bus_AWLEN, M1_AW_bus_AWSIZE, M1_AW_bus_AWBURST} = M1_AW_rdata;
assign {M1_W_bus_WDATA, M1_W_bus_WSTRB, M1_W_bus_WLAST} = M1_W_rdata;
assign {M1_RID, M1_RDATA, M1_RRESP, M1_RLAST} = M1_R_rdata;
assign {M1_BID, M1_BRESP} = M1_B_rdata;

// M2(DMA): AR / AW / W / R / B
FIFO_wrapper #(.DATA_WIDTH(M_AR_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AR_M2(
    .wclk    (CPU_CLK),
    .wrst    (cpu_rst),
    .wdata   (M2_AR_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (M2_AR_rdata),
    .VALID_w (M2_ARVALID),
    .READY_w (M2_ARREADY),
    .VALID_r (M2_AR_bus_ARVALID),
    .READY_r (M2_AR_bus_ARREADY)
);

FIFO_wrapper #(.DATA_WIDTH(M_AW_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AW_M2(
    .wclk    (CPU_CLK),
    .wrst    (cpu_rst),
    .wdata   (M2_AW_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (M2_AW_rdata),
    .VALID_w (M2_AWVALID),
    .READY_w (M2_AWREADY),
    .VALID_r (M2_AW_bus_AWVALID),
    .READY_r (M2_AW_bus_AWREADY)
);

FIFO_wrapper #(.DATA_WIDTH(M_W_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) W_M2(
    .wclk    (CPU_CLK),
    .wrst    (cpu_rst),
    .wdata   (M2_W_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (M2_W_rdata),
    .VALID_w (M2_WVALID),
    .READY_w (M2_WREADY),
    .VALID_r (M2_W_bus_WVALID),
    .READY_r (M2_W_bus_WREADY)
);

FIFO_wrapper #(.DATA_WIDTH(M_R_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) R_M2(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (M2_R_wdata),
    .rclk    (CPU_CLK),
    .rrst    (cpu_rst),
    .rdata   (M2_R_rdata),
    .VALID_w (M2_R_bus_RVALID),
    .READY_w (M2_R_bus_RREADY),
    .VALID_r (M2_RVALID),
    .READY_r (M2_RREADY)
);

FIFO_wrapper #(.DATA_WIDTH(M_B_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) B_M2(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (M2_B_wdata),
    .rclk    (CPU_CLK),
    .rrst    (cpu_rst),
    .rdata   (M2_B_rdata),
    .VALID_w (M2_B_bus_BVALID),
    .READY_w (M2_B_bus_BREADY),
    .VALID_r (M2_BVALID),
    .READY_r (M2_BREADY)
);

assign {M2_AR_bus_ARID, M2_AR_bus_ARADDR, M2_AR_bus_ARLEN, M2_AR_bus_ARSIZE, M2_AR_bus_ARBURST} = M2_AR_rdata;
assign {M2_AW_bus_AWID, M2_AW_bus_AWADDR, M2_AW_bus_AWLEN, M2_AW_bus_AWSIZE, M2_AW_bus_AWBURST} = M2_AW_rdata;
assign {M2_W_bus_WDATA, M2_W_bus_WSTRB, M2_W_bus_WLAST} = M2_W_rdata;
assign {M2_RID, M2_RDATA, M2_RRESP, M2_RLAST} = M2_R_rdata;
assign {M2_BID, M2_BRESP} = M2_B_rdata;

// ------------------------------------------------------------
// FIFO crossings: AXI clock domain <-> Slaves
// ------------------------------------------------------------
// S0 (ROM): AR / R
FIFO_wrapper #(.DATA_WIDTH(S_AR_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AR_S0(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S0_AR_wdata),
    .rclk    (ROM_CLK),
    .rrst    (rom_rst),
    .rdata   (S0_AR_rdata),
    .VALID_w (S0_AR_bus_ARVALID),
    .READY_w (S0_AR_bus_ARREADY),
    .VALID_r (S0_ARVALID),
    .READY_r (S0_ARREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_R_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) R_S0(
    .wclk    (ROM_CLK),
    .wrst    (rom_rst),
    .wdata   (S0_R_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (S0_R_rdata),
    .VALID_w (S0_RVALID),
    .READY_w (S0_RREADY),
    .VALID_r (S0_R_bus_RVALID),
    .READY_r (S0_R_bus_RREADY)
);

assign {S0_ARID, S0_ARADDR, S0_ARLEN, S0_ARSIZE, S0_ARBURST} = S0_AR_rdata;
assign {S0_R_bus_RID, S0_R_bus_RDATA, S0_R_bus_RRESP, S0_R_bus_RLAST} = S0_R_rdata;

// S1 (SRAM IM): AR / AW / W / R / B
FIFO_wrapper #(.DATA_WIDTH(S_AR_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AR_S1(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S1_AR_wdata),
    .rclk    (CPU_CLK),
    .rrst    (cpu_rst),
    .rdata   (S1_AR_rdata),
    .VALID_w (S1_AR_bus_ARVALID),
    .READY_w (S1_AR_bus_ARREADY),
    .VALID_r (S1_ARVALID),
    .READY_r (S1_ARREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_AW_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AW_S1(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S1_AW_wdata),
    .rclk    (CPU_CLK),
    .rrst    (cpu_rst),
    .rdata   (S1_AW_rdata),
    .VALID_w (S1_AW_bus_AWVALID),
    .READY_w (S1_AW_bus_AWREADY),
    .VALID_r (S1_AWVALID),
    .READY_r (S1_AWREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_W_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) W_S1(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S1_W_wdata),
    .rclk    (CPU_CLK),
    .rrst    (cpu_rst),
    .rdata   (S1_W_rdata),
    .VALID_w (S1_W_bus_WVALID),
    .READY_w (S1_W_bus_WREADY),
    .VALID_r (S1_WVALID),
    .READY_r (S1_WREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_R_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) R_S1(
    .wclk    (CPU_CLK),
    .wrst    (cpu_rst),
    .wdata   (S1_R_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (S1_R_rdata),
    .VALID_w (S1_RVALID),
    .READY_w (S1_RREADY),
    .VALID_r (S1_R_bus_RVALID),
    .READY_r (S1_R_bus_RREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_B_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) B_S1(
    .wclk    (CPU_CLK),
    .wrst    (cpu_rst),
    .wdata   (S1_B_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (S1_B_rdata),
    .VALID_w (S1_BVALID),
    .READY_w (S1_BREADY),
    .VALID_r (S1_B_bus_BVALID),
    .READY_r (S1_B_bus_BREADY)
);

assign {S1_ARID, S1_ARADDR, S1_ARLEN, S1_ARSIZE, S1_ARBURST} = S1_AR_rdata;
assign {S1_AWID, S1_AWADDR, S1_AWLEN, S1_AWSIZE, S1_AWBURST} = S1_AW_rdata;
assign {S1_WDATA, S1_WSTRB, S1_WLAST} = S1_W_rdata;
assign {S1_R_bus_RID, S1_R_bus_RDATA, S1_R_bus_RRESP, S1_R_bus_RLAST} = S1_R_rdata;
assign {S1_B_bus_BID, S1_B_bus_BRESP} = S1_B_rdata;

// S2 (SRAM DM): AR / AW / W / R / B
FIFO_wrapper #(.DATA_WIDTH(S_AR_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AR_S2(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S2_AR_wdata),
    .rclk    (CPU_CLK),
    .rrst    (cpu_rst),
    .rdata   (S2_AR_rdata),
    .VALID_w (S2_AR_bus_ARVALID),
    .READY_w (S2_AR_bus_ARREADY),
    .VALID_r (S2_ARVALID),
    .READY_r (S2_ARREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_AW_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AW_S2(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S2_AW_wdata),
    .rclk    (CPU_CLK),
    .rrst    (cpu_rst),
    .rdata   (S2_AW_rdata),
    .VALID_w (S2_AW_bus_AWVALID),
    .READY_w (S2_AW_bus_AWREADY),
    .VALID_r (S2_AWVALID),
    .READY_r (S2_AWREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_W_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) W_S2(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S2_W_wdata),
    .rclk    (CPU_CLK),
    .rrst    (cpu_rst),
    .rdata   (S2_W_rdata),
    .VALID_w (S2_W_bus_WVALID),
    .READY_w (S2_W_bus_WREADY),
    .VALID_r (S2_WVALID),
    .READY_r (S2_WREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_R_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) R_S2(
    .wclk    (CPU_CLK),
    .wrst    (cpu_rst),
    .wdata   (S2_R_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (S2_R_rdata),
    .VALID_w (S2_RVALID),
    .READY_w (S2_RREADY),
    .VALID_r (S2_R_bus_RVALID),
    .READY_r (S2_R_bus_RREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_B_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) B_S2(
    .wclk    (CPU_CLK),
    .wrst    (cpu_rst),
    .wdata   (S2_B_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (S2_B_rdata),
    .VALID_w (S2_BVALID),
    .READY_w (S2_BREADY),
    .VALID_r (S2_B_bus_BVALID),
    .READY_r (S2_B_bus_BREADY)
);

assign {S2_ARID, S2_ARADDR, S2_ARLEN, S2_ARSIZE, S2_ARBURST} = S2_AR_rdata;
assign {S2_AWID, S2_AWADDR, S2_AWLEN, S2_AWSIZE, S2_AWBURST} = S2_AW_rdata;
assign {S2_WDATA, S2_WSTRB, S2_WLAST} = S2_W_rdata;
assign {S2_R_bus_RID, S2_R_bus_RDATA, S2_R_bus_RRESP, S2_R_bus_RLAST} = S2_R_rdata;
assign {S2_B_bus_BID, S2_B_bus_BRESP} = S2_B_rdata;

// S3 (DMA slave): AW / W / B (write-only)
FIFO_wrapper #(.DATA_WIDTH(S_AW_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AW_S3(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S3_AW_wdata),
    .rclk    (CPU_CLK),
    .rrst    (cpu_rst),
    .rdata   (S3_AW_rdata),
    .VALID_w (S3_AW_bus_AWVALID),
    .READY_w (S3_AW_bus_AWREADY),
    .VALID_r (S3_AWVALID),
    .READY_r (S3_AWREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_W_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) W_S3(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S3_W_wdata),
    .rclk    (CPU_CLK),
    .rrst    (cpu_rst),
    .rdata   (S3_W_rdata),
    .VALID_w (S3_W_bus_WVALID),
    .READY_w (S3_W_bus_WREADY),
    .VALID_r (S3_WVALID),
    .READY_r (S3_WREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_B_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) B_S3(
    .wclk    (CPU_CLK),
    .wrst    (cpu_rst),
    .wdata   (S3_B_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (S3_B_rdata),
    .VALID_w (S3_BVALID),
    .READY_w (S3_BREADY),
    .VALID_r (S3_B_bus_BVALID),
    .READY_r (S3_B_bus_BREADY)
);

assign {S3_AWID, S3_AWADDR, S3_AWLEN, S3_AWSIZE, S3_AWBURST} = S3_AW_rdata;
assign {S3_WDATA, S3_WSTRB, S3_WLAST} = S3_W_rdata;
assign {S3_B_bus_BID, S3_B_bus_BRESP} = S3_B_rdata;

// S4 (WDT): AR / AW / W / R / B
FIFO_wrapper #(.DATA_WIDTH(S_AR_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AR_S4(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S4_AR_wdata),
    .rclk    (ROM_CLK),
    .rrst    (rom_rst),
    .rdata   (S4_AR_rdata),
    .VALID_w (S4_AR_bus_ARVALID),
    .READY_w (S4_AR_bus_ARREADY),
    .VALID_r (S4_ARVALID),
    .READY_r (S4_ARREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_AW_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AW_S4(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S4_AW_wdata),
    .rclk    (ROM_CLK),
    .rrst    (rom_rst),
    .rdata   (S4_AW_rdata),
    .VALID_w (S4_AW_bus_AWVALID),
    .READY_w (S4_AW_bus_AWREADY),
    .VALID_r (S4_AWVALID),
    .READY_r (S4_AWREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_W_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) W_S4(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S4_W_wdata),
    .rclk    (ROM_CLK),
    .rrst    (rom_rst),
    .rdata   (S4_W_rdata),
    .VALID_w (S4_W_bus_WVALID),
    .READY_w (S4_W_bus_WREADY),
    .VALID_r (S4_WVALID),
    .READY_r (S4_WREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_R_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) R_S4(
    .wclk    (ROM_CLK),
    .wrst    (rom_rst),
    .wdata   (S4_R_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (S4_R_rdata),
    .VALID_w (S4_RVALID),
    .READY_w (S4_RREADY),
    .VALID_r (S4_R_bus_RVALID),
    .READY_r (S4_R_bus_RREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_B_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) B_S4(
    .wclk    (ROM_CLK),
    .wrst    (rom_rst),
    .wdata   (S4_B_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (S4_B_rdata),
    .VALID_w (S4_BVALID),
    .READY_w (S4_BREADY),
    .VALID_r (S4_B_bus_BVALID),
    .READY_r (S4_B_bus_BREADY)
);

assign {S4_ARID, S4_ARADDR, S4_ARLEN, S4_ARSIZE, S4_ARBURST} = S4_AR_rdata;
assign {S4_AWID, S4_AWADDR, S4_AWLEN, S4_AWSIZE, S4_AWBURST} = S4_AW_rdata;
assign {S4_WDATA, S4_WSTRB, S4_WLAST} = S4_W_rdata;
assign {S4_R_bus_RID, S4_R_bus_RDATA, S4_R_bus_RRESP, S4_R_bus_RLAST} = S4_R_rdata;
assign {S4_B_bus_BID, S4_B_bus_BRESP} = S4_B_rdata;

// S5 (DRAM): AR / AW / W / R / B
FIFO_wrapper #(.DATA_WIDTH(S_AR_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AR_S5(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S5_AR_wdata),
    .rclk    (DRAM_CLK),
    .rrst    (dram_rst),
    .rdata   (S5_AR_rdata),
    .VALID_w (S5_AR_bus_ARVALID),
    .READY_w (S5_AR_bus_ARREADY),
    .VALID_r (S5_ARVALID),
    .READY_r (S5_ARREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_AW_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) AW_S5(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S5_AW_wdata),
    .rclk    (DRAM_CLK),
    .rrst    (dram_rst),
    .rdata   (S5_AW_rdata),
    .VALID_w (S5_AW_bus_AWVALID),
    .READY_w (S5_AW_bus_AWREADY),
    .VALID_r (S5_AWVALID),
    .READY_r (S5_AWREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_W_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) W_S5(
    .wclk    (AXI_CLK),
    .wrst    (axi_rst),
    .wdata   (S5_W_wdata),
    .rclk    (DRAM_CLK),
    .rrst    (dram_rst),
    .rdata   (S5_W_rdata),
    .VALID_w (S5_W_bus_WVALID),
    .READY_w (S5_W_bus_WREADY),
    .VALID_r (S5_WVALID),
    .READY_r (S5_WREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_R_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) R_S5(
    .wclk    (DRAM_CLK),
    .wrst    (dram_rst),
    .wdata   (S5_R_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (S5_R_rdata),
    .VALID_w (S5_RVALID),
    .READY_w (S5_RREADY),
    .VALID_r (S5_R_bus_RVALID),
    .READY_r (S5_R_bus_RREADY)
);

FIFO_wrapper #(.DATA_WIDTH(S_B_W), .ADDR_SIZE(FIFO_ADDR_SIZE)) B_S5(
    .wclk    (DRAM_CLK),
    .wrst    (dram_rst),
    .wdata   (S5_B_wdata),
    .rclk    (AXI_CLK),
    .rrst    (axi_rst),
    .rdata   (S5_B_rdata),
    .VALID_w (S5_BVALID),
    .READY_w (S5_BREADY),
    .VALID_r (S5_B_bus_BVALID),
    .READY_r (S5_B_bus_BREADY)
);

assign {S5_ARID, S5_ARADDR, S5_ARLEN, S5_ARSIZE, S5_ARBURST} = S5_AR_rdata;
assign {S5_AWID, S5_AWADDR, S5_AWLEN, S5_AWSIZE, S5_AWBURST} = S5_AW_rdata;
assign {S5_WDATA, S5_WSTRB, S5_WLAST} = S5_W_rdata;
assign {S5_R_bus_RID, S5_R_bus_RDATA, S5_R_bus_RRESP, S5_R_bus_RLAST} = S5_R_rdata;
assign {S5_B_bus_BID, S5_B_bus_BRESP} = S5_B_rdata;


// ------------------------------------------------------------
// - Limits each master to one outstanding transaction with AW-over-AR priority and busy-gating logic
// ------------------------------------------------------------

// 1. Outstanding Status Registers
logic m0_busy;
logic m1_busy, m1_busy_is_write;
logic m2_busy, m2_busy_is_write;

// Global write transaction context (global write outstanding = 1)
// Held until B handshake
logic       wr_active;
logic [3:0] wr_master;    //  AWID[7:4]
logic [4:0] wr_slave_sel; // {S5,S4,S3,S2,S1}
// Single-cycle pulse triggered during handshake
logic [4:0] wr_slave_sel_fire;
logic [3:0] wr_master_fire;

// 2. Gated Requests (Requests that pass the Outstanding limit)
// Conditional signals sent to the AR/AW modules (and then Arbiter).
logic m0_ar_bus_req;
logic m1_ar_bus_req, m1_aw_bus_req;
logic m2_ar_bus_req, m2_aw_bus_req;

// AW priority when both asserted in same cycle (hold off AR if AWVALID is high)
assign m0_ar_bus_req = M0_AR_bus_ARVALID && ~m0_busy;
assign m1_aw_bus_req = M1_AW_bus_AWVALID && ~m1_busy && ~wr_active;
assign m2_aw_bus_req = M2_AW_bus_AWVALID && ~m2_busy && ~wr_active;
assign m1_ar_bus_req = M1_AR_bus_ARVALID && ~m1_busy && ~m1_aw_bus_req;
assign m2_ar_bus_req = M2_AR_bus_ARVALID && ~m2_busy && ~m2_aw_bus_req;

// 3. Handshake "Fire" Signals (Current transaction starts)
wire m0_ar_fire = m0_ar_bus_req && M0_AR_bus_ARREADY;
wire m1_ar_fire = m1_ar_bus_req && M1_AR_bus_ARREADY;
wire m2_ar_fire = m2_ar_bus_req && M2_AR_bus_ARREADY;
wire m1_aw_fire = m1_aw_bus_req && M1_AW_bus_AWREADY;
wire m2_aw_fire = m2_aw_bus_req && M2_AW_bus_AWREADY;

// 4. Completion "Done" Signals (Current transaction ends)
wire m0_r_done = M0_R_bus_RVALID && M0_R_bus_RREADY && M0_R_bus_RLAST;
wire m1_r_done = M1_R_bus_RVALID && M1_R_bus_RREADY && M1_R_bus_RLAST;
wire m2_r_done = M2_R_bus_RVALID && M2_R_bus_RREADY && M2_R_bus_RLAST;
wire m1_b_done = M1_B_bus_BVALID && M1_B_bus_BREADY;
wire m2_b_done = M2_B_bus_BVALID && M2_B_bus_BREADY;

// ------------------------------------------------------------
// Global write outstanding=1 context (AW handshake -> B handshake)
// ------------------------------------------------------------
wire s1_aw_fire = S1_AW_bus_AWVALID && S1_AW_bus_AWREADY;
wire s2_aw_fire = S2_AW_bus_AWVALID && S2_AW_bus_AWREADY;
wire s3_aw_fire = S3_AW_bus_AWVALID && S3_AW_bus_AWREADY;
wire s4_aw_fire = S4_AW_bus_AWVALID && S4_AW_bus_AWREADY;
wire s5_aw_fire = S5_AW_bus_AWVALID && S5_AW_bus_AWREADY;
wire aw_fire_any = s1_aw_fire || s2_aw_fire || s3_aw_fire || s4_aw_fire || s5_aw_fire;

always_comb begin
    wr_slave_sel_fire = 5'b0_0000;
    wr_master_fire = 4'b0000;

    if (s1_aw_fire) begin
        wr_slave_sel_fire = 5'b0_0001;
        wr_master_fire = S1_AW_bus_AWID[7:4];
    end else if (s2_aw_fire) begin
        wr_slave_sel_fire = 5'b0_0010;
        wr_master_fire = S2_AW_bus_AWID[7:4];
    end else if (s3_aw_fire) begin
        wr_slave_sel_fire = 5'b0_0100;
        wr_master_fire = S3_AW_bus_AWID[7:4];
    end else if (s4_aw_fire) begin
        wr_slave_sel_fire = 5'b0_1000;
        wr_master_fire = S4_AW_bus_AWID[7:4];
    end else if (s5_aw_fire) begin
        wr_slave_sel_fire = 5'b1_0000;
        wr_master_fire = S5_AW_bus_AWID[7:4];
    end
end

always_ff @(posedge AXI_CLK) begin
    if (!AXI_RSTn) begin
        wr_active <= 1'b0;
        wr_master <= 4'b0000;
        wr_slave_sel <= 5'b00000;
    end else begin
        if (wr_active) begin
            if (m1_b_done || m2_b_done) begin
                wr_active <= 1'b0;
                wr_master <= 4'b0000;
                wr_slave_sel <= 5'b00000;
            end
        end else if (aw_fire_any) begin
            wr_active <= 1'b1;
            wr_master <= wr_master_fire;
            wr_slave_sel <= wr_slave_sel_fire;
        end
    end
end

always_ff @(posedge AXI_CLK) begin
    if (!AXI_RSTn) begin
        m0_busy <= 1'b0;
        {m1_busy, m1_busy_is_write} <= 2'b00;
        {m2_busy, m2_busy_is_write} <= 2'b00;
    end else begin
        // Master 0: read-only
        m0_busy <= m0_busy ? ~m0_r_done : m0_ar_fire;

        // Master 1: shared busy for read/write
        if (!m1_busy) begin
            if (m1_aw_fire)      {m1_busy, m1_busy_is_write} <= 2'b11;
            else if (m1_ar_fire) {m1_busy, m1_busy_is_write} <= 2'b10;
        end else if (m1_busy_is_write ? m1_b_done : m1_r_done) begin
            m1_busy <= 1'b0;
            m1_busy_is_write <= 1'b0;
        end

        // Master 2: shared busy for read/write
        if (!m2_busy) begin
            if (m2_aw_fire)      {m2_busy, m2_busy_is_write} <= 2'b11;
            else if (m2_ar_fire) {m2_busy, m2_busy_is_write} <= 2'b10;
        end else if (m2_busy_is_write ? m2_b_done : m2_r_done) begin
            m2_busy <= 1'b0;
            m2_busy_is_write <= 1'b0;
        end
    end
end

AR i_AR(
    .clk          (AXI_CLK),
    .rstn         (AXI_RSTn),
    .M0_ARID      (M0_AR_bus_ARID),
    .M0_ARADDR    (M0_AR_bus_ARADDR),
    .M0_ARLEN     (M0_AR_bus_ARLEN),
    .M0_ARSIZE    (M0_AR_bus_ARSIZE),
    .M0_ARBURST   (M0_AR_bus_ARBURST),
    .M0_ARVALID   (m0_ar_bus_req),
    .M0_ARREADY   (M0_AR_bus_ARREADY),

    .M1_ARID      (M1_AR_bus_ARID),
    .M1_ARADDR    (M1_AR_bus_ARADDR),
    .M1_ARLEN     (M1_AR_bus_ARLEN),
    .M1_ARSIZE    (M1_AR_bus_ARSIZE),
    .M1_ARBURST   (M1_AR_bus_ARBURST),
    .M1_ARVALID   (m1_ar_bus_req),
    .M1_ARREADY   (M1_AR_bus_ARREADY),

    .M2_ARID      (M2_AR_bus_ARID),
    .M2_ARADDR    (M2_AR_bus_ARADDR),
    .M2_ARLEN     (M2_AR_bus_ARLEN),
    .M2_ARSIZE    (M2_AR_bus_ARSIZE),
    .M2_ARBURST   (M2_AR_bus_ARBURST),
    .M2_ARVALID   (m2_ar_bus_req),
    .M2_ARREADY   (M2_AR_bus_ARREADY),

    .S0_ARID      (S0_AR_bus_ARID),
    .S0_ARADDR    (S0_AR_bus_ARADDR),
    .S0_ARLEN     (S0_AR_bus_ARLEN),
    .S0_ARSIZE    (S0_AR_bus_ARSIZE),
    .S0_ARBURST   (S0_AR_bus_ARBURST),
    .S0_ARVALID   (S0_AR_bus_ARVALID),
    .S0_ARREADY   (S0_AR_bus_ARREADY),

    .S1_ARID      (S1_AR_bus_ARID),
    .S1_ARADDR    (S1_AR_bus_ARADDR),
    .S1_ARLEN     (S1_AR_bus_ARLEN),
    .S1_ARSIZE    (S1_AR_bus_ARSIZE),
    .S1_ARBURST   (S1_AR_bus_ARBURST),
    .S1_ARVALID   (S1_AR_bus_ARVALID),
    .S1_ARREADY   (S1_AR_bus_ARREADY),

    .S2_ARID      (S2_AR_bus_ARID),
    .S2_ARADDR    (S2_AR_bus_ARADDR),
    .S2_ARLEN     (S2_AR_bus_ARLEN),
    .S2_ARSIZE    (S2_AR_bus_ARSIZE),
    .S2_ARBURST   (S2_AR_bus_ARBURST),
    .S2_ARVALID   (S2_AR_bus_ARVALID),
    .S2_ARREADY   (S2_AR_bus_ARREADY),

    .S4_ARID      (S4_AR_bus_ARID),
    .S4_ARADDR    (S4_AR_bus_ARADDR),
    .S4_ARLEN     (S4_AR_bus_ARLEN),
    .S4_ARSIZE    (S4_AR_bus_ARSIZE),
    .S4_ARBURST   (S4_AR_bus_ARBURST),
    .S4_ARVALID   (S4_AR_bus_ARVALID),
    .S4_ARREADY   (S4_AR_bus_ARREADY),

    .S5_ARID      (S5_AR_bus_ARID),
    .S5_ARADDR    (S5_AR_bus_ARADDR),
    .S5_ARLEN     (S5_AR_bus_ARLEN),
    .S5_ARSIZE    (S5_AR_bus_ARSIZE),
    .S5_ARBURST   (S5_AR_bus_ARBURST),
    .S5_ARVALID   (S5_AR_bus_ARVALID),
    .S5_ARREADY   (S5_AR_bus_ARREADY)
);

R i_R(
    .clk          (AXI_CLK),
    .rstn         (AXI_RSTn),
    .M0_RID       (M0_R_bus_RID),
    .M0_RDATA     (M0_R_bus_RDATA),
    .M0_RRESP     (M0_R_bus_RRESP),
    .M0_RLAST     (M0_R_bus_RLAST),
    .M0_RVALID    (M0_R_bus_RVALID),
    .M0_RREADY    (M0_R_bus_RREADY),

    .M1_RID       (M1_R_bus_RID),
    .M1_RDATA     (M1_R_bus_RDATA),
    .M1_RRESP     (M1_R_bus_RRESP),
    .M1_RLAST     (M1_R_bus_RLAST),
    .M1_RVALID    (M1_R_bus_RVALID),
    .M1_RREADY    (M1_R_bus_RREADY),

    .M2_RID       (M2_R_bus_RID),
    .M2_RDATA     (M2_R_bus_RDATA),
    .M2_RRESP     (M2_R_bus_RRESP),
    .M2_RLAST     (M2_R_bus_RLAST),
    .M2_RVALID    (M2_R_bus_RVALID),
    .M2_RREADY    (M2_R_bus_RREADY),

    .S0_RID       (S0_R_bus_RID),
    .S0_RDATA     (S0_R_bus_RDATA),
    .S0_RRESP     (S0_R_bus_RRESP),
    .S0_RLAST     (S0_R_bus_RLAST),
    .S0_RVALID    (S0_R_bus_RVALID),
    .S0_RREADY    (S0_R_bus_RREADY),

    .S1_RID       (S1_R_bus_RID),
    .S1_RDATA     (S1_R_bus_RDATA),
    .S1_RRESP     (S1_R_bus_RRESP),
    .S1_RLAST     (S1_R_bus_RLAST),
    .S1_RVALID    (S1_R_bus_RVALID),
    .S1_RREADY    (S1_R_bus_RREADY),

    .S2_RID       (S2_R_bus_RID),
    .S2_RDATA     (S2_R_bus_RDATA),
    .S2_RRESP     (S2_R_bus_RRESP),
    .S2_RLAST     (S2_R_bus_RLAST),
    .S2_RVALID    (S2_R_bus_RVALID),
    .S2_RREADY    (S2_R_bus_RREADY),

    .S4_RID       (S4_R_bus_RID),
    .S4_RDATA     (S4_R_bus_RDATA),
    .S4_RRESP     (S4_R_bus_RRESP),
    .S4_RLAST     (S4_R_bus_RLAST),
    .S4_RVALID    (S4_R_bus_RVALID),
    .S4_RREADY    (S4_R_bus_RREADY),

    .S5_RID       (S5_R_bus_RID),
    .S5_RDATA     (S5_R_bus_RDATA),
    .S5_RRESP     (S5_R_bus_RRESP),
    .S5_RLAST     (S5_R_bus_RLAST),
    .S5_RVALID    (S5_R_bus_RVALID),
    .S5_RREADY    (S5_R_bus_RREADY)
);

AW i_AW(
    .clk          (AXI_CLK),
    .rstn         (AXI_RSTn),
    .M1_AWID      (M1_AW_bus_AWID),
    .M1_AWADDR    (M1_AW_bus_AWADDR),
    .M1_AWLEN     (M1_AW_bus_AWLEN),
    .M1_AWSIZE    (M1_AW_bus_AWSIZE),
    .M1_AWBURST   (M1_AW_bus_AWBURST),
    .M1_AWVALID   (m1_aw_bus_req),
    .M1_AWREADY   (M1_AW_bus_AWREADY),

    .M2_AWID      (M2_AW_bus_AWID),
    .M2_AWADDR    (M2_AW_bus_AWADDR),
    .M2_AWLEN     (M2_AW_bus_AWLEN),
    .M2_AWSIZE    (M2_AW_bus_AWSIZE),
    .M2_AWBURST   (M2_AW_bus_AWBURST),
    .M2_AWVALID   (m2_aw_bus_req),
    .M2_AWREADY   (M2_AW_bus_AWREADY),

    .S1_AWID      (S1_AW_bus_AWID),
    .S1_AWADDR    (S1_AW_bus_AWADDR),
    .S1_AWLEN     (S1_AW_bus_AWLEN),
    .S1_AWSIZE    (S1_AW_bus_AWSIZE),
    .S1_AWBURST   (S1_AW_bus_AWBURST),
    .S1_AWVALID   (S1_AW_bus_AWVALID),
    .S1_AWREADY   (S1_AW_bus_AWREADY),

    .S2_AWID      (S2_AW_bus_AWID),
    .S2_AWADDR    (S2_AW_bus_AWADDR),
    .S2_AWLEN     (S2_AW_bus_AWLEN),
    .S2_AWSIZE    (S2_AW_bus_AWSIZE),
    .S2_AWBURST   (S2_AW_bus_AWBURST),
    .S2_AWVALID   (S2_AW_bus_AWVALID),
    .S2_AWREADY   (S2_AW_bus_AWREADY),

    .S3_AWID      (S3_AW_bus_AWID),
    .S3_AWADDR    (S3_AW_bus_AWADDR),
    .S3_AWLEN     (S3_AW_bus_AWLEN),
    .S3_AWSIZE    (S3_AW_bus_AWSIZE),
    .S3_AWBURST   (S3_AW_bus_AWBURST),
    .S3_AWVALID   (S3_AW_bus_AWVALID),
    .S3_AWREADY   (S3_AW_bus_AWREADY),

    .S4_AWID      (S4_AW_bus_AWID),
    .S4_AWADDR    (S4_AW_bus_AWADDR),
    .S4_AWLEN     (S4_AW_bus_AWLEN),
    .S4_AWSIZE    (S4_AW_bus_AWSIZE),
    .S4_AWBURST   (S4_AW_bus_AWBURST),
    .S4_AWVALID   (S4_AW_bus_AWVALID),
    .S4_AWREADY   (S4_AW_bus_AWREADY),

    .S5_AWID      (S5_AW_bus_AWID),
    .S5_AWADDR    (S5_AW_bus_AWADDR),
    .S5_AWLEN     (S5_AW_bus_AWLEN),
    .S5_AWSIZE    (S5_AW_bus_AWSIZE),
    .S5_AWBURST   (S5_AW_bus_AWBURST),
    .S5_AWVALID   (S5_AW_bus_AWVALID),
    .S5_AWREADY   (S5_AW_bus_AWREADY)
);

W i_W(
    .clk          (AXI_CLK),
    .rstn         (AXI_RSTn),
    .M1_WDATA     (M1_W_bus_WDATA),
    .M1_WSTRB     (M1_W_bus_WSTRB),
    .M1_WLAST     (M1_W_bus_WLAST),
    .M1_WVALID    (M1_W_bus_WVALID),
    .M1_WREADY    (M1_W_bus_WREADY),
    .M2_WDATA     (M2_W_bus_WDATA),
    .M2_WSTRB     (M2_W_bus_WSTRB),
    .M2_WLAST     (M2_W_bus_WLAST),
    .M2_WVALID    (M2_W_bus_WVALID),
    .M2_WREADY    (M2_W_bus_WREADY),

    .S1_WDATA     (S1_W_bus_WDATA),
    .S1_WSTRB     (S1_W_bus_WSTRB),
    .S1_WLAST     (S1_W_bus_WLAST),
    .S1_WVALID    (S1_W_bus_WVALID),
    .S1_WREADY    (S1_W_bus_WREADY),

    .S2_WDATA     (S2_W_bus_WDATA),
    .S2_WSTRB     (S2_W_bus_WSTRB),
    .S2_WLAST     (S2_W_bus_WLAST),
    .S2_WVALID    (S2_W_bus_WVALID),
    .S2_WREADY    (S2_W_bus_WREADY),

    .S3_WDATA     (S3_W_bus_WDATA),
    .S3_WSTRB     (S3_W_bus_WSTRB),
    .S3_WLAST     (S3_W_bus_WLAST),
    .S3_WVALID    (S3_W_bus_WVALID),
    .S3_WREADY    (S3_W_bus_WREADY),

    .S4_WDATA     (S4_W_bus_WDATA),
    .S4_WSTRB     (S4_W_bus_WSTRB),
    .S4_WLAST     (S4_W_bus_WLAST),
    .S4_WVALID    (S4_W_bus_WVALID),
    .S4_WREADY    (S4_W_bus_WREADY),

    .S5_WDATA     (S5_W_bus_WDATA),
    .S5_WSTRB     (S5_W_bus_WSTRB),
    .S5_WLAST     (S5_W_bus_WLAST),
    .S5_WVALID    (S5_W_bus_WVALID),
    .S5_WREADY    (S5_W_bus_WREADY),

    .wr_active    (wr_active),
    .wr_master    (wr_master),
    .wr_slave_sel (wr_slave_sel)
);

B i_B(
    .M1_BREADY    (M1_B_bus_BREADY),
    .M1_BID       (M1_B_bus_BID),
    .M1_BRESP     (M1_B_bus_BRESP),
    .M1_BVALID    (M1_B_bus_BVALID),

    .M2_BREADY    (M2_B_bus_BREADY),
    .M2_BID       (M2_B_bus_BID),
    .M2_BRESP     (M2_B_bus_BRESP),
    .M2_BVALID    (M2_B_bus_BVALID),

    .S1_BID       (S1_B_bus_BID),
    .S1_BRESP     (S1_B_bus_BRESP),
    .S1_BVALID    (S1_B_bus_BVALID),
    .S1_BREADY    (S1_B_bus_BREADY),

    .S2_BID       (S2_B_bus_BID),
    .S2_BRESP     (S2_B_bus_BRESP),
    .S2_BVALID    (S2_B_bus_BVALID),
    .S2_BREADY    (S2_B_bus_BREADY),

    .S3_BID       (S3_B_bus_BID),
    .S3_BRESP     (S3_B_bus_BRESP),
    .S3_BVALID    (S3_B_bus_BVALID),
    .S3_BREADY    (S3_B_bus_BREADY),

    .S4_BID       (S4_B_bus_BID),
    .S4_BRESP     (S4_B_bus_BRESP),
    .S4_BVALID    (S4_B_bus_BVALID),
    .S4_BREADY    (S4_B_bus_BREADY),

    .S5_BID       (S5_B_bus_BID),
    .S5_BRESP     (S5_B_bus_BRESP),
    .S5_BVALID    (S5_B_bus_BVALID),
    .S5_BREADY    (S5_B_bus_BREADY)
);

endmodule
