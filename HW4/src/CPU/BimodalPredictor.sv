// ============================================================================
// Bimodal Branch Predictor (2-bit saturating counters + simple BTB)
// ============================================================================
// - Direct-mapped table indexed by PC bits [INDEX_BITS+1:2] (word-aligned)
// - Each entry holds: valid, tag, 2-bit counter, target address
// - Predict phase (combinational):
//     hit = valid && tag match
//     predict_taken = hit && (counter[1] == 1)
//     predict_target = stored target (undefined if not hit)
// - Update phase (sequential on clk):
//     on update_valid (for the resolving branch PC), write tag/target/valid
//     and bump 2-bit counter toward taken/not-taken based on outcome.
//
// Notes:
// - Designed to be simple and self-contained. External logic decides when
//   to update (typically when a conditional branch is resolved in EXE stage).
// - Target is updated even on not-taken to keep last-known target fresh.
// ============================================================================

module BimodalPredictor #(
	parameter ENTRIES    = 16,
	parameter USE_GSHARE = 1'b1,
	parameter GHR_BITS   = 2,
	parameter [1:0] INIT_COUNTER = 2'b11,
	parameter ALLOCATE_ON_TAKEN = 1'b1,
	parameter COLD_SEED_BTFNT   = 1'b1,
	parameter FILTER_REDUNDANT_TARGETS = 1'b1
) (
	input  logic clk,
	input  logic rst,

	// Lookup (IF stage)
	input  logic [`RegBus] req_pc,
	output logic                        predict_taken,
	output logic [`RegBus] predict_target,
	output logic                        predict_hit,

	// Update (on branch resolution in EXE)
	input  logic                        update_valid,   // 1 for a resolved conditional branch
	input  logic [`RegBus] update_pc,   // PC of the branch instruction
	input  logic                        update_taken,   // actual outcome
	input  logic [`RegBus] update_target // actual target (PC+imm)
);

	// Derived widths
	localparam int INDEX_BITS = $clog2(ENTRIES);
	localparam int TAG_BITS   = 32 - INDEX_BITS - 2;

	// Tables
	logic [1:0]          ctr_table   [ENTRIES-1:0];
	logic                valid_table [ENTRIES-1:0];
	logic [TAG_BITS-1:0] tag_table   [ENTRIES-1:0];
	logic [`RegBus]      target_table[ENTRIES-1:0];

	// Global History Register (for gshare)
	logic [GHR_BITS-1:0] ghr;

	// Fold/align GHR to INDEX_BITS
	function [INDEX_BITS-1:0] fold_ghr(input logic [GHR_BITS-1:0] g);
		logic [INDEX_BITS-1:0] r;
		integer j;
		integer idx;
		begin
			r = '0;
			if (GHR_BITS <= INDEX_BITS) begin
				// Simple zero-extend when history fits into index width
				r[GHR_BITS-1:0] = g;
			end else begin
				// Fold by XOR with a wrap-around index (no modulo operator)
				idx = 0;
				for (j = 0; j < GHR_BITS; j++) begin
					r[idx] = r[idx] ^ g[j];
					idx = (idx == (INDEX_BITS-1)) ? 0 : (idx + 1);
				end
			end
			return r;
		end
	endfunction

	// Indexing helpers
	function [INDEX_BITS-1:0] pc_index(input logic [31:0] pc);
		return pc[INDEX_BITS+1:2];
	endfunction

	function [TAG_BITS-1:0] tag(input logic [31:0] pc);
		return pc[31:INDEX_BITS+2];
	endfunction

	// Combinational predict path
	logic [INDEX_BITS-1:0] pht_index, btb_index;
	logic [TAG_BITS-1:0]   req_tag;
	logic                  hit;
	logic [1:0]            ctr;

	always_comb begin
		btb_index = pc_index(req_pc);
		pht_index = USE_GSHARE ? (pc_index(req_pc) ^ fold_ghr(ghr)) : btb_index;
		req_tag   = tag(req_pc);

		hit       = valid_table[btb_index] && (tag_table[btb_index] == req_tag);
		ctr       = ctr_table[pht_index];

		predict_hit    = hit;
		predict_taken  = hit && ctr[1];
		predict_target = target_table[btb_index];
	end

	// Pre-compute update path signals combinationally
	logic [INDEX_BITS-1:0] u_btb_index;
	logic [INDEX_BITS-1:0] u_pht_index;
	logic [TAG_BITS-1:0]   utag;
	logic                  old_valid;
	logic [TAG_BITS-1:0]   old_tag;
	logic                  will_allocate;
	logic [`RegBus]        pc_plus4;

	always_comb begin
		u_btb_index = pc_index(update_pc);
		u_pht_index = USE_GSHARE ? (pc_index(update_pc) ^ fold_ghr(ghr)) : u_btb_index;
		utag        = tag(update_pc);
		old_valid   = valid_table[u_btb_index];
		old_tag     = tag_table[u_btb_index];
		pc_plus4    = update_pc + `DataWidth'd4;
		will_allocate = (!old_valid || (old_tag != utag)) && (ALLOCATE_ON_TAKEN ? update_taken : 1'b1);
		if (FILTER_REDUNDANT_TARGETS && will_allocate) begin
			if ((update_target == pc_plus4) || (update_target == `ZeroWord)) begin
				will_allocate = 1'b0;
			end
		end
	end

	// Initialize and sequential updates
	integer i;
	always_ff @(posedge clk) begin
		if (rst) begin
			for (i = 0; i < ENTRIES; i++) begin
				ctr_table[i]    <= INIT_COUNTER; // initial bias
				valid_table[i]  <= 1'b0;
				tag_table[i]    <= '0;
				target_table[i] <= `ZeroWord;
			end
			ghr <= '0;
		end else if (update_valid) begin
			// Allocate/refresh BTB on policy
			if (will_allocate) begin
				valid_table[u_btb_index]  <= 1'b1;
				tag_table[u_btb_index]    <= utag;
				target_table[u_btb_index] <= update_target;
			end else if (old_valid && (old_tag == utag) && update_taken) begin
				// Refresh target on matching tag if taken (keeps target hot)
				target_table[u_btb_index] <= update_target;
			end

			// Cold-start seeding using BTFNT if this is a new allocation
			if (COLD_SEED_BTFNT && will_allocate) begin
				if (update_target < pc_plus4) begin
					// Backward: seed strongly taken
					ctr_table[u_pht_index] <= 2'b11;
				end else begin
					// Forward: seed strongly not taken
					ctr_table[u_pht_index] <= 2'b00;
				end
			end else begin
				// Normal 2-bit saturating counter update in PHT
				unique case (update_taken)
					1'b1: ctr_table[u_pht_index] <= (ctr_table[u_pht_index] == 2'b11) ? 2'b11 : (ctr_table[u_pht_index] + 2'b01);
					1'b0: ctr_table[u_pht_index] <= (ctr_table[u_pht_index] == 2'b00) ? 2'b00 : (ctr_table[u_pht_index] - 2'b01);
				endcase
			end

			// Non-speculative GHR update (on resolution)
			ghr <= {ghr[GHR_BITS-2:0], update_taken};
		end
	end

endmodule

