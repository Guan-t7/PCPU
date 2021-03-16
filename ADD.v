`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2020/01/20 15:01:17
// Design Name: 
// Module Name: ADD32
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module ADD32 #(parameter WIDTH = 32)(
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B, 
    output [WIDTH-1:0] S
    );
    assign S = A + B;
endmodule