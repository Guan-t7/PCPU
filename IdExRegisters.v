module IdExRegisters (
    input clk,
    input rst,
    input CE,
    input id_WMEM,
    input id_WREG,
    input [31:0] id_pc,
    input id_JAL,
    input id_M2REG,
    input [31:0] id_FQ1,
    input id_LUI,
    input [2:0] id_ALU_Ctr,
    input id_SHIFT,
    input [31:0] id_inst,
    input id_ALUIMM,
    input [31:0] id_pc_p4,
    input [4:0] id_nd,
    input id_RMEM,
    input [31:0] id_EXT_imm16,
    input [31:0] id_FQ2,
    output reg ex_WMEM,
    output reg ex_WREG,
    output reg [31:0] ex_pc,
    output reg ex_JAL,
    output reg ex_M2REG,
    output reg [31:0] ex_FQ1,
    output reg ex_LUI,
    output reg [2:0] ex_ALU_Ctr,
    output reg ex_SHIFT,
    output reg [31:0] ex_inst,
    output reg ex_ALUIMM,
    output reg [31:0] ex_pc_p4,
    output reg [4:0] ex_nd,
    output reg ex_RMEM,
    output reg [31:0] ex_EXT_imm16,
    output reg [31:0] ex_FQ2
    );
    always @(posedge clk) begin
        if (rst) begin
            ex_WMEM <= 0;
            ex_WREG <= 0;
            ex_pc <= 0;
            ex_JAL <= 0;
            ex_M2REG <= 0;
            ex_FQ1 <= 0;
            ex_LUI <= 0;
            ex_ALU_Ctr <= 0;
            ex_SHIFT <= 0;
            ex_inst <= 0;
            ex_ALUIMM <= 0;
            ex_pc_p4 <= 0;
            ex_nd <= 0;
            ex_RMEM <= 0;
            ex_EXT_imm16 <= 0;
            ex_FQ2 <= 0;
        end 
        else if (CE) begin
            ex_WMEM <= id_WMEM;
            ex_WREG <= id_WREG;
            ex_pc <= id_pc;
            ex_JAL <= id_JAL;
            ex_M2REG <= id_M2REG;
            ex_FQ1 <= id_FQ1;
            ex_LUI <= id_LUI;
            ex_ALU_Ctr <= id_ALU_Ctr;
            ex_SHIFT <= id_SHIFT;
            ex_inst <= id_inst;
            ex_ALUIMM <= id_ALUIMM;
            ex_pc_p4 <= id_pc_p4;
            ex_nd <= id_nd;
            ex_RMEM <= id_RMEM;
            ex_EXT_imm16 <= id_EXT_imm16;
            ex_FQ2 <= id_FQ2;
        end
    end
endmodule

