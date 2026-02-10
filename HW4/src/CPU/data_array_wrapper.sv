module data_array_wrapper (
    input CK,
    input rstn,
    input CS,
    input OE,
    input set_to_change,
    input [15:0] WEB,
    input [4:0] A,
    input [127:0] DI,
    output logic [127:0] DO1,
    output logic [127:0] DO2
);

logic [63:0] bWEB00, bWEB01, bWEB10, bWEB11, DO1_tmp1, DO1_tmp2, DO2_tmp1, DO2_tmp2; 
logic [1:0] wire_WEB;
logic web00, web01, web10, web11;

logic [31:0] valid0, valid1;
logic [127:0] reg_DO1, reg_DO2;

always_ff @( posedge CK or negedge rstn ) begin 
    if(~rstn)begin
        valid0 <= 32'd0;
        valid1 <= 32'd0;
    end
    else if(web00 | web01)begin
        valid0[A] <= 1'b1;
        valid1 <= valid1;
    end
    else if(web10 | web11)begin
        valid1[A] <= 1'b1;
        valid0 <= valid0;
    end
    else begin
        valid0 <= valid0;
        valid1 <= valid1;
    end
end

assign reg_DO1 = (valid0[A]) ? DO1 : 128'd0;
assign reg_DO2 = (valid1[A]) ? DO2 : 128'd0;

localparam [1:0] MISS = 2'b00,
                 WRITE = 2'b01,
                 READ = 2'b10;

assign wire_WEB = (WEB == 16'd0) ? MISS : (WEB != 16'hffff) ? WRITE : READ; 
assign DO1 = {DO1_tmp2, DO1_tmp1};
assign DO2 = {DO2_tmp2, DO2_tmp1};

always_comb begin 
    case (wire_WEB)
        MISS : begin
            if(set_to_change)begin
                bWEB10 = 64'd0;
                bWEB11 = 64'd0;
                bWEB00 = 64'hffffffffffffffff;
                bWEB01 = 64'hffffffffffffffff;
                web10 = 1'b0;
                web11 = 1'b0;
                web00 = 1'b1;
                web01 = 1'b1;
            end
            else begin
                bWEB00 = 64'd0;
                bWEB01 = 64'd0;
                bWEB10 = 64'hffffffffffffffff;
                bWEB11 = 64'hffffffffffffffff;
                web00 = 1'b0;
                web01 = 1'b0;
                web10 = 1'b1;
                web11 = 1'b1;
            end
        end
        WRITE : begin
            if(set_to_change)begin
                bWEB10 = {{8{WEB[7]}}, {8{WEB[6]}}, {8{WEB[5]}}, {8{WEB[4]}}, {8{WEB[3]}}, {8{WEB[2]}}, {8{WEB[1]}}, {8{WEB[0]}}};
                bWEB11 = {{8{WEB[15]}}, {8{WEB[14]}}, {8{WEB[13]}}, {8{WEB[12]}}, {8{WEB[11]}}, {8{WEB[10]}}, {8{WEB[9]}}, {8{WEB[8]}}};
                bWEB00 = 64'hffffffffffffffff;
                bWEB01 = 64'hffffffffffffffff;
                web10 = WEB[7] & WEB[6] & WEB[5] & WEB[4] & WEB[3] & WEB[2] & WEB[1] & WEB[0];
                web11 = WEB[15] & WEB[14] & WEB[13] & WEB[12] & WEB[11] & WEB[10] & WEB[9] & WEB[8];
                web00 = 1'b1;
                web01 = 1'b1;
            end
            else begin
                bWEB10 = 64'hffffffffffffffff;
                bWEB11 = 64'hffffffffffffffff;
                bWEB00 = {{8{WEB[7]}}, {8{WEB[6]}}, {8{WEB[5]}},{ 8{WEB[4]}}, {8{WEB[3]}}, {8{WEB[2]}}, {8{WEB[1]}}, {8{WEB[0]}}};
                bWEB01 = {{8{WEB[15]}}, {8{WEB[14]}}, {8{WEB[13]}}, {8{WEB[12]}}, {8{WEB[11]}}, {8{WEB[10]}}, {8{WEB[9]}}, {8{WEB[8]}}};
                web10 = 1'b1;
                web11 = 1'b1;
                web00 = WEB[7] & WEB[6] & WEB[5] & WEB[4] & WEB[3] & WEB[2] & WEB[1] & WEB[0];
                web01 = WEB[15] & WEB[14] & WEB[13] & WEB[12] & WEB[11] & WEB[10] & WEB[9] & WEB[8];
            end
        end
        default : begin
            bWEB10 = 64'hffffffffffffffff;
            bWEB11 = 64'hffffffffffffffff;
            bWEB00 = 64'hffffffffffffffff;
            bWEB01 = 64'hffffffffffffffff;
            web10 = 1'b1;
            web11 = 1'b1;
            web00 = 1'b1;
            web01 = 1'b1;
        end 
    endcase
end


  TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array1_1 (
    .CLK        (CK),
    .A          (A),
    .CEB        (CS),  // chip enable, active LOW
    .WEB        (web00),  // write:LOW, read:HIGH
    .BWEB       (bWEB00),  // bitwise write enable write:LOW
    .D          (DI[63:0]),  // Data into RAM
    .Q          (DO1_tmp1),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );
  
  
    TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array1_2 (
    .CLK        (CK),
    .A          (A),
    .CEB        (CS),  // chip enable, active LOW
    .WEB        (web01),  // write:LOW, read:HIGH
    .BWEB       (bWEB01),  // bitwise write enable write:LOW
    .D          (DI[127:64]),  // Data into RAM
    .Q          (DO1_tmp2),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array2_1 (
    .CLK        (CK),
    .A          (A),
    .CEB        (CS),  // chip enable, active LOW
    .WEB        (web10),  // write:LOW, read:HIGH
    .BWEB       (bWEB10),  // bitwise write enable write:LOW
    .D          (DI[63:0]),  // Data into RAM
    .Q          (DO2_tmp1),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );
  
  TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array2_2 (
    .CLK        (CK),
    .A          (A),
    .CEB        (CS),  // chip enable, active LOW
    .WEB        (web11),  // write:LOW, read:HIGH
    .BWEB       (bWEB11),  // bitwise write enable write:LOW
    .D          (DI[127:64]),  // Data into RAM
    .Q          (DO2_tmp2),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );


endmodule
