module MEM_Stage (
    //----------------From EXE/MEM Register----------------//

    //------------ Control signals------------//
    input  logic                   MEM_MEM_rd_sel,
    input  logic                   MEM_MemRead,
    input  logic                   MEM_MemWrite,
    //------------ Control signals------------//

    input  logic [`FUNCTION_3-1:0] MEM_funct3,

    input  logic [        `RegBus] MEM_PC_sel_out,
    input  logic [        `RegBus] MEM_ALU_final,
    input  logic [        `RegBus] MEM_EXE_mux_rs2_data,

    //----------------From EXE/MEM Register----------------//

    //---------------------Data Memory---------------------//
    output logic [       `BWEBBus] DM_BWEB,       //Bit write enable (active low)
    output logic [   `DataAddrBus] Data_addr,
    input  logic [       `DataBus] Data_in,
    output logic [       `DataBus] Data_out,      
    //---------------------Data Memory---------------------//

    // below are output signals or data
    output logic [        `RegBus] MEM_rd_data,   /*one of the final outputs, offers forwarding*/
    output logic [        `RegBus] DM_rd_data     /*one of the final outputs*/
);

localparam  from_ALU = 1'b0,
            from_PC  = 1'b1;

//DM
always_comb
begin
    DM_BWEB = `INACTIVE;
    
    if(MEM_MemWrite)
    begin
        unique case (MEM_funct3)
            3'b000:  DM_BWEB[{MEM_ALU_final[1:0] , 3'd0} +: 8]  = 8'd0;      //SB           when Data_addr moves 32'd1, it moves 1byte(8bits)
            3'b001:  DM_BWEB[{MEM_ALU_final[1]   , 4'd0} +:16]  = 16'd0;     //SH
            3'b010:  DM_BWEB                                    = `ZeroWord; //SW & FSW
            default: DM_BWEB                                    = `INACTIVE;
        endcase
    end
    else
        DM_BWEB = `INACTIVE;
end

assign Data_addr = MEM_ALU_final;

always_comb
begin
    Data_out = `ZeroWord; //reset value

    if(MEM_MemWrite)
    begin
        unique case (MEM_funct3)
            3'b000:  Data_out[{MEM_ALU_final[1:0] , 3'd0} +: 8] = MEM_EXE_mux_rs2_data[7:0];  //SB
            3'b001:  Data_out[{MEM_ALU_final[1]   , 4'd0} +:16] = MEM_EXE_mux_rs2_data[15:0]; //SH
            3'b010:  Data_out                                   = MEM_EXE_mux_rs2_data;       //SW & FSW
            default: Data_out                                   = `ZeroWord;
        endcase
    end
    else
        Data_out = `ZeroWord;
end

always_comb
begin
    unique case(MEM_MEM_rd_sel)
        from_ALU: MEM_rd_data = MEM_ALU_final;
        from_PC : MEM_rd_data = MEM_PC_sel_out;
        default : MEM_rd_data = `ZeroWord;
    endcase
end

always_comb
begin
    unique case (MEM_funct3)
        3'b000: //LB(signed)
        begin
            unique case(MEM_rd_data[1:0])
                2'b00:
                    DM_rd_data = {{24{Data_in[7]}},  Data_in[7:0]};
                2'b01:
                    DM_rd_data = {{24{Data_in[15]}}, Data_in[15:8]};
                2'b10:
                    DM_rd_data = {{24{Data_in[23]}}, Data_in[23:16]};
                2'b11:
                    DM_rd_data = {{24{Data_in[31]}}, Data_in[31:24]};
                default:
                    DM_rd_data = `ZeroWord;
            endcase
        end

        3'b001: //LH
        begin
            unique case(MEM_rd_data[1])
                1'b0:
                    DM_rd_data = {{16{Data_in[15]}}, Data_in[15:0]};
                1'b1:
                    DM_rd_data = {{16{Data_in[31]}}, Data_in[31:16]};
                default:
                    DM_rd_data = `ZeroWord;
            endcase
        end     
        
        3'b010: //LW & FLW
            DM_rd_data = Data_in; 

        3'b100: //LBU
        begin
            unique case(MEM_rd_data[1:0])
                2'b00:
                    DM_rd_data = {{24{1'b0}}, Data_in[7:0]};
                2'b01:
                    DM_rd_data = {{24{1'b0}}, Data_in[15:8]};
                2'b10:
                    DM_rd_data = {{24{1'b0}}, Data_in[23:16]};
                2'b11:
                    DM_rd_data = {{24{1'b0}}, Data_in[31:24]};
            endcase
        end

        3'b101: //LHU
        begin
            unique case(MEM_rd_data[1])
                1'b0:
                    DM_rd_data = {{16{1'b0}}, Data_in[15:0]};
                1'b1:
                    DM_rd_data = {{16{1'b0}}, Data_in[31:16]};
            endcase
        end

        default:
            DM_rd_data = `ZeroWord;
    endcase
end

endmodule