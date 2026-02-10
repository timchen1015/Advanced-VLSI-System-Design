module WDT_wrapper (
    // clk/rst runs in fast domain, clk2/rstn2 runs in slow domain before
    // Now both run in the same domain via AFIFO
    input  logic clk,    
    input  logic rstn,   
    input  logic clk2,   
    input  logic rstn2, 

    input  logic [ `AXI_IDS_BITS-1:0] S4_ARID,
    input  logic [`AXI_ADDR_BITS-1:0] S4_ARADDR,
    input  logic [ `AXI_LEN_BITS-1:0] S4_ARLEN,
    input  logic [`AXI_SIZE_BITS-1:0] S4_ARSIZE,
    input  logic [               1:0] S4_ARBURST,
    input  logic                      S4_ARVALID,
    output logic                      S4_ARREADY,

    output logic [ `AXI_IDS_BITS-1:0] S4_RID,
    output logic [`AXI_DATA_BITS-1:0] S4_RDATA,
    output logic [               1:0] S4_RRESP,
    output logic                      S4_RLAST,
    output logic                      S4_RVALID,
    input  logic                      S4_RREADY,

    input  logic [ `AXI_IDS_BITS-1:0] S4_AWID,
    input  logic [`AXI_ADDR_BITS-1:0] S4_AWADDR,
    input  logic [ `AXI_LEN_BITS-1:0] S4_AWLEN,
    input  logic [`AXI_SIZE_BITS-1:0] S4_AWSIZE,
    input  logic [               1:0] S4_AWBURST,
    input  logic                      S4_AWVALID,
    output logic                      S4_AWREADY,

    input  logic [`AXI_DATA_BITS-1:0] S4_WDATA,
    input  logic [`AXI_STRB_BITS-1:0] S4_WSTRB,
    input  logic                      S4_WLAST,
    input  logic                      S4_WVALID,
    output logic                      S4_WREADY,

    output logic [ `AXI_IDS_BITS-1:0] S4_BID,
    output logic [               1:0] S4_BRESP,
    output logic                      S4_BVALID,
    input  logic                      S4_BREADY,

    output logic     WTO // WDT timeout; synchronized to cpu clock in top.sv
);


logic        WDEN;        // Enable the watchdog   (clk domain)
logic        WDLIVE;      // Restart the watchdog  (clk domain)
logic [31:0] WTOCNT;      // Watchdog reload value (clk domain)


//Handshake process check
logic AR_hs_done;
logic R_hs_done;
logic AW_hs_done;
logic W_hs_done;
logic B_hs_done;

assign AR_hs_done = S4_ARVALID & S4_ARREADY; 
assign R_hs_done  = S4_RVALID   & S4_RREADY;
assign AW_hs_done = S4_AWVALID & S4_AWREADY;
assign W_hs_done  = S4_WVALID   & S4_WREADY;
assign B_hs_done  = S4_BVALID   & S4_BREADY;

//Last check
logic  R_last;
logic  W_last;
assign R_last = S4_RLAST & R_hs_done;
assign W_last = S4_WLAST & W_hs_done;

//FSM
typedef enum logic [1:0] {
	ADDR,
	READ,
	WRITE,
	WRESP
} WDT_state_t;

WDT_state_t cur_state, next_state;

always_ff @ (posedge clk)
begin
    if(!rstn)
        cur_state <= ADDR;
    else
        cur_state <= next_state;
end

always_comb
begin
    unique case(cur_state)
        ADDR:
        begin
            if(AR_hs_done)
                next_state = READ;
            else if(AW_hs_done)
                next_state = WRITE;
            else
                next_state = ADDR;
        end

        READ:
            next_state = (   R_last) ? ADDR  : READ;

        WRITE:
            next_state = (   W_last) ? WRESP : WRITE;

        WRESP:
            next_state = (B_hs_done) ? ADDR  : WRESP;

        default:
            next_state = ADDR;
    endcase    
end

//length count
logic [`AXI_LEN_BITS-1:0] len_cnt;
always_ff @ (posedge clk)
begin
	if (!rstn)
		len_cnt <= `AXI_LEN_BITS'd0;
	else
	begin
		if(R_last)
			len_cnt <= `AXI_LEN_BITS'd0;            
		else if(R_hs_done)
			len_cnt <= len_cnt + `AXI_LEN_BITS'd1;            
		else
			len_cnt <= len_cnt;
	end
end

//AR-channel
always_ff @ (posedge clk)
begin
	if(!rstn)
		S4_ARREADY <= 1'b0;
	else
		S4_ARREADY <= (cur_state == ADDR) & (~AR_hs_done);
end

//R-channel
logic [ `AXI_IDS_BITS-1:0] ARID_S_reg;
logic [ `AXI_LEN_BITS-1:0] ARLEN_reg;
logic [`AXI_ADDR_BITS-1:0] ARADDR_reg; // capture read address
always_ff @ (posedge clk)
begin
	if(!rstn)
	begin
		ARID_S_reg <= `AXI_IDS_BITS'd0;
		ARLEN_reg  <= `AXI_LEN_BITS'd0;
        ARADDR_reg <= `AXI_ADDR_BITS'd0;
	end
	else
	begin
		ARID_S_reg <= (AR_hs_done) ? S4_ARID : ARID_S_reg;
		ARLEN_reg  <= (AR_hs_done) ? S4_ARLEN : ARLEN_reg;
        ARADDR_reg <= (AR_hs_done) ? S4_ARADDR : ARADDR_reg;
	end
end

assign S4_RID  =  ARID_S_reg;

// Return read data: map a few readable registers so CPU can query WDT
always_comb
begin
    unique case(ARADDR_reg[15:0])
        16'h0000: S4_RDATA = {31'd0, WDEN};   // status: WDEN
        16'h0004: S4_RDATA = {31'd0, WDLIVE}; // status: WDLIVE
        16'h0008: S4_RDATA = WTOCNT;          // current reload value (clk domain shadow)
        default:  S4_RDATA = `AXI_DATA_BITS'd0;
    endcase
end

assign S4_RRESP  = `AXI_RESP_OKAY;
assign S4_RLAST  = (len_cnt == ARLEN_reg) & (cur_state == READ);
assign S4_RVALID = (cur_state == READ);


//AW-channel
always_ff @ (posedge clk)
begin
	if(!rstn)
		S4_AWREADY <= 1'b0;
	else
    	S4_AWREADY <= (cur_state == ADDR) & (~AW_hs_done);
end

//W-channel
assign S4_WREADY = (cur_state == WRITE);

//B-channel
logic [ `AXI_IDS_BITS-1:0] AWID_S_reg;
logic [`AXI_ADDR_BITS-1:0] AWADDR_reg;
always_ff @ (posedge clk)
begin
	if(!rstn)
	begin
		AWID_S_reg <= `AXI_IDS_BITS'd0;
		AWADDR_reg <= `AXI_ADDR_BITS'd0;
	end
	else
	begin
		AWID_S_reg <= (AW_hs_done) ? S4_AWID : AWID_S_reg;
		AWADDR_reg <= (AW_hs_done) ? S4_AWADDR : AWADDR_reg;
	end
end

assign S4_BID     = AWID_S_reg; 
assign S4_BRESP   = `AXI_RESP_OKAY;
assign S4_BVALID  = (cur_state == WRESP);


// Register write: update WDEN, WDLIVE, WTOCNT in clk domain when a write handshake completes
always_ff @ (posedge clk)
begin
    if(!rstn)
    begin
        WDEN   <= 1'b0;
        WDLIVE <= 1'b0;
        WTOCNT <= 32'd0;
    end
    else if(W_hs_done)
    begin
        unique case(AWADDR_reg[15:0])
            16'h0100: WDEN   <= S4_WDATA[0];
            16'h0200: WDLIVE <= S4_WDATA[0];
            16'h0300: WTOCNT <= S4_WDATA; // write new reload value into clk-domain shadow
            default:
            begin
                WDEN   <= WDEN;
                WDLIVE <= WDLIVE;
                WTOCNT <= WTOCNT;
            end
        endcase
    end
    else
    begin
        WDEN   <= WDEN;
        WDLIVE <= WDLIVE;
        WTOCNT <= WTOCNT;
    end
end

// No WTOCNT toggle/ack required when wrapper and core share the same clock.
// Timeout is already in the same domain; export directly.
logic WTO_clk2;
assign WTO = WTO_clk2;


// Instantiate the WDT core (runs in clk2 domain).
// But now clk2=clk in this design via AFIFO. 
WDT i_WDT (
    .clk2   (clk2),
    .rstn2  (rstn2),
    .WDEN   (WDEN),
    .WDLIVE (WDLIVE),
    .WTOCNT (WTOCNT),
    .WTO    (WTO_clk2)
);

endmodule
