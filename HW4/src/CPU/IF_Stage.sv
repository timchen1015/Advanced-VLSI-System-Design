module IF_Stage (
    input  logic clk,
    input  logic rst,

    // Hazard/branch control inputs
    input  logic              PCWrite,
    input  logic              redirect_valid,
    input  logic [   `RegBus] redirect_pc,

    // Predictor update inputs from EXE stage
    input  logic              predictor_update_valid,
    input  logic [   `RegBus] predictor_update_pc,
    input  logic              predictor_update_taken,
    input  logic [   `RegBus] predictor_update_target,

    output logic [   `RegBus] IF_ID_PC_out, // To IM and IF/ID Register

    output logic              instruction_fetch_sig,

    // Predictor metadata propagated down the pipe
    output logic              IF_ID_branch_prediction,
    output logic [   `RegBus] IF_ID_predicted_target,
    output logic              IF_ID_predict_hit,

    input  logic [   `RegBus] CSR_return_PC,
    input  logic [   `RegBus] CSR_ISR_PC,
    input  logic              CSR_stall,   
    input  logic              CSR_interrupt,
    input  logic              CSR_ret,
    input  logic              CSR_rst
);

assign instruction_fetch_sig = ~CSR_stall;

logic [`RegBus] PC_4;
assign PC_4 = IF_ID_PC_out + `DataWidth'd4;

logic [`RegBus] PC_in;

// -----------------------------------------------------------------------------
// Bimodal predictor instance
// -----------------------------------------------------------------------------
logic              predict_taken;
logic              predict_hit;
logic [`RegBus]    predict_target;

BimodalPredictor i_BimodalPredictor (
    .clk                (clk),
    .rst                (rst),
    .req_pc             (IF_ID_PC_out),
    .predict_taken      (predict_taken),
    .predict_target     (predict_target),
    .predict_hit        (predict_hit),
    .update_valid       (predictor_update_valid),
    .update_pc          (predictor_update_pc),
    .update_taken       (predictor_update_taken),
    .update_target      (predictor_update_target)
);

assign IF_ID_branch_prediction = predict_taken;
assign IF_ID_predicted_target  = predict_target;
assign IF_ID_predict_hit       = predict_hit;

// Next PC selection
always_comb begin
    if (redirect_valid)
        PC_in = redirect_pc;
    else if (predict_taken)
        PC_in = predict_target;
    else
        PC_in = PC_4;
end

//ProgramCounter//
IF_ProgramCounter i_IF_ProgramCounter(
    .clk(clk),
    .rst(rst),
    .PCWrite(PCWrite),
    .PC_in(PC_in),
    .PC_out(IF_ID_PC_out),

    .CSR_return_PC(CSR_return_PC),
    .CSR_ISR_PC(CSR_ISR_PC),
    .CSR_interrupt(CSR_interrupt),
    .CSR_ret(CSR_ret),
    .CSR_rst(CSR_rst)
);

endmodule