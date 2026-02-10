module fifo_memory #(
    parameter int DATA_WIDTH = 51,
    parameter int ADDR_SIZE  = 1  // depth = 2**ADDR_SIZE (ADDR_SIZE=1 => depth=2)
)(
    input        wclk,
    input        wrst,
    input        wclken,
    input  [ADDR_SIZE-1:0] waddr,
    input        rclk,
    input        rrst,
    input        rclken,
    input  [ADDR_SIZE-1:0] raddr,

    input [DATA_WIDTH-1:0] wdata,

    output logic [DATA_WIDTH-1:0] rdata
);

localparam int DEPTH = (1 << ADDR_SIZE);

logic [DATA_WIDTH-1:0] memory [0:DEPTH-1];
integer i;

//write fifo
always_ff @(posedge wclk or posedge wrst) begin
    if(wrst)begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            memory[i] <= '0;
        end
    end
    else if(wclken)begin
        memory[waddr] <= wdata;
    end
end

// Registered read on rclk domain (1 clock latency)
always_ff @(posedge rclk or posedge rrst) begin
    if (rrst) begin
        rdata <= '0;
    end
    else begin
        rdata <= memory[raddr];
    end
end

endmodule
