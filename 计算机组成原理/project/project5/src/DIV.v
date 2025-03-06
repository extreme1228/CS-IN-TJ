`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/04 15:19:45
// Design Name: 
// Module Name: DIV
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


module DIV(
    input [31:0] dividend,
    input [31:0] divisor,
    input start,
    input clock,
    input reset,
    output [31:0] q,
    output [31:0] r,
    output reg busy
    );
    reg [31:0]abs_dividend;
    reg [31:0]abs_divisor;
    reg [63:0]tmp_a;
    reg[63:0]tmp_b;
    reg[15:0]cnt;
    parameter kase = 32;
    always @(posedge clock or posedge reset)
    begin
        if(reset==1)
        begin
            cnt<=0;
            busy<=0;
        end
        else
        begin
            if(start==1)begin
                cnt=0;
                busy=1;
                if(dividend[31]==1)abs_dividend=~(dividend-1);
                else abs_dividend=dividend;
                if(divisor[31]==1)abs_divisor=~(divisor-1);
                else abs_divisor=divisor;
                tmp_a={32'b0,abs_dividend};
                tmp_b={abs_divisor,32'b0};
                repeat(kase)
                begin
                    tmp_a={tmp_a[62:0],1'b0};
                    if(tmp_a>=tmp_b)tmp_a=tmp_a-tmp_b+1'b1;
                    else tmp_a=tmp_a;
                end
            end
        end
    end
    assign q=(dividend[31]^divisor[31]?~(tmp_a[31:0])+1:tmp_a[31:0]);
    assign r=(dividend[31]?~(tmp_a[63:32])+1:tmp_a[63:32]);

endmodule
