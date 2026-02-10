module AR (
    input logic clk,
    input logic rstn,

    // Masters -> AXI
    input  logic [  `AXI_ID_BITS-1:0] M0_ARID,
    input  logic [`AXI_ADDR_BITS-1:0] M0_ARADDR,
    input  logic [ `AXI_LEN_BITS-1:0] M0_ARLEN,
    input  logic [`AXI_SIZE_BITS-1:0] M0_ARSIZE,
    input  logic [               1:0] M0_ARBURST,
    input  logic                      M0_ARVALID,
    output logic                      M0_ARREADY,

    input  logic [  `AXI_ID_BITS-1:0] M1_ARID,
    input  logic [`AXI_ADDR_BITS-1:0] M1_ARADDR,
    input  logic [ `AXI_LEN_BITS-1:0] M1_ARLEN,
    input  logic [`AXI_SIZE_BITS-1:0] M1_ARSIZE,
    input  logic [               1:0] M1_ARBURST,
    input  logic                      M1_ARVALID,
    output logic                      M1_ARREADY,

    input  logic [  `AXI_ID_BITS-1:0] M2_ARID,
    input  logic [`AXI_ADDR_BITS-1:0] M2_ARADDR,
    input  logic [ `AXI_LEN_BITS-1:0] M2_ARLEN,
    input  logic [`AXI_SIZE_BITS-1:0] M2_ARSIZE,
    input  logic [               1:0] M2_ARBURST,
    input  logic                      M2_ARVALID,
    output logic                      M2_ARREADY,

    // AXI -> Slaves
    output logic [ `AXI_IDS_BITS-1:0] S0_ARID,
    output logic [`AXI_ADDR_BITS-1:0] S0_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] S0_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] S0_ARSIZE,
    output logic [               1:0] S0_ARBURST,
    output logic                      S0_ARVALID,
    input  logic                      S0_ARREADY,

    output logic [ `AXI_IDS_BITS-1:0] S1_ARID,
    output logic [`AXI_ADDR_BITS-1:0] S1_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] S1_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] S1_ARSIZE,
    output logic [               1:0] S1_ARBURST,
    output logic                      S1_ARVALID,
    input  logic                      S1_ARREADY,

    output logic [ `AXI_IDS_BITS-1:0] S2_ARID,
    output logic [`AXI_ADDR_BITS-1:0] S2_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] S2_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] S2_ARSIZE,
    output logic [               1:0] S2_ARBURST,
    output logic                      S2_ARVALID,
    input  logic                      S2_ARREADY,

    output logic [ `AXI_IDS_BITS-1:0] S4_ARID,
    output logic [`AXI_ADDR_BITS-1:0] S4_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] S4_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] S4_ARSIZE,
    output logic [               1:0] S4_ARBURST,
    output logic                      S4_ARVALID,
    input  logic                      S4_ARREADY,

    output logic [ `AXI_IDS_BITS-1:0] S5_ARID,
    output logic [`AXI_ADDR_BITS-1:0] S5_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] S5_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] S5_ARSIZE,
    output logic [               1:0] S5_ARBURST,
    output logic                      S5_ARVALID,
    input  logic                      S5_ARREADY
);

logic [ `AXI_IDS_BITS-1:0] IDS_M;
logic [`AXI_ADDR_BITS-1:0] ADDR_M;
logic [ `AXI_LEN_BITS-1:0] LEN_M;
logic [`AXI_SIZE_BITS-1:0] SIZE_M;
logic [               1:0] BURST_M;

logic                      READY_S;
logic                      VALID_M;
logic                      dummy_valid_s3;

// slave 0: ROM
assign S0_ARID        = IDS_M;
assign S0_ARADDR      = ADDR_M;
assign S0_ARLEN       = LEN_M;
assign S0_ARSIZE      = SIZE_M;
assign S0_ARBURST     = BURST_M;

// slave 1: IM
assign S1_ARID        = IDS_M;
assign S1_ARADDR      = ADDR_M;
assign S1_ARLEN       = LEN_M;
assign S1_ARSIZE      = SIZE_M;
assign S1_ARBURST     = BURST_M;

// slave 2: DM
assign S2_ARID        = IDS_M;
assign S2_ARADDR      = ADDR_M;
assign S2_ARLEN       = LEN_M;
assign S2_ARSIZE      = SIZE_M;
assign S2_ARBURST     = BURST_M;

// slave 4: WDT
assign S4_ARID        = IDS_M;
assign S4_ARADDR      = ADDR_M;
assign S4_ARLEN       = LEN_M;
assign S4_ARSIZE      = SIZE_M;
assign S4_ARBURST     = BURST_M;

// slave 5: DRAM
assign S5_ARID        = IDS_M;
assign S5_ARADDR      = ADDR_M;
assign S5_ARLEN       = LEN_M;
assign S5_ARSIZE      = SIZE_M;
assign S5_ARBURST     = BURST_M;

Arbiter AR_Arbiter(
    .clk            (clk),
    .rstn           (rstn),

    // from M0
    .ID_M0          (M0_ARID),
    .ADDR_M0        (M0_ARADDR),
    .LEN_M0         (M0_ARLEN),
    .SIZE_M0        (M0_ARSIZE),
    .BURST_M0       (M0_ARBURST),
    .VALID_M0       (M0_ARVALID),
    // to M0
    .READY_M0       (M0_ARREADY),

    // from M1
    .ID_M1          (M1_ARID),
    .ADDR_M1        (M1_ARADDR),
    .LEN_M1         (M1_ARLEN),
    .SIZE_M1        (M1_ARSIZE),
    .BURST_M1       (M1_ARBURST),
    .VALID_M1       (M1_ARVALID),
    // to M1
    .READY_M1       (M1_ARREADY),

    // from DMA
    .ID_M2          (M2_ARID),
    .ADDR_M2        (M2_ARADDR),
    .LEN_M2         (M2_ARLEN),
    .SIZE_M2        (M2_ARSIZE),
    .BURST_M2       (M2_ARBURST),
    .VALID_M2       (M2_ARVALID),
    // to DMA
    .READY_M2       (M2_ARREADY),

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

Decoder AR_Decoder(
    .ADDR_M         (ADDR_M),

    .VALID_M        (VALID_M),
    .VALID_S0       (S0_ARVALID),
    .VALID_S1       (S1_ARVALID),
    .VALID_S2       (S2_ARVALID),
    .VALID_S3       (dummy_valid_s3),
    .VALID_S4       (S4_ARVALID),
    .VALID_S5       (S5_ARVALID),
    
    .READY_S0       (S0_ARREADY),
    .READY_S1       (S1_ARREADY),
    .READY_S2       (S2_ARREADY),
    .READY_S3       (1'b0), // DMA read not supported: stall AR handshake
    .READY_S4       (S4_ARREADY),
    .READY_S5       (S5_ARREADY),
    .READY_S        (READY_S)
);

endmodule
