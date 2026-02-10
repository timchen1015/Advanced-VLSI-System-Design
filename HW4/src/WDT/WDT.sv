module WDT (
    // Single clock/reset domain version: runs entirely in clk2/rstn2
    input  logic        clk2,    // WDT clock domain
    input  logic        rstn2,   // active-low reset synchronized to clk2

    // Controls and reload value (same domain as clk2)
    input  logic        WDEN,
    input  logic        WDLIVE,
    input  logic [31:0] WTOCNT,

    // Timeout output (clk2 domain)
    output logic        WTO
);

// -----------------------------------------------------------------------------
// Summary of approach
// 1) Clock Domain: This module operates entirely in the 'clk2' domain.
// 2) CDC Handling: All control inputs (WDEN, WDLIVE, WTOCNT) are assumed to 
//    be synchronized to 'clk2' via AFIFO.
// 3) Reload Logic: WTOCNT is sampled into WTOCNT_clk2 for counter initialization.
// 4) WTO Generation: Timeout output (WTO) is asserted only when cur_state is 
//    TIMEOUT and WDT is still enabled (WDEN).
// -----------------------------------------------------------------------------

// -------------------------------
// Reload register in clk2 domain
// -------------------------------
logic [31:0] WTOCNT_clk2; // reload value used by the WDT counter (clk2 domain)
always_ff @ (posedge clk2)
begin
    if(!rstn2)
        WTOCNT_clk2 <= 32'd0;
    else
        WTOCNT_clk2 <= WTOCNT; // simple write in same clock domain
end

// -------------------------------
// WDT state machine and counter (runs in clk2 domain)
// -------------------------------
typedef enum logic [1:0] {
	INIT,
	CNTDOWN,
	RSTCNT,
	TIMEOUT
} WDT_state_t;

WDT_state_t cur_state, next_state;

logic [31:0] WDT_cnt;

logic  cnt_is_zero;
assign cnt_is_zero = (WDT_cnt == 32'd0);

always_ff @ (posedge clk2)
begin
    if(!rstn2)
        cur_state <= INIT;
    else
        cur_state <= next_state;
end

always_comb
begin
    unique case(cur_state)
        INIT:
        begin
            if(WDEN)
                next_state = CNTDOWN;
            else if(WDLIVE)                             // Feed dog: reset counter
                next_state = RSTCNT;
            else
                next_state = INIT;
        end

        CNTDOWN:
            next_state = (cnt_is_zero) ? TIMEOUT : CNTDOWN;

        RSTCNT:
            next_state = INIT;                          // go to INIT to reload value

        TIMEOUT:
            next_state = (WDEN) ? INIT : TIMEOUT;       // Restart if enabled; else hold TIMEOUT until WDT is disabled.

        default:
            next_state = INIT;
    endcase
end

//counter logic
always_ff @ (posedge clk2)
begin
    if(!rstn2)
        WDT_cnt <= 32'd0;
    else
    begin
        unique case(cur_state)
            INIT:    WDT_cnt <= WTOCNT_clk2; // load reload value
            CNTDOWN: WDT_cnt <= (WDLIVE) ? WTOCNT_clk2 : (WDT_cnt - 32'd1);
            RSTCNT:  WDT_cnt <= 32'd0;
            TIMEOUT: WDT_cnt <= WDT_cnt;
        endcase
    end
end

// WTO output (clk2 domain)
always_ff @ (posedge clk2)
begin
    if(!rstn2)
        WTO <= 1'b0;
    else
        WTO <= (cur_state == TIMEOUT) & WDEN;
end

endmodule