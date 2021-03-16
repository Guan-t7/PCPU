module MemStage (
    input clk,
    input [31:0] alu_out,
    input [31:0] FQ2,
    input WMEM,
    input RMEM,
    
    output [31:0] d,
    output stall
	);

wire cs = RMEM | WMEM;

wire [31:0] mem_douta;
wire mem_ack, mem_cs, mem_wea;
wire  [9:0]  mem_addra;
wire  [31:0]  mem_dina;

CMU #(
    .INDEX_W ( 2    ))
 data_cache (
    .clka                    ( clk          ),
    .cs                      ( cs        ),
    .wea                     ( WMEM         ),
    .addra                   ( alu_out[2+:10]       ),
    .dina                    ( FQ2        ),
    .mem_douta               ( mem_douta   ),
    .mem_ack                 ( mem_ack     ),

    .douta                   ( d       ),
    .ack                     ( ack         ),
    .mem_cs                  ( mem_cs      ),
    .mem_wea                 ( mem_wea     ),
    .mem_addra               ( mem_addra   ),
    .mem_dina                ( mem_dina    )
);

data_ram  u_data_ram (
    .clka                    ( clk  ),
    .cs                      ( mem_cs     ),
    .wea                     ( mem_wea    ),
    .addra                   ( mem_addra   ),
    .dina                    ( mem_dina    ),

    .douta                   ( mem_douta   ),
    .ack                     ( mem_ack     )
);

assign stall = cs & ~ack;
//TODO CE for holding data_ram

endmodule