`timescale 1ns / 1ps
module MUX4T1_5 #(parameter WIDTH = 5)(
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