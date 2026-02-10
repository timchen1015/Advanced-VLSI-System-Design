// --------------------------------------------------
// - Arbitrates concurrent requests from multiple masters to a single slave
// - Alternates priority between three masters after each address handshake by Round-Robin
// - Does not depend on R/B completion (handled elsewhere by outstanding control)
// --------------------------------------------------

module Arbiter (
    input  logic clk,
    input  logic rstn,

    // Master 0
    input  logic [  `AXI_ID_BITS-1:0] ID_M0,
    input  logic [`AXI_ADDR_BITS-1:0] ADDR_M0,
    input  logic [ `AXI_LEN_BITS-1:0] LEN_M0,
    input  logic [`AXI_SIZE_BITS-1:0] SIZE_M0,
    input  logic [               1:0] BURST_M0,
    input  logic                      VALID_M0,
    output logic                      READY_M0,

    // Master 1
    input  logic [  `AXI_ID_BITS-1:0] ID_M1,
    input  logic [`AXI_ADDR_BITS-1:0] ADDR_M1,
    input  logic [ `AXI_LEN_BITS-1:0] LEN_M1,
    input  logic [`AXI_SIZE_BITS-1:0] SIZE_M1,
    input  logic [               1:0] BURST_M1,
    input  logic                      VALID_M1,
    output logic                      READY_M1,

    // Master 2 DMA
    input  logic [  `AXI_ID_BITS-1:0] ID_M2,
    input  logic [`AXI_ADDR_BITS-1:0] ADDR_M2,
    input  logic [ `AXI_LEN_BITS-1:0] LEN_M2,
    input  logic [`AXI_SIZE_BITS-1:0] SIZE_M2,
    input  logic [               1:0] BURST_M2,
    input  logic                      VALID_M2,
    output logic                      READY_M2,

    // Slaves
    input  logic                      READY_S,

    // Select Master outputs to slave
    output logic [ `AXI_IDS_BITS-1:0] IDS_M,
    output logic [`AXI_ADDR_BITS-1:0] ADDR_M,
    output logic [ `AXI_LEN_BITS-1:0] LEN_M,
    output logic [`AXI_SIZE_BITS-1:0] SIZE_M,
    output logic [               1:0] BURST_M,
    output logic                      VALID_M
);

logic [2:0] master; // Selected master (001 = M0, 010 = M1, 100 = M2)
logic [1:0] last_winner; // 0 = M0 won last, 1 = M1 won last, 2 = M2 won last

// --------------------------------------------------
// Arbitration logic (Round-Robin)
// --------------------------------------------------
always_comb begin
    master = 3'b000;
    case (last_winner)
        2'd0: begin // last M0 -> try M1, M2, M0
            if (VALID_M1) master = 3'b010;
            else if (VALID_M2) master = 3'b100;
            else if (VALID_M0) master = 3'b001;
        end
        2'd1: begin // last M1 -> try M2, M0, M1
            if (VALID_M2) master = 3'b100;
            else if (VALID_M0) master = 3'b001;
            else if (VALID_M1) master = 3'b010;
        end
        default: begin // last M2 -> try M0, M1, M2
            if (VALID_M0) master = 3'b001;
            else if (VALID_M1) master = 3'b010;
            else if (VALID_M2) master = 3'b100;
        end
    endcase
end

// --------------------------------------------------
// Output multiplexer
// --------------------------------------------------
always_comb begin
    READY_M0 = 1'b0;
    READY_M1 = 1'b0;
    READY_M2 = 1'b0;

    IDS_M   = {4'd0, `AXI_ID_BITS'b0};
    ADDR_M  = `AXI_ADDR_BITS'b0;
    LEN_M   = `AXI_LEN_BITS'b0;
    SIZE_M  = `AXI_SIZE_BITS'b0;
    BURST_M = 2'b0;
    VALID_M = 1'b0;

    unique case (master)
        3'b001: begin
            READY_M0 = READY_S;
            IDS_M    = {4'b0001, ID_M0};
            ADDR_M   = ADDR_M0;
            LEN_M    = LEN_M0;
            SIZE_M   = SIZE_M0;
            BURST_M  = BURST_M0;
            VALID_M  = VALID_M0;
        end
        3'b010: begin
            READY_M1 = READY_S;
            IDS_M    = {4'b0010, ID_M1};
            ADDR_M   = ADDR_M1;
            LEN_M    = LEN_M1;
            SIZE_M   = SIZE_M1;
            BURST_M  = BURST_M1;
            VALID_M  = VALID_M1;
        end
        3'b100: begin
            READY_M2 = READY_S;
            IDS_M    = {4'b0100, ID_M2};
            ADDR_M   = ADDR_M2;
            LEN_M    = LEN_M2;
            SIZE_M   = SIZE_M2;
            BURST_M  = BURST_M2;
            VALID_M  = VALID_M2;
        end
        default: begin end
    endcase
end

// --------------------------------------------------
// Update last_winner on address handshake
// --------------------------------------------------
wire addr_hit = READY_S && VALID_M;

always_ff @(posedge clk) begin
    if (!rstn)
        last_winner <= 2'd0;
    else if (addr_hit) begin
        case (master)
            3'b001: last_winner <= 2'd0;
            3'b010: last_winner <= 2'd1;
            3'b100: last_winner <= 2'd2;
            default: last_winner <= last_winner;
        endcase
    end
end

endmodule

