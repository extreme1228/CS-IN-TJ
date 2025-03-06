`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/13 17:49:55
// Design Name: 
// Module Name: PCReg
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


module PCReg(
    input clk,
    input rst,
    input ena,
    input [31:0]pc_in,
    output  reg[31:0] pc_out
    );
    always@(negedge clk or posedge rst)
    begin
        if(rst)pc_out<=32'h00400000;//这是MARS中取指令的开始地址
        else if(rst==0&&ena)pc_out<=pc_in;
    end
endmodule
