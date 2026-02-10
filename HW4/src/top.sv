`include "../include/def.svh"
`include "../include/AXI_define.svh"
module top(
  // Clocks
  input  logic           cpu_clk,
  input  logic           axi_clk,
  input  logic           rom_clk,
  input  logic           dram_clk,
  // Resets (active high)
  input  logic           cpu_rst,
  input  logic           axi_rst,
  input  logic           rom_rst,
  input  logic           dram_rst,
  // ROM
  input  logic [   31:0] ROM_out,
  output logic           ROM_read,
  output logic           ROM_enable,
  output logic [   11:0] ROM_address,
  // DRAM
  output logic           DRAM_CSn,
  output logic [    3:0] DRAM_WEn,
  output logic           DRAM_RASn,
  output logic           DRAM_CASn,
  output logic [   10:0] DRAM_A,
  output logic [   31:0] DRAM_D,
  input  logic [   31:0] DRAM_Q,
  input  logic           DRAM_valid
);

// ------------------------------------------------------------
// Reset synchronizers (convert active high -> active low)
// ------------------------------------------------------------
logic cpu_rstn_sync, axi_rstn_sync;
logic rom_rstn_sync, dram_rstn_sync;
Reset_Sync i_Reset_Sync_cpu (
	.clk       (cpu_clk),
	.rst       (cpu_rst),
	.rstn_sync (cpu_rstn_sync)
);
Reset_Sync i_Reset_Sync_axi (
	.clk       (axi_clk),
	.rst       (axi_rst),
	.rstn_sync (axi_rstn_sync)
);
Reset_Sync i_Reset_Sync_rom (
	.clk       (rom_clk),
	.rst       (rom_rst),
	.rstn_sync (rom_rstn_sync)
);
Reset_Sync i_Reset_Sync_dram (
	.clk       (dram_clk),
	.rst       (dram_rst),
	.rstn_sync (dram_rstn_sync)
);

// ------------------------------------------------------------
// AXI ports
// ------------------------------------------------------------
/* CPU_wrapper */
// IM Master
logic [  `AXI_ID_BITS-1:0] M0_ARID;
logic [`AXI_ADDR_BITS-1:0] M0_ARADDR;
logic [ `AXI_LEN_BITS-1:0] M0_ARLEN;
logic [`AXI_SIZE_BITS-1:0] M0_ARSIZE;
logic [               1:0] M0_ARBURST;
logic                      M0_ARVALID;
logic                      M0_ARREADY;
logic [  `AXI_ID_BITS-1:0] M0_RID;
logic [`AXI_DATA_BITS-1:0] M0_RDATA;
logic [               1:0] M0_RRESP;
logic                      M0_RLAST;
logic                      M0_RVALID;
logic                      M0_RREADY;
// DM Master
logic [  `AXI_ID_BITS-1:0] M1_ARID;
logic [`AXI_ADDR_BITS-1:0] M1_ARADDR;
logic [ `AXI_LEN_BITS-1:0] M1_ARLEN;
logic [`AXI_SIZE_BITS-1:0] M1_ARSIZE;
logic [               1:0] M1_ARBURST;
logic                      M1_ARVALID;
logic                      M1_ARREADY;
logic [  `AXI_ID_BITS-1:0] M1_RID;
logic [`AXI_DATA_BITS-1:0] M1_RDATA;
logic [               1:0] M1_RRESP;
logic                      M1_RLAST;
logic                      M1_RVALID;
logic                      M1_RREADY;

logic [  `AXI_ID_BITS-1:0] M1_AWID;
logic [`AXI_ADDR_BITS-1:0] M1_AWADDR;
logic [ `AXI_LEN_BITS-1:0] M1_AWLEN;
logic [`AXI_SIZE_BITS-1:0] M1_AWSIZE;
logic [               1:0] M1_AWBURST;
logic                      M1_AWVALID;
logic                      M1_AWREADY;

logic [`AXI_DATA_BITS-1:0] M1_WDATA;
logic [`AXI_STRB_BITS-1:0] M1_WSTRB;
logic                      M1_WLAST;
logic                      M1_WVALID;
logic                      M1_WREADY;

logic [  `AXI_ID_BITS-1:0] M1_BID;
logic [               1:0] M1_BRESP;
logic                      M1_BVALID;
logic                      M1_BREADY;

/* SRAM_wrapper */
// SRAM (IM)
logic [ `AXI_IDS_BITS-1:0] S1_ARID;
logic [`AXI_ADDR_BITS-1:0] S1_ARADDR;
logic [ `AXI_LEN_BITS-1:0] S1_ARLEN;
logic [`AXI_SIZE_BITS-1:0] S1_ARSIZE;
logic [               1:0] S1_ARBURST;
logic                      S1_ARVALID;
logic                      S1_ARREADY;
logic [ `AXI_IDS_BITS-1:0] S1_RID;
logic [`AXI_DATA_BITS-1:0] S1_RDATA;
logic [               1:0] S1_RRESP;
logic                      S1_RLAST;
logic                      S1_RVALID;
logic                      S1_RREADY;

logic [ `AXI_IDS_BITS-1:0] S1_AWID;
logic [`AXI_ADDR_BITS-1:0] S1_AWADDR;
logic [ `AXI_LEN_BITS-1:0] S1_AWLEN;
logic [`AXI_SIZE_BITS-1:0] S1_AWSIZE;
logic [               1:0] S1_AWBURST;
logic                      S1_AWVALID;
logic                      S1_AWREADY;

logic [`AXI_DATA_BITS-1:0] S1_WDATA;
logic [`AXI_STRB_BITS-1:0] S1_WSTRB;
logic                      S1_WLAST;
logic                      S1_WVALID;
logic                      S1_WREADY;

logic [ `AXI_IDS_BITS-1:0] S1_BID;
logic [               1:0] S1_BRESP;
logic                      S1_BVALID;
logic                      S1_BREADY;
// SRAM (DM)
logic [ `AXI_IDS_BITS-1:0] S2_ARID;
logic [`AXI_ADDR_BITS-1:0] S2_ARADDR;
logic [ `AXI_LEN_BITS-1:0] S2_ARLEN;
logic [`AXI_SIZE_BITS-1:0] S2_ARSIZE;
logic [               1:0] S2_ARBURST;
logic                      S2_ARVALID;
logic                      S2_ARREADY;
logic [ `AXI_IDS_BITS-1:0] S2_RID;
logic [`AXI_DATA_BITS-1:0] S2_RDATA;
logic [               1:0] S2_RRESP;
logic                      S2_RLAST;
logic                      S2_RVALID;
logic                      S2_RREADY;

logic [ `AXI_IDS_BITS-1:0] S2_AWID;
logic [`AXI_ADDR_BITS-1:0] S2_AWADDR;
logic [ `AXI_LEN_BITS-1:0] S2_AWLEN;
logic [`AXI_SIZE_BITS-1:0] S2_AWSIZE;
logic [               1:0] S2_AWBURST;
logic                      S2_AWVALID;
logic                      S2_AWREADY;

logic [`AXI_DATA_BITS-1:0] S2_WDATA;
logic [`AXI_STRB_BITS-1:0] S2_WSTRB;
logic                      S2_WLAST;
logic                      S2_WVALID;
logic                      S2_WREADY;

logic [ `AXI_IDS_BITS-1:0] S2_BID;
logic [               1:0] S2_BRESP;
logic                      S2_BVALID;
logic                      S2_BREADY;

/* DRAM */
logic [ `AXI_IDS_BITS-1:0] S5_ARID;
logic [`AXI_ADDR_BITS-1:0] S5_ARADDR;
logic [ `AXI_LEN_BITS-1:0] S5_ARLEN;
logic [`AXI_SIZE_BITS-1:0] S5_ARSIZE;
logic [               1:0] S5_ARBURST;
logic                      S5_ARVALID;
logic                      S5_ARREADY;
logic [ `AXI_IDS_BITS-1:0] S5_RID;
logic [`AXI_DATA_BITS-1:0] S5_RDATA;
logic [               1:0] S5_RRESP;
logic                      S5_RLAST;
logic                      S5_RVALID;
logic                      S5_RREADY;

logic [ `AXI_IDS_BITS-1:0] S5_AWID;
logic [`AXI_ADDR_BITS-1:0] S5_AWADDR;
logic [ `AXI_LEN_BITS-1:0] S5_AWLEN;
logic [`AXI_SIZE_BITS-1:0] S5_AWSIZE;
logic [               1:0] S5_AWBURST;
logic                      S5_AWVALID;
logic                      S5_AWREADY;

logic [`AXI_DATA_BITS-1:0] S5_WDATA;
logic [`AXI_STRB_BITS-1:0] S5_WSTRB;
logic                      S5_WLAST;
logic                      S5_WVALID;
logic                      S5_WREADY;

logic [ `AXI_IDS_BITS-1:0] S5_BID;
logic [               1:0] S5_BRESP;
logic                      S5_BVALID;
logic                      S5_BREADY;

/* ROM */
logic [ `AXI_IDS_BITS-1:0] S0_ARID;
logic [`AXI_ADDR_BITS-1:0] S0_ARADDR;
logic [ `AXI_LEN_BITS-1:0] S0_ARLEN;
logic [`AXI_SIZE_BITS-1:0] S0_ARSIZE;
logic [               1:0] S0_ARBURST;
logic                      S0_ARVALID;
logic                      S0_ARREADY;
logic [ `AXI_IDS_BITS-1:0] S0_RID;
logic [`AXI_DATA_BITS-1:0] S0_RDATA;
logic [               1:0] S0_RRESP;
logic                      S0_RLAST;
logic                      S0_RVALID;
logic                      S0_RREADY;

/* DMA */
// Master
logic [  `AXI_ID_BITS-1:0] M2_ARID;
logic [`AXI_ADDR_BITS-1:0] M2_ARADDR;
logic [ `AXI_LEN_BITS-1:0] M2_ARLEN;
logic [`AXI_SIZE_BITS-1:0] M2_ARSIZE;
logic [               1:0] M2_ARBURST;
logic                      M2_ARVALID;
logic                      M2_ARREADY;
logic [  `AXI_ID_BITS-1:0] M2_RID;
logic [`AXI_DATA_BITS-1:0] M2_RDATA;
logic [               1:0] M2_RRESP;
logic                      M2_RLAST;
logic                      M2_RVALID;
logic                      M2_RREADY;

logic [  `AXI_ID_BITS-1:0] M2_AWID;
logic [`AXI_ADDR_BITS-1:0] M2_AWADDR;
logic [ `AXI_LEN_BITS-1:0] M2_AWLEN;
logic [`AXI_SIZE_BITS-1:0] M2_AWSIZE;
logic [               1:0] M2_AWBURST;
logic                      M2_AWVALID;
logic                      M2_AWREADY;

logic [`AXI_DATA_BITS-1:0] M2_WDATA;
logic [`AXI_STRB_BITS-1:0] M2_WSTRB;
logic                      M2_WLAST;
logic                      M2_WVALID;
logic                      M2_WREADY;

logic [  `AXI_ID_BITS-1:0] M2_BID;
logic [               1:0] M2_BRESP;
logic                      M2_BVALID;
logic                      M2_BREADY;
// Slave (DMA config interface uses AW/W/B only)
logic [ `AXI_IDS_BITS-1:0] S3_AWID;
logic [`AXI_ADDR_BITS-1:0] S3_AWADDR;
logic [ `AXI_LEN_BITS-1:0] S3_AWLEN;
logic [`AXI_SIZE_BITS-1:0] S3_AWSIZE;
logic [               1:0] S3_AWBURST;
logic                      S3_AWVALID;
logic                      S3_AWREADY;

logic [`AXI_DATA_BITS-1:0] S3_WDATA;
logic [`AXI_STRB_BITS-1:0] S3_WSTRB;
logic                      S3_WLAST;
logic                      S3_WVALID;
logic                      S3_WREADY;

logic [ `AXI_IDS_BITS-1:0] S3_BID;
logic [               1:0] S3_BRESP;
logic                      S3_BVALID;
logic                      S3_BREADY;

/* WDT */
logic [ `AXI_IDS_BITS-1:0] S4_ARID;
logic [`AXI_ADDR_BITS-1:0] S4_ARADDR;
logic [ `AXI_LEN_BITS-1:0] S4_ARLEN;
logic [`AXI_SIZE_BITS-1:0] S4_ARSIZE;
logic [               1:0] S4_ARBURST;
logic                      S4_ARVALID;
logic                      S4_ARREADY;
logic [ `AXI_IDS_BITS-1:0] S4_RID;
logic [`AXI_DATA_BITS-1:0] S4_RDATA;
logic [               1:0] S4_RRESP;
logic                      S4_RLAST;
logic                      S4_RVALID;
logic                      S4_RREADY;

logic [ `AXI_IDS_BITS-1:0] S4_AWID;
logic [`AXI_ADDR_BITS-1:0] S4_AWADDR;
logic [ `AXI_LEN_BITS-1:0] S4_AWLEN;
logic [`AXI_SIZE_BITS-1:0] S4_AWSIZE;
logic [               1:0] S4_AWBURST;
logic                      S4_AWVALID;
logic                      S4_AWREADY;

logic [`AXI_DATA_BITS-1:0] S4_WDATA;
logic [`AXI_STRB_BITS-1:0] S4_WSTRB;
logic                      S4_WLAST;
logic                      S4_WVALID;
logic                      S4_WREADY;

logic [ `AXI_IDS_BITS-1:0] S4_BID;
logic [               1:0] S4_BRESP;
logic                      S4_BVALID;
logic                      S4_BREADY;

logic DMA_interrupt;
logic WDT_timeout;
logic WDT_timeout_rom;

// ------------------------------------------------------------
// AXI interconnect (multi-clock with async FIFO)
// ------------------------------------------------------------
AXI i_AXI (
    .CPU_CLK      (cpu_clk),
    .AXI_CLK      (axi_clk),
    .ROM_CLK      (rom_clk),
    .DRAM_CLK     (dram_clk),
    .CPU_RSTn     (cpu_rstn_sync),
    .AXI_RSTn     (axi_rstn_sync),
    .ROM_RSTn     (rom_rstn_sync),
    .DRAM_RSTn    (dram_rstn_sync),

    .M0_ARID      (M0_ARID),
    .M0_ARADDR    (M0_ARADDR),
    .M0_ARLEN     (M0_ARLEN),
    .M0_ARSIZE    (M0_ARSIZE),
    .M0_ARBURST   (M0_ARBURST),
    .M0_ARVALID   (M0_ARVALID),
    .M0_ARREADY   (M0_ARREADY),
    .M0_RID       (M0_RID),
    .M0_RDATA     (M0_RDATA),
    .M0_RRESP     (M0_RRESP),
    .M0_RLAST     (M0_RLAST),
    .M0_RVALID    (M0_RVALID),
    .M0_RREADY    (M0_RREADY),

    .M1_ARID      (M1_ARID),
    .M1_ARADDR    (M1_ARADDR),
    .M1_ARLEN     (M1_ARLEN),
    .M1_ARSIZE    (M1_ARSIZE),
    .M1_ARBURST   (M1_ARBURST),
    .M1_ARVALID   (M1_ARVALID),
    .M1_ARREADY   (M1_ARREADY),
    .M1_RID       (M1_RID),
    .M1_RDATA     (M1_RDATA),
    .M1_RRESP     (M1_RRESP),
    .M1_RLAST     (M1_RLAST),
    .M1_RVALID    (M1_RVALID),
    .M1_RREADY    (M1_RREADY),

    .M1_AWID      (M1_AWID),
    .M1_AWADDR    (M1_AWADDR),
    .M1_AWLEN     (M1_AWLEN),
    .M1_AWSIZE    (M1_AWSIZE),
    .M1_AWBURST   (M1_AWBURST),
    .M1_AWVALID   (M1_AWVALID),
    .M1_AWREADY   (M1_AWREADY),

    .M1_WDATA     (M1_WDATA),
    .M1_WSTRB     (M1_WSTRB),
    .M1_WLAST     (M1_WLAST),
    .M1_WVALID    (M1_WVALID),
    .M1_WREADY    (M1_WREADY),

    .M1_BID       (M1_BID),
    .M1_BRESP     (M1_BRESP),
    .M1_BVALID    (M1_BVALID),
    .M1_BREADY    (M1_BREADY),

    .M2_ARID      (M2_ARID),
    .M2_ARADDR    (M2_ARADDR),
    .M2_ARLEN     (M2_ARLEN),
    .M2_ARSIZE    (M2_ARSIZE),
    .M2_ARBURST   (M2_ARBURST),
    .M2_ARVALID   (M2_ARVALID),
    .M2_ARREADY   (M2_ARREADY),
    .M2_RID       (M2_RID),
    .M2_RDATA     (M2_RDATA),
    .M2_RRESP     (M2_RRESP),
    .M2_RLAST     (M2_RLAST),
    .M2_RVALID    (M2_RVALID),
    .M2_RREADY    (M2_RREADY),

    .M2_AWID      (M2_AWID),
    .M2_AWADDR    (M2_AWADDR),
    .M2_AWLEN     (M2_AWLEN),
    .M2_AWSIZE    (M2_AWSIZE),
    .M2_AWBURST   (M2_AWBURST),
    .M2_AWVALID   (M2_AWVALID),
    .M2_AWREADY   (M2_AWREADY),

    .M2_WDATA     (M2_WDATA),
    .M2_WSTRB     (M2_WSTRB),
    .M2_WLAST     (M2_WLAST),
    .M2_WVALID    (M2_WVALID),
    .M2_WREADY    (M2_WREADY),

    .M2_BID       (M2_BID),
    .M2_BRESP     (M2_BRESP),
    .M2_BVALID    (M2_BVALID),
    .M2_BREADY    (M2_BREADY),

    .S0_ARID      (S0_ARID),
    .S0_ARADDR    (S0_ARADDR),
    .S0_ARLEN     (S0_ARLEN),
    .S0_ARSIZE    (S0_ARSIZE),
    .S0_ARBURST   (S0_ARBURST),
    .S0_ARVALID   (S0_ARVALID),
    .S0_ARREADY   (S0_ARREADY),
    .S0_RID       (S0_RID),
    .S0_RDATA     (S0_RDATA),
    .S0_RRESP     (S0_RRESP),
    .S0_RLAST     (S0_RLAST),
    .S0_RVALID    (S0_RVALID),
    .S0_RREADY    (S0_RREADY),

    .S1_ARID      (S1_ARID),
    .S1_ARADDR    (S1_ARADDR),
    .S1_ARLEN     (S1_ARLEN),
    .S1_ARSIZE    (S1_ARSIZE),
    .S1_ARBURST   (S1_ARBURST),
    .S1_ARVALID   (S1_ARVALID),
    .S1_ARREADY   (S1_ARREADY),
    .S1_RID       (S1_RID),
    .S1_RDATA     (S1_RDATA),
    .S1_RRESP     (S1_RRESP),
    .S1_RLAST     (S1_RLAST),
    .S1_RVALID    (S1_RVALID),
    .S1_RREADY    (S1_RREADY),

    .S1_AWID      (S1_AWID),
    .S1_AWADDR    (S1_AWADDR),
    .S1_AWLEN     (S1_AWLEN),
    .S1_AWSIZE    (S1_AWSIZE),
    .S1_AWBURST   (S1_AWBURST),
    .S1_AWVALID   (S1_AWVALID),
    .S1_AWREADY   (S1_AWREADY),

    .S1_WDATA     (S1_WDATA),
    .S1_WSTRB     (S1_WSTRB),
    .S1_WLAST     (S1_WLAST),
    .S1_WVALID    (S1_WVALID),
    .S1_WREADY    (S1_WREADY),

    .S1_BID       (S1_BID),
    .S1_BRESP     (S1_BRESP),
    .S1_BVALID    (S1_BVALID),
    .S1_BREADY    (S1_BREADY),

    .S2_ARID      (S2_ARID),
    .S2_ARADDR    (S2_ARADDR),
    .S2_ARLEN     (S2_ARLEN),
    .S2_ARSIZE    (S2_ARSIZE),
    .S2_ARBURST   (S2_ARBURST),
    .S2_ARVALID   (S2_ARVALID),
    .S2_ARREADY   (S2_ARREADY),
    .S2_RID       (S2_RID),
    .S2_RDATA     (S2_RDATA),
    .S2_RRESP     (S2_RRESP),
    .S2_RLAST     (S2_RLAST),
    .S2_RVALID    (S2_RVALID),
    .S2_RREADY    (S2_RREADY),

    .S2_AWID      (S2_AWID),
    .S2_AWADDR    (S2_AWADDR),
    .S2_AWLEN     (S2_AWLEN),
    .S2_AWSIZE    (S2_AWSIZE),
    .S2_AWBURST   (S2_AWBURST),
    .S2_AWVALID   (S2_AWVALID),
    .S2_AWREADY   (S2_AWREADY),

    .S2_WDATA     (S2_WDATA),
    .S2_WSTRB     (S2_WSTRB),
    .S2_WLAST     (S2_WLAST),
    .S2_WVALID    (S2_WVALID),
    .S2_WREADY    (S2_WREADY),

    .S2_BID       (S2_BID),
    .S2_BRESP     (S2_BRESP),
    .S2_BVALID    (S2_BVALID),
    .S2_BREADY    (S2_BREADY),

    .S3_AWID      (S3_AWID),
    .S3_AWADDR    (S3_AWADDR),
    .S3_AWLEN     (S3_AWLEN),
    .S3_AWSIZE    (S3_AWSIZE),
    .S3_AWBURST   (S3_AWBURST),
    .S3_AWVALID   (S3_AWVALID),
    .S3_AWREADY   (S3_AWREADY),

    .S3_WDATA     (S3_WDATA),
    .S3_WSTRB     (S3_WSTRB),
    .S3_WLAST     (S3_WLAST),
    .S3_WVALID    (S3_WVALID),
    .S3_WREADY    (S3_WREADY),

    .S3_BID       (S3_BID),
    .S3_BRESP     (S3_BRESP),
    .S3_BVALID    (S3_BVALID),
    .S3_BREADY    (S3_BREADY),

    .S4_ARID      (S4_ARID),
    .S4_ARADDR    (S4_ARADDR),
    .S4_ARLEN     (S4_ARLEN),
    .S4_ARSIZE    (S4_ARSIZE),
    .S4_ARBURST   (S4_ARBURST),
    .S4_ARVALID   (S4_ARVALID),
    .S4_ARREADY   (S4_ARREADY),
    .S4_RID       (S4_RID),
    .S4_RDATA     (S4_RDATA),
    .S4_RRESP     (S4_RRESP),
    .S4_RLAST     (S4_RLAST),
    .S4_RVALID    (S4_RVALID),
    .S4_RREADY    (S4_RREADY),

    .S4_AWID      (S4_AWID),
    .S4_AWADDR    (S4_AWADDR),
    .S4_AWLEN     (S4_AWLEN),
    .S4_AWSIZE    (S4_AWSIZE),
    .S4_AWBURST   (S4_AWBURST),
    .S4_AWVALID   (S4_AWVALID),
    .S4_AWREADY   (S4_AWREADY),

    .S4_WDATA     (S4_WDATA),
    .S4_WSTRB     (S4_WSTRB),
    .S4_WLAST     (S4_WLAST),
    .S4_WVALID    (S4_WVALID),
    .S4_WREADY    (S4_WREADY),

    .S4_BID       (S4_BID),
    .S4_BRESP     (S4_BRESP),
    .S4_BVALID    (S4_BVALID),
    .S4_BREADY    (S4_BREADY),

    .S5_ARID      (S5_ARID),
    .S5_ARADDR    (S5_ARADDR),
    .S5_ARLEN     (S5_ARLEN),
    .S5_ARSIZE    (S5_ARSIZE),
    .S5_ARBURST   (S5_ARBURST),
    .S5_ARVALID   (S5_ARVALID),
    .S5_ARREADY   (S5_ARREADY),
    .S5_RID       (S5_RID),
    .S5_RDATA     (S5_RDATA),
    .S5_RRESP     (S5_RRESP),
    .S5_RLAST     (S5_RLAST),
    .S5_RVALID    (S5_RVALID),
    .S5_RREADY    (S5_RREADY),

    .S5_AWID      (S5_AWID),
    .S5_AWADDR    (S5_AWADDR),
    .S5_AWLEN     (S5_AWLEN),
    .S5_AWSIZE    (S5_AWSIZE),
    .S5_AWBURST   (S5_AWBURST),
    .S5_AWVALID   (S5_AWVALID),
    .S5_AWREADY   (S5_AWREADY),

    .S5_WDATA     (S5_WDATA),
    .S5_WSTRB     (S5_WSTRB),
    .S5_WLAST     (S5_WLAST),
    .S5_WVALID    (S5_WVALID),
    .S5_WREADY    (S5_WREADY),

    .S5_BID       (S5_BID),
    .S5_BRESP     (S5_BRESP),
    .S5_BVALID    (S5_BVALID),
    .S5_BREADY    (S5_BREADY)
);

// ------------------------------------------------------------
// CPU wrapper (masters M0/M1)
// ------------------------------------------------------------
CPU_wrapper i_CPU_wrapper (
    .ACLK		  (cpu_clk),
	.ARESETn	  (cpu_rstn_sync),

    .M0_ARID      (M0_ARID),
    .M0_ARADDR    (M0_ARADDR),
    .M0_ARLEN     (M0_ARLEN),
    .M0_ARSIZE    (M0_ARSIZE),
    .M0_ARBURST   (M0_ARBURST),
    .M0_ARVALID   (M0_ARVALID),
    .M0_ARREADY   (M0_ARREADY),
    .M0_RID       (M0_RID),
    .M0_RDATA     (M0_RDATA),
    .M0_RRESP     (M0_RRESP),
    .M0_RLAST     (M0_RLAST),
    .M0_RVALID    (M0_RVALID),
    .M0_RREADY    (M0_RREADY),

    .M1_ARID      (M1_ARID),
    .M1_ARADDR    (M1_ARADDR),
    .M1_ARLEN     (M1_ARLEN),
    .M1_ARSIZE    (M1_ARSIZE),
    .M1_ARBURST   (M1_ARBURST),
    .M1_ARVALID   (M1_ARVALID),
    .M1_ARREADY   (M1_ARREADY),
    .M1_RID       (M1_RID),
    .M1_RDATA     (M1_RDATA),
    .M1_RRESP     (M1_RRESP),
    .M1_RLAST     (M1_RLAST),
    .M1_RVALID    (M1_RVALID),
    .M1_RREADY    (M1_RREADY),

    .M1_AWID      (M1_AWID),
    .M1_AWADDR    (M1_AWADDR),
    .M1_AWLEN     (M1_AWLEN),
    .M1_AWSIZE    (M1_AWSIZE),
    .M1_AWBURST   (M1_AWBURST),
    .M1_AWVALID   (M1_AWVALID),
    .M1_AWREADY   (M1_AWREADY),

    .M1_WDATA     (M1_WDATA),
    .M1_WSTRB     (M1_WSTRB),
    .M1_WLAST     (M1_WLAST),
    .M1_WVALID    (M1_WVALID),
    .M1_WREADY    (M1_WREADY),

    .M1_BID       (M1_BID),
    .M1_BRESP     (M1_BRESP),
    .M1_BVALID    (M1_BVALID),
    .M1_BREADY    (M1_BREADY),

	.DMA_interrupt(DMA_interrupt),
	.WDT_timeout  (WDT_timeout)
);

// ------------------------------------------------------------
// SRAM wrappers (slaves S1/S2)
// ------------------------------------------------------------
// IM wrapper
SRAM_wrapper IM1 (
    .ACLK		  (cpu_clk),
    .ARESETn	  (cpu_rstn_sync),

    .S_ARID       (S1_ARID),
    .S_ARADDR     (S1_ARADDR),
    .S_ARLEN      (S1_ARLEN),
    .S_ARSIZE     (S1_ARSIZE),
    .S_ARBURST    (S1_ARBURST),
    .S_ARVALID    (S1_ARVALID),
    .S_ARREADY    (S1_ARREADY),

    .S_RID        (S1_RID),
    .S_RDATA      (S1_RDATA),
    .S_RRESP      (S1_RRESP),
    .S_RLAST      (S1_RLAST),
    .S_RVALID     (S1_RVALID),
    .S_RREADY     (S1_RREADY),

    .S_AWID       (S1_AWID),
    .S_AWADDR     (S1_AWADDR),
    .S_AWLEN      (S1_AWLEN),
    .S_AWSIZE     (S1_AWSIZE),
    .S_AWBURST    (S1_AWBURST),
    .S_AWVALID    (S1_AWVALID),
    .S_AWREADY    (S1_AWREADY),

    .S_WDATA      (S1_WDATA),
    .S_WSTRB      (S1_WSTRB),
    .S_WLAST      (S1_WLAST),
    .S_WVALID     (S1_WVALID),
    .S_WREADY     (S1_WREADY),

    .S_BID        (S1_BID),
    .S_BRESP      (S1_BRESP),
    .S_BVALID     (S1_BVALID),
    .S_BREADY     (S1_BREADY)
);

// DM wrapper
SRAM_wrapper DM1 (
    .ACLK		  (cpu_clk),
    .ARESETn	  (cpu_rstn_sync),

    .S_ARID       (S2_ARID),
    .S_ARADDR     (S2_ARADDR),
    .S_ARLEN      (S2_ARLEN),
    .S_ARSIZE     (S2_ARSIZE),
    .S_ARBURST    (S2_ARBURST),
    .S_ARVALID    (S2_ARVALID),
    .S_ARREADY    (S2_ARREADY),

    .S_RID        (S2_RID),
    .S_RDATA      (S2_RDATA),
    .S_RRESP      (S2_RRESP),
    .S_RLAST      (S2_RLAST),
    .S_RVALID     (S2_RVALID),
    .S_RREADY     (S2_RREADY),

    .S_AWID       (S2_AWID),
    .S_AWADDR     (S2_AWADDR),
    .S_AWLEN      (S2_AWLEN),
    .S_AWSIZE     (S2_AWSIZE),
    .S_AWBURST    (S2_AWBURST),
    .S_AWVALID    (S2_AWVALID),
    .S_AWREADY    (S2_AWREADY),

    .S_WDATA      (S2_WDATA),
    .S_WSTRB      (S2_WSTRB),
    .S_WLAST      (S2_WLAST),
    .S_WVALID     (S2_WVALID),
    .S_WREADY     (S2_WREADY),

    .S_BID        (S2_BID),
    .S_BRESP      (S2_BRESP),
    .S_BVALID     (S2_BVALID),
    .S_BREADY     (S2_BREADY)
);

// ------------------------------------------------------------
// DRAM / ROM wrappers (slaves S5/S0)
// ------------------------------------------------------------
DRAM_wrapper DRAM (
	.ACLK		  (dram_clk),
	.ARESETn	  (dram_rstn_sync),

	.DRAM_CSn	  (DRAM_CSn),
	.DRAM_WEn	  (DRAM_WEn),
	.DRAM_RASn	  (DRAM_RASn),
	.DRAM_CASn	  (DRAM_CASn),
	.DRAM_A		  (DRAM_A),
	.DRAM_D		  (DRAM_D),
	.DRAM_Q		  (DRAM_Q),
	.DRAM_valid	  (DRAM_valid),

    .S5_ARID      (S5_ARID),
    .S5_ARADDR    (S5_ARADDR),
    .S5_ARLEN     (S5_ARLEN),
    .S5_ARSIZE    (S5_ARSIZE),
    .S5_ARBURST   (S5_ARBURST),
    .S5_ARVALID   (S5_ARVALID),
    .S5_ARREADY   (S5_ARREADY),

    .S5_RID       (S5_RID),
    .S5_RDATA     (S5_RDATA),
    .S5_RRESP     (S5_RRESP),
    .S5_RLAST     (S5_RLAST),
    .S5_RVALID    (S5_RVALID),
    .S5_RREADY    (S5_RREADY),

    .S5_AWID      (S5_AWID),
    .S5_AWADDR    (S5_AWADDR),
    .S5_AWLEN     (S5_AWLEN),
    .S5_AWSIZE    (S5_AWSIZE),
    .S5_AWBURST   (S5_AWBURST),
    .S5_AWVALID   (S5_AWVALID),
    .S5_AWREADY   (S5_AWREADY),

    .S5_WDATA     (S5_WDATA),
    .S5_WSTRB     (S5_WSTRB),
    .S5_WLAST     (S5_WLAST),
    .S5_WVALID    (S5_WVALID),
    .S5_WREADY    (S5_WREADY),

    .S5_BID       (S5_BID),
    .S5_BRESP     (S5_BRESP),
    .S5_BVALID    (S5_BVALID),
    .S5_BREADY    (S5_BREADY)
);

ROM_wrapper ROM (
	.ACLK		  (rom_clk),
	.ARESETn	  (rom_rstn_sync),

	.ROM_out	  (ROM_out),
	.ROM_read	  (ROM_read),
	.ROM_enable   (ROM_enable),
	.ROM_address  (ROM_address),

    .S0_ARID      (S0_ARID),
    .S0_ARADDR    (S0_ARADDR),
    .S0_ARLEN     (S0_ARLEN),
    .S0_ARSIZE    (S0_ARSIZE),
    .S0_ARBURST   (S0_ARBURST),
    .S0_ARVALID   (S0_ARVALID),
    .S0_ARREADY   (S0_ARREADY),

    .S0_RID       (S0_RID),
    .S0_RDATA     (S0_RDATA),
    .S0_RRESP     (S0_RRESP),
    .S0_RLAST     (S0_RLAST),
    .S0_RVALID    (S0_RVALID),
    .S0_RREADY    (S0_RREADY)
);

// ------------------------------------------------------------
// DMA wrapper (master M2, slave S3)
// ------------------------------------------------------------
DMA_wrapper DMA (
	.ACLK		  (cpu_clk),
	.ARESETn	  (cpu_rstn_sync),

    .M2_ARID      (M2_ARID),
    .M2_ARADDR    (M2_ARADDR),
    .M2_ARLEN     (M2_ARLEN),
    .M2_ARSIZE    (M2_ARSIZE),
    .M2_ARBURST   (M2_ARBURST),
    .M2_ARVALID   (M2_ARVALID),
    .M2_ARREADY   (M2_ARREADY),
    .M2_RID       (M2_RID),
    .M2_RDATA     (M2_RDATA),
    .M2_RRESP     (M2_RRESP),
    .M2_RLAST     (M2_RLAST),
    .M2_RVALID    (M2_RVALID),
    .M2_RREADY    (M2_RREADY),

    .M2_AWID      (M2_AWID),
    .M2_AWADDR    (M2_AWADDR),
    .M2_AWLEN     (M2_AWLEN),
    .M2_AWSIZE    (M2_AWSIZE),
    .M2_AWBURST   (M2_AWBURST),
    .M2_AWVALID   (M2_AWVALID),
    .M2_AWREADY   (M2_AWREADY),

    .M2_WDATA     (M2_WDATA),
    .M2_WSTRB     (M2_WSTRB),
    .M2_WLAST     (M2_WLAST),
    .M2_WVALID    (M2_WVALID),
    .M2_WREADY    (M2_WREADY),

    .M2_BID       (M2_BID),
    .M2_BRESP     (M2_BRESP),
    .M2_BVALID    (M2_BVALID),
    .M2_BREADY    (M2_BREADY),

    .S3_AWID      (S3_AWID),
    .S3_AWADDR    (S3_AWADDR),
    .S3_AWLEN     (S3_AWLEN),
    .S3_AWSIZE    (S3_AWSIZE),
    .S3_AWBURST   (S3_AWBURST),
    .S3_AWVALID   (S3_AWVALID),
    .S3_AWREADY   (S3_AWREADY),

    .S3_WDATA     (S3_WDATA),
    .S3_WSTRB     (S3_WSTRB),
    .S3_WLAST     (S3_WLAST),
    .S3_WVALID    (S3_WVALID),
    .S3_WREADY    (S3_WREADY),

    .S3_BID       (S3_BID),
    .S3_BRESP     (S3_BRESP),
    .S3_BVALID    (S3_BVALID),
    .S3_BREADY    (S3_BREADY),

	.DMA_interrupt(DMA_interrupt)
);


WDT_wrapper WDT (
	.clk		  (rom_clk),
	.rstn		  (rom_rstn_sync),
	.clk2		  (rom_clk),
	.rstn2		  (rom_rstn_sync),

    .S4_ARID      (S4_ARID),
    .S4_ARADDR    (S4_ARADDR),
    .S4_ARLEN     (S4_ARLEN),
    .S4_ARSIZE    (S4_ARSIZE),
    .S4_ARBURST   (S4_ARBURST),
    .S4_ARVALID   (S4_ARVALID),
    .S4_ARREADY   (S4_ARREADY),

    .S4_RID       (S4_RID),
    .S4_RDATA     (S4_RDATA),
    .S4_RRESP     (S4_RRESP),
    .S4_RLAST     (S4_RLAST),
    .S4_RVALID    (S4_RVALID),
    .S4_RREADY    (S4_RREADY),

    .S4_AWID      (S4_AWID),
    .S4_AWADDR    (S4_AWADDR),
    .S4_AWLEN     (S4_AWLEN),
    .S4_AWSIZE    (S4_AWSIZE),
    .S4_AWBURST   (S4_AWBURST),
    .S4_AWVALID   (S4_AWVALID),
    .S4_AWREADY   (S4_AWREADY),

    .S4_WDATA     (S4_WDATA),
    .S4_WSTRB     (S4_WSTRB),
    .S4_WLAST     (S4_WLAST),
    .S4_WVALID    (S4_WVALID),
    .S4_WREADY    (S4_WREADY),

    .S4_BID       (S4_BID),
    .S4_BRESP     (S4_BRESP),
    .S4_BVALID    (S4_BVALID),
    .S4_BREADY    (S4_BREADY),

	.WTO		  (WDT_timeout_rom)
);

// Synchronize ROM-domain WDT timeout into CPU clock domain
logic wdt_irq_sync1, wdt_irq_sync2;
always_ff @(posedge cpu_clk)
begin
    if(!cpu_rstn_sync)
    begin
        wdt_irq_sync1 <= 1'b0;
        wdt_irq_sync2 <= 1'b0;
    end
    else
    begin
        wdt_irq_sync1 <= WDT_timeout_rom;
        wdt_irq_sync2 <= wdt_irq_sync1;
    end
end

assign WDT_timeout = wdt_irq_sync2;

endmodule
