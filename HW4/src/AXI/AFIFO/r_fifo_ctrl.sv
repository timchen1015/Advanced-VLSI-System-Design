module r_fifo_ctrl #(
    parameter int ADDR_SIZE = 1  // depth = 2**ADDR_SIZE (ADDR_SIZE=1 => depth=2)
)(
    input  rclk,
    input  rinc,
    input  rrst,
    input  [ADDR_SIZE:0] rq2_wptr, // synchronized write pointer (Gray)

    output logic rclken,
    output logic [ADDR_SIZE:0] rptr,            // read pointer (Gray)
    output logic [ADDR_SIZE-1:0] raddr_next,    // next read address (binary)
    output logic rempty,
    output logic rvalid
);

localparam int PTR_WIDTH = ADDR_SIZE + 1;

logic [PTR_WIDTH-1:0] rbin;
logic [PTR_WIDTH-1:0] rbinnext;
logic [PTR_WIDTH-1:0] rgraynext;
logic                 rempty_next;

assign rclken   = (rinc && ~rempty);
assign rbinnext = rbin + (rclken ? {{(PTR_WIDTH-1){1'b0}}, 1'b1} : '0);          // increment 1 if rclken
assign rgraynext = (rbinnext >> 1) ^ rbinnext;                                   // binary to Gray (G = B ^ (B>>1))

assign raddr_next = rbinnext[ADDR_SIZE-1:0];

// NOTE: rq2_wptr is already 2-flop synchronized in FIFO.sv (syn_ptr).
// empty updates based on *next* read pointer
assign rempty_next = (rgraynext == rq2_wptr);

// read pointer: binary + Gray
always_ff @(posedge rclk or posedge rrst) begin
    if (rrst) begin
        rbin <= '0;
        rptr <= '0;
        rempty <= 1'b1;
        rvalid <= 1'b0;
    end
    else begin
        rbin <= rbinnext;
        rptr <= rgraynext;
        rempty <= rempty_next;
        rvalid <= ~rempty_next;
    end
end

endmodule
