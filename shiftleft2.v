`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:37:35 05/03/2020 
// Design Name: 
// Module Name:    shiftleft2 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module shiftleft2(
    input [31:0] in_,
    output [31:0] out_
    );
assign out_ = {in_[29:0],2'b0};

endmodule
