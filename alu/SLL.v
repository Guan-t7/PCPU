`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2020/11/8
// Design Name: 
// Module Name: SLL32
// Description: Modified to adapt PCPU
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module SLL32 (
    input [31:0] A,
    input [31:0] B, 
    output [31:0] res
    );
    assign res = B << A[10:6];;
endmodule
