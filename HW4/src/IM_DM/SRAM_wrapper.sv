module SRAM_wrapper (
	input logic ACLK,
	input logic ARESETn,

	input  logic [ `AXI_IDS_BITS-1:0] S_ARID,
	input  logic [`AXI_ADDR_BITS-1:0] S_ARADDR,
	input  logic [ `AXI_LEN_BITS-1:0] S_ARLEN,
	input  logic [`AXI_SIZE_BITS-1:0] S_ARSIZE,
	input  logic [               1:0] S_ARBURST,
	input  logic                      S_ARVALID,
	output logic                      S_ARREADY,

	output logic [ `AXI_IDS_BITS-1:0] S_RID,
	output logic [`AXI_DATA_BITS-1:0] S_RDATA,
	output logic [               1:0] S_RRESP,
	output logic                      S_RLAST,
	output logic                      S_RVALID,
	input  logic                      S_RREADY,

	input  logic [ `AXI_IDS_BITS-1:0] S_AWID,
	input  logic [`AXI_ADDR_BITS-1:0] S_AWADDR,
	input  logic [ `AXI_LEN_BITS-1:0] S_AWLEN,
	input  logic [`AXI_SIZE_BITS-1:0] S_AWSIZE,
	input  logic [               1:0] S_AWBURST,
	input  logic                      S_AWVALID,
	output logic                      S_AWREADY,

	input  logic [`AXI_DATA_BITS-1:0] S_WDATA,
	input  logic [`AXI_STRB_BITS-1:0] S_WSTRB,
	input  logic                      S_WLAST,
	input  logic                      S_WVALID,
	output logic                      S_WREADY,

	output logic [ `AXI_IDS_BITS-1:0] S_BID,
	output logic [               1:0] S_BRESP,
	output logic                      S_BVALID,
	input  logic                      S_BREADY
);

//SRAM parameter
logic 		 CEB;
logic 		 WEB;
logic [31:0] BWEB;
logic [13:0] A;
logic [31:0] DI;
logic [31:0] DO;

// AXI channel handshake detection (asserted when VALID and READY are both high)
logic AR_hs_done;
logic R_hs_done;
logic AW_hs_done;
logic W_hs_done;
logic B_hs_done;

assign AR_hs_done = S_ARVALID & S_ARREADY; 
assign R_hs_done  = S_RVALID   & S_RREADY;
assign AW_hs_done = S_AWVALID & S_AWREADY;
assign W_hs_done  = S_WVALID   & S_WREADY;
assign B_hs_done  = S_BVALID   & S_BREADY;

// Track last beat indicators for read/write bursts
logic  R_last;
logic  W_last;
assign R_last = S_RLAST & R_hs_done;
assign W_last = S_WLAST & W_hs_done;

// FSM
typedef enum logic [1:0] {
	ADDR,
	READ,
	WRITE,
	WRESP
} SRAM_state_t;

SRAM_state_t cur_state, next_state;

always_ff @ (posedge ACLK)
begin
    if(!ARESETn)
        cur_state <= ADDR;
	else
        cur_state <= next_state;
end

// always_comb
// begin
// 	next_state = cur_state;
	
// 	unique case(cur_state)
//         ADDR:
// 		begin
// 			if(AR_hs_done)
// 				next_state = READ;
// 			else if(AW_hs_done)
// 				next_state = WRITE;
// 			else
// 				next_state = ADDR;
//         end

// 		READ:
// 			if (!R_last) next_state = READ;
// 			else next_state = (AW_hs_done) ? WRITE : ADDR;

// 		WRITE:
// 			next_state = (W_last) ? WRESP : WRITE;

// 		WRESP:
// 			next_state = (B_hs_done) ? ADDR : WRESP;

// 		default:
// 			next_state = ADDR;
// 	endcase
// end

//Write priority over read
always_comb
begin
	next_state = cur_state;
	
	unique case(cur_state)
        ADDR:
		begin
			if(AW_hs_done)
				next_state = WRITE;
			else if(AR_hs_done)
				next_state = READ;
			else
				next_state = ADDR;
        end

		READ:
			next_state = (R_last) ? ADDR : READ;

		WRITE:
			next_state = (W_last) ? WRESP : WRITE;

		WRESP:
			next_state = (B_hs_done) ? ADDR : WRESP;

		default:
			next_state = ADDR;
	endcase
end

//AR-channel
assign S_ARREADY = (cur_state == ADDR && !S_AWVALID);         	// AR ready in ADDR state and AWVALID is low (no write address pending). Write priority over read.

//R-channel
logic [`AXI_IDS_BITS-1:0] ARID_S_reg;
logic [`AXI_LEN_BITS-1:0] ARLEN_reg;
always_ff @ (posedge ACLK)
begin
	if(!ARESETn)
	begin
		ARID_S_reg <= `AXI_IDS_BITS'd0;
		ARLEN_reg  <= `AXI_LEN_BITS'd0;
	end
	else
	begin
		ARID_S_reg <= (AR_hs_done) ? S_ARID : ARID_S_reg;
		ARLEN_reg  <= (AR_hs_done) ? S_ARLEN : ARLEN_reg;
	end
end

//length count
logic [`AXI_LEN_BITS-1:0] len_cnt;
always_ff @ (posedge ACLK)
begin
	if (!ARESETn)
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

// AXI  signals
assign S_RID    = ARID_S_reg;
assign S_RDATA  = DO;
assign S_RRESP  = `AXI_RESP_OKAY;
assign S_RLAST  = (len_cnt == ARLEN_reg) & (cur_state == READ);
assign S_RVALID = (cur_state == READ);

//AW-channel
assign S_AWREADY = (cur_state == ADDR); 	

//W-channel
assign S_WREADY = (cur_state == WRITE);

//B-channel
logic [`AXI_IDS_BITS-1:0] AWID_S_reg;
always_ff @ (posedge ACLK)
begin
	if(!ARESETn)
		AWID_S_reg <= `AXI_IDS_BITS'd0;
	else
		AWID_S_reg <= (AW_hs_done) ? S_AWID : AWID_S_reg;
end

assign S_BID    = AWID_S_reg; 
assign S_BRESP  = `AXI_RESP_OKAY;
assign S_BVALID = (cur_state == WRESP);

logic [13:0] ARADDR_reg;
logic [13:0] AWADDR_reg;

always_ff @ (posedge ACLK)
begin
	if(!ARESETn)
		ARADDR_reg <= 14'd0;
	else if(cur_state == ADDR)
		ARADDR_reg <= (AR_hs_done) ? S_ARADDR[15:2] : ARADDR_reg;
	else if(cur_state == READ)
	begin
		if(R_hs_done)
			ARADDR_reg <= ARADDR_reg + 14'd1;
		else
			ARADDR_reg <= ARADDR_reg;
	end 
	else
		ARADDR_reg <= ARADDR_reg;
end

always_ff @ (posedge ACLK)
begin
	if(!ARESETn)
		AWADDR_reg <= 14'd0;
	else if(cur_state == ADDR)
		AWADDR_reg <= (AW_hs_done) ? S_AWADDR[15:2] : AWADDR_reg;
	else if(cur_state == WRITE)
	begin
		if(W_hs_done)
			AWADDR_reg <= AWADDR_reg + 14'd1;
		else
			AWADDR_reg <= AWADDR_reg;
	end 
	else
		AWADDR_reg <= AWADDR_reg;
end


// SRAM control signals
assign CEB = 1'b0;
assign WEB = (cur_state == WRITE) ? 1'b0 : 1'b1; //read:active high , write:active low
assign BWEB = ~{ {8{S_WSTRB[3]}} , {8{S_WSTRB[2]}} , {8{S_WSTRB[1]}} , {8{S_WSTRB[0]}} }; //Bit write enable (active low)

always_comb //Address
begin
	unique case(cur_state)
		ADDR:    A = (AW_hs_done) ? S_AWADDR[15:2] : ( (AR_hs_done) ? S_ARADDR[15:2] : 14'd0 );
		// SRAM is synchronous-read. To support back-to-back R handshakes (deeper R-channel FIFO),
		// present the *next* address to SRAM on the same cycle a beat is accepted, so data is ready
		// in the following cycle. When stalled (RREADY=0), hold the address to keep DO stable.
		READ:    A = ARADDR_reg + (R_hs_done ? 14'd1 : 14'd0);
		WRITE:   A = AWADDR_reg;
		default: A = 14'd0;
	endcase
end

assign DI = S_WDATA;

TS1N16ADFPCLLLVTA512X45M4SWSHOD i_SRAM (
    .SLP    (1'b0),
    .DSLP   (1'b0),
    .SD     (1'b0),
    .PUDELAY(),
    .CLK    (ACLK),
    .CEB    (CEB),
    .WEB    (WEB),
    .A      (A),
    .D      (DI),
    .BWEB   (BWEB),
    .RTSEL  (2'b01),
    .WTSEL  (2'b01),
    .Q      (DO)
);

endmodule
