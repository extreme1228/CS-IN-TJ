`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/08 18:33:56
// Design Name: 
// Module Name: CP0
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


module CP0(
    input clk,
    input rst,
    input mfc0,//cp0 read
    input mtc0,//cp0 write
    input [31:0]pc,//指令
    input [4:0] Rd,//address
    input [31:0] wdata,//向cp0写的数据
    input exception,//是否为异常信号
    input eret,//是否为错误返回信号
    input[4:0]cause,//异常原因
    input intr,//外部中断
    output [31:0]rdata,//cp0读出的数据
    output [31:0] status,//status register
    output reg timer_int,
    output[31:0]exc_addr //返回异常保存的地址
    );

    parameter  STATUS_POS = 12;
    parameter  CAUSE_POS = 13;
    parameter  EPC_POS = 14;
    // parameter  SYS_ERR = 4'b1000;
    // parameter  BREAK_ERR = 4'b1001;
    // parameter  TEQ_ERR = 4'b1101;

    reg[31:0] cp0_reg[0:31];
    assign status = cp0_reg[STATUS_POS];
    // assign exception = (status[0] == 1)&&
    // ((status[1] == 1&& cause == SYS_ERR)||
    // (status[2] == 1&&cause == BREAK_ERR)||
    // (status == 1&&cause == TEQ_ERR));
    assign rdata = (mfc0?(cp0_reg[Rd]):32'b0);
    assign exc_addr = (eret?cp0_reg[EPC_POS]:32'b0);
    integer i;
    always @(posedge clk or posedge rst)
    begin
        if(rst == 1)begin
            for(i = 0;i<32;i=i+1)
                cp0_reg[i]<=32'b0;
        end
        else 
        begin
            if(mtc0 == 1)
                cp0_reg[Rd]<=wdata;
            else if(exception)begin
                cp0_reg[STATUS_POS]<=(status<<5);
                cp0_reg[CAUSE_POS]<={25'b0,cause,2'b0};
                cp0_reg[EPC_POS]<=pc;
            end
            else if(eret == 1)begin
                cp0_reg[STATUS_POS]<=(status>>5);
            end
        end
    end
endmodule
