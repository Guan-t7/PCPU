`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2020/01/20 15:01:17
// Design Name: 
// Module Name: MUX4T1
// Description: Assume 32-bit operation
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module MUX4T1_32 #(parameter WIDTH = 32)(
    input [WIDTH-1:0] I0,
    input [WIDTH-1:0] I1,
    input [WIDTH-1:0] I2,
    input [WIDTH-1:0] I3,
    input [1:0] s,
    output reg [WIDTH-1:0] o
    );
    always @* begin
        case(s)
            0: o = I0;
            1: o = I1;
            2: o = I2;
            3: o = I3;
            default: o = 'bx;
        endcase
    end
endmodule