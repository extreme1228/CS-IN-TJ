`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/04 09:24:53
// Design Name: 
// Module Name: DIVU
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


module DIVU(
    input [31:0] dividend,
    input [31:0] divisor,
    input start,
    input clock,
    input reset,
    output [31:0] q,
    output [31:0] r,
    output reg busy
    );
    reg [63:0]tmp_a;
    reg[63:0]tmp_b;
    reg[15:0]cnt;
    // reg mul_end=0;
    parameter kase = 32;
    always @(posedge clock or posedge reset)
    begin
        if(reset==1)
        begin
            cnt<=0;
            busy<=0;
            // mul_end<=0;
        end
        else
        begin
            if(start==1)begin
                cnt=0;
                busy=1;
                tmp_a={32'b0,dividend};
                tmp_b={divisor,32'b0};
                repeat(kase)
                begin
                    tmp_a={tmp_a[62:0],1'b0};
                    if(tmp_a>=tmp_b)tmp_a=tmp_a-tmp_b+1'b1;
                    else tmp_a=tmp_a;
                end
                // mul_end=1;
            end
        end
    end
    assign q=tmp_a[31:0];
    assign r=tmp_a[63:32];
endmodule
