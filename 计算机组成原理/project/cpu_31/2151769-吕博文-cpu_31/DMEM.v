`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/13 16:58:59
// Design Name: 
// Module Name: DMEM
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


module DMEM(
    input clk,
    input w_ena,//控制在存储器中的读写信号
    input [10:0]addr,
    input [31:0] wdata,
    output [31:0] rdata
    );
    reg[31:0] DM_data[0:31];//32个32位的通用寄存器
    //这里我们向寄存器写采用同步逻辑，而读寄存器内容采用异步逻辑
    always@(negedge clk)
    begin
        if(w_ena)DM_data[addr]<=wdata;
    end
    assign rdata=(w_ena==0?DM_data[addr]:32'bz);
endmodule
