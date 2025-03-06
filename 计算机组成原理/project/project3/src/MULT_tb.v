`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/28 22:01:17
// Design Name: 
// Module Name: MULT_tb
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


module MULT_tb(

    );
    // MULT Inputs
reg   clk                                  = 0 ;
reg   reset                                = 0 ;
reg   [31:0]  a                            = 0 ;
reg   [31:0]  b                            = 0 ;

// MULT Outputs
wire  [63:0]  z                            ;
wire  [63:0]  tmp                            ;
wire signz;

MULT  u_MULT (
    .clk                     ( clk           ),
    .reset                   ( reset         ),
    .a                       ( a      [31:0] ),
    .b                       ( b      [31:0] ),
    .z                       ( z      [63:0] )
);

always
begin
    #1
    clk=~clk;
end
initial 
begin
    a=32'b0000_0000_0000_0000_0000_0000_0000_0001;
    b=32'b1111_1111_1111_1111_1111_1111_1111_1111;
    #200
    reset=1;
    #20
    reset=0;
    a=32'b1111_1111_1111_1111_1111_1111_1111_1000;
    b=32'b1111_1111_1111_1111_1111_1111_1111_1011;
    #200
    reset=1;
    #20
    reset=0;
    a=32'b0000_0000_0000_0000_0000_0000_0000_1000;
    b=32'b0000_0000_0000_0000_0000_0000_0000_0101;

end
endmodule
