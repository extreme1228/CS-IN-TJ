`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/15 19:47:05
// Design Name: 
// Module Name: cpu
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


module cpu(
    input clk,
    input rst,
    input[31:0]inst,
    output [31:0]pc,
    output ram_ena,
    output[31:0]ram_addr,
    input [31:0]ram_rdata,
    output[31:0]ram_wdata
    );
    //定义需要在模块中调用的变量
    wire[31:0]pc_next;
    wire[4:0]rs,rt;
    wire[31:0]rdata1,rdata2,wdata;
    wire[31:0]alu_a,alu_b,alu_res;
    wire w_ena;
    wire[5:0]alu_func;
    wire[4:0]waddr;
    wire zero,carry,negative,overflow;

    //PC port，完成PC_next-->PC的工作
    PCReg pc_reg(
        .clk(clk),
        .rst(rst),
        .ena(1),
        .pc_in(pc_next),
        .pc_out(pc)
    );

    //Control_Unit模块，完成指令的译码并产生各总线信号的模块
    Control_Unit my_control(
        .inst(inst),
        .pc(pc),
        .pc_out(pc_next),
        .rs(rs),
        .rt(rt),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .alu_func(alu_func),
        .alu_a(alu_a),
        .alu_b(alu_b),
        .ram_rdata(ram_rdata),
        .alu_res(alu_res),
        .w_ena(w_ena),
        .waddr(waddr),
        .wdata(wdata),
        .ram_ena(ram_ena),
        .ram_addr(ram_addr),
        .ram_wdata(ram_wdata)
    );

    //Register
    RegFile cpu_ref(
        .clk(clk),
        .rst(rst),
        .w_ena(w_ena),
        .waddr(waddr),
        .wdata(wdata),
        .raddr1(rs),
        .rdata1(rdata1),
        .raddr2(rt),
        .rdata2(rdata2)
    );

    //ALU
    ALU alu_part(
        .a(alu_a),
        .b(alu_b),
        .res(alu_res),
        .alu_func(alu_func),
        .zero(zero),
        .carry(carry),
        .negative(negative),
        .overflow(overflow)
    );
endmodule
