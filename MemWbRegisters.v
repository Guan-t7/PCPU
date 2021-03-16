module MemWbRegisters (
    input clk,
    input rst,
    input CE,
    input mem_WREG,
    input [31:0] mem_pc,
    input [31:0] mem_alu_out,
    input mem_M2REG,
    input [4:0] mem_nd,
    input [31:0] mem_d,
    input [31:0] mem_inst,
    output reg wb_WREG,
    output reg [31:0] wb_pc,
    output reg [31:0] wb_alu_out,
    output reg wb_M2REG,
    output reg [4:0] wb_nd,
    output reg [31:0] wb_d,
    output reg [31:0] wb_inst
    );
    always @(posedge clk) begin
        if (rst) begin
            wb_WREG <= 0;
            wb_pc <= 0;
            wb_alu_out <= 0;
            wb_M2REG <= 0;
            wb_nd <= 0;
            wb_d <= 0;
            wb_inst <= 0;
        end 
        else if (CE) begin
            wb_WREG <= mem_WREG;
            wb_pc <= mem_pc;
            wb_alu_out <= mem_alu_out;
            wb_M2REG <= mem_M2REG;
            wb_nd <= mem_nd;
            wb_d <= mem_d;
            wb_inst <= mem_inst;
        end
    end
endmodule

