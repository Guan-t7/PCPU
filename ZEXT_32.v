`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/01/21 19:07:46
// Design Name: 
// Module Name: ZEXT_32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ZEXT_32(
    input [15:0] imm_16,
    output [31:0] imm_32
    );
    assign imm_32 = {{16{1'b0}},imm_16};
endmodule
