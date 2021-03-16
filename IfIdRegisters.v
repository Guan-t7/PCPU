module IfIdRegisters (
    input clk,
    input rst,
    input CE,
    input [31:0] if_pc_p4,
    input [31:0] if_pc,
    input [31:0] if_inst,
    output reg [31:0] id_pc_p4,
    output reg [31:0] id_pc,
    output reg [31:0] id_inst
    );
    always @(posedge clk) begin
        if (rst) begin
            id_pc_p4 <= 0;
            id_pc <= 0;
            id_inst <= 0;
        end 
        else if (CE) begin
            id_pc_p4 <= if_pc_p4;
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end
endmodule

