`timescale 1ns / 1ps

module RegFile(
    input RF_ena,
    input clk,
    input rst, 
    input [4:0] Rdc,
    input [4:0] Rsc,
    input [4:0] Rtc,
    input [31:0] Rd,
    output [31:0] Rs,
    output [31:0] Rt,
    input RF_W
    );
    reg [31:0] array_reg[0:31];//定义RegFile中的寄存器
    integer i;
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            for(i=0;i<32;i=i+1)array_reg[i]<=32'b0;
            //rst信号发挥作用，全部寄存器内容清空
        end
        else begin
             //写信号且不能改变寄存器0中的内容
            if (RF_W == 1'b1 && RF_ena && Rdc != 5'b0)
                array_reg[Rdc] <= Rd;
        end
    end

    assign Rs = RF_ena ? array_reg[Rsc] : 32'bz;
    assign Rt = RF_ena ? array_reg[Rtc] : 32'bz;
endmodule

