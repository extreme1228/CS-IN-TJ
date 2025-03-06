`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/08 19:54:59
// Design Name: 
// Module Name: cp0_tb
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


module cp0_tb(

    );

    reg clk,rst,mfc0,mtc0;
    reg [31:0]pc;
    reg [4:0]Rd;
    reg [31:0]wdata;
    reg exception;
    reg eret;
    reg[4:0]cause;
    reg intr  = 1;
    wire [31:0]rdata,status;
    wire timer_int;
    wire[31:0]exc_addr;


    CP0 u_cp0(
        .clk(clk),
        .rst(rst),
        .mfc0(mfc0),
        .mtc0(mtc0),
        .pc(pc[31:0]),
        .Rd(Rd[4:0]),
        .wdata(wdata[31:0]),
        .exception(exception),
        .eret(eret),
        .cause(cause[4:0]),
        .intr(intr),
        .rdata(rdata[31:0]),
        .status(status[31:0]),
        .timer_int(timer_int),
        .exc_addr(exc_addr[31:0])
    );
    always
    begin
        #10 clk =~clk;
    end
    initial begin
        clk = 1;
        rst = 1;
        #100
        rst = 0;
        //测试简单读写
        eret = 0;
        mfc0 = 0;
        mtc0 = 1;
        Rd = 0;
        wdata = 32'hffff_ffff;
        #50
        Rd = 1;
        wdata = 32'h0000_ffff;
        #50
        mfc0 = 1;
        mtc0 = 0;
        Rd = 0;
        #50
        mfc0 = 1;
        mtc0 = 0;
        Rd = 1;
        //测试异常处理
        #50
        mfc0 = 0;
        mtc0 = 0;
        exception = 1;
        eret = 0;
        pc = 32'h0000_000f;
        #50
        eret = 1;
        exception = 0;
        mfc0 = 0;
        mtc0 = 0;
        #50
        eret = 0;
        exception = 0;
        mfc0 = 0;
        mtc0 = 0;
    end

endmodule
