`timescale 1ns / 1ps

module sccomp_dataflow(
    input clk_in,
    input reset,
    output[31:0]inst,
    output[31:0]pc
    );
    wire[31:0] _pc;//符合MARS格式的pc
    assign _pc = pc-32'h00400000;
    wire [31:0] _addr,addr;//符合MARS格式的地址
    assign _addr = (addr -32'h10010000);//这里不同于cpu31，我们选择DMEM存储数据采用标准的8位是为了方便LB等取字节指令的执行

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
        .addr(_addr),
        .wdata(ram_wdata),
        .rdata(ram_rdata)
    );
endmodule