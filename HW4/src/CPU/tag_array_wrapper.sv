module tag_array_wrapper (
    input CK,
    input rstn,
    input CS,
    input OE,             //read
    input WEB,            //write
    input set_to_change,
    input [4:0] A,
    input [22:0] DI,
    output logic [22:0] DO1,
    output logic [22:0] DO2
);

logic [31:0] bWEB0, bWEB1;
logic [31:0] valid0, valid1;
logic [31:0] reg_DO1, reg_DO2;

always_ff @( posedge CK or negedge rstn ) begin 
    if(~rstn)begin
        valid0 <= 32'd0;
        valid1 <= 32'd0;
    end
    else if(~(|bWEB0[22:0]))begin
        valid0[A] <= 1'b1;
        valid1 <= valid1;
    end
    else if(~(|bWEB1[22:0]))begin
        valid1[A] <= 1'b1;
        valid0 <= valid0;
    end
    else begin
        valid0 <= valid0;
        valid1 <= valid1;
    end
end

assign DO1 = (valid0[A]) ? reg_DO1[22:0] : 23'd0;
assign DO2 = (valid1[A]) ? reg_DO2[22:0] : 23'd0;

always_comb begin 
    if(~WEB)begin
        if(set_to_change)begin
            bWEB1 = {9'h1ff, 23'h0};
            bWEB0 = 32'hffff_ffff;
        end
        else begin
            bWEB0 = {9'h1ff, 23'h0};
            bWEB1 = 32'hffff_ffff;
        end
    end
    else begin
        bWEB0 = 32'hffff_ffff;
        bWEB1 = 32'hffff_ffff;
    end
end

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_tag_array i_tag_array1 (          //0
    .CLK        (CK),
    .A          (A),
    .CEB        (CS),           // chip enable, active LOW
    .WEB        (bWEB0[0]),     // write:LOW, read:HIGH
    .BWEB       (bWEB0),        // bitwise write enable write:LOW
    .D          ({9'd0,DI}),    // Data into RAM
    .Q          (reg_DO1),      // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_tag_array i_tag_array2 (          //1
    .CLK        (CK),
    .A          (A),
    .CEB        (CS),           // chip enable, active LOW
    .WEB        (bWEB1[0]),     // write:LOW, read:HIGH
    .BWEB       (bWEB1),        // bitwise write enable write:LOW
    .D          ({9'd0,DI}),    // Data into RAM
    .Q          (reg_DO2),      // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );

endmodule
