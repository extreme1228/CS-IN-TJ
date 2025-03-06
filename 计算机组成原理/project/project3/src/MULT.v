`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/28 20:21:42
// Design Name: 
// Module Name: MULT
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


module MULT(
    input clk,
    input reset,
    input [31:0] a,
    input [31:0] b,
    output [63:0] z
    );
    // reg [15:0]cnt = 0;
    // reg [32:0]high_bit = 0;
	// reg [31:0]low_bit = 0;
    // wire signz;
    // wire [63:0]tmp;
    // wire [31:0]abs_a;
    // wire [31:0]abs_b;
    // assign sign1=a[31]; 
    // assign sign2=b[31];
    // assign signz=a[31]^b[31];
    // assign abs_a=a[31]?~(a-1):a;
    // assign abs_b=b[31]?~(b-1):b;
	// always@(posedge clk or posedge reset) 
    // begin
	// 	if(reset==1) begin
	// 		cnt<=0;
	// 		high_bit<=0;
    //         low_bit<=0;
	// 	end
	// 	else if(cnt==32) begin
	// 	end
	// 	else begin
	// 		if(abs_b[cnt]==1'b1)
    //         begin
	// 			high_bit=high_bit+abs_a;
	// 		end
	// 		low_bit={high_bit[0],low_bit[31:1]};
	// 		high_bit={1'b0,high_bit[32:1]};
	// 		cnt=cnt+1;
	// 	end
	// end

	// assign tmp={high_bit[31:0],low_bit};
    // assign z=signz?(~tmp+1):tmp;
    reg [63:0] ans;
    reg [63:0] reg_a;
    reg [63:0] reg_b;
    parameter cnt = 31;

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
            reg_a = {{32{a[31]}},a};
            reg_b = {{32{b[31]}},b};
            // reg_b[31]=0;
            ans = 0;     
            repeat(cnt) begin
                if(reg_b[0]) 
                begin
                    ans = ans + reg_a;
                end
                reg_a = reg_a<<1;
                reg_b = reg_b>>1;
            end
            if(reg_b[0]==1)ans=ans-reg_a; 
        end
    end
    assign z = ans;

endmodule
