module Decoder (
    input  logic [`AXI_ADDR_BITS-1:0] ADDR_M,
    // VALID
    input  logic                      VALID_M,
    output logic                      VALID_S0,
    output logic                      VALID_S1,
    output logic                      VALID_S2,
    output logic                      VALID_S3,
    output logic                      VALID_S4,
    output logic                      VALID_S5,

    // READY
    input  logic                      READY_S0,
    input  logic                      READY_S1,
    input  logic                      READY_S2,
    input  logic                      READY_S3,
    input  logic                      READY_S4,
    input  logic                      READY_S5,
    output logic                      READY_S
);

always_comb
begin
    VALID_S0 = 1'b0;
    VALID_S1 = 1'b0;
    VALID_S2 = 1'b0;
    VALID_S3 = 1'b0;
    VALID_S4 = 1'b0;
    VALID_S5 = 1'b0;
    READY_S  = 1'b0;

    unique casez(ADDR_M[31:16])
        16'h0000: //ROM
        begin
            VALID_S0 = VALID_M;
            READY_S = (VALID_M) ? READY_S0 : 1'b0;
        end

        16'h0001: //IM
        begin
            VALID_S1 = VALID_M;
            READY_S = (VALID_M) ? READY_S1 : 1'b0;
        end

        16'h0002: //DM
        begin
            VALID_S2 = VALID_M;
            READY_S = (VALID_M) ? READY_S2 : 1'b0;
        end

        16'h1002: //DMA
        begin
            if(ADDR_M[15:0] <= 16'h0400)
            begin
                VALID_S3 = VALID_M;
                READY_S = (VALID_M) ? READY_S3 : 1'b0;
            end
        end

        16'h1001: //WDT
        begin
            if(ADDR_M[15:0] <= 16'h03FF)
            begin         
                VALID_S4 = VALID_M;
                READY_S = (VALID_M) ? READY_S4 : 1'b0;
            end
        end

        16'h20??: //DRAM
        begin
            if(ADDR_M[23:0] <= 24'h1F_FFFF)
            begin         
                VALID_S5 = VALID_M;
                READY_S = (VALID_M) ? READY_S5 : 1'b0;
            end
        end
        
        default:
        begin
            VALID_S0 = 1'b0;
            VALID_S1 = 1'b0;
            VALID_S2 = 1'b0;
            VALID_S3 = 1'b0;
            VALID_S4 = 1'b0;
            VALID_S5 = 1'b0;
            READY_S  = 1'b0;
        end
    endcase
end

endmodule
