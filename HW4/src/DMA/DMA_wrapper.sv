module DMA_wrapper (
    input  logic ACLK,
    input  logic ARESETn,

    output logic [  `AXI_ID_BITS-1:0] M2_ARID,
    output logic [`AXI_ADDR_BITS-1:0] M2_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] M2_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] M2_ARSIZE,
    output logic [               1:0] M2_ARBURST,
    output logic                      M2_ARVALID,
    input  logic                      M2_ARREADY,

    input  logic [  `AXI_ID_BITS-1:0] M2_RID,
    input  logic [`AXI_DATA_BITS-1:0] M2_RDATA,
    input  logic [               1:0] M2_RRESP,
    input  logic                      M2_RLAST,
    input  logic                      M2_RVALID,
    output logic                      M2_RREADY,

    output logic [  `AXI_ID_BITS-1:0] M2_AWID,
    output logic [`AXI_ADDR_BITS-1:0] M2_AWADDR,
    output logic [ `AXI_LEN_BITS-1:0] M2_AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] M2_AWSIZE,
    output logic [               1:0] M2_AWBURST,
    output logic                      M2_AWVALID,
    input  logic                      M2_AWREADY,

    output logic [`AXI_DATA_BITS-1:0] M2_WDATA,
    output logic [`AXI_STRB_BITS-1:0] M2_WSTRB,
    output logic                      M2_WLAST,
    output logic                      M2_WVALID,
    input  logic                      M2_WREADY,

    input  logic [  `AXI_ID_BITS-1:0] M2_BID,
    input  logic [               1:0] M2_BRESP,
    input  logic                      M2_BVALID,
    output logic                      M2_BREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S3_AWID,
    input  logic [`AXI_ADDR_BITS-1:0] S3_AWADDR,
    input  logic [ `AXI_LEN_BITS-1:0] S3_AWLEN,
    input  logic [`AXI_SIZE_BITS-1:0] S3_AWSIZE,
    input  logic [               1:0] S3_AWBURST,
    input  logic                      S3_AWVALID,
    output logic                      S3_AWREADY,

    input  logic [`AXI_DATA_BITS-1:0] S3_WDATA,
    input  logic [`AXI_STRB_BITS-1:0] S3_WSTRB,
    input  logic                      S3_WLAST,
    input  logic                      S3_WVALID,
    output logic                      S3_WREADY,

    output logic [ `AXI_IDS_BITS-1:0] S3_BID,
    output logic [               1:0] S3_BRESP,
    output logic                      S3_BVALID,
    input  logic                      S3_BREADY,

    output logic       DMA_interrupt
);

//DMA_Slave pass to DMA_Master
logic        DMAEN;
logic [31:0] DESC_BASE;

/*          DMA Master          */
DMA_Master i_DMA_Master(
    .ACLK         (ACLK),
    .ARESETn      (ARESETn),

    .DMAEN        (DMAEN),
    .DESC_BASE    (DESC_BASE),
    .DMA_interrupt(DMA_interrupt),

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
    .M2_BREADY    (M2_BREADY)
);

/*          DMA Slave           */
DMA_Slave i_DMA_Slave(
    .ACLK         (ACLK),
    .ARESETn      (ARESETn),

    .DMAEN        (DMAEN),
    .DESC_BASE    (DESC_BASE),

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
    .S3_BREADY    (S3_BREADY)
);

endmodule
