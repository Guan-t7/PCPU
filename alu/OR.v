`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2020/01/20 15:01:17
// Design Name: 
// Module Name: OR32
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module OR32 #(parameter WIDTH = 32)(
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B, 
    output [WIDTH-1:0] res
    );
    assign res = A | B;
endmodule
