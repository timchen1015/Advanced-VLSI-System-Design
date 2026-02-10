module IM_Master (
    input  logic clk,
    input  logic rstn,

    //from CPU
    input  logic                      read,
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
	output logic                      RREADY_M
);

typedef enum logic [1:0] {
	IDLE,
	READADDR,
	READDATA
} master_state_t;

master_state_t cur_state, nxt_state;

// AXI channel handshake detection (asserted when VALID and READY are both high)
logic AR_hs_done;
logic R_hs_done;

assign AR_hs_done = ARVALID_M & ARREADY_M; 
assign R_hs_done  = RVALID_M  & RREADY_M ;

// Last-beat indicator for the read burst (RLAST + handshake)
logic R_last;
assign R_last = RLAST_M & R_hs_done;

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
                nxt_state = (AR_hs_done) ? READDATA : READADDR;
            else
                nxt_state = IDLE;
        end

        READADDR:
            nxt_state = (AR_hs_done) ? READDATA : READADDR;

        READDATA:
            nxt_state = (R_last) ? IDLE : READDATA;

        default:
            nxt_state = IDLE;
    endcase
end


// VIP
logic r;
always_ff @ (posedge clk)
begin
    if(!rstn)
        r <= 1'b0;
    else
        r <= 1'b1;
end

logic ARVALID_M_reg;
always_ff @ (posedge clk)
begin
    if(!rstn)
        ARVALID_M_reg <= 1'b0;
    else
        ARVALID_M_reg <= ARVALID_M;
end

logic [`AXI_ADDR_BITS-1:0] addr_in_reg;
always_ff @ (posedge clk)
begin
    if(!rstn)
        addr_in_reg <= 32'd0;
    else
        addr_in_reg <= (~ARVALID_M_reg) ? addr_in : addr_in_reg;
end
//

//AR
assign ARID_M    = `AXI_ID_BITS'd0;
assign ARADDR_M  =  (ARVALID_M && ~(ARVALID_M_reg)) ? addr_in : addr_in_reg;
assign ARLEN_M   = `AXI_LEN_BITS'd3;    // 4-beat burst for 16-byte cache line
assign ARSIZE_M  = `AXI_SIZE_BITS'b10;  // 4 bytes (32 bits)
assign ARBURST_M = `AXI_BURST_INC;      // burst type irrelevant for single transfer
assign ARVALID_M = (cur_state == IDLE) ? ( r & read ) : (cur_state == READADDR);

//R
assign RREADY_M  = (cur_state == READDATA);

logic [`AXI_DATA_BITS-1:0] rdata_buf;
always_ff @ (posedge clk)
begin
    if(!rstn)
        rdata_buf <= `AXI_DATA_BITS'd0;
    else if(R_hs_done)
        rdata_buf <= RDATA_M;
end

always_comb
begin
    if(R_hs_done)
        data_out = RDATA_M;
    else
        data_out = rdata_buf;
end

always_comb
begin
    unique case (cur_state)
        IDLE:     stall = read;
        READADDR: stall = 1'b1;
        READDATA: stall = ~R_hs_done;
        default:  stall = 1'b0;
    endcase
end

endmodule