// DMA_Slave for CPU config, Only AW/W/B channels are needed
module DMA_Slave (
    input  logic        ACLK,
    input  logic        ARESETn,
    output logic        DMAEN,
    output logic [31:0] DESC_BASE,

    // input  logic [ `AXI_IDS_BITS-1:0] S3_ARID,
    // input  logic [`AXI_ADDR_BITS-1:0] S3_ARADDR,
    // input  logic [ `AXI_LEN_BITS-1:0] S3_ARLEN,
    // input  logic [`AXI_SIZE_BITS-1:0] S3_ARSIZE,
    // input  logic [               1:0] S3_ARBURST,
    // input  logic                      S3_ARVALID,
    // output logic                      S3_ARREADY,

    // output logic [ `AXI_IDS_BITS-1:0] S3_RID,
    // output logic [`AXI_DATA_BITS-1:0] S3_RDATA,
    // output logic [               1:0] S3_RRESP,
    // output logic                      S3_RLAST,
    // output logic                      S3_RVALID,
    // input  logic                      S3_RREADY,

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
    input  logic                      S3_BREADY
);

//Handshake process check
// logic  AR_hs_done;
// logic  R_hs_done;
// logic  AW_hs_done;
logic  W_hs_done;
logic  B_hs_done;

// assign AR_hs_done = S3_ARVALID & S3_ARREADY; 
// assign R_hs_done  = S3_RVALID   & S3_RREADY;
assign AW_hs_done = S3_AWVALID & S3_AWREADY;
assign W_hs_done  = S3_WVALID   & S3_WREADY;
assign B_hs_done  = S3_BVALID   & S3_BREADY;

//Last check
logic  R_last;
logic  W_last;
// assign R_last = S3_RLAST & R_hs_done;
assign W_last = S3_WLAST & W_hs_done;

/*                  FSM                 */
typedef enum logic [1:0] {
	ADDR,
	WDATA,
	WRESP
} DMA_state_t;

DMA_state_t cur_state, next_state;

always_ff @ (posedge ACLK)
begin
    if(!ARESETn)
        cur_state <= ADDR;
    else
        cur_state <= next_state;
end

always_comb
begin
    unique case(cur_state)
        ADDR:
        begin
            next_state = (AW_hs_done) ? WDATA : ADDR;
        end
        WDATA:
            next_state = (W_last)    ? WRESP : WDATA;

        WRESP:
            next_state = (B_hs_done) ? ADDR  : WRESP; 

        default:
            next_state = ADDR;
    endcase
end


// //length count
// logic [`AXI_LEN_BITS-1:0] len_cnt;
// always_ff @ (posedge ACLK)
// begin
// 	if (!ARESETn)
// 	begin
// 		len_cnt <= `AXI_LEN_BITS'd0;
// 	end 
// 	else
// 	begin
// 		if(R_last)
// 			len_cnt <= `AXI_LEN_BITS'd0;            
// 		else if (R_hs_done)
// 			len_cnt <= len_cnt + `AXI_LEN_BITS'd1;            
// 		else
// 			len_cnt <= len_cnt;
// 	end
// end

// //AR-channel
// always_ff @ (posedge ACLK)
// begin
// 	if(!ARESETn)
// 		S3_ARREADY <= 1'b0;
// 	else
// 		S3_ARREADY <= (cur_state == ADDR) & (~AR_hs_done);
// end

// //R-channel
// logic [`AXI_IDS_BITS-1:0] ARID_S_reg;
// logic [`AXI_LEN_BITS-1:0] ARLEN_reg;
// always_ff @ (posedge ACLK)
// begin
// 	if(!ARESETn)
// 	begin
// 		ARID_S_reg <= `AXI_IDS_BITS'd0;
// 		ARLEN_reg  <= `AXI_LEN_BITS'd0;
// 	end
// 	else
// 	begin
// 		ARID_S_reg <= (AR_hs_done) ? S3_ARID : ARID_S_reg;
// 		ARLEN_reg  <= (AR_hs_done) ? S3_ARLEN : ARLEN_reg;
// 	end
// end

// assign S3_RID    = ARID_S_reg;
// assign S3_RDATA  = `AXI_DATA_BITS'd0; //?
// assign S3_RRESP  = `AXI_RESP_OKAY;
// assign S3_RLAST  = ( len_cnt == ARLEN_reg && cur_state == RDATA );
// assign S3_RVALID = (cur_state == RDATA);

//AW-channel
always_ff @ (posedge ACLK)
begin
	if(!ARESETn)
		S3_AWREADY <= 1'b0;
	else
        S3_AWREADY <= (cur_state == ADDR) & (~AW_hs_done);
end

//W-channel
assign S3_WREADY   = (cur_state == WDATA);

//B-channel
logic [ `AXI_IDS_BITS-1:0] AWID_S_reg;
logic [`AXI_ADDR_BITS-1:0] AWADDR_reg;
always_ff @ (posedge ACLK)
begin
	if(!ARESETn)
	begin
		AWID_S_reg <= `AXI_IDS_BITS'd0;
		AWADDR_reg <= `AXI_ADDR_BITS'd0;
	end
	else
	begin
		AWID_S_reg <= (AW_hs_done)  ? S3_AWID : AWID_S_reg;
		AWADDR_reg <= (AW_hs_done)  ? S3_AWADDR : AWADDR_reg;
	end
end


assign S3_BID     = AWID_S_reg; 
assign S3_BRESP   = `AXI_RESP_OKAY;
assign S3_BVALID  = (cur_state == WRESP);

//DMA output signal
always_ff @ (posedge ACLK)
begin
    if(!ARESETn)
    begin
        DMAEN     <= 1'b0;
        DESC_BASE <= 32'd0;
    end
    else if(W_hs_done)
    begin
        unique case(AWADDR_reg[15:0])
            // 0x1002_0100 -> DMAEN
            16'h0100: DMAEN     <= S3_WDATA[0];
            // 0x1002_0200 -> DESC_BASE
            16'h0200: DESC_BASE <= S3_WDATA;
            default:
            begin
                DMAEN     <= DMAEN;
                DESC_BASE <= DESC_BASE;
            end
        endcase  
    end
    else
    begin
        DMAEN     <= DMAEN;
        DESC_BASE <= DESC_BASE;
    end
end

endmodule
