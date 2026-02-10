// --- Cache Policy  ---
// Read Miss  : Read Allocate (load block into cache on read miss)

module L1C_inst(
    input clk,
    input rstn,

    // --- Interface to CPU Core  ---
	input                   			 cpu_core_req,   // Instruction fetch request
    input  				[`DATA_BITS-1:0] cpu_core_addr,  // PC address from CPU
    output logic 		[`DATA_BITS-1:0] cpu_core_out,   // Instruction word back to CPU
    output logic            			 cpu_core_wait,  // High when Cache is busy (handling miss)

    // --- Interface to CPU Wrapper / SRAM ---
    output logic            			 I_req,          // Request to Wrapper for SRAM access
    output logic 		[`DATA_BITS-1:0] I_addr,   		 // Memory address for fetch (Cache line aligned)
    input  				[`DATA_BITS-1:0] I_out,          // Data block returned from Wrapper
    input                   		     I_wait,         // Signal from Wrapper: Memory system is busy
    
    // --- AXI Handshake Signals  ---
    input                   			rvalid_m0_i,    // I_out is valid
    input                   			rready_m0_i     // M0 (IM_Master) RREADY indicates the master accepts RDATA this cycle
);

// Cache Parameters
logic [`CACHE_INDEX_BITS-1:0] index;
logic [`CACHE_DATA_BITS-1:0]  DA_out1, DA_out2;	// data out 128 bits
logic [`CACHE_DATA_BITS-1:0]  DA_in;			// data in 128 bits
logic [`CACHE_WRITE_BITS-1:0] DA_write;			// write signal to data array: 16bits
logic DA_read;
logic [`CACHE_TAG_BITS-1:0] TA_out1, TA_out2;	// tag out 23 bits
logic [`CACHE_TAG_BITS-1:0] TA_in;				// tag in 23 bits
logic TA_write;
logic TA_read;
logic [`CACHE_LINES-1:0] valid;					// valid bits for each cache line
			
logic hit1, hit2, set;							// set: choose which way to replace

logic [2:0] counter;							// counter for burst read from memory


// --- Address Decomposition ---
wire [22:0] addr_tag   = cpu_core_addr[31:9]; // 23-bit Tag
wire [4:0]  addr_index = cpu_core_addr[8:4];  // 5-bit Index (32 sets)
wire [1:0]  addr_word  = cpu_core_addr[3:2];  // 2-bit Word select (for 128-bit block) chooses which 32-bit word within the 128-bit block
// cpu_core_addr[1:0] is byte offset, ignored for 32-bit word access

assign TA_in = addr_tag;
assign index = addr_index;
assign hit1 = valid[index] & (TA_out1 == TA_in);
assign hit2 = valid[index] & (TA_out2 == TA_in);


typedef enum logic [1:0] {
	IDLE,
	CHECK,		// cache hit check state
	READ   		// cache miss state
} I_cache_state_t;

I_cache_state_t curr_state, next_state;


always_ff @( posedge clk ) begin 
	if(~rstn)
		curr_state <= IDLE;
	else 
		curr_state <= next_state;
end

// next state logic
always_comb begin 
	case (curr_state)
		IDLE : begin
			if(cpu_core_req)begin
				if(valid[index])		//cache line  valid	
					next_state = CHECK;
				else
					next_state = READ;
			end
			else begin
				next_state = IDLE;
			end
		end
		CHECK : begin
			if(hit1 | hit2)begin
				next_state = IDLE;		//cache hit
			end
			else begin
				next_state = READ;		//cache miss
			end
		end
		READ: begin						//cache miss
			if(counter == 3'd4 & ~I_wait)begin
				next_state = IDLE;
			end
			else begin
				next_state = READ;
			end
		end
		default : begin					
			next_state = IDLE;
		end
	endcase
end

// cpu_core_wait
always_comb begin 
	if(curr_state == IDLE)begin
		if(cpu_core_req)begin									//request arrive
			cpu_core_wait = 1'b1;
		end
		else begin
			cpu_core_wait = 1'b0;
		end
	end
	else if((curr_state == CHECK) & (hit1 | hit2))begin			//cache hit
		cpu_core_wait = 1'b0;
	end
	else begin													//cache miss
		cpu_core_wait = 1'b1;
	end
end


//write signal activate low
always_comb begin 
	case (curr_state)
		IDLE : begin
			I_req = 1'b0;
			I_addr = `DATA_BITS'd0;
			TA_read = 1'b1;
			DA_read = 1'b1;
			TA_write = 1'b1;
			DA_write = 16'hffff;
		end
		CHECK : begin
			I_req = 1'b0;
			I_addr = `DATA_BITS'd0;
			TA_read = 1'b1;
			DA_read = 1'b1;
			TA_write = 1'b1;
			DA_write = 16'hffff;
		end
		READ : begin
			I_req = (counter == 3'd4) ? 1'b0 : 1'b1;
			I_addr = {addr_tag, addr_index, 4'd0};		// Align to the start of the 16-byte block
			TA_read = 1'b0;
			DA_read = 1'b0;
			TA_write = ( counter == 3'd4) ? 1'b0 : 1'b1;
			DA_write = ( counter == 3'd4) ? 16'h0 : 16'hffff;
		end
		default : begin
			I_req = 1'b0;
			I_addr = `DATA_BITS'd0;
			TA_read = 1'b1;
			DA_read = 1'b1;
		end 
	endcase
end


//cache miss
always_ff @( posedge clk) begin 
	if (~rstn) begin
		counter <= 3'd0;
		valid <= {`CACHE_LINES{1'b0}};
		DA_in <= 128'd0;
	end
	else if(curr_state == READ)begin
		valid <= valid;
		if(rvalid_m0_i & rready_m0_i)begin
			counter <= counter + 3'd1;
			case (counter)
				3'd0: DA_in[31:0]   <= I_out;
				3'd1: DA_in[63:32]  <= I_out;
				3'd2: DA_in[95:64]  <= I_out;
				3'd3: DA_in[127:96] <= I_out;
				default: DA_in      <= DA_in; 
			endcase

			if(counter == 3'd3) begin			//last data word received
				valid[index] <= 1'b1;
			end
		end
	end
	else begin
		counter <= 3'd0;
		DA_in <= 128'd0;
		valid <= valid;		
	end
end




//cache hit
always_comb begin 
	if(hit1)begin
		case (addr_word)
			2'b00 : cpu_core_out = DA_out1[31:0];   // Word 0
            2'b01 : cpu_core_out = DA_out1[63:32];  // Word 1
            2'b10 : cpu_core_out = DA_out1[95:64];  // Word 2
            2'b11 : cpu_core_out = DA_out1[127:96]; // Word 3	
		endcase
	end
	else if(hit2)begin
		case (addr_word)
			2'b00 : cpu_core_out = DA_out2[31:0];
            2'b01 : cpu_core_out = DA_out2[63:32];
            2'b10 : cpu_core_out = DA_out2[95:64];
            2'b11 : cpu_core_out = DA_out2[127:96];
		endcase
	end
	else if(counter == 3'd4) begin
        // Handle the case when data has been fetched from memory after a miss
        case (addr_word)
            2'b00 : cpu_core_out = DA_in[31:0];
            2'b01 : cpu_core_out = DA_in[63:32];
            2'b10 : cpu_core_out = DA_in[95:64];
            2'b11 : cpu_core_out = DA_in[127:96];
        endcase
    end
	else begin
		cpu_core_out = `DATA_BITS'd0;
	end
end

// -----  LRU Algorithm -----
// LRU[index] = 0 : Way1 is LRU
// LRU[index] = 1 : Way2 is LRU
logic LRU_lock;							  // prevent multiple updates in one miss (4 beats)
logic [`CACHE_LINES-1:0] LRU;
always_ff @( posedge clk ) begin          //cache miss write
    if(~rstn)begin
        LRU <= {`CACHE_LINES{1'b0}};
		set <=  1'b0;
		LRU_lock <= 1'b0;
    end
    else if(curr_state == READ & counter == 3'd3 & ~LRU_lock)begin		//Cache miss pick way to replace
        LRU_lock <= 1'b1;
		case (LRU[index])
            1'b0 : begin
				set <= 1'b0;
                LRU[index] <= 1'b1;
            end
            1'b1 : begin
				set <= 1'b1;
                LRU[index] <= 1'b0;
            end
        endcase
    end
	else if((curr_state == CHECK) & hit1)begin							//cache hit way1, Update LRU 
		LRU[index] <= 1'b1;
		LRU_lock <= 1'b0;
	end
	else if((curr_state == CHECK) & hit2)begin							//cache hit way2, Update LRU
		LRU[index] <= 1'b0;
		LRU_lock <= 1'b0;
	end
end

data_array_wrapper DA(
	.A(index),
	.DO1(DA_out1),
	.DO2(DA_out2),
	.DI(DA_in),
	.CK(clk),
	.rstn(rstn),
	.WEB(DA_write),				// each bit control 1 byte, 128=[16]*8 bits
	.OE(DA_read),
	.CS(1'b0),
	.set_to_change(set)
);
 
tag_array_wrapper  TA(
	.A(index),
	.DO1(TA_out1),				//switch to 23 bits
	.DO2(TA_out2),
	.DI(TA_in),
	.CK(clk),
	.rstn(rstn),
	.WEB(TA_write),
	.OE(TA_read),
	.CS(1'b0),
	.set_to_change(set)
);

endmodule
