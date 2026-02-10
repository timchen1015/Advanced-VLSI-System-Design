module HazardDetectionUnit (
    input  logic               branch_redirect,
    input  logic               EXE_MemRead,

    input  logic [`RegAddrBus] rs1_addr,
    input  logic [`RegAddrBus] rs2_addr,
    input  logic [`RegAddrBus] EXE_rd_addr,

    output logic               PCWrite,
    output logic               IF_Flush,
    output logic               ID_Flush, // Because we branch in EXE

    input  logic               IM_stall,
    input  logic               DM_stall,
    output logic               Hazardstall_flag,

    output logic               IF_ID_Reg_Write,
    output logic               ID_EXE_Reg_Write,
    output logic               EXE_MEM_Reg_Write,
    output logic               MEM_WB_Reg_Write,

    // CSR signals
    input  logic               CSR_stall,
    input  logic               CSR_ret,
    input  logic               CSR_rst,

    output logic [        1:0] CSR_type
);

logic lw_use;
assign lw_use = EXE_MemRead & ((EXE_rd_addr == rs1_addr) | (EXE_rd_addr == rs2_addr)); 
// when an R-format instruction following a load tries to use the data

assign Hazardstall_flag = IM_stall | DM_stall;

logic control_hazard;
assign control_hazard = branch_redirect;

// always_comb
// begin
//     if(Hazardstall_flag)
//     begin
//         PCWrite           = 1'b0;
//         IF_Flush          = 1'b0;
//         ID_Flush          = 1'b0;
//         IF_ID_Reg_Write   = 1'b0;
//         ID_EXE_Reg_Write  = 1'b0;
//         EXE_MEM_Reg_Write = 1'b0;
//         MEM_WB_Reg_Write  = 1'b0;
//     end
//     else if(PCSrc != 2'b00) //branch taken
//     begin
//         PCWrite           = 1'b1;
//         IF_Flush          = 1'b1;
//         ID_Flush          = 1'b1;
//         IF_ID_Reg_Write   = 1'b1;
//         ID_EXE_Reg_Write  = 1'b1;
//         EXE_MEM_Reg_Write = 1'b1;
//         MEM_WB_Reg_Write  = 1'b1;
//     end
//     else if(lw_use)         //load-use hazard
//     begin
//         PCWrite           = 1'b0;
//         IF_Flush          = 1'b0;
//         ID_Flush          = 1'b1;
//         IF_ID_Reg_Write   = 1'b0;
//         ID_EXE_Reg_Write  = 1'b1;
//         EXE_MEM_Reg_Write = 1'b1;
//         MEM_WB_Reg_Write  = 1'b1;
//     end
//     else
//     begin
//         PCWrite           = 1'b1;
//         IF_Flush          = 1'b0;
//         ID_Flush          = 1'b0;
//         IF_ID_Reg_Write   = 1'b1;
//         ID_EXE_Reg_Write  = 1'b1;
//         EXE_MEM_Reg_Write = 1'b1;
//         MEM_WB_Reg_Write  = 1'b1;
//     end
// end

assign PCWrite           = ~(IM_stall | DM_stall | CSR_stall | lw_use);
assign IF_Flush          =   control_hazard | CSR_ret | CSR_rst;
assign ID_Flush          =   control_hazard | CSR_ret | CSR_rst | lw_use;
assign IF_ID_Reg_Write   = ~(IM_stall | DM_stall | CSR_stall | lw_use);
assign ID_EXE_Reg_Write  = ~(IM_stall | DM_stall | CSR_stall);
assign EXE_MEM_Reg_Write = ~(IM_stall | DM_stall | CSR_stall);
assign MEM_WB_Reg_Write  = ~(IM_stall | DM_stall | CSR_stall);

always_comb
begin
    if(branch_redirect)
        CSR_type = 2'd1;
    else if(lw_use)
        CSR_type = 2'd2;
    else
        CSR_type = 2'd0;
end

endmodule