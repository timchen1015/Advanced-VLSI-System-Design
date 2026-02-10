module W (
    input  logic clk,
    input  logic rstn,

    // Masters -> AXI
    input  logic [`AXI_DATA_BITS-1:0] M1_WDATA,
    input  logic [`AXI_STRB_BITS-1:0] M1_WSTRB,
    input  logic                      M1_WLAST,
    input  logic                      M1_WVALID,
    output logic                      M1_WREADY,

    input  logic [`AXI_DATA_BITS-1:0] M2_WDATA,
    input  logic [`AXI_STRB_BITS-1:0] M2_WSTRB,
    input  logic                      M2_WLAST,
    input  logic                      M2_WVALID,
    output logic                      M2_WREADY,

    // AXI -> Slaves
    output logic [`AXI_DATA_BITS-1:0] S1_WDATA,
    output logic [`AXI_STRB_BITS-1:0] S1_WSTRB,
    output logic                      S1_WLAST,
    output logic                      S1_WVALID,
    input  logic                      S1_WREADY,

    output logic [`AXI_DATA_BITS-1:0] S2_WDATA,
    output logic [`AXI_STRB_BITS-1:0] S2_WSTRB,
    output logic                      S2_WLAST,
    output logic                      S2_WVALID,
    input  logic                      S2_WREADY,

    output logic [`AXI_DATA_BITS-1:0] S3_WDATA,
    output logic [`AXI_STRB_BITS-1:0] S3_WSTRB,
    output logic                      S3_WLAST,
    output logic                      S3_WVALID,
    input  logic                      S3_WREADY,

    output logic [`AXI_DATA_BITS-1:0] S4_WDATA,
    output logic [`AXI_STRB_BITS-1:0] S4_WSTRB,
    output logic                      S4_WLAST,
    output logic                      S4_WVALID,
    input  logic                      S4_WREADY,

    output logic [`AXI_DATA_BITS-1:0] S5_WDATA,
    output logic [`AXI_STRB_BITS-1:0] S5_WSTRB,
    output logic                      S5_WLAST,
    output logic                      S5_WVALID,
    input  logic                      S5_WREADY,

    // Write transaction context (global write outstanding = 1)
    input  logic                      wr_active,
    input  logic [3:0]                wr_master,
    input  logic [4:0]                wr_slave_sel
);

logic [`AXI_DATA_BITS-1:0] WDATA_M;
logic [`AXI_STRB_BITS-1:0] WSTRB_M;
logic                      WLAST_M;
logic                      WVALID_M;
logic                      WREADY_S;

always_comb begin
    WDATA_M  = `AXI_DATA_BITS'd0;
    WSTRB_M  = `AXI_STRB_BITS'd0;
    WLAST_M  = 1'b0;
    WVALID_M = 1'b0;

    if (wr_active) begin
        unique case (wr_master)
            4'b0010: begin
                WDATA_M  = M1_WDATA;
                WSTRB_M  = M1_WSTRB;
                WLAST_M  = M1_WLAST;
                WVALID_M = M1_WVALID;
            end
            4'b0100: begin
                WDATA_M  = M2_WDATA;
                WSTRB_M  = M2_WSTRB;
                WLAST_M  = M2_WLAST;
                WVALID_M = M2_WVALID;
            end
            default: begin end
        endcase
    end
end

always_comb begin
    WREADY_S = 1'b0;

    S1_WDATA  = WDATA_M;
    S1_WSTRB  = `AXI_STRB_BITS'd0;
    S1_WLAST  = WLAST_M;
    S1_WVALID = 1'b0;

    S2_WDATA  = WDATA_M;
    S2_WSTRB  = `AXI_STRB_BITS'd0;
    S2_WLAST  = WLAST_M;
    S2_WVALID = 1'b0;

    S3_WDATA  = WDATA_M;
    S3_WSTRB  = `AXI_STRB_BITS'd0;
    S3_WLAST  = WLAST_M;
    S3_WVALID = 1'b0;

    S4_WDATA  = WDATA_M;
    S4_WSTRB  = `AXI_STRB_BITS'd0;
    S4_WLAST  = WLAST_M;
    S4_WVALID = 1'b0;

    S5_WDATA  = WDATA_M;
    S5_WSTRB  = `AXI_STRB_BITS'd0;
    S5_WLAST  = WLAST_M;
    S5_WVALID = 1'b0;

    if (wr_active) begin
        unique case (wr_slave_sel)
            5'b0_0001: begin
                WREADY_S = S1_WREADY;
                S1_WVALID = WVALID_M;
                S1_WSTRB  = (S1_WVALID) ? WSTRB_M : `AXI_STRB_BITS'd0;
            end
            5'b0_0010: begin
                WREADY_S = S2_WREADY;
                S2_WVALID = WVALID_M;
                S2_WSTRB  = (S2_WVALID) ? WSTRB_M : `AXI_STRB_BITS'd0;
            end
            5'b0_0100: begin
                WREADY_S = S3_WREADY;
                S3_WVALID = WVALID_M;
                S3_WSTRB  = (S3_WVALID) ? WSTRB_M : `AXI_STRB_BITS'd0;
            end
            5'b0_1000: begin
                WREADY_S = S4_WREADY;
                S4_WVALID = WVALID_M;
                S4_WSTRB  = (S4_WVALID) ? WSTRB_M : `AXI_STRB_BITS'd0;
            end
            5'b1_0000: begin
                WREADY_S = S5_WREADY;
                S5_WVALID = WVALID_M;
                S5_WSTRB  = (S5_WVALID) ? WSTRB_M : `AXI_STRB_BITS'd0;
            end
            default: begin end
        endcase
    end
end

always_comb begin
    M1_WREADY = 1'b0;
    M2_WREADY = 1'b0;

    if (wr_active) begin
        unique case (wr_master)
            4'b0010: M1_WREADY = WREADY_S;
            4'b0100: M2_WREADY = WREADY_S;
            default: begin end
        endcase
    end
end

endmodule

