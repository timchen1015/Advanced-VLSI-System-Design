module syn_ptr #(
parameter int PTR_WIDTH = 1
)(
    input  clk,
    input  rst,
    input  [PTR_WIDTH-1:0] ptr_in,   // input gray code
    output logic [PTR_WIDTH-1:0] syn_ptr // output gray code
);

logic [PTR_WIDTH-1:0] ptr_reg;  // first stage synchronizer
logic [PTR_WIDTH-1:0] ptr_reg2; // second stage synchronizer

// double flop to cross clock domains safely
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        ptr_reg  <= '0;
        ptr_reg2 <= '0;
    end
    else begin
        ptr_reg  <= ptr_in;
        ptr_reg2 <= ptr_reg;
    end
end

assign syn_ptr = ptr_reg2;

endmodule
