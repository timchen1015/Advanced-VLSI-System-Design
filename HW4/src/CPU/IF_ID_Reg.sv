module IF_ID_Reg (
    input  logic clk,
    input  logic rst,

    //control
    input  logic                   IF_ID_Reg_Write, //Stall or not
    input  logic                   IF_Flush,        //Flush or not

    //---------------------------------data pass in---------------------------------//
    input  logic [        `RegBus] IF_ID_PC_out,
    input  logic [`InstructionBus] IF_ID_instruction,
    input  logic                   IF_ID_branch_prediction,
    input  logic [        `RegBus] IF_ID_predicted_target,
    input  logic                   IF_ID_predict_hit,

    //---------------------------------data pass out---------------------------------//
    output logic [        `RegBus] ID_PC_out,
    output logic [`InstructionBus] ID_instruction,
    output logic                   ID_branch_prediction,
    output logic [        `RegBus] ID_predicted_target,
    output logic                   ID_predict_hit
);

always_ff @ (posedge clk)
begin
    if(rst)
    begin
        ID_PC_out       <= `ZeroWord;
        ID_instruction  <= `NOP;
        ID_branch_prediction <= 1'b0;
        ID_predicted_target  <= `ZeroWord;
        ID_predict_hit       <= 1'b0;
    end
    else if(IF_ID_Reg_Write)
    begin
        if (IF_Flush)
        begin
            ID_PC_out            <= `ZeroWord;
            ID_instruction       <= `NOP;
            ID_branch_prediction <= 1'b0;
            ID_predicted_target  <= `ZeroWord;
            ID_predict_hit       <= 1'b0;
        end
        else
        begin
            ID_PC_out            <= IF_ID_PC_out;
            ID_instruction       <= IF_ID_instruction;
            ID_branch_prediction <= IF_ID_branch_prediction;
            ID_predicted_target  <= IF_ID_predicted_target;
            ID_predict_hit       <= IF_ID_predict_hit;
        end
    end
    else
    begin
        ID_PC_out       <= ID_PC_out;
        ID_instruction  <= ID_instruction;
        ID_branch_prediction <= ID_branch_prediction;
        ID_predicted_target  <= ID_predicted_target;
        ID_predict_hit       <= ID_predict_hit;
    end
end

endmodule