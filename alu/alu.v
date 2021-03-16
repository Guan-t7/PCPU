`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    10:10:33 05/03/2020 
// Design Name: 
// Module Name:    alu 
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
//////////////////////////////////////////////////////////////////////////////////
module ALU_Org(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALU_Ctr,
    output [31:0] res,
    output zero,
    output overflow
    );

    wire [31:0] and_res, or_res, adc_res, xor_res, sll_res, srl_res;

AND32  u_AND32 (
    .A                       ( A     ),
    .B                       ( B     ),

    .res                     ( and_res   )
    );
OR32  u_OR32 (
    .A                       ( A     ),
    .B                       ( B     ),

    .res                     ( or_res   )
    );
ADC32  u_ADC32 (
    .A                       ( A    ),
    .B                       ( ALU_Ctr[2] ? ~B : B    ),
    .Ci                      ( ALU_Ctr[2]   ),

    .S                       ( adc_res    ),
    .Co                      ( Co   )
    );
XOR32  u_XOR32 (
    .A                       ( A     ),
    .B                       ( B     ),

    .res                     ( xor_res   )
);
SLL32  u_SLL32 (
    .A                       ( A     ),
    .B                       ( B     ),

    .res                     ( sll_res   )
);
SRL32  u_SRL32 (
    .A                       ( A     ),
    .B                       ( B     ),

    .res                     ( srl_res   )
);

wire SF = adc_res[31];
wire OF = adc_res[31] != Co;

MUX8T1  ALUMUX (
    .I0                      ( and_res   ),
    .I1                      ( or_res   ),
    .I2                      ( adc_res   ),
    .I3                      ( xor_res   ),
    .I4                      ( sll_res   ),
    .I5                      ( srl_res   ),
    .I6                      ( adc_res   ),
    .I7                      ( {31'b0, SF != OF}   ),   // <=> Co
    .s                       ( ALU_Ctr    ),

    .o                       ( res    )
);
or_reduct  u_or_reduct (
    .A                       ( res   ),

    .o                       ( NZ   )
);
assign zero = ~NZ;
assign overflow = (ALU_Ctr == 3'b010 | ALU_Ctr == 3'b110) & OF; //! is still too wide, e.g. beq bne

endmodule
