module Reset_Sync (
    input  logic clk,
    input  logic rst,
    output logic rstn_sync
);

logic sync_stage1;
logic sync_stage2;

// Stage 1: capture async reset into clock domain
always_ff @(posedge clk or posedge rst)
begin
    if (rst)
        sync_stage1 <= 1'b0;
    else
        sync_stage1 <= 1'b1;
end

// Stage 2: synchronize reset deassertion
always_ff @(posedge clk or posedge rst)
begin
    if (rst)
        sync_stage2 <= 1'b0;
    else
        sync_stage2 <= sync_stage1;
end

assign rstn_sync = sync_stage2;

endmodule
