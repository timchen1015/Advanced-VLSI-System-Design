`include "../include/defines.svh"
module FPU(
  input  logic [`FUNCT5_WIDTH-1:0]  funct5,
  input  logic [`DATA_WIDTH-1:0] op1,
  input  logic [`DATA_WIDTH-1:0] op2,
  output logic [`DATA_WIDTH-1:0] frd
);

logic is_sub;
assign is_sub = (funct5 == `FSUB_S);                        

// Unpack
logic        s1, s2;        // sign
logic [7:0]  e1, e2;        // exponent
logic [22:0] f1, f2;        // fraction

assign s1 = op1[31]; 
assign e1 = op1[30:23]; 
assign f1 = op1[22:0];
assign s2 = op2[31];
assign e2 = op2[30:23]; 
assign f2 = op2[22:0];


// Extend (hidden bit)
logic [23:0] f1_extend, f2_extend;
assign f1_extend = { (e1!=8'd0), f1 };
assign f2_extend = { (e2!=8'd0), f2 };    

// Effective signs (FSUB flips op2)
logic  s1_eff, s2_eff;
assign s1_eff = s1;
assign s2_eff = s2 ^ is_sub;

// Pick big/small 
logic        swap;
logic        sb, ss;           // signs after effective op applied
logic [7:0]  eb, es;
logic [23:0] fb, fs;


assign swap = (e2 > e1) || ((e2==e1) && (f2_extend > f1_extend));
assign    sb   = swap ? s2_eff : s1_eff;    
assign    ss   = swap ? s1_eff : s2_eff;     
assign    eb   = swap ? e2 : e1;             
assign    es   = swap ? e1 : e2;            
assign    fb   = swap ? f2_extend : f1_extend; 
assign    fs   = swap ? f1_extend : f2_extend; 

// Align smaller with G/R/X and sticky
logic [7:0]  ediff;                       // exponent difference
logic [26:0] fs_ext, fs_shifted, fs_mask; // mantissa + G/R/X lanes and mask
logic        sticky_s;                    // OR of discarded bits (sticky)
logic [26:0] fb_ext;

// align smaller (with 3 zeros to keep [26]=int)
assign ediff  = eb - es;
assign fs_ext = {fs, 3'b000};            // {mant, G, R, X}
assign fb_ext = {fb, 3'b000};

always_comb begin
    if (ediff == 8'd0) begin
      fs_shifted = fs_ext;
      sticky_s   = 1'b0;
      fs_mask    = 27'd0;
    end else if (ediff < 8'd27) begin
      fs_shifted = fs_ext >> ediff;
      fs_mask    = ((27'd1 << ediff) - 27'd1);    // low ediff bits = 1
      sticky_s   = |(fs_ext & fs_mask);           // OR of shifted-out bits
    end else begin
      fs_shifted = 27'd0;
      sticky_s   = |fs_ext;                       // everything discarded
      fs_mask    = 27'h7FFFFFF;                   // all bits
    end
end

// Effective add/sub
logic        eff_sub;          // 1: subtract magnitudes, 0: add magnitudes
assign eff_sub = (sb ^ ss);

logic [27:0] add_res;          // adder result: {carry[27], aligned significand sum/diff[26:0] incl. G/R/X}; 
assign add_res = (!eff_sub) ? ({1'b0, fb_ext} + {1'b0, fs_shifted}) : ({1'b0, fb_ext} - {1'b0, fs_shifted});
logic        s_res;            // sign of result (+0 for exact zero)
assign s_res = (add_res==28'd0) ? 1'b0 : sb;

// Normalize (pre-round)
logic [7:0]  e_res;
logic [26:0] frac_norm;        // [26]=int, [25:3]=frac23, [2]=G, [1]=R, [0]=X
logic        sticky_all;
logic [4:0] lzc;

always_comb begin
    //default
    lzc = 5'd0;
    // normalize (pre-round)
    if (!eff_sub) begin
      // addition: may carry by 1 (bit 27)
      if (add_res[27]) begin
        e_res      = eb + 8'd1;
        frac_norm  = add_res[27:1];            // >>1
        sticky_all = add_res[0] | sticky_s;
      end else begin
        e_res      = eb;
        frac_norm  = add_res[26:0];
        sticky_all = sticky_s;
      end
    end else begin
      // subtraction: may need left normalize
      if (add_res[26:0] == 27'd0) begin
        e_res      = 8'd0;
        frac_norm  = 27'd0;
        sticky_all = 1'b0;
      end else begin
        for (int k=26; k>=0; k=k-1) begin
          if (add_res[k]) begin
            lzc = 5'(26 - k);
            break;
          end
        end
        e_res      = (eb > lzc) ? (eb - lzc) : 8'd0; // lab: ignore UF
        frac_norm  = add_res[26:0] << lzc;
        sticky_all = 1'b0;                            // left shift keeps bits
      end
    end
end

  // Round (RNE)
  logic [22:0] frac23;
  logic        guard_bit, round_bit, sticky;
  logic        incr;
  logic [23:0] frac_plus;
  logic [7:0]  e_final;
  logic [22:0] f_final;

  assign frac23    = frac_norm[25:3];                // normalized 23-bit fraction (no hidden bit);
  assign guard_bit = frac_norm[2];
  assign round_bit = frac_norm[1];
  assign sticky    = sticky_all | frac_norm[0];
  assign incr      = guard_bit & (round_bit | sticky | frac23[0]);
  assign frac_plus = {1'b0, frac23} + incr;
  assign e_final   = (frac_plus[23]) ? (e_res + 8'd1) : e_res;
  assign f_final   = (frac_plus[23]) ? frac_plus[23:1] : frac_plus[22:0];

  // Pack
  logic [31:0] res_packed;
  always_comb begin
    if ((e_final==8'd0) && (f_final==23'd0))
      res_packed = 32'h0000_0000;
    else
      res_packed = {s_res, e_final, f_final};
  end

  assign frd = (funct5 == `FADD_S || funct5 == `FSUB_S) ? res_packed : 32'd0;

endmodule
