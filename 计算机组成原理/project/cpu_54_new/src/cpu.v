`timescale 1ns / 1ps

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
    wire pc_ena;

    wire[4:0]rs,rt,rd;

    wire[31:0]rdata1,rdata2,wdata;
    wire[31:0]alu_a,alu_b,alu_res;

    wire w_ena;
    wire[5:0]alu_func;

    wire[4:0]waddr;
    wire zero,carry,negative,overflow;

    //cp0_port
    wire [31:0] cp0_rdata;
    wire[31:0] exc_addr;
    wire mtc0,eret,teq_exc;
    wire [3:0] cause;

    //MDU port
    wire [2:0]mduc;
    wire [63:0]mul_res;
    wire[31:0]high,low;

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
        .inst(inst),.pc(pc),
        .pc_out(pc_next),
        .rs(rs),.rt(rt),
        .rdata1(rdata1),.rdata2(rdata2),
        .alu_func(alu_func),.alu_a(alu_a), .alu_b(alu_b),
        .ram_rdata(ram_rdata),.alu_res(alu_res),
        .w_ena(w_ena), .waddr(waddr),.wdata(wdata),
        .ram_ena(ram_ena), .ram_addr(ram_addr),.ram_wdata(ram_wdata),

        .cp0_rdata(cp0_rdata),.exc_addr(exc_addr),
        .mtc0(mtc0),.eret(eret),.teq_exc(teq_exc),
        .cause(cause),
        .rd(rd),

        .mul_res(mul_res[31:0]),
        .high(high),.low(low),
        .mdu_op(mduc)
    );

    //CP0
    CP0 cp0_unit(
        .clk(clk),.rst(rst),
        .mtc0(mtc0),
        .pc(pc),
        .addr(rd),.wdata(rdata2),
        .eret(eret),.teq_exc(teq_exc),.cause(cause),
        .rdata(cp0_rdata),.exc_addr(exc_addr)
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

    //MDU
    MDU mdu_unit(
        .clk(clk),.rst(rst),
        .mduc(mduc),
        .a(rdata1),.b(rdata2),
        .mul_res(mul_res),
        .high(high),.low(low),
        .pc_ena(pc_ena)
    );
endmodule