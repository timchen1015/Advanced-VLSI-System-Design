module BranchControl (
    input  logic                  branch_taken_flag,
    input  logic [`BranchTypeBus] branch_signal,
    input  logic                  branch_prediction,
    input  logic                  branch_predict_hit,
    input  logic [        `RegBus] predicted_target,
    input  logic [        `RegBus] pc_plus4,
    input  logic [        `RegBus] pc_imm,
    input  logic [        `RegBus] pc_imm_rs1,

    output logic                  redirect_valid,
    output logic [        `RegBus] redirect_pc,
    output logic                  branch_mispredict
);

// Branch type encodings
localparam [`BranchTypeBus] No_Branch   = 2'b00,
                            JALR_Branch = 2'b01,
                            B_Branch    = 2'b10,
                            J_Branch    = 2'b11;

always_comb begin
    redirect_valid   = 1'b0;
    redirect_pc      = pc_plus4;
    branch_mispredict = 1'b0;

    unique case (branch_signal)
        No_Branch: begin
            redirect_valid    = 1'b0;
            branch_mispredict = 1'b0;
            redirect_pc       = pc_plus4;
        end

        JALR_Branch: begin
            redirect_valid    = 1'b1;
            redirect_pc       = pc_imm_rs1;
            branch_mispredict = 1'b0;
        end

        B_Branch: begin
            logic prediction_taken;
            prediction_taken = branch_prediction & branch_predict_hit;

            if (branch_taken_flag) begin
                if (!prediction_taken || (predicted_target != pc_imm)) begin
                    redirect_valid    = 1'b1;
                    redirect_pc       = pc_imm;
                    branch_mispredict = 1'b1;
                end
            end else if (prediction_taken) begin
                redirect_valid    = 1'b1;
                redirect_pc       = pc_plus4;
                branch_mispredict = 1'b1;
            end
        end

        J_Branch: begin
            redirect_valid    = 1'b1;
            redirect_pc       = pc_imm;
            branch_mispredict = 1'b0;
        end

        default: begin
            redirect_valid    = 1'b0;
            redirect_pc       = pc_plus4;
            branch_mispredict = 1'b0;
        end
    endcase
end

endmodule