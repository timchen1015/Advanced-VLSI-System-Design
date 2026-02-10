module IF_ProgramCounter (
    input  logic clk,
    input  logic rst,

    //Control
    input  logic PCWrite,

    //I/O
    input  logic [`RegBus] PC_in,
    output logic [`RegBus] PC_out,

    input  logic [`RegBus] CSR_return_PC,
    input  logic [`RegBus] CSR_ISR_PC,
    input  logic           CSR_interrupt,
    input  logic           CSR_ret,
    input  logic           CSR_rst
);

logic csr_int_sync_ff1;
logic csr_int_sync_ff2;
logic csr_int_sync_ff3;
logic ISR_reg_result;

always_ff @ (posedge clk)
begin
    if (rst) begin
        csr_int_sync_ff1 <= 1'b0;
        csr_int_sync_ff2 <= 1'b0;
        csr_int_sync_ff3 <= 1'b0;
    end else begin
        // two-flop synchronizer plus a one-cycle history for edge detection
        csr_int_sync_ff1 <= CSR_interrupt;
        csr_int_sync_ff2 <= csr_int_sync_ff1;
        csr_int_sync_ff3 <= csr_int_sync_ff2;
    end
end

assign ISR_reg_result = csr_int_sync_ff2 & ~csr_int_sync_ff3;

always_ff @ (posedge clk)
begin
    if(rst)
        PC_out <= `StartAddress;
    else if(CSR_rst)
        PC_out <= `StartAddress;
    else if(CSR_ret)
        PC_out <= CSR_return_PC;
    else if(ISR_reg_result)
        PC_out <= CSR_ISR_PC;
    else if(PCWrite)
        PC_out <= PC_in;
    else
        PC_out <= PC_out;
end

endmodule