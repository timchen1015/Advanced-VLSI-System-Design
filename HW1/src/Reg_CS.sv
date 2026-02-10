module Reg_CS (
	input  logic        clk,
	input  logic        rst,
	input  logic        instret_en,
	input  logic        is_instret,
	input  logic        cs_high_bit,
	output logic [31:0] cs_out
);
logic [63:0] cycle_count_q;
logic [63:0] instret_count_q;
logic [63:0] csr_value;
localparam logic [63:0] INSTRET_PIPELINE_OFFSET = 64'd3;					// Adjust for pipeline latency

always_ff @(posedge clk) begin
	if (rst) begin
		cycle_count_q <= 64'd0;
	end else begin
		cycle_count_q <= cycle_count_q + 64'd1;
	end
end

// Instruction retire counter increments only when a valid instruction retires
always_ff @(posedge clk) begin
	if (rst) begin
		instret_count_q <= 64'd0;
	end else if (instret_en) begin
		instret_count_q <= instret_count_q + 64'd1;
	end
end
always_comb begin
  if (is_instret) begin
    if (instret_count_q > INSTRET_PIPELINE_OFFSET)
      csr_value = instret_count_q - INSTRET_PIPELINE_OFFSET;
    else
      csr_value = instret_count_q;
  end else begin
    csr_value = cycle_count_q;
  end
  cs_out = cs_high_bit ? csr_value[63:32] : csr_value[31:0];
end
endmodule
