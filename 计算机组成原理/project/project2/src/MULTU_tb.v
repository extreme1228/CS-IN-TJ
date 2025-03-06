`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/28 15:59:32
// Design Name: 
// Module Name: MULTU_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MULTU_tb(

    );


// MULTU Inputs
reg   clk                                  = 0 ;
reg   reset                                = 0 ;
reg   [31:0]  a                            = 0 ;
reg   [31:0]  b                            = 0 ;

// MULTU Outputs
wire  [63:0]  z                            ;
always
begin
    #1
    clk=~clk;
end

initial
begin
    a=32'b11111111111111111111111111111111;
    b=32'b11111111111111111111111111111111;
    #200
    reset=1;
    #10
    reset=0;
    a=32'b10101010101010101010101010101010;
    b=32'b10000000000000000000000000000000;
    #200
    reset=1;
    #10
    reset=0;
    a=32'b10101010111100001111000011111111;
    b=32'b11110000111100001111000011110000;
    #200
    reset=1;
    #10
    reset=0;
    a=32'b10001110111100001010101000001111;
    b=32'b11010000110100001101000011010000;
end

MULTU  u_MULTU (
    .clk                     ( clk           ),
    .reset                   ( reset         ),
    .a                       ( a      [31:0] ),
    .b                       ( b      [31:0] ),
    .z                       ( z      [63:0] )
);

endmodule
