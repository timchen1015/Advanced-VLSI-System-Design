module B (
    input  logic                      M1_BREADY,
    output logic [  `AXI_ID_BITS-1:0] M1_BID,
    output logic [               1:0] M1_BRESP,
    output logic                      M1_BVALID,

    input  logic                      M2_BREADY,
    output logic [  `AXI_ID_BITS-1:0] M2_BID,
    output logic [               1:0] M2_BRESP,
    output logic                      M2_BVALID,

    input  logic [ `AXI_IDS_BITS-1:0] S1_BID,
    input  logic [               1:0] S1_BRESP,
    input  logic                      S1_BVALID,
    output logic                      S1_BREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S2_BID,
    input  logic [               1:0] S2_BRESP,
    input  logic                      S2_BVALID,
    output logic                      S2_BREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S3_BID,
    input  logic [               1:0] S3_BRESP,
    input  logic                      S3_BVALID,
    output logic                      S3_BREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S4_BID,
    input  logic [               1:0] S4_BRESP,
    input  logic                      S4_BVALID,
    output logic                      S4_BREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S5_BID,
    input  logic [               1:0] S5_BRESP,
    input  logic                      S5_BVALID,
    output logic                      S5_BREADY
);

logic [3:0] master;
logic [4:0] slave;

logic                      bready_sel;
logic                      bvalid_sel;
logic [               1:0] bresp_sel;
logic [`AXI_ID_BITS-1:0] bid_sel;

always_comb
begin
    if(S1_BVALID)
        slave = 5'b0_0001;
    else if(S2_BVALID)
        slave = 5'b0_0010;
    else if(S3_BVALID)
        slave = 5'b0_0100;
    else if(S4_BVALID)
        slave = 5'b0_1000;
    else if(S5_BVALID)
        slave = 5'b1_0000;
    else
        slave = 5'b0_0000;
end

always_comb
begin
    unique case(master)
        4'b0010:
        begin
            bready_sel = M1_BREADY;
            M1_BID     = bid_sel;
            M1_BRESP   = bresp_sel;
            M1_BVALID  = bvalid_sel;
            M2_BID    = `AXI_ID_BITS'd0;
            M2_BRESP  = `AXI_RESP_DECERR;
            M2_BVALID = 1'b0;
        end

        4'b0100:
        begin
            bready_sel = M2_BREADY;
            M1_BID    = `AXI_ID_BITS'd0;
            M1_BRESP  = `AXI_RESP_DECERR;
            M1_BVALID = 1'b0;
            M2_BID    = bid_sel;
            M2_BRESP  = bresp_sel;
            M2_BVALID = bvalid_sel;
        end

        default:
        begin
            bready_sel = 1'b0;
            M1_BID    = `AXI_ID_BITS'd0;
            M1_BRESP  = `AXI_RESP_DECERR;
            M1_BVALID = 1'b0;
            M2_BID    = `AXI_ID_BITS'd0;
            M2_BRESP  = `AXI_RESP_DECERR;
            M2_BVALID = 1'b0;
        end
    endcase
end

always_comb
begin
    unique case(slave)
        5'b0_0001:
        begin
            master   = S1_BID[7:4];
            bid_sel  = S1_BID[`AXI_ID_BITS-1:0];
            bresp_sel  = S1_BRESP;
            bvalid_sel = S1_BVALID;
            {S5_BREADY, S4_BREADY, S3_BREADY, S2_BREADY, S1_BREADY} = {4'b0000, bready_sel};  
        end

        5'b0_0010:
        begin
            master   = S2_BID[7:4];
            bid_sel  = S2_BID[`AXI_ID_BITS-1:0];
            bresp_sel  = S2_BRESP;
            bvalid_sel = S2_BVALID;
            {S5_BREADY, S4_BREADY, S3_BREADY, S2_BREADY, S1_BREADY} = {3'b000, bready_sel, 1'b0};
        end

        5'b0_0100:
        begin
            master   = S3_BID[7:4];
            bid_sel  = S3_BID[`AXI_ID_BITS-1:0];
            bresp_sel  = S3_BRESP;
            bvalid_sel = S3_BVALID;
            {S5_BREADY, S4_BREADY, S3_BREADY, S2_BREADY, S1_BREADY} = {2'b00, bready_sel, 2'b00};
        end

        5'b0_1000:
        begin
            master   = S4_BID[7:4];
            bid_sel  = S4_BID[`AXI_ID_BITS-1:0];
            bresp_sel  = S4_BRESP;
            bvalid_sel = S4_BVALID;
            {S5_BREADY, S4_BREADY, S3_BREADY, S2_BREADY, S1_BREADY} = {1'b0, bready_sel, 3'b000};
        end

        5'b1_0000:
        begin
            master   = S5_BID[7:4];
            bid_sel  = S5_BID[`AXI_ID_BITS-1:0];
            bresp_sel  = S5_BRESP;
            bvalid_sel = S5_BVALID;
            {S5_BREADY, S4_BREADY, S3_BREADY, S2_BREADY, S1_BREADY} = {bready_sel, 4'b0000};
        end
        
        default:
        begin
            master   = 4'b0000;
            bid_sel    = `AXI_ID_BITS'd0;
            bresp_sel  = `AXI_RESP_DECERR;
            bvalid_sel = 1'b0;
            {S5_BREADY, S4_BREADY, S3_BREADY, S2_BREADY, S1_BREADY} = 5'b0_0000;
        end
    endcase
end

endmodule
