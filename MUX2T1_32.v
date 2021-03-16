`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2020/01/20 15:01:17
// Design Name: 
// Module Name: MUX2T1
// Description: Assume 32-bit operation
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module MUX2T1_32 #(parameter WIDTH = 32)(
    input [WIDTH-1:0] I0,
    input [WIDTH-1:0] I1,
    input s,
    output reg [WIDTH-1:0] o
    );
    always @* begin
        case(s)
            0: o = I0;
            1: o = I1;
            default: o = 'bx;
        endcase
    end
endmodule