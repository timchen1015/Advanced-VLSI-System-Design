// --- Cache Policy  ---
// Read Miss  : Read Allocate (load block into cache on read miss)
// Write Miss : Write No Allocate
// Write Hit  : Write through (update cache and memory on write hit)
module L1C_data(
  input clk,
  input rstn,

  // --- Interface to CPU Core ---
  input                         cpu_core_req,    // Data access request (read/write)
  input [`DATA_BITS-1:0]        cpu_core_addr,   // Data address from CPU
  input [3:0]                   cpu_core_write,	 // Byte-enable (4'hf means read)
  input [`DATA_BITS-1:0]        cpu_core_in,     // Write data from CPU
  output logic [`DATA_BITS-1:0] cpu_core_out,    // Read data back to CPU
  output logic                  cpu_core_wait,   // High when cache is busy (stall CPU)

  // --- Interface to CPU Wrapper / SRAM ---
  output logic                  D_req,           // Request to wrapper for memory access
  output logic [`DATA_BITS-1:0] D_addr,          // Memory address (aligned for refill)
  output logic [`DATA_BITS-1:0] D_in,            // Write data to memory system
  output logic [3:0]            D_type,          // Byte-enable to memory system (4'hf means read)
  input  [`DATA_BITS-1:0]       D_out,           // Read data from memory system
  input                         D_wait,          // Memory system busy / stall

  // --- AXI Handshake Signals ---
  input                         rvalid_m1_i,     // D_out is valid
  input                         rready_m1_i      // M1 (DM_Master) RREADY indicates the master accepts RDATA this cycle
);

// Cache Parameters
logic [`CACHE_INDEX_BITS-1:0] index; 
logic [`CACHE_DATA_BITS-1:0]  DA_out1;          // data out 128 bits
logic [`CACHE_DATA_BITS-1:0]  DA_out2;

logic [`CACHE_DATA_BITS-1:0]  DA_in;            // data in 128 bits
logic [`CACHE_WRITE_BITS-1:0] DA_write;         // write signal to data array: 16bits
logic                         DA_read;

logic [`CACHE_TAG_BITS-1:0]   TA_out1, TA_out2; // tag out 23 bits
logic [`CACHE_TAG_BITS-1:0]   TA_in;            // tag in 23 bits
logic                         TA_write;
logic                         TA_read;
logic [`CACHE_LINES-1:0]      valid;            // valid bits for each cache line



typedef enum logic [2:0] {
  IDLE,
  CHECK,            // check cache hit state
  MISS_RFD,         // refresh data
  MISS_RD_RETURN,   // read-miss return/settle stage (data becomes stable after refill)
  HIT_WD,           // write-hit data
  MISS_WD,
  FINISH  
} D_cache_state_t;

D_cache_state_t curr_state, next_state;


logic   hit1, hit2;                         // tag hit (Way1 / Way2)
logic   hit_TA1_reg, hit_TA2_reg;           // Registered versions to avoid reconvergent-clock on compare outputs
//tag hit /tag miss   12/14
logic   miss_return_done, miss_rfd_done;
logic   hit_w_done, miss_w_done;

logic   [`DATA_BITS-1:0]  cpu_core_addr_reg;
logic   [`DATA_BITS-1:0]  cpu_core_wdata_reg;
logic   [3:0]             cpu_core_wstrb_reg;
logic   [1:0]             RFD_cnt;

logic   [`CACHE_LINES-1:0] LRU;
logic   set, set_next;
// One-cycle gating to align with registered tag-hit compares
// logic   cmp_valid;

// --- Address Decomposition ---
// Use the latched address for multi-cycle cache operations.
wire [`CACHE_TAG_BITS-1:0]   addr_tag   = cpu_core_addr_reg[31:9];      // 23-bit Tag
wire [`CACHE_INDEX_BITS-1:0] addr_index = cpu_core_addr_reg[8:4];       // 5-bit Index (32 sets)
wire [1:0]                   addr_word  = cpu_core_addr_reg[3:2];       // 2-bit Word select (for 128-bit block)
// Use the incoming address only for IDLE lookup (before cpu_core_addr_reg updates).
wire [`CACHE_INDEX_BITS-1:0] addr_index_req = cpu_core_addr[8:4];
assign  index = (curr_state == IDLE) ? addr_index_req : addr_index;              

assign  TA_in =  addr_tag;
assign  hit1 = valid[index] & (TA_out1 == TA_in);
assign  hit2 = valid[index] & (TA_out2 == TA_in);

// Registering removes the reported Clock_converge01 on hit_TA1 
always_ff @(posedge clk) begin
  if (!rstn) begin
    hit_TA1_reg <= 1'b0;
    hit_TA2_reg <= 1'b0;
  end else begin
    hit_TA1_reg <= hit1;
    hit_TA2_reg <= hit2;
  end
end

logic  miss_return_cnt;
always_ff @(posedge clk ) begin
  if (!rstn) 
    miss_return_cnt <=  1'b0;
  else if(curr_state == MISS_RD_RETURN)  
    miss_return_cnt <= miss_return_cnt + 1'b1;
  else 
    miss_return_cnt  <=  1'b0;       
end

assign  miss_return_done    = (curr_state == MISS_RD_RETURN && miss_return_cnt) ? 1'b1 : 1'b0;
assign  miss_rfd_done = (rvalid_m1_i && rready_m1_i) & (RFD_cnt == 2'd3);
assign  hit_w_done    = ((~D_wait) & (curr_state == HIT_WD)) ? 1'b1 : 1'b0;
assign  miss_w_done   = ((~D_wait) & (curr_state == MISS_WD)) ? 1'b1 : 1'b0;

// FSM 
always_ff @(posedge clk) begin
  if (!rstn)   
    curr_state <= IDLE; 
  else        
    curr_state <= next_state;
end

always_comb begin
  case (curr_state)
    IDLE:     
    begin
      if(cpu_core_req) begin           
        if(valid[index])           //cache line valid
          next_state  = CHECK;
        else begin
          if(cpu_core_write == 4'hf)
            next_state  = MISS_RFD;
          else
            next_state  = MISS_WD;       
        end
      end  
      else 
        next_state  = IDLE;
    end
    CHECK:    
    begin
      // Read hit fast path: decide in the first CHECK cycle (no extra compare-register wait)
      if (cpu_core_wstrb_reg == 4'hf)
        next_state = (hit1 || hit2) ? FINISH : MISS_RFD;
      else 
        // Write hit/miss
        next_state = (hit1 || hit2) ? HIT_WD : MISS_WD;
    end
    MISS_RFD: next_state  = (miss_rfd_done) ? MISS_RD_RETURN : MISS_RFD;
    MISS_RD_RETURN:   next_state  = (miss_return_done) ? FINISH : MISS_RD_RETURN;
    HIT_WD:   next_state  = (hit_w_done) ? FINISH : HIT_WD;
    MISS_WD:  next_state  = (miss_w_done) ? FINISH : MISS_WD;
    FINISH:   next_state  = IDLE;
    default:  next_state  = IDLE;
  endcase   
end
  
// reserve data 
always_ff @(posedge clk) begin
  if(!rstn) 
  begin   
    cpu_core_addr_reg   <=  `DATA_BITS'd0; 
    cpu_core_wstrb_reg  <=  4'd0;
    cpu_core_wdata_reg  <=  `DATA_BITS'd0;
  end
  else if (cpu_core_req)  
  begin
    cpu_core_addr_reg   <=  cpu_core_addr;
    cpu_core_wstrb_reg  <=  cpu_core_write;
    cpu_core_wdata_reg  <=  cpu_core_in;
  end
end

// count read refresh data
//(increments on each R handshake during MISS_RFD)
always_ff @(posedge clk) begin
  if (!rstn)
    RFD_cnt   <=  2'd0;
  else if(curr_state == MISS_RFD) begin
    if (rvalid_m1_i && rready_m1_i) 
      RFD_cnt   <=  RFD_cnt + 2'd1;
    else 
      RFD_cnt   <= RFD_cnt;
  end
  else
    RFD_cnt   <= 2'd0;
end
 
// -----  LRU Algorithm -----
// LRU[index] = 0 : Way1 is LRU
// LRU[index] = 1 : Way2 is LRU
always_ff @(posedge clk) begin
  if (!rstn) begin
    LRU <= {`CACHE_LINES{1'b0}};
  end else begin
    unique case (curr_state)
      CHECK: begin
        // Read hit fast path: update LRU on hit
        if (cpu_core_wstrb_reg == 4'hf) begin
          if (hit1)      LRU[index] <= 1'b1; // used way1 => way2 becomes LRU
          else if (hit2) LRU[index] <= 1'b0; // used way2 => way1 becomes LRU
        end
      end

      MISS_RFD: begin
        // After refill done, the filled way becomes MRU => flip LRU bit
        if (miss_rfd_done)
          LRU[index] <= ~LRU[index];
      end

      HIT_WD: begin
        // Update LRU once when the write transaction completes
        if (hit_w_done) begin
          if (hit_TA1_reg)      LRU[index] <= 1'b1;
          else if (hit_TA2_reg) LRU[index] <= 1'b0;
        end
      end

      default: begin
        // hold
      end
    endcase
  end
end

//Set
always_ff @(posedge clk) begin
  if (!rstn) begin
    set <= 1'b0;
  end else if (curr_state == CHECK) begin
    if (next_state == MISS_RFD)      set <= LRU[index]; // miss: pick victim way
    else if (next_state == HIT_WD)   set <= hit2;       // write hit: pick hit way
    else                             set <= set;       // hold
  end
end

//Data reg
logic [`CACHE_DATA_BITS -1 : 0] reg_da_in;
always_ff @(posedge clk) begin
  if (!rstn)
    reg_da_in   <=  `CACHE_DATA_BITS'd0;
  else if (curr_state == MISS_RFD) begin
    case (RFD_cnt)
      2'd0: reg_da_in[31:0]    <= D_out;
      2'd1: reg_da_in[63:32]   <= D_out;
      2'd2: reg_da_in[95:64]   <= D_out;
      2'd3: reg_da_in[127:96]  <= D_out;
    endcase  
  end
end
always_comb begin
  case (curr_state)
    HIT_WD: begin
      case (addr_word)
        2'd0: DA_in = {96'd0,cpu_core_wdata_reg};
        2'd1: DA_in = {64'd0, cpu_core_wdata_reg, 32'd0}; 
        2'd2: DA_in = {32'd0, cpu_core_wdata_reg, 64'd0};
        2'd3: DA_in = {cpu_core_wdata_reg, 96'd0}; 
        default: DA_in = 128'd0;
      endcase
    end   
    MISS_RFD: begin
      DA_in   = (RFD_cnt == 2'd3) ? {D_out, reg_da_in[95:0]} : `CACHE_DATA_BITS'd0; 
    end
    default:  DA_in   = `CACHE_DATA_BITS'd0; 
  endcase
end

//write select //used offset 
logic [`CACHE_WRITE_BITS -1 : 0]  DA_write_sel;
always_comb begin
  case (curr_state)
    HIT_WD: begin
      if(addr_word == 2'd0)
        DA_write_sel  = {12'hfff, cpu_core_wstrb_reg};
      else if(addr_word == 2'd1)
        DA_write_sel  = {8'hff, cpu_core_wstrb_reg, 4'hf};
      else if(addr_word == 2'd2)
        DA_write_sel  = {4'hf, cpu_core_wstrb_reg, 8'hff};
      else
        DA_write_sel  = {cpu_core_wstrb_reg, 12'hfff};
    end 
    default: DA_write_sel = `CACHE_WRITE_BITS'hffff;
  endcase
end
//DA_write
always_comb begin      //w: 16 bit  
  case (curr_state)
    HIT_WD:   DA_write  = DA_write_sel;
    MISS_RFD: DA_write  = `CACHE_WRITE_BITS'h0000;
    default:  DA_write  = `CACHE_WRITE_BITS'hffff;
  endcase
end
//DA_read
always_comb begin     
  case (curr_state)
    CHECK:    DA_read   = 1'b1; // read hit completes in FINISH; keep SRAM outputs enabled
    MISS_RD_RETURN:   DA_read   = 1'b1;
    default:  DA_read   = 1'b0;
  endcase
end

//TA_write/TA read
always_comb begin
  case (curr_state)
    CHECK: begin
      TA_read   = 1'b1;
      TA_write  = 1'b1;       
    end
    MISS_RFD: begin
      TA_read   = 1'b1;
      TA_write  = 1'b0;              
    end
    default: begin
      TA_read   = 1'b1;
      TA_write  = 1'b1;
    end
  endcase
end
//valid
always_ff @(posedge clk) begin
  if (!rstn)
    valid <=  {`CACHE_LINES{1'b0}};
  else if(curr_state  ==  MISS_RFD)
    valid[index] <=  1'b1;  
end
//------------------ CPU wrapper to core -----------------------//
// cpu_core_out
always_comb begin
  cpu_core_out = `DATA_BITS'd0;

  if (hit_TA1_reg) begin
    unique case (addr_word)
      2'd0: cpu_core_out = DA_out1[ 31:  0];
      2'd1: cpu_core_out = DA_out1[ 63: 32];
      2'd2: cpu_core_out = DA_out1[ 95: 64];
      2'd3: cpu_core_out = DA_out1[127: 96];
      default: cpu_core_out = `DATA_BITS'd0;
    endcase
  end
  else if (hit_TA2_reg) begin
    unique case (addr_word)
      2'd0: cpu_core_out = DA_out2[ 31:  0];
      2'd1: cpu_core_out = DA_out2[ 63: 32];
      2'd2: cpu_core_out = DA_out2[ 95: 64];
      2'd3: cpu_core_out = DA_out2[127: 96];
      default: cpu_core_out = `DATA_BITS'd0;
    endcase
  end
end

// cpu_core_wait
always_comb begin
  case (curr_state)
    IDLE:     cpu_core_wait = 1'b0;
    FINISH:   cpu_core_wait = 1'b0;
    default:  cpu_core_wait = 1'b1;
  endcase
end
//------------------- CPU wrapper to Mem -----------------------//
always_comb begin
  case (curr_state)
    IDLE: begin
      D_req   = 1'b0;
      D_addr  = `DATA_BITS'd0;
    end
    MISS_RFD: begin
      D_req   = 1'b1;
      D_addr  = {cpu_core_addr_reg[31:4], 4'd0};
    end
    MISS_WD, HIT_WD: begin
      D_req   = 1'b1;
      D_addr  = cpu_core_addr_reg;
    end
    default: begin
      D_req   = 1'b0;
      D_addr  = `DATA_BITS'd0;
    end
  endcase
end

always_comb begin
  case (curr_state)
    HIT_WD, MISS_WD: begin
      D_in    = cpu_core_wdata_reg;
      D_type  = cpu_core_wstrb_reg;
    end
    default: begin
      D_in    = `DATA_BITS'd0;
      D_type  = 4'hf;
    end
  endcase
end



data_array_wrapper DA(
  .CK   (clk),
  .rstn (rstn),
  .CS   (1'b0),
  .OE   (DA_read),
  .WEB  (DA_write),
  .A    (index),
  .DI   (DA_in),
  .DO1  (DA_out1),
  .DO2  (DA_out2),
  .set_to_change (set) 
);

tag_array_wrapper  TA(
  .CK   (clk),
  .rstn (rstn),
  .CS   (1'b0),
  .OE   (TA_read),
  .WEB  (TA_write),
  .A    (index),
  .DI   (TA_in),
  .DO1  (TA_out1),
  .DO2  (TA_out2),
  .set_to_change (set) 
);
    
 
endmodule
