module ExStage (
    // A, B
    input [31:0] FQ1,
    input [31:0] FQ2,
    input [31:0] EXT_imm16,
    input SHIFT,
    input ALUIMM,
    // 
    input [2:0] ALU_Ctr,
    // res
    input [31:0] pc_p4,
    input JAL,
    input [31:0] inst,
    input LUI,
    
    output [31:0] alu_out,
    output [31:0] A, // dbg
    output [31:0] B // dbg
	);

MUX2T1_32  AMUX (
    .I0                      ( FQ1   ),
    .I1                      ( EXT_imm16   ),
    .s                       ( SHIFT    ),

    .o                       ( A   )
);
MUX2T1_32  BMUX (
    .I0                      ( FQ2   ),
    .I1                      ( EXT_imm16   ),
    .s                       ( ALUIMM    ),

    .o                       ( B    )
);
// wrapping
wire [31:0] ALU_O;
ALU_Org  ALU (
    .A(A), 
    .B(B), 
    .ALU_Ctr(ALU_Ctr), 
    .overflow(), 
    .res(ALU_O), 
    .zero()
);

assign alu_out = 
    JAL ? pc_p4 :
    LUI ? {inst[15:0], 16'b0} : 
    ALU_O;

endmodule