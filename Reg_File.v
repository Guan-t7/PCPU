`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:49:07 05/03/2020 
// Design Name: 
// Module Name:    Reg_File 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Reg_File(
    input clk,
    input [4:0] SR1,
    input [4:0] SR2,
    input [4:0] DR,
    input WReg,
    input [31:0] Data_in,
    output [31:0] SR1_OUT,
    output [31:0] SR2_OUT,

    input wire [4:0] debug_addr,
	output wire [31:0] debug_data
    );
reg [31:0] regs [1:31];

assign SR1_OUT = SR1 ? regs[SR1] : 32'b0;
assign SR2_OUT = SR2 ? regs[SR2] : 32'b0;

always @(posedge clk ) begin
    if(WReg) begin
        if (DR) begin
            regs[DR] <= Data_in;
        end
    end
end

assign debug_data = (debug_addr == 0) ? 0 : regs[debug_addr];

endmodule
