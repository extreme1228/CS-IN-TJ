`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/04 15:27:44
// Design Name: 
// Module Name: DIV_tb
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


module DIV_tb(

    );
    // DIV Inputs
reg   [31:0]  dividend                     = 0 ;
reg   [31:0]  divisor                      = 0 ;
reg   start                                = 0 ;
reg   clock                                = 0 ;
reg   reset                                = 0 ;

// DIV Outputs
wire  [31:0]  q                            ;
wire  [31:0]  r                            ;
wire  busy                                 ;


DIV u_DIV (
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
    dividend=32'b1111_1111_1111_1111_1111_1111_1111_0011;
    divisor=32'b0000_0000_0000_0000_0000_0000_0000_0010;
    #200
    reset=1;
    #20
    reset=0;
    dividend=32'b0000_0000_0000_0000_0000_0000_0000_1101;
    divisor=32'b1111_1111_1111_1111_1111_1111_1111_1110;
end
endmodule
