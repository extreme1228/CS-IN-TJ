`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/04 13:36:46
// Design Name: 
// Module Name: DIVU_tb
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


module DIVU_tb(

    );

    // DIVU Inputs
reg   [31:0]  dividend                     = 0 ;
reg   [31:0]  divisor                      = 0 ;
reg   start                                = 0 ;
reg   clock                                = 0 ;
reg   reset                                = 0 ;

// DIVU Outputs
wire  [31:0]  q                            ;
wire  [31:0]  r                            ;
wire  busy                                 ;


DIVU  u_DIVU (
    .dividend                ( dividend  [31:0] ),
    .divisor                 ( divisor   [31:0] ),
    .start                   ( start            ),
    .clock                   ( clock            ),
    .reset                   ( reset            ),

    .q                       ( q         [31:0] ),
    .r                       ( r         [31:0] ),
    .busy                    ( busy             )
);
always
begin
    #1
    clock=~clock;
end
initial 
begin
    start=1;
    dividend=32'b00000000000000000111111111111111;
    divisor=32'b00000000000000000000000000010000;
    #200
    reset=1;
    #20
    reset=0;
    dividend=32'b11111111111111111111111111111000;
    divisor=32'b00000000000000000000000000000011;
    #200
    reset=1;
    #20
    reset=0;
    dividend=32'b11111111111111111111111111111000;
    divisor=32'b00000000000000000000000000000010;
end
endmodule
