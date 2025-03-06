`timescale 1ns / 1ps


module DMEM(
    input clk,
    input w_ena,//控制在存储器中的读写信号
    input [31:0]addr,
    input [31:0] wdata,
    output [31:0] rdata
    );
    reg[7:0] DM_data[0:1023];
    //这里我们向寄存器写采用同步逻辑，而读寄存器内容采用异步逻辑
    always@(negedge clk)
    begin
        if(w_ena)begin
            DM_data[addr + 3] <= wdata[31:24];
            DM_data[addr + 2] <= wdata[23:16];
            DM_data[addr + 1] <= wdata[15:8];
            DM_data[addr]     <= wdata[7:0];
        end
    end
    assign rdata[31:24] = (w_ena == 0) ? DM_data[addr + 3] : 8'b0;
    assign rdata[23:16] = (w_ena == 0) ? DM_data[addr + 2] : 8'b0;
    assign rdata[15:8]  = (w_ena == 0) ? DM_data[addr + 1] : 8'b0;
    assign rdata[7:0]   = (w_ena == 0) ? DM_data[addr]     : 8'b0;

endmodule
