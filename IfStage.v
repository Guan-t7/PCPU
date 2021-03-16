module IfStage (
    input clk,
    input rst,
    // pc
	input [31:0] id_target,
    input id_BRANCH,
	input CE,
    
    // pc
    output [31:0] pc, // dbg
    output [31:0] pc_p4,
    // 
    output [31:0] inst,
    output stall
	);

// --------------------------------------
wire [31:0] pc_in;

MUX2T1_32  PCMUX (
    .I0                      ( pc_p4   ),
    .I1                      ( id_target   ),
    .s                       ( id_BRANCH    ),

    .o                       ( pc_in    )
);

REG32  PC (
    .clk                     ( clk   ),
    .rst                     ( rst   ),
    .CE                      ( CE    ),
    .D                       ( pc_in     ),

    .Q                       ( pc     )
);

ADD32  p4 (
    .A                       ( pc   ),
    .B                       ( 32'd4   ),

    .S                       ( pc_p4   )
);

// --------------------------------------
wire cs = 1'b1;
wire [31:0] mem_douta;
wire mem_ack, mem_cs;
wire  [9:0]  mem_addra;

CMU #(
    .INDEX_W ( 3    ))
 inst_cache (
    .clka                    ( clk          ),
    .cs                      ( cs        ),
    .wea                     ( 1'b0         ),
    .addra                   ( pc[2+:10]       ),
    .dina                    ( 'bx        ),
    .mem_douta               ( mem_douta   ),
    .mem_ack                 ( mem_ack     ),

    .douta                   ( inst       ),
    .ack                     ( ack         ),
    .mem_cs                  ( mem_cs      ),
    .mem_wea                 (     ),
    .mem_addra               ( mem_addra   ),
    .mem_dina                (     )
);

inst_rom  u_inst_rom (
    .clka                    ( clk   ),
    .cs                      ( mem_cs     ),
    .a                       ( mem_addra     ),

    .spo                     ( mem_douta   ),
    .ack                     ( mem_ack    )
);

assign stall = cs & ~ack;
// TODO verify: 
// ROM read be restarted with new address in case of id_BRANCH

endmodule