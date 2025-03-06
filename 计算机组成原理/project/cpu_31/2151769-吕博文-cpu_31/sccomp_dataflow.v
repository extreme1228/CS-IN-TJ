`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/15 20:08:56
// Design Name: 
// Module Name: sccomp_dataflow
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


module sccomp_dataflow(
    input clk_in,
    input reset,
    output[31:0]inst,
    output[31:0]pc
    );
    wire[31:0] _pc;//符合MARS格式的pc
    assign _pc = pc-32'h00400000;
    wire [31:0] _addr,addr;//符合MARS格式的地址
    assign _addr = (addr -32'h10010000)/4;//这里除以4是因为我们在DMEM中定义的reg是32位的,不同于常规的8位，所以要除以4

    wire[31:0]ram_wdata,ram_rdata;
    wire ram_ena;

    //CPU
    cpu sccpu(
        .clk(clk_in),
        .rst(reset),
        .inst(inst),
        .pc(pc),
        .ram_ena(ram_ena),
        .ram_addr(addr),
        .ram_rdata(ram_rdata),
        .ram_wdata(ram_wdata)
    );

    //ROM
    IMEM rom(
        .addr(_pc[12:2]),
        .inst(inst)
    );

    //RAM
    DMEM ram(
        .clk(clk_in),
        .w_ena(ram_ena),
        .addr(_addr[10:0]),
        .wdata(ram_wdata),
        .rdata(ram_rdata)
    );
endmodule
