module DMA_Master (
    input  logic ACLK,
    input  logic ARESETn,

    input  logic        DMAEN,                          // Enable the DMA
    input  logic [31:0] DESC_BASE,                      // Address of first descriptor
    output logic        DMA_interrupt,                  // DMA interrupt

    output logic [  `AXI_ID_BITS-1:0] M2_ARID,
    output logic [`AXI_ADDR_BITS-1:0] M2_ARADDR,
    output logic [ `AXI_LEN_BITS-1:0] M2_ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] M2_ARSIZE,
    output logic [               1:0] M2_ARBURST,
    output logic                      M2_ARVALID,
    input  logic                      M2_ARREADY,

    input  logic [  `AXI_ID_BITS-1:0] M2_RID,
    input  logic [`AXI_DATA_BITS-1:0] M2_RDATA,
    input  logic [               1:0] M2_RRESP,
    input  logic                      M2_RLAST,
    input  logic                      M2_RVALID,
    output logic                      M2_RREADY,

    output logic [  `AXI_ID_BITS-1:0] M2_AWID,
    output logic [`AXI_ADDR_BITS-1:0] M2_AWADDR,
    output logic [ `AXI_LEN_BITS-1:0] M2_AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] M2_AWSIZE,
    output logic [               1:0] M2_AWBURST,
    output logic                      M2_AWVALID,
    input  logic                      M2_AWREADY,

    output logic [`AXI_DATA_BITS-1:0] M2_WDATA,
    output logic [`AXI_STRB_BITS-1:0] M2_WSTRB,
    output logic                      M2_WLAST,
    output logic                      M2_WVALID,
    input  logic                      M2_WREADY,

    input  logic [  `AXI_ID_BITS-1:0] M2_BID,
    input  logic [               1:0] M2_BRESP,
    input  logic                      M2_BVALID,
    output logic                      M2_BREADY
);

//Handshake process check
logic  AR_hs_done;
logic  R_hs_done;
logic  AW_hs_done;
logic  W_hs_done;
logic  B_hs_done;

assign AR_hs_done = M2_ARVALID & M2_ARREADY; 
assign R_hs_done  = M2_RVALID   & M2_RREADY;
assign AW_hs_done = M2_AWVALID & M2_AWREADY;
assign W_hs_done  = M2_WVALID   & M2_WREADY;
assign B_hs_done  = M2_BVALID   & M2_BREADY;

//Last check
logic  R_last;
logic  W_last;
assign R_last = M2_RLAST & R_hs_done;
assign W_last = M2_WLAST & W_hs_done;

logic busy;                     // still got remaining data
// Descriptor fields decoded by DMA (fetched via AXI read from DM)
//descriptor list: src, dst, len, next, eoc
logic [31:0] d_src;             //Source address of DMA
logic [31:0] d_dst;             //Destination address of DMA
logic [31:0] d_len;             //Total length of the data
logic [31:0] d_next;            //Address of next descriptor field
logic        d_eoc;             // 1 -> end of chain (last of list)

// Descriptor fetch 
logic [31:0] desc_ptr;          // Base address of current descriptor (5 words)
logic        desc_ready;        // one-shot flag: new descriptor fetched and ready to use
logic        load_descriptor;   // Strobe: latch d_src/d_dst/d_len into working regs
logic        need_first_desc;   // 1 = fetch first descriptor from DESC_BASE

//Transfer progress tracking
logic [`AXI_ADDR_BITS-1:0] slave_src;               // Current source address for this block
logic [`AXI_ADDR_BITS-1:0] slave_dst;               // Current destination address for this block
logic [              31:0] total_data;              // Total length from descriptor
logic [              31:0] remain_data;             // Remaining length to transfer
logic [               4:0] single_transfer_data;    // Beats needed to be transfered in this block (<=16)

//FSM
typedef enum logic [2:0] {
	PREPARE,
    RADDR,
	RDATA,
    WADDR,
    WDATA,
    WRESP,
    FINISH
} DMA_state_t;

DMA_state_t cur_state, next_state;

always_ff @ (posedge ACLK)
begin
    if(!ARESETn)
        cur_state <= PREPARE;
    else
        cur_state <= next_state;
end

always_comb
begin
    unique case(cur_state)
        PREPARE:
        begin
            // Wait for software to enable and a freshly fetched descriptor to be ready
            if(DMAEN && desc_ready)
                next_state = RADDR;
            else
                next_state = PREPARE;
        end

        RADDR:
        begin
            if(AR_hs_done)
                next_state = RDATA;
            else
                next_state = RADDR;
        end

        RDATA:
        begin
            if(R_last)
                next_state = WADDR;
            else
                next_state = RDATA;
        end

        WADDR:
        begin
            if(AW_hs_done)
                next_state = WDATA;
            else
                next_state = WADDR;
        end

        WDATA:
        begin
            if(W_last)
                next_state = WRESP;
            else
                next_state = WDATA;
        end

        WRESP:
        begin
            if(B_hs_done)
                // If there is more data in this block, continue. Otherwise
                // either go to next descriptor or finish when EOC set.
                if(busy) 
                    next_state = RADDR;
                else 
                    next_state = (d_eoc) ? FINISH : PREPARE;
            else
                next_state = WRESP;
        end

        FINISH:
        begin
            if(!DMAEN)             
                next_state = PREPARE;
            else
                next_state = FINISH;
        end

        default:
            next_state = PREPARE;
    endcase
end

always_ff @ (posedge ACLK)
begin
	if (!ARESETn)
        remain_data <= 32'd0;
    else if(load_descriptor)
        remain_data <= d_len;
    else if(W_last)                   // Subtract on the last beat of a burst(16beats)
        remain_data <= remain_data - {27'd0, single_transfer_data};
    else
        remain_data <= remain_data;
end

always_ff @ (posedge ACLK)
begin
	if (!ARESETn)
        single_transfer_data <= 5'd0;
    else if(load_descriptor)
        single_transfer_data <= (d_len  < 32'd16) ? d_len[4:0]  : 5'd16;
    else if(cur_state == WADDR)
        single_transfer_data <= (remain_data < 32'd16) ? remain_data[4:0] : 5'd16;
    else
        single_transfer_data <= single_transfer_data;
end

assign busy = |remain_data;                     // still got remaining data
assign load_descriptor = (cur_state == PREPARE) && desc_ready;

// Descriptor fetch micro-FSM (runs while main FSM is in PREPARE)
typedef enum logic [1:0] {
    D_IDLE, 
    D_AR, 
    D_RD, 
    D_DONE
} desc_state_t;
desc_state_t desc_state, desc_nstate;
logic [2:0]  desc_idx;  // read descriptor index, 0..4 for five 32-bit words(src/dst/len/next/eoc)
logic [31:0] desc_addr; //descriptor address for AXI read (desc_ptr + desc_idx*4)

// Handshake flags for chaining descriptors
logic        block_done;       // one-shot in WRESP when a block finishes (!EOC)
logic        block_done_hold;  // held across the PREPARE cycle to trigger next fetch
assign block_done = (cur_state == WRESP) && B_hs_done && (busy == 1'b0) && (d_eoc == 1'b0);
always_ff @(posedge ACLK) begin
    if(!ARESETn) begin
        block_done_hold <= 1'b0;
    end else begin
        if(block_done)
            block_done_hold <= 1'b1;
        else if(cur_state == PREPARE && desc_state == D_IDLE && desc_nstate == D_AR)
            block_done_hold <= 1'b0;
        else if(!DMAEN)
            block_done_hold <= 1'b0;
        else
            block_done_hold <= block_done_hold;
    end
end

assign desc_addr = desc_ptr + {desc_idx, 2'b00};

always_ff @(posedge ACLK) begin
    if(!ARESETn) begin
        desc_state      <= D_IDLE;
        desc_idx        <= 3'd0;
        desc_ptr        <= 32'd0;
        need_first_desc <= 1'b1;
        d_src           <= 32'd0; 
        d_dst           <= 32'd0; 
        d_len           <= 32'd0; 
        d_next          <= 32'd0; 
        d_eoc           <= 1'b0;
    end else begin
        desc_state <= desc_nstate;
        // Capture data on read beat
        if(cur_state == PREPARE && desc_state == D_RD && R_hs_done) begin
            case (desc_idx)
                3'd0: d_src  <= M2_RDATA;
                3'd1: d_dst  <= M2_RDATA;
                3'd2: d_len  <= M2_RDATA;
                3'd3: d_next <= M2_RDATA;
                3'd4: d_eoc  <= M2_RDATA[0];
                default: ;
            endcase
        end
        // Move to next word after a successful single-beat read
        if(cur_state == PREPARE && desc_state == D_RD && R_last)
            desc_idx <= desc_idx + 3'd1;
        else if(desc_state == D_IDLE && desc_nstate == D_AR)        // clear index when starting a new descriptor fetch
            desc_idx <= 3'd0;

        // Start pointer selection
        if(cur_state == PREPARE) begin
            if(need_first_desc && DMAEN) begin
                // First time: take DESC_BASE from SW
                desc_ptr        <= DESC_BASE;
                need_first_desc <= 1'b0;
            end else if(block_done_hold) begin
                // After finishing a block and before fetching next, advance pointer
                desc_ptr <= d_next;
            end else begin
                desc_ptr <= desc_ptr;
            end
        end

        // Reset fetch when software disables DMA
        if(!DMAEN) begin
            need_first_desc <= 1'b1;
        end
    end
end

always_comb begin
    desc_nstate = desc_state;
    case(desc_state)
        D_IDLE: begin
            if(cur_state == PREPARE && DMAEN && (need_first_desc || block_done_hold))       // Start a new fetch when either it's the first descriptor 
                desc_nstate = D_AR;                                                         // or we've just finished a block and need to fetch the next
        end
        D_AR: begin
            if(AR_hs_done) 
                desc_nstate = D_RD; 
            else 
                desc_nstate = D_AR;
        end
        D_RD: begin
            if(R_hs_done && M2_RLAST) begin
                if(desc_idx == 3'd4) 
                    desc_nstate = D_DONE; 
                else 
                    desc_nstate = D_AR;
            end 
            else begin
                desc_nstate = D_RD;
            end
        end
        D_DONE: begin
            // When returning to PREPARE after a block, go back to IDLE so we can
            // advance desc_ptr and start fetching the next descriptor.
            if(cur_state == PREPARE) 
                desc_nstate = D_IDLE; 
            else 
                desc_nstate = D_DONE;
        end
        default: desc_nstate = D_IDLE;
    endcase
end


// desc_ready pulses high when a descriptor fetch completes, and is consumed
// when the master FSM leaves PREPARE toward RADDR.
always_ff @(posedge ACLK) begin
    if(!ARESETn) begin
        desc_ready <= 1'b0;
    end else begin
        // Set when D_RD -> D_DONE at the last beat
        if(desc_state != D_DONE && desc_nstate == D_DONE)
            desc_ready <= 1'b1;
        // Clear when PREPARE -> RADDR (consumed)
        else if(cur_state == PREPARE && next_state == RADDR)
            desc_ready <= 1'b0;
        else if(!DMAEN)
            desc_ready <= 1'b0;
        else
            desc_ready <= desc_ready;
    end
end

//length count (for AXI M2_WLAST)
logic [`AXI_LEN_BITS:0] len_cnt;
always_ff @ (posedge ACLK)
begin
	if (!ARESETn)
		len_cnt <= 5'd0;
	else
	begin
		if(W_last)
			len_cnt <= 5'd0;            
		else if(W_hs_done)
			len_cnt <= len_cnt + 5'd1;            
		else
			len_cnt <= len_cnt;
	end
end
// AXI
//AR-channel
assign M2_ARID    = `AXI_ID_BITS'd2;
assign M2_ARADDR  = (cur_state == PREPARE) ? desc_addr : slave_src;
assign M2_ARLEN   = (cur_state == PREPARE) ? `AXI_LEN_BITS'd0 : `AXI_LEN_BITS'd15;
assign M2_ARSIZE  = `AXI_SIZE_BITS'b10;
assign M2_ARBURST = `AXI_BURST_INC;

always_ff @ (posedge ACLK)
begin
    if(!ARESETn)
        M2_ARVALID <= 1'b0;
    else
        M2_ARVALID <= ( (cur_state == PREPARE) ? (desc_state == D_AR) : (cur_state == RADDR) ) & (~AR_hs_done);
end

//R-channel
assign M2_RREADY   = (cur_state == PREPARE) ? 1'b1 : (cur_state == RDATA);

//AW-channel
assign M2_AWID    = `AXI_ID_BITS'd2;
assign M2_AWADDR  =  slave_dst;
assign M2_AWLEN   = `AXI_LEN_BITS'd15; 
assign M2_AWSIZE  = `AXI_SIZE_BITS'b10;
assign M2_AWBURST = `AXI_BURST_INC;

always_ff @ (posedge ACLK)
begin
    if(!ARESETn)
        M2_AWVALID <= 1'b0;
    else
        M2_AWVALID <= (cur_state == WADDR) & (~AW_hs_done);
end

//W-channel
always_comb
begin
    // if(len_cnt >= single_transfer_data)
    if(cur_state != WDATA)
        M2_WSTRB   = `AXI_STRB_BITS'd0; // stop driving WDATA when not in WDATA state to avoid unnexpected bus activity 
    else
        M2_WSTRB   = `AXI_STRB_BITS'hf;
end

assign M2_WLAST    =  (cur_state == WDATA) & (len_cnt == {1'b0,M2_AWLEN}) ;
assign M2_WVALID   =  (cur_state == WDATA);

//B-channel
assign M2_BREADY   =  ( cur_state == WDATA || cur_state == WRESP);  

//slave info for DMA
always_ff @ (posedge ACLK)
begin
    if(!ARESETn)
    begin
        slave_src  <= `AXI_ADDR_BITS'd0;
        slave_dst  <= `AXI_ADDR_BITS'd0;
        total_data <= 32'd0;
    end
    else if(load_descriptor)
    begin
        slave_src  <= d_src;
        slave_dst  <= d_dst;
        total_data <= d_len;
    end
    else if(cur_state == WRESP && B_hs_done)
    begin
        slave_src  <= slave_src + ((`AXI_ADDR_BITS'd16) << 2); //16 datas each move address 4
        slave_dst  <= slave_dst + ((`AXI_ADDR_BITS'd16) << 2);
    end
    else
    begin
        slave_src  <= slave_src;
        slave_dst  <= slave_dst;
        total_data <= total_data;
    end
end

//Store Read Data for later write
integer i;
logic [`AXI_DATA_BITS-1:0] data_buffer [15:0]; //burst length up to 15+1=16
always_ff @ (posedge ACLK)
begin
    if(!ARESETn)
    begin
        for(i = 0; i <= 15; i = i + 1)
            data_buffer[i] <= `AXI_DATA_BITS'd0;
    end
    else
    begin
        if( (cur_state == RDATA) && R_hs_done )
        begin
            data_buffer[0] <= M2_RDATA;
            for(i = 0; i <= 14; i = i + 1)
                data_buffer[i+1] <= data_buffer[i];
        end
        else if( (cur_state == WDATA) && W_hs_done )
        begin
            data_buffer[0] <= `AXI_DATA_BITS'd0;
            for(i = 0; i <= 14; i = i + 1)
                data_buffer[i+1] <= data_buffer[i];
        end
        else
        begin
            for(i = 0; i <= 15; i = i + 1)
                data_buffer[i] <= data_buffer[i];
        end
    end
end

assign M2_WDATA = data_buffer[15];

//DMA output signal
always_ff @ (posedge ACLK)
begin
    if(!ARESETn)
        DMA_interrupt <= 1'b0;
    else if(cur_state == FINISH)
        DMA_interrupt <= 1'b1;
    else
        DMA_interrupt <= 1'b0;
end

endmodule
