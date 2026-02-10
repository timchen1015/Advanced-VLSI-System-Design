module DM_Master (
    input  logic clk,
    input  logic rstn,

    //from CPU
    input  logic                      read,
    input  logic                      write,
    input  logic [          `BWEBBus] DM_BWEB,
    input  logic [`AXI_DATA_BITS-1:0] data_in,
    input  logic [`AXI_ADDR_BITS-1:0] addr_in,
    //to CPU
    output logic [`AXI_DATA_BITS-1:0] data_out,
    output logic                      stall,

	//READ ADDRESS
	output logic [  `AXI_ID_BITS-1:0] ARID_M,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M,
	output logic [ `AXI_LEN_BITS-1:0] ARLEN_M,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M,
	output logic [               1:0] ARBURST_M,
	output logic                      ARVALID_M,
	input  logic                      ARREADY_M,
	
	//READ DATA
	input  logic [  `AXI_ID_BITS-1:0] RID_M,
	input  logic [`AXI_DATA_BITS-1:0] RDATA_M,
	input  logic [               1:0] RRESP_M,
	input  logic                      RLAST_M,
	input  logic                      RVALID_M,
	output logic                      RREADY_M,

	//WRITE ADDRESS
	output logic [  `AXI_ID_BITS-1:0] AWID_M,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M,
	output logic [ `AXI_LEN_BITS-1:0] AWLEN_M,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M,
	output logic [               1:0] AWBURST_M,
	output logic                      AWVALID_M,
	input  logic                      AWREADY_M,
	
	//WRITE DATA
	output logic [`AXI_DATA_BITS-1:0] WDATA_M,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M,
	output logic                      WLAST_M,
	output logic                      WVALID_M,
	input  logic                      WREADY_M,
	
	//WRITE RESPONSE
	input  logic [  `AXI_ID_BITS-1:0] BID_M,
	input  logic [               1:0] BRESP_M,
	input  logic                      BVALID_M,
	output logic                      BREADY_M
);

typedef enum logic [2:0] {
	IDLE,
	READADDR,
	READDATA,
    WRITEADDR,
    WRITEDATA,
    WRITERESP
} master_state_t;

master_state_t cur_state, nxt_state;

// AXI channel handshake detection (asserted when VALID and READY are both high)
logic AR_hs_done;
logic R_hs_done;
logic AW_hs_done;
logic W_hs_done;
logic B_hs_done;

assign AR_hs_done = ARVALID_M & ARREADY_M; 
assign R_hs_done  = RVALID_M  & RREADY_M ;
assign AW_hs_done = AWVALID_M & AWREADY_M;
assign W_hs_done  = WVALID_M  & WREADY_M ;
assign B_hs_done  = BVALID_M  & BREADY_M ;

// Track last beat indicators for read/write bursts
logic R_last;
logic W_last;
assign R_last = RLAST_M & R_hs_done;
assign W_last = WLAST_M & W_hs_done;

// -----------------------------------------------------------------------------
// State transition logic
// -----------------------------------------------------------------------------
always_ff @ (posedge clk)
begin
    if(!rstn)
        cur_state <= IDLE;
    else
        cur_state <= nxt_state;
end

always_comb
begin
    unique case(cur_state)
        IDLE:
        begin
            if(ARVALID_M)
                nxt_state = (AR_hs_done) ? READDATA  : READADDR ;
            else if(AWVALID_M)
                nxt_state = (AW_hs_done) ? WRITEDATA : WRITEADDR;
            else
                nxt_state = IDLE;
        end

        READADDR:
            nxt_state = (AR_hs_done) ? READDATA : READADDR;

        READDATA:
            nxt_state = (R_last) ? IDLE : READDATA;

        WRITEADDR:
            nxt_state = (AW_hs_done) ? WRITEDATA : WRITEADDR;

        WRITEDATA:
            nxt_state = (W_last) ? WRITERESP : WRITEDATA;

        WRITERESP:
            nxt_state = (B_hs_done) ? IDLE : WRITERESP;

        default:
            nxt_state = IDLE;
    endcase
end

// VIP
logic r, w;
always_ff @ (posedge clk)
begin
    if(!rstn)
        {r,w} <= 2'b00;
    else
        {r,w} <= 2'b11;
end
//

// VIP
logic ARVALID_M_reg;
always_ff @ (posedge clk)
begin
    if(!rstn)
        ARVALID_M_reg <= 1'b0;
    else
        ARVALID_M_reg <= ARVALID_M;
end

logic [`AXI_ADDR_BITS-1:0] addr_in_reg_r;
always_ff @ (posedge clk)
begin
    if(!rstn)
        addr_in_reg_r <= 32'd0;
    else
        addr_in_reg_r <= (~ARVALID_M_reg) ? addr_in : addr_in_reg_r;
end
//

//AR
assign ARID_M    = `AXI_ID_BITS'd1;
assign ARADDR_M  = (ARVALID_M && (~(ARVALID_M_reg))) ? addr_in : addr_in_reg_r;
assign ARLEN_M   = `AXI_LEN_BITS'd3;    // 4-beat burst for cache line refill
assign ARSIZE_M  = `AXI_SIZE_BITS'b10;  // 4 bytes (32 bits)
assign ARBURST_M = `AXI_BURST_INC;      // incrementing burst for sequential beats
assign ARVALID_M = (cur_state == IDLE) ? ( r & read ) : (cur_state == READADDR);

//R
assign RREADY_M  = (cur_state == READDATA);

logic [`AXI_DATA_BITS -1:0] RDATA_M_reg;
always_ff @ (posedge clk)
begin
    if(!rstn)
        RDATA_M_reg <= `AXI_DATA_BITS'd0;
    else if(R_hs_done)
        RDATA_M_reg <= RDATA_M;
end

assign data_out  = (R_hs_done) ? RDATA_M : RDATA_M_reg;

// VIP
logic AWVALID_M_reg;
always_ff @ (posedge clk)
begin
    if(!rstn)
        AWVALID_M_reg <= 1'b0;
    else
        AWVALID_M_reg <= AWVALID_M;
end

logic [`AXI_ADDR_BITS-1:0] addr_in_reg_w;
always_ff @ (posedge clk)
begin
    if(!rstn)
        addr_in_reg_w <= 32'd0;
    else
        addr_in_reg_w <= (~AWVALID_M_reg) ? addr_in : addr_in_reg_w;
end
//

//AW
assign AWID_M    = `AXI_ID_BITS'd1;
assign AWADDR_M  = (AWVALID_M && ~(AWVALID_M_reg)) ? addr_in : addr_in_reg_w;
assign AWLEN_M   = `AXI_LEN_BITS'd0;    // single transfer
assign AWSIZE_M  = `AXI_SIZE_BITS'b10;  // 4 bytes (32 bits)
assign AWBURST_M = `AXI_BURST_INC;      // burst type irrelevant for single transfer
assign AWVALID_M = (cur_state == IDLE) ? ( w & write ) : (cur_state == WRITEADDR); 

//W
assign WDATA_M  = data_in;
assign WSTRB_M  = {~&DM_BWEB[31:24] , ~&DM_BWEB[23:16] , ~&DM_BWEB[15:8] , ~&DM_BWEB[7:0]};
assign WLAST_M  = 1'b1; // Single transfer
assign WVALID_M = (cur_state == WRITEDATA);

//B
assign BREADY_M = (cur_state == WRITERESP);

assign stall = (read & (~R_last)) | (write & (~W_last));

endmodule