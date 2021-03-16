`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2020/01/20 15:01:17
// Design Name: 
// Module Name: or_reduct
// Description: Assume 32-bit operation
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module or_reduct #(parameter WIDTH = 32)(
    input [WIDTH-1:0] A,
    output o
    );
    assign o = |A;
endmodule