`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/28 15:38:04
// Design Name: 
// Module Name: MULTU
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


// module MULTU(
//     input [31:0] a,
//     input [31:0] b,
//     input clk,
//     input reset,
// 	output [63:0] z
//     );

// 	reg [15:0]cnt = 0;
//     reg [32:0]high_bit = 0;
// 	reg [31:0]low_bit = 0;
//     reg tmp=0;

// 	always@(posedge clk or posedge reset) 
//     begin
// 		if(reset==1) begin
// 			cnt<=0;
// 			high_bit<=0;
//             low_bit<=0;
// 		end
// 		else if(cnt==32) begin
// 		end
// 		else begin
// 			if(b[cnt]==1'b1)
//             begin
// 				high_bit=high_bit+a;
// 			end
// 			low_bit={high_bit[0],low_bit[31:1]};
// 			high_bit={1'b0,high_bit[32:1]};
// 			cnt=cnt+1;
// 		end
// 	end

// 	assign z={high_bit[31:0],low_bit};

// endmodule
module MULTU(
    input clk,
    input reset,
    input [31:0] a,
    input [31:0] b,
    output [63:0] z
    );
    reg [63:0] ans;
    reg [63:0] reg_a;
    reg [63:0] reg_b;
    parameter cnt = 32;

    always @(posedge clk or negedge reset) 
    begin
        if(reset) 
        begin
            ans <= 0;
            reg_a <= 0;
            reg_b <= 0;
        end
        else 
        begin
            reg_a = a;
            reg_b = b;
            ans = 0;     
            repeat(cnt) begin
                if(reg_b[0]) 
                begin
                    ans = ans + reg_a;
                end
                reg_a = reg_a<<1;
                reg_b = reg_b>>1;
            end
        end
    end
    assign z = ans;
endmodule

