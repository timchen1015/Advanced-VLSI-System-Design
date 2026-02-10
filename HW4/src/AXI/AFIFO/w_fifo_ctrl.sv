module w_fifo_ctrl #(
    parameter int ADDR_SIZE = 1               // depth = 2 ^ ADDR_SIZE (ADDR_SIZE=1 => depth=2)
)(
    input  wclk,
    input  winc,
    input  wrst,
    input  [ADDR_SIZE:0] wq2_rptr,        // synchronized read pointer (Gray)

    output logic wclken,
    output logic [ADDR_SIZE:0] wptr,      // write pointer for outter design (Gray), more 1 bit for full detection
    output logic [ADDR_SIZE-1:0] waddr,   // write address for inner memory  (binary)
    output logic wfull
);

localparam int PTR_WIDTH = ADDR_SIZE + 1;

logic [PTR_WIDTH-1:0] wbin;               // write pointer (binary)
logic [PTR_WIDTH-1:0] wbinnext;           // next write pointer (binary)
logic [PTR_WIDTH-1:0] wgraynext;          // next write pointer (Gray)
logic [PTR_WIDTH-1:0] wq2_rptr_inv;       

// In gray code, "full" is defined as: the top two bits are inverted, the rest are the same
always_comb begin
   //initialize
    wq2_rptr_inv = wq2_rptr;

   // invert top two MSBs
    wq2_rptr_inv[PTR_WIDTH-1] = ~wq2_rptr[PTR_WIDTH-1];
    if (PTR_WIDTH >= 2) begin
        wq2_rptr_inv[PTR_WIDTH-2] = ~wq2_rptr[PTR_WIDTH-2];
    end
end

assign wclken = (winc && ~wfull);
assign wbinnext  = wbin + (wclken ? {{(PTR_WIDTH-1){1'b0}}, 1'b1} : '0);      // increment 1 if wclken
assign wgraynext = (wbinnext >> 1) ^ wbinnext;                                // binary to Gray (G = B ^ (B>>1))

assign waddr = wbin[ADDR_SIZE-1:0];

// NOTE: wq2_rptr is already 2-flop synchronized in FIFO.sv (syn_ptr).
// full when *next* write pointer catches up to read pointer (MSBs inverted)
logic wfull_next;
assign wfull_next = (wgraynext == wq2_rptr_inv);

// write pointer: binary + Gray
always_ff @(posedge wclk or posedge wrst) begin
    if (wrst) begin
        wbin <= '0;
        wptr <= '0;
        wfull <= 1'b0;
    end
    else begin
        wbin <= wbinnext;
        wptr <= wgraynext;
        wfull <= wfull_next;
    end
end

endmodule
