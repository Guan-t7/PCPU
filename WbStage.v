module WbStage (
    input [31:0] alu_out,
    input [31:0] d,
    input M2REG,
    input [31:0] inst, // dbg
    input [31:0] pc, // dbg
    
    output [31:0] RegDataIn
	);

MUX2T1_32  u_MUX2T1_32 (
    .I0                      ( alu_out   ),
    .I1                      ( d   ),
    .s                       ( M2REG    ),

    .o                       ( RegDataIn    )
);

endmodule