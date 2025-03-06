`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/13 17:40:38
// Design Name: 
// Module Name: RegFile
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


module RegFile(
    input clk,
    input rst,
    input w_ena,
    input [4:0]waddr,
    input [31:0] wdata,
    input [4:0]raddr1,
    output[31:0]rdata1,
    input [4:0]raddr2,
    output[31:0]rdata2
    );
    reg[31:0] array_reg[0:31];//定义RegFile中的寄存器
    integer i;
    //write信号
    always@(negedge clk or posedge rst)
    begin
        if(rst)begin
            for(i=0;i<32;i=i+1)array_reg[i]<=32'b0;//rst信号发挥作用，全部寄存器内容清空
        end
        else if(rst==0)begin
            if(w_ena&&waddr!=5'b0)begin
                //写信号且不能改变寄存器0中的内容
                array_reg[waddr]<=wdata;
            end
        end
    end

    //read信号
    assign rdata1 = array_reg[raddr1];
    assign rdata2 = array_reg[raddr2];
endmodule
