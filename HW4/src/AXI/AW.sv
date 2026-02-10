module AW (
    input  logic clk,
    input  logic rstn,
    
    // Masters -> AXI
    input  logic [  `AXI_ID_BITS-1:0] M1_AWID,
    input  logic [`AXI_ADDR_BITS-1:0] M1_AWADDR,
    input  logic [ `AXI_LEN_BITS-1:0] M1_AWLEN,
    input  logic [`AXI_SIZE_BITS-1:0] M1_AWSIZE,
    input  logic [               1:0] M1_AWBURST,
    input  logic                      M1_AWVALID,
    output logic                      M1_AWREADY,

    input  logic [  `AXI_ID_BITS-1:0] M2_AWID,
    input  logic [`AXI_ADDR_BITS-1:0] M2_AWADDR,
    input  logic [ `AXI_LEN_BITS-1:0] M2_AWLEN,
    input  logic [`AXI_SIZE_BITS-1:0] M2_AWSIZE,
    input  logic [               1:0] M2_AWBURST,
    input  logic                      M2_AWVALID,
    output logic                      M2_AWREADY,

    // AXI -> Slaves
    output logic [ `AXI_IDS_BITS-1:0] S1_AWID,
    output logic [`AXI_ADDR_BITS-1:0] S1_AWADDR,
    output logic [ `AXI_LEN_BITS-1:0] S1_AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] S1_AWSIZE,
    output logic [               1:0] S1_AWBURST,
    output logic                      S1_AWVALID,
    input  logic                      S1_AWREADY,

    output logic [ `AXI_IDS_BITS-1:0] S2_AWID,
    output logic [`AXI_ADDR_BITS-1:0] S2_AWADDR,
    output logic [ `AXI_LEN_BITS-1:0] S2_AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] S2_AWSIZE,
    output logic [               1:0] S2_AWBURST,
    output logic                      S2_AWVALID,
    input  logic                      S2_AWREADY,

    output logic [ `AXI_IDS_BITS-1:0] S3_AWID,
    output logic [`AXI_ADDR_BITS-1:0] S3_AWADDR,
    output logic [ `AXI_LEN_BITS-1:0] S3_AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] S3_AWSIZE,
    output logic [               1:0] S3_AWBURST,
    output logic                      S3_AWVALID,
    input  logic                      S3_AWREADY,

    output logic [ `AXI_IDS_BITS-1:0] S4_AWID,
    output logic [`AXI_ADDR_BITS-1:0] S4_AWADDR,
    output logic [ `AXI_LEN_BITS-1:0] S4_AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] S4_AWSIZE,
    output logic [               1:0] S4_AWBURST,
    output logic                      S4_AWVALID,
    input  logic                      S4_AWREADY,

    output logic [ `AXI_IDS_BITS-1:0] S5_AWID,
    output logic [`AXI_ADDR_BITS-1:0] S5_AWADDR,
    output logic [ `AXI_LEN_BITS-1:0] S5_AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] S5_AWSIZE,
    output logic [               1:0] S5_AWBURST,
    output logic                      S5_AWVALID,
    input  logic                      S5_AWREADY
);

logic [`AXI_IDS_BITS-1:0] IDS_M;
logic [`AXI_ADDR_BITS-1:0] ADDR_M;
logic [ `AXI_LEN_BITS-1:0] LEN_M;
logic [`AXI_SIZE_BITS-1:0] SIZE_M;
logic [               1:0] BURST_M;

logic                      READY_S;
logic                      VALID_M;

// dummy signals for M0 and S0
logic                      DUMMY_M0_AWREADY;
logic                      DUMMY_S0_AWVALID;
logic                      DUMMY_S0_AWREADY;

// slave 1: IM
assign S1_AWID        = IDS_M;
assign S1_AWADDR      = ADDR_M;
assign S1_AWLEN       = LEN_M;
assign S1_AWSIZE      = SIZE_M;
assign S1_AWBURST     = BURST_M;

// slave 2: DM
assign S2_AWID        = IDS_M;
assign S2_AWADDR      = ADDR_M;
assign S2_AWLEN       = LEN_M;
assign S2_AWSIZE      = SIZE_M;
assign S2_AWBURST     = BURST_M;

// slave 3: DMA
assign S3_AWID        = IDS_M;
assign S3_AWADDR      = ADDR_M;
assign S3_AWLEN       = LEN_M;
assign S3_AWSIZE      = SIZE_M;
assign S3_AWBURST     = BURST_M;

// slave 4: WDT
assign S4_AWID        = IDS_M;
assign S4_AWADDR      = ADDR_M;
assign S4_AWLEN       = LEN_M;
assign S4_AWSIZE      = SIZE_M;
assign S4_AWBURST     = BURST_M;

// slave 5: DRAM
assign S5_AWID        = IDS_M;
assign S5_AWADDR      = ADDR_M;
assign S5_AWLEN       = LEN_M;
assign S5_AWSIZE      = SIZE_M;
assign S5_AWBURST     = BURST_M;


Arbiter AW_Arbiter(
    .clk(clk),
    .rstn(rstn),

    // from M0
    .ID_M0          (`AXI_ID_BITS'd0),
    .ADDR_M0        (`AXI_ADDR_BITS'd0),
    .LEN_M0         (`AXI_LEN_BITS'd0),
    .SIZE_M0        (`AXI_SIZE_BITS'd0),
    .BURST_M0       (2'b00),
    .VALID_M0       (1'b0),
    // to M0
    .READY_M0       (DUMMY_M0_AWREADY), // Because M0.AWREADY doesn't exist

    // from M1
    .ID_M1          (M1_AWID),
    .ADDR_M1        (M1_AWADDR),
    .LEN_M1         (M1_AWLEN),
    .SIZE_M1        (M1_AWSIZE),
    .BURST_M1       (M1_AWBURST),
    .VALID_M1       (M1_AWVALID),
    // to M1
    .READY_M1       (M1_AWREADY),

    // from DMA
    .ID_M2          (M2_AWID),
    .ADDR_M2        (M2_AWADDR),
    .LEN_M2         (M2_AWLEN),
    .SIZE_M2        (M2_AWSIZE),
    .BURST_M2       (M2_AWBURST),
    .VALID_M2       (M2_AWVALID),
    // to DMA
    .READY_M2       (M2_AWREADY),

    // from Slaves
    .READY_S        (READY_S),
    // to Slaves
    .IDS_M          (IDS_M),
    .ADDR_M         (ADDR_M),
    .LEN_M          (LEN_M),
    .SIZE_M         (SIZE_M),
    .BURST_M        (BURST_M),
    .VALID_M        (VALID_M)
);


Decoder AW_Decoder(
    .ADDR_M         (ADDR_M),

    .VALID_M        (VALID_M),
    .VALID_S0       (DUMMY_S0_AWVALID), // Because S0.AWVALID doesn't exist
    .VALID_S1       (S1_AWVALID),
    .VALID_S2       (S2_AWVALID),
    .VALID_S3       (S3_AWVALID),
    .VALID_S4       (S4_AWVALID),
    .VALID_S5       (S5_AWVALID),

    .READY_S0       (DUMMY_S0_AWREADY), // Because S0.AWREADY doesn't exist
    .READY_S1       (S1_AWREADY),
    .READY_S2       (S2_AWREADY),
    .READY_S3       (S3_AWREADY),
    .READY_S4       (S4_AWREADY),
    .READY_S5       (S5_AWREADY),
    .READY_S        (READY_S)
);

endmodule
