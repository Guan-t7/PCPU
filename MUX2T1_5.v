`timescale 1ns / 1ps

module MUX2T1_5 #(parameter WIDTH = 5)(
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