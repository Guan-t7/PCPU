`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2020/01/20 15:01:17
// Design Name: 
// Module Name: MUX8T1
// Description: Assume 32-bit operation
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module MUX8T1 #(parameter WIDTH = 32)(
    input [WIDTH-1:0] I0,
    input [WIDTH-1:0] I1,
    input [WIDTH-1:0] I2,
    input [WIDTH-1:0] I3,
    input [WIDTH-1:0] I4,
    input [WIDTH-1:0] I5,
    input [WIDTH-1:0] I6,
    input [WIDTH-1:0] I7,
    input [2:0] s,
    output reg [WIDTH-1:0] o
    );
    always @* begin
        case(s)
            0: o = I0;
            1: o = I1;
            2: o = I2;
            3: o = I3;
            4: o = I4;
            5: o = I5;
            6: o = I6;
            7: o = I7;
            default: o = 'bx;
        endcase
    end
endmodule