module ExMemRegisters (
    input clk,
    input rst,
    input CE,
    input ex_WMEM,
    input ex_WREG,
    input [31:0] ex_pc,
    input ex_M2REG,
    input [31:0] ex_inst,
    input [31:0] ex_alu_out,
    input [4:0] ex_nd,
    input ex_RMEM,
    input [31:0] ex_FQ2,
    output reg mem_WMEM,
    output reg mem_WREG,
    output reg [31:0] mem_pc,
    output reg mem_M2REG,
    output reg [31:0] mem_inst,
    output reg [31:0] mem_alu_out,
    output reg [4:0] mem_nd,
    output reg mem_RMEM,
    output reg [31:0] mem_FQ2
    );
    always @(posedge clk) begin
        if (rst) begin
            mem_WMEM <= 0;
            mem_WREG <= 0;
            mem_pc <= 0;
            mem_M2REG <= 0;
            mem_inst <= 0;
            mem_alu_out <= 0;
            mem_nd <= 0;
            mem_RMEM <= 0;
            mem_FQ2 <= 0;
        end 
        else if (CE) begin
            mem_WMEM <= ex_WMEM;
            mem_WREG <= ex_WREG;
            mem_pc <= ex_pc;
            mem_M2REG <= ex_M2REG;
            mem_inst <= ex_inst;
            mem_alu_out <= ex_alu_out;
            mem_nd <= ex_nd;
            mem_RMEM <= ex_RMEM;
            mem_FQ2 <= ex_FQ2;
        end
    end
endmodule

