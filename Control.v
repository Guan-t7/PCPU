// *Extended support: see mips_define.instructions
module Control(
    input [5:0] opcode,
    input [5:0] funct,
    input RSRTEQU,

    output JAL,
    output LUI,
    output WREG,
    output M2REG,
    output RMEM,
    output WMEM,
    output reg [2:0] ALU_Ctr,
    output ALUIMM,
    output SHIFT,
    output SEXT,
    output REGRT,
    output JR,
    output JUMP,
    output BRANCH,
    output WPCIR,
    output need_rs,
    output need_rt
    );
// parsing R-instr
wire ALURR = opcode==6'b0;
wire add = ALURR & funct==6'b100000;
wire sub = ALURR & funct==6'b100010;
wire and_ = ALURR & funct==6'b100100;
wire or_ = ALURR & funct==6'b100101;
wire xor_ = ALURR & funct==6'b100110;
wire sll = ALURR & funct==6'b000000;    //! special dta
wire srl = ALURR & funct==6'b000010;    //! special dta
wire slt = ALURR & funct==6'b101010;
wire jr = ALURR & funct==6'b001000;
wire jalr = ALURR & funct==6'b001001;   // R-type
// parsing J,I-instr
wire addi = opcode==6'b001000;
wire andi = opcode==6'b001100;
wire ori = opcode==6'b001101;
wire xori = opcode==6'b001110;
wire lw = opcode==6'b100011;
wire sw = opcode==6'b101011;
wire lui = opcode==6'b001111;
wire slti = opcode==6'b001010;
wire beq = opcode==6'b000100;
wire bne = opcode==6'b000101;   // I-type
wire j = opcode==6'b000010;
wire jal = opcode==6'b000011;   // J-type
wire eret = opcode==6'b010000;
// oprand arrangement
wire dst = add | sub | and_ | or_ | xor_ | slt;
wire sto = beq | bne;
wire tsi = addi | slti | andi | ori | xori;
wire S = jr | jalr;
wire dta = sll | srl;
// Datapath control
assign JAL = jal | jalr;
assign LUI = lui;
assign WREG = ~(j | jr | beq | bne | sw | eret);
assign RMEM = lw;
assign WMEM = sw;
assign ALUIMM = SEXT | (andi | ori | xori);
assign SHIFT = sll | srl;
assign SEXT = addi | lw | sw | slti;
assign REGRT = ALUIMM | lui;
assign JR = jr | jalr;
assign JUMP = j | jal;
assign BRANCH = beq & RSRTEQU | bne & ~RSRTEQU | JR | JUMP; //! pc to another basic block; bad name
assign WPCIR = 1'b1;
assign M2REG = lw;

always @* begin
    if (and_ | andi) ALU_Ctr = 0;
    else if (or_ | ori) ALU_Ctr = 1;
    else if (add | addi | lw | sw) ALU_Ctr = 2;
    else if (xor_ | xori) ALU_Ctr = 3;
    else if (sll) ALU_Ctr = 4;
    else if (srl) ALU_Ctr = 5;
    else if (sub) ALU_Ctr = 6;
    else if (slt | slti) ALU_Ctr = 7;
    else ALU_Ctr = 'bx;
end
// oprand dependency
assign need_rs = dst | sto | sw | tsi | lw | S;
assign need_rt = dst | sto | sw | dta;

endmodule