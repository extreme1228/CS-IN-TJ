`timescale 1ns / 1ps
`include "define.vh"

module cp0(
    input clk,             
    input rst,            
    input mfc0,            // MFC0（Move From CP0）指令信号
    input mtc0,            // MTC0（Move To CP0）指令信号
    input [31:0] pc,      
    input [4:0] addr,      
    input [31:0] wdata,    
    input exception,       // 异常信号
    input eret,            // ERET（Exception Return）指令信号
    input [4:0] cause,     // 异常原因码
    output [31:0] rdata,   // 从CP0寄存器读取的数据
    output [31:0] status,  // 状态寄存器的值
    output [31:0] exc_addr // 异常地址
    );

    reg [31:0] register [31:0]; // CP0寄存器数组
    reg [31:0] temp_status;     // 临时存储状态寄存器的值
    integer i;

    // 寄存器写入和状态更新逻辑
    always @ (posedge clk or posedge rst) 
    begin
        if (rst == `RST_ENABLED) begin
            for(i = 0; i < 32; i = i + 1) begin
                if(i == `STATUS)
                    register[i] <= 32'h0000000f; // 在复位时，将状态寄存器初始化为默认值
                else
                    register[i] <= 0;
            end
            temp_status <= 0;
        end

        else begin
            if(mtc0)
                register[addr] <= wdata; // 如果是MTC0指令，则将指定的CP0寄存器写入新的数据

            else if(exception) begin
                register[`EPC] = pc;  // 如果有异常，将程序计数器（PC）的值写入EPC寄存器
                temp_status = register[`STATUS]; // 保存状态寄存器的值
                register[`STATUS] = register[`STATUS] << 5; // 修改状态寄存器的值
                register[`CAUSE] = {25'b0, cause, 2'b0}; // 设置异常原因码
            end

            else if(eret) 
                register[`STATUS] = temp_status; // 如果是ERET指令，则恢复状态寄存器的值
        end 
    end

    // 根据不同的指令信号，决定从CP0寄存器读取的数据
    assign exc_addr = eret ? register[`EPC] : `EXCEPTION_ADDR;
    assign rdata = mfc0 ? register[addr] : 32'h0; // 根据MFC0指令信号决定读取的数据
    assign status = register[`STATUS]; // 状态寄存器的值

endmodule
