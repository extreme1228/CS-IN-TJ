`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/13 17:11:03
// Design Name: 
// Module Name: ALU
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


module ALU(
    input[31:0] a,
    input[31:0] b,
    output[31:0] res,
    input[5:0] alu_func,
    output zero,
    output carry,
    output negative,
    output overflow
    );
    //参数中的alu_func代表执行运算的类型，由指令的opt和func决定，在传入ALU模块之前就计算好了
    //下面定义几个运算类型的表示,按照文档顺序定义 
    parameter ADD = 0 ;
    parameter ADDU =1;
    parameter SUB = 2;
    parameter SUBU = 3;
    parameter AND = 4;
    parameter OR = 5;
    parameter XOR = 6;
    parameter NOR = 7;
    parameter SLT = 8;
    parameter SLTU = 9;
    parameter SLL = 10;
    parameter SRL = 11;
    parameter SRA = 12;
    parameter SLLV = 13;
    parameter SRLV = 14;
    parameter SRAV = 15 ;
    parameter LUI = 16;
    wire signed [31:0]sign_a,sign_b;//将给定数据转化为有符号数方便接下来进行计算
    assign sign_a = a;
    assign sign_b = b;
    reg[32:0]tmp_res;//暂时存储结果
    always@(*)
    begin
        case(alu_func)
        ADD : tmp_res<=sign_a+sign_b;
        ADDU : tmp_res<=a+b;
        SUB : tmp_res<=sign_a-sign_b;
        SUBU : tmp_res<=a-b;
        AND : tmp_res<=a & b;
        OR : tmp_res<=a | b;
        XOR : tmp_res<= a ^ b;
        NOR : tmp_res<= ~(a|b);
        SLT : tmp_res<=(sign_a<sign_b);
        SLTU : tmp_res<=(a<b);
        SLL : tmp_res<=(b<<a);
        SRL : tmp_res<=(b>>a);
        SRA : tmp_res<=(sign_b>>>sign_a);
        SLLV : tmp_res<= (b<<a[4:0]);
        SRLV : tmp_res<=(b>>a[4:0]);
        SRAV : tmp_res<=(sign_b>>>sign_a[4:0]);
        LUI : tmp_res<={b[15:0],16'b0};
        endcase
    end
    assign res = tmp_res[31:0];
    assign zero=(tmp_res==32'b0)?1:0;
    assign carry = tmp_res[32];
    assign overflow = tmp_res[32];
    assign negative = tmp_res[31];
endmodule
