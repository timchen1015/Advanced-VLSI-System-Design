`include "../include/defines.svh"
module HazardUnit(
  input  logic        D_use_rs1,
  input  logic        D_use_rs2,
  input  logic        D_rs1_float,
  input  logic        D_rs2_float,
  input  logic [`ADDR_WIDTH-1:0]  rs1_idx,
  input  logic [`ADDR_WIDTH-1:0]  rs2_idx,
  input  logic        E_use_rd,
  input  logic        E_use_rs1,
  input  logic        E_use_rs2,
  input  logic        E_rs1_float,
  input  logic        E_rs2_float,
  input  logic [`ADDR_WIDTH-1:0]  E_rs1_idx,
  input  logic [`ADDR_WIDTH-1:0]  E_rs2_idx,
  input  logic [`ADDR_WIDTH-1:0]  E_rd_idx,
  input  logic [`MAJOR_OPCODE_WIDTH-1:0]  E_opcode,
  input  logic        M_use_rd,
  input  logic        M_use_rs2,
  input  logic        M_rd_float,
  input  logic        M_rs2_float,
  input  logic [`ADDR_WIDTH-1:0]  M_rd_idx,
  input  logic [`ADDR_WIDTH-1:0]  M_rs2_idx,
  input  logic        W_use_rd,
  input  logic        W_rd_float,
  input  logic [`ADDR_WIDTH-1:0]  W_rd_idx,
  output logic        stall,
  output logic        D_rs1_data_sel,
  output logic        D_rs2_data_sel,
  output logic [1:0]  E_rs1_data_sel,
  output logic [1:0]  E_rs2_data_sel,
  output logic        M_rs2_data_sel
);

  logic has_w_rd;
  logic has_m_rd;
  logic has_e_rd;

  logic rs1_hits_w_rd;
  logic rs2_hits_w_rd;
  logic e_rs1_hits_w_rd;
  logic e_rs2_hits_w_rd;
  logic m_rs2_hits_w_rd;
  logic rs1_hits_e_rd;
  logic rs2_hits_e_rd;
  logic rs1_hits_m_rd;
  logic rs2_hits_m_rd;

  logic is_D_rs1_E_rd_hazard;
  logic is_D_rs2_E_rd_hazard;
  logic is_E_rs1_W_rd_hazard;
  logic is_E_rs1_M_rd_hazard;
  logic is_E_rs2_W_rd_hazard;
  logic is_E_rs2_M_rd_hazard;

  assign has_w_rd = W_use_rd && (W_rd_idx != `ZERO_REG);
  assign has_m_rd = M_use_rd && (M_rd_idx != `ZERO_REG);
  assign has_e_rd = E_use_rd && (E_rd_idx != `ZERO_REG);

  assign rs1_hits_w_rd   = (rs1_idx  == W_rd_idx);
  assign rs2_hits_w_rd   = (rs2_idx  == W_rd_idx);
  assign e_rs1_hits_w_rd = (E_rs1_idx == W_rd_idx);
  assign e_rs2_hits_w_rd = (E_rs2_idx == W_rd_idx);
  assign m_rs2_hits_w_rd = (M_rs2_idx == W_rd_idx);
  assign rs1_hits_e_rd   = (rs1_idx  == E_rd_idx);
  assign rs2_hits_e_rd   = (rs2_idx  == E_rd_idx);
  assign rs1_hits_m_rd   = (E_rs1_idx == M_rd_idx);
  assign rs2_hits_m_rd   = (E_rs2_idx == M_rd_idx);

  //D_rs1_W_rd_hazard
  assign D_rs1_data_sel = has_w_rd && D_use_rs1 &&
                                (D_rs1_float == W_rd_float) && rs1_hits_w_rd;
  //D_rs2_W_rd_hazard
  assign D_rs2_data_sel = has_w_rd && D_use_rs2 &&
                                (D_rs2_float == W_rd_float) && rs2_hits_w_rd;
  
  assign is_E_rs1_W_rd_hazard = has_w_rd && E_use_rs1 &&
                                (E_rs1_float == W_rd_float) && e_rs1_hits_w_rd;
  assign is_E_rs1_M_rd_hazard = has_m_rd && E_use_rs1 &&
                                (E_rs1_float == M_rd_float) && rs1_hits_m_rd;

  assign is_E_rs2_W_rd_hazard = has_w_rd && E_use_rs2 &&
                                (E_rs2_float == W_rd_float) && e_rs2_hits_w_rd;
  assign is_E_rs2_M_rd_hazard = has_m_rd && E_use_rs2 &&
                                (E_rs2_float == M_rd_float) && rs2_hits_m_rd;

  //M_rs2_W_rd_hazard
  assign M_rs2_data_sel = has_w_rd && M_use_rs2 &&
                                (M_rs2_float == W_rd_float) && m_rs2_hits_w_rd;

  assign E_rs1_data_sel = is_E_rs1_M_rd_hazard ? 2'b01 :
                          is_E_rs1_W_rd_hazard ? 2'b10 :
                                                  2'b00;

  assign E_rs2_data_sel = is_E_rs2_M_rd_hazard ? 2'b01 :
                          is_E_rs2_W_rd_hazard ? 2'b10 :
                                                  2'b00;

  assign is_D_rs1_E_rd_hazard = has_e_rd && D_use_rs1 && rs1_hits_e_rd;
  assign is_D_rs2_E_rd_hazard = has_e_rd && D_use_rs2 && rs2_hits_e_rd;

  // stall for load-use hazard(f-load include)
  assign stall = ((E_opcode == `I_TYPE_LOAD) || (E_opcode == `F_TYPE_LOAD)) &&
                 (is_D_rs1_E_rd_hazard || is_D_rs2_E_rd_hazard);

endmodule

