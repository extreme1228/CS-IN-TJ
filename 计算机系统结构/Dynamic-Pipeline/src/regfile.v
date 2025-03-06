`timescale 1ns / 1ps
`include "define.vh"
module regfile(
    input clk,            
    input rst,            
    input wena,           // 写使能信号
    input [4:0] raddr1,   // 读地址1
    input [4:0] raddr2,   // 读地址2
    input rena1,          // 读使能1
    input rena2,          // 读使能2
    input [4:0] waddr,    // 写地址
    input [31:0] wdata,   // 写数据
    output reg [31:0] rdata1, // 读数据1
    output reg [31:0] rdata2, // 读数据2
    output [31:0] reg28,     // 寄存器28，存储计算结果
    output [31:0] reg29      // 寄存器29，通常为零
    );
    
    reg [31:0] Regs[0:31]; // 寄存器文件，共32个寄存器
    integer i;

    // 写
	always @ (posedge clk or posedge rst) 
    begin
        if(rst == `RST_ENABLED) begin
            for(i = 0; i < 32; i = i + 1)
                Regs[i] = 0; // 复位时将所有寄存器清零
        end
	    else begin
            if((wena == `WRITE_ENABLED) && (waddr != 0))
                Regs[waddr] = wdata; // 如果写使能信号有效且写地址不为0，则写入数据到指定寄存器
        end
	end

    // 读
	always @ (*) 
    begin
	    if(rst == `RST_ENABLED) 
			  rdata1 <= `ZERO_32BIT;

	    else if(raddr1 == 5'b0) 
	  		rdata1 <= `ZERO_32BIT;

	    else if((raddr1 == waddr) && (wena == `WRITE_ENABLED) && (rena1 == `READ_ENABLED)) 
	  	    rdata1 <= wdata; // 如果读地址1等于写地址且写使能信号有效且读使能信号有效，则读取写入的数据
	    else if(rena1 == `READ_ENABLED) 
	        rdata1 <= Regs[raddr1]; // 从指定寄存器读取数据
	    else 
	        rdata1 <= `ZERO_32BIT;
	end

    // 读
	always @ (*) 
    begin
	    if(rst == `RST_ENABLED) 
			  rdata2 <= `ZERO_32BIT;

	    else if(raddr2 == 5'b0) 
	  		rdata2 <= `ZERO_32BIT;

        else if((raddr2 == waddr) && (wena == `WRITE_ENABLED) && (rena2 == `READ_ENABLED)) 
            rdata2 <= wdata; // 如果读地址2等于写地址且写使能信号有效且读使能信号有效，则读取写入的数据
	    else if(rena2 == `READ_ENABLED) 
	        rdata2 <= Regs[raddr2]; // 从指定寄存器读取数据
	    else 
	        rdata2 <= `ZERO_32BIT;
	end

    assign reg28 = Regs[28]; // 计算结果存储在寄存器28
    assign reg29 = Regs[29]; // 寄存器29通常为零

endmodule