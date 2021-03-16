module IdStage (
    input clk,
    // if
    input [31:0] inst,
    input [31:0] pc_p4,
    // id.reg_File
    input [4:0] debug_addr, // dbg
    // forward, stall
    input ex_WREG,
    input [4:0] ex_nd,
    input ex_M2REG,
    input [31:0] ex_alu_out,
    input mem_WREG,
    input [4:0] mem_nd,
    input mem_M2REG,
    input [31:0] mem_alu_out,
    input [31:0] mem_d,
    // wb
    input [4:0] wb_nd,
    input [31:0] wb_RegDataIn,
    input wb_WREG,

    // if
    output [31:0] target,
    output BRANCH,
    // id.reg_File
    output [4:0] rs, // dbg
    output [4:0] rt, // dbg
    output [31:0] debug_data, // dbg
    output [31:0] Q1, // dbg
    output [31:0] Q2, // dbg
    // forward, stall
    output reg [1:0] FWDA,
    output reg [1:0] FWDB,
    output reg FQ1_stall, 
    output reg FQ2_stall,
    output stall,
    // ex
    output [31:0] FQ1,
    output [31:0] FQ2,
    output [31:0] EXT_imm16, // dbg
    output [2:0] ALU_Ctr,
    output ALUIMM,
    output SHIFT,
    output JAL,
    output LUI,
    // mem
    output RMEM,
    output WMEM,
    // wb
    output [4:0] nd,
    output M2REG,
    output WREG
	);

wire RSRTEQU;
wire [5:0] opcode = inst[31:26], funct = inst[5:0];
assign rs = inst[25:21], rt = inst[20:16];
wire [4:0] rd = inst[15:11];
wire [15:0] imm = inst[15:0];
// ----------core instr parsing----------
Control  u_Control (
    .opcode                  ( opcode    ),
    .funct                   ( funct     ),
    .RSRTEQU                 ( RSRTEQU   ),

    .JAL                     ( JAL       ),
    .LUI                     ( LUI       ),
    .WREG                    ( WREG      ),
    .M2REG                   ( M2REG     ),
    .RMEM                    ( RMEM      ),
    .WMEM                    ( WMEM      ),
    .ALU_Ctr                 ( ALU_Ctr   ),
    .ALUIMM                  ( ALUIMM    ),
    .SHIFT                   ( SHIFT     ),
    .SEXT                    ( SEXT      ),
    .REGRT                   ( REGRT     ),
    .JR                      ( JR        ),
    .JUMP                    ( JUMP      ),
    .BRANCH                  ( BRANCH    ),
    .WPCIR                   ( WPCIR     ),
    .need_rs                 ( need_rs   ),
    .need_rt                 ( need_rt   )
);
// --------------------------------------
Reg_File  reg_File (
    .clk                     ( ~clk       ), //! Read after Write
    .SR1                     ( rs       ),
    .SR2                     ( rt       ),
    .DR                      ( wb_nd        ),
    .WReg                    ( wb_WREG      ),
    .Data_in                 ( wb_RegDataIn   ),

    .SR1_OUT                 ( Q1   ),
    .SR2_OUT                 ( Q2   ),

    .debug_addr(debug_addr),
    .debug_data(debug_data)
);
// ------------forward, stall------------
always @(*) begin
    FWDA = 0;
    FQ1_stall = 0;
    if (rs && need_rs) begin
        if (ex_WREG && ex_nd == rs) begin
            if (ex_M2REG) FQ1_stall = 1;
            else FWDA = 1;
        end
        else if (mem_WREG && mem_nd == rs) begin
            FWDA = mem_M2REG ? 3 : 2;
        end
    end

    FWDB = 0;
    FQ2_stall = 0;
    if (rt && need_rt) begin
        if (ex_WREG && ex_nd == rt) begin
            if (ex_M2REG) FQ2_stall = 1;
            else FWDB = 1;
        end
        else if (mem_WREG && mem_nd == rt) begin
            FWDB = mem_M2REG ? 3 : 2;
        end
    end
end

MUX4T1_32  FQ1MUX (
    .I0                      ( Q1   ),
    .I1                      ( ex_alu_out   ),
    .I2                      ( mem_alu_out   ),
    .I3                      ( mem_d   ),
    .s                       ( FWDA    ),

    .o                       ( FQ1   )
);
MUX4T1_32  FQ2MUX (
    .I0                      ( Q2   ),
    .I1                      ( ex_alu_out   ),
    .I2                      ( mem_alu_out   ),
    .I3                      ( mem_d   ),
    .s                       ( FWDB    ),

    .o                       ( FQ2   )
);
assign RSRTEQU = (FQ1==FQ2);
assign stall = FQ1_stall | FQ2_stall;
// --------------EXT_imm16---------------
wire [31:0] SEXT_imm16, ZEXT_imm16;
SEXT_32  sEXT_32 (
    .imm_16                  ( imm   ),

    .imm_32                  ( SEXT_imm16[31:0]   )
);
ZEXT_32  zEXT_32 (
    .imm_16                  ( imm   ),

    .imm_32                  ( ZEXT_imm16[31:0]   )
);
MUX2T1_32  IMMMUX (
    .I0                      ( ZEXT_imm16   ),
    .I1                      ( SEXT_imm16   ),
    .s                       ( SEXT    ),

    .o                       ( EXT_imm16    )
);
// ------------------nd------------------
wire [4:0] DRMUX1_O;
MUX2T1_5  DRMUX1 (
    .I0                      ( rd   ),
    .I1                      ( rt   ),
    .s                       ( REGRT    ),

    .o                       ( DRMUX1_O   )
);
MUX2T1_5  DRMUX2 (
    .I0                      ( DRMUX1_O   ),
    .I1                      ( 5'd31   ),
    .s                       ( JAL    ),

    .o                       ( nd    )
);
// -----------------flow-----------------
wire [31:0] br_offs, br_addr;
shiftleft2  u_shiftleft2 (
    .in_(SEXT_imm16), 
    .out_(br_offs)
);
ADD32  aDD32 (
    .A(pc_p4), 
    .B(br_offs), 
    .S(br_addr)
);

wire [31:0] PCMUX1_O;
MUX2T1_32  PCMUX1 (
    .I0                      ( br_addr   ),
    .I1                      ( {pc_p4[31:28], inst[25:0], 2'b0}   ),
    .s                       ( JUMP    ),

    .o                       ( PCMUX1_O   )
);
MUX2T1_32  PCMUX2 (
    .I0                      ( PCMUX1_O   ),
    .I1                      ( FQ1   ),
    .s                       ( JR    ),

    .o                       ( target    )
);

endmodule