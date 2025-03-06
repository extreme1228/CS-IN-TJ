`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/05 17:22:50
// Design Name: 
// Module Name: DIV
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


module DIV(
    input [31:0]a,
    input [31:0]b,
    output[63:0]div_res,
    output[63:0]divu_res,
    output div_busy,
    output divu_busy
    );
    wire signed[31:0]signed_a,signed_b;
    assign signed_a = a;
    assign signed_b = b;
    wire[31:0] signed_q,signed_r,unsigned_q,unsigned_r;
    
    assign signed_r = (b == 32'b0)?32'b0:(signed_a%signed_b);
    assign signed_q = (b == 32'b0)?32'b0:(signed_a/signed_b);

    assign unsigned_r = (b == 32'b0)?32'b0:(a%b);
    assign unsigned_q = (b == 32'b0)?32'b0:(a/b);

    assign div_res = {signed_q,signed_r};
    assign divu_res = {unsigned_q,unsigned_r};
    assign div_busy = 0;
    assign divu_busy = 0;
endmodule
