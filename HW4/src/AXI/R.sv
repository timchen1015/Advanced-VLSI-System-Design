module R (
    input  logic clk,
    input  logic rstn,

    // AXI -> Masters
    output logic [  `AXI_ID_BITS-1:0] M0_RID,
    output logic [`AXI_DATA_BITS-1:0] M0_RDATA,
    output logic [               1:0] M0_RRESP,
    output logic                      M0_RLAST,
    output logic                      M0_RVALID,
    input  logic                      M0_RREADY,

    output logic [  `AXI_ID_BITS-1:0] M1_RID,
    output logic [`AXI_DATA_BITS-1:0] M1_RDATA,
    output logic [               1:0] M1_RRESP,
    output logic                      M1_RLAST,
    output logic                      M1_RVALID,
    input  logic                      M1_RREADY,

    output logic [  `AXI_ID_BITS-1:0] M2_RID,
    output logic [`AXI_DATA_BITS-1:0] M2_RDATA,
    output logic [               1:0] M2_RRESP,
    output logic                      M2_RLAST,
    output logic                      M2_RVALID,
    input  logic                      M2_RREADY,

    // Slaves -> AXI
    input  logic [ `AXI_IDS_BITS-1:0] S0_RID,
    input  logic [`AXI_DATA_BITS-1:0] S0_RDATA,
    input  logic [               1:0] S0_RRESP,
    input  logic                      S0_RLAST,
    input  logic                      S0_RVALID,
    output logic                      S0_RREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S1_RID,
    input  logic [`AXI_DATA_BITS-1:0] S1_RDATA,
    input  logic [               1:0] S1_RRESP,
    input  logic                      S1_RLAST,
    input  logic                      S1_RVALID,
    output logic                      S1_RREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S2_RID,
    input  logic [`AXI_DATA_BITS-1:0] S2_RDATA,
    input  logic [               1:0] S2_RRESP,
    input  logic                      S2_RLAST,
    input  logic                      S2_RVALID,
    output logic                      S2_RREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S4_RID,
    input  logic [`AXI_DATA_BITS-1:0] S4_RDATA,
    input  logic [               1:0] S4_RRESP,
    input  logic                      S4_RLAST,
    input  logic                      S4_RVALID,
    output logic                      S4_RREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S5_RID,
    input  logic [`AXI_DATA_BITS-1:0] S5_RDATA,
    input  logic [               1:0] S5_RRESP,
    input  logic                      S5_RLAST,
    input  logic                      S5_RVALID,
    output logic                      S5_RREADY
);

// ------------------------------------------------------------
// Read return arbitration (simplified)
// - Pick one slave to forward on the shared R channel
// - Once a burst starts, hold the same slave until RLAST handshake
// ------------------------------------------------------------

logic                      rd_active;
logic [4:0]                rd_src_sel;   // latched slave select: {S5,S4,S2,S1,S0}
logic [4:0]                rd_sel_comb;  // combinational slave select when not active
logic [4:0]                rd_sel;       // effective selection

logic [ `AXI_IDS_BITS-1:0] RID_S;
logic [`AXI_DATA_BITS-1:0] RDATA_S;
logic [               1:0] RRESP_S;
logic                      RLAST_S;

always_comb begin
    rd_sel_comb = 5'b0_0000;
    if (S5_RVALID) rd_sel_comb = 5'b1_0000;
    else if (S4_RVALID) rd_sel_comb = 5'b0_1000;
    else if (S2_RVALID) rd_sel_comb = 5'b0_0100;
    else if (S1_RVALID) rd_sel_comb = 5'b0_0010;
    else if (S0_RVALID) rd_sel_comb = 5'b0_0001;
end

assign rd_sel = rd_active ? rd_src_sel : rd_sel_comb;

always_comb begin
    RID_S    = `AXI_IDS_BITS'd0;
    RDATA_S  = `AXI_DATA_BITS'd0;
    RRESP_S  = `AXI_RESP_DECERR;
    RLAST_S  = 1'b0;

    {S5_RREADY, S4_RREADY, S2_RREADY, S1_RREADY, S0_RREADY} = 5'b0_0000;
    {M2_RVALID, M1_RVALID, M0_RVALID} = 3'b000;

    unique case (rd_sel)
        5'b0_0001: begin // S0
            RID_S    = S0_RID;
            RDATA_S  = S0_RDATA;
            RRESP_S  = S0_RRESP;
            RLAST_S  = S0_RLAST;
            unique case (S0_RID[6:4])
                3'b001: begin S0_RREADY = M0_RREADY; M0_RVALID = S0_RVALID; end
                3'b010: begin S0_RREADY = M1_RREADY; M1_RVALID = S0_RVALID; end
                3'b100: begin S0_RREADY = M2_RREADY; M2_RVALID = S0_RVALID; end
                default: begin end
            endcase
        end
        5'b0_0010: begin // S1
            RID_S    = S1_RID;
            RDATA_S  = S1_RDATA;
            RRESP_S  = S1_RRESP;
            RLAST_S  = S1_RLAST;
            unique case (S1_RID[6:4])
                3'b001: begin S1_RREADY = M0_RREADY; M0_RVALID = S1_RVALID; end
                3'b010: begin S1_RREADY = M1_RREADY; M1_RVALID = S1_RVALID; end
                3'b100: begin S1_RREADY = M2_RREADY; M2_RVALID = S1_RVALID; end
                default: begin end
            endcase
        end
        5'b0_0100: begin // S2
            RID_S    = S2_RID;
            RDATA_S  = S2_RDATA;
            RRESP_S  = S2_RRESP;
            RLAST_S  = S2_RLAST;
            unique case (S2_RID[6:4])
                3'b001: begin S2_RREADY = M0_RREADY; M0_RVALID = S2_RVALID; end
                3'b010: begin S2_RREADY = M1_RREADY; M1_RVALID = S2_RVALID; end
                3'b100: begin S2_RREADY = M2_RREADY; M2_RVALID = S2_RVALID; end
                default: begin end
            endcase
        end
        5'b0_1000: begin // S4
            RID_S    = S4_RID;
            RDATA_S  = S4_RDATA;
            RRESP_S  = S4_RRESP;
            RLAST_S  = S4_RLAST;
            unique case (S4_RID[6:4])
                3'b001: begin S4_RREADY = M0_RREADY; M0_RVALID = S4_RVALID; end
                3'b010: begin S4_RREADY = M1_RREADY; M1_RVALID = S4_RVALID; end
                3'b100: begin S4_RREADY = M2_RREADY; M2_RVALID = S4_RVALID; end
                default: begin end
            endcase
        end
        5'b1_0000: begin // S5
            RID_S    = S5_RID;
            RDATA_S  = S5_RDATA;
            RRESP_S  = S5_RRESP;
            RLAST_S  = S5_RLAST;
            unique case (S5_RID[6:4])
                3'b001: begin S5_RREADY = M0_RREADY; M0_RVALID = S5_RVALID; end
                3'b010: begin S5_RREADY = M1_RREADY; M1_RVALID = S5_RVALID; end
                3'b100: begin S5_RREADY = M2_RREADY; M2_RVALID = S5_RVALID; end
                default: begin end
            endcase
        end
        default: begin end
    endcase
end

wire rd_fire =
    (rd_sel[0] && S0_RVALID && S0_RREADY) ||
    (rd_sel[1] && S1_RVALID && S1_RREADY) ||
    (rd_sel[2] && S2_RVALID && S2_RREADY) ||
    (rd_sel[3] && S4_RVALID && S4_RREADY) ||
    (rd_sel[4] && S5_RVALID && S5_RREADY);

always_ff @(posedge clk) begin
    if (!rstn) begin
        rd_active  <= 1'b0;
        rd_src_sel <= 5'b0_0000;
    end else begin
        if (rd_active) begin
            if (rd_fire && RLAST_S) begin
                rd_active  <= 1'b0;
                rd_src_sel <= 5'b0_0000;
            end
        end else begin
            if (rd_fire) begin
                if (RLAST_S) begin
                    rd_active  <= 1'b0;
                    rd_src_sel <= 5'b0_0000;
                end else begin
                    rd_active  <= 1'b1;
                    rd_src_sel <= rd_sel;
                end
            end
        end
    end
end

// ---------------------------
// Data pass to Master
// ---------------------------
assign M0_RID   = RID_S[`AXI_ID_BITS-1:0];
assign M0_RDATA = RDATA_S;
assign M0_RRESP = RRESP_S;
assign M0_RLAST = RLAST_S;

assign M1_RID   = RID_S[`AXI_ID_BITS-1:0];
assign M1_RDATA = RDATA_S;
assign M1_RRESP = RRESP_S;
assign M1_RLAST = RLAST_S;

assign M2_RID   = RID_S[`AXI_ID_BITS-1:0];
assign M2_RDATA = RDATA_S;
assign M2_RRESP = RRESP_S;
assign M2_RLAST = RLAST_S;

endmodule
