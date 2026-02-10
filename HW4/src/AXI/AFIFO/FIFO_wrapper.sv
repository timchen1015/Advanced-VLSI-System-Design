module FIFO_wrapper #(
       parameter int DATA_WIDTH = 51,
       parameter int ADDR_SIZE  = 1  // depth = 2**ADDR_SIZE. Default 1 => depth=2.
)(
       input wclk,
       input wrst,
       input rclk,
       input rrst,
       input [DATA_WIDTH-1:0] wdata,
       input VALID_w,
       input READY_r,

       output logic [DATA_WIDTH-1:0] rdata,
       output logic  READY_w,
       output logic  VALID_r
);

logic wfull;
logic rempty;
logic rvalid;

FIFO #(
       .DATA_WIDTH(DATA_WIDTH),
       .ADDR_SIZE(ADDR_SIZE)
) FIFO(
       .wclk(wclk),
       .wrst(wrst),
       .winc(VALID_w),
       .rclk(rclk),
       .rrst(rrst),
       .rinc(READY_r),
       .wdata(wdata),
       //output
       .wfull(wfull),
       .rdata(rdata),
       .rempty(rempty),
       .rvalid(rvalid)
);

assign READY_w = (~wfull);

assign VALID_r = rvalid;


endmodule
