`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: ADC32
// Description: 
// 
// Dependencies: 
// Additional Comments:
//! SEXT
//////////////////////////////////////////////////////////////////////////////////
module ADC32 #(parameter WIDTH = 32)(
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B, 
    input Ci,
    output [WIDTH-1:0] S,
    output Co
    );
    wire [WIDTH:0] tmp = {A[WIDTH-1],A} + {B[WIDTH-1],B} + Ci;
    assign S = tmp[WIDTH-1:0];
    assign Co = tmp[WIDTH];
endmodule