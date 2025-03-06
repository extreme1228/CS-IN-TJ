`timescale 1ns / 1ps



module IMEM(
    input [10:0] addr,
    output [31:0] inst
    );
    //IMEM模块就是调用了我们事先实现好的IP核，给定一个地址，返回对应的指令，在cpu指令流程图中与pc相连接，起到读取指令的作用
    dist_mem_gen_0 inst_get(.a(addr),.spo(inst));
endmodule