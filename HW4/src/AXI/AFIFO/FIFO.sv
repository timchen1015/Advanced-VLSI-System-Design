module FIFO #(
parameter int DATA_WIDTH = 51,
parameter int ADDR_SIZE  = 1  // depth = 2**ADDR_SIZE (ADDR_SIZE>=1)
)(
    input        wclk,
    input        winc,  
    input        wrst,
    input        rclk,
    input        rinc,
    input        rrst,

    input [DATA_WIDTH-1:0] wdata,

    output logic        wfull,
    output logic        rempty,
    output logic        rvalid,
    output logic [DATA_WIDTH-1:0] rdata
);
    // Depth >= 2 async FIFO (ADDR_SIZE>=1)
    logic wclken, rclken;
    localparam int PTR_WIDTH = ADDR_SIZE + 1;

    logic [PTR_WIDTH-1:0] wptr_wire, rptr_wire;
    logic [PTR_WIDTH-1:0] wq2_rptr_wire, rq2_wptr_wire;
    logic [ADDR_SIZE-1:0] waddr_wire, raddr_next_wire;

    w_fifo_ctrl #(
        .ADDR_SIZE(ADDR_SIZE)
    ) w_fifo_ctrl(
        .wclk(wclk),
        .winc(winc),
        .wrst(wrst),
        .wq2_rptr(wq2_rptr_wire),
        .wclken(wclken),
        .wptr(wptr_wire),
        .waddr(waddr_wire),
        .wfull(wfull)
    );

    r_fifo_ctrl #(
        .ADDR_SIZE(ADDR_SIZE)
    ) r_fifo_ctrl(
        .rclk(rclk),
        .rinc(rinc),
        .rrst(rrst),
        .rq2_wptr(rq2_wptr_wire),
        .rclken(rclken),
        .rptr(rptr_wire),
        .raddr_next(raddr_next_wire),
        .rempty(rempty),
        .rvalid(rvalid)
    );

    // sync pointers across domains
    syn_ptr #(
        .PTR_WIDTH(PTR_WIDTH)
    ) wptr(
        .clk(rclk),
        .rst(rrst),
        .ptr_in(wptr_wire),
        .syn_ptr(rq2_wptr_wire)
    );
    syn_ptr #(
        .PTR_WIDTH(PTR_WIDTH)
    ) rptr(
        .clk(wclk),
        .rst(wrst),
        .ptr_in(rptr_wire),
        .syn_ptr(wq2_rptr_wire)
    );

    fifo_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_SIZE(ADDR_SIZE)
    ) fifo_memory(
        .wclk(wclk),
        .wrst(wrst),
        .wclken(wclken),
        .waddr(waddr_wire),
        .rclk(rclk),
        .rrst(rrst),
        .rclken(rclken),
        // Use next read address so rdata is prefetched and aligned with rvalid (registered read)
        .raddr(raddr_next_wire),
        .wdata(wdata),
        .rdata(rdata)
    );

endmodule
