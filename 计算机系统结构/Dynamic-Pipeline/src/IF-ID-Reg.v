`timescale 1ns / 1ps  

`include "define.vh" 

//根据IF-ID中间的流水寄存器的一些情况决定是否要对ID阶段使用的PC或指令做出改变
module IF_ID_Reg(
    input clk,                
    input rst,                
    input [31:0] if_pc4,     // IF阶段的PC + 4
    input [31:0] if_instruction,  // IF阶段的指令
    input stall,             // 是否暂停流水线的信号
    input is_branch,         // 是否是分支指令的信号
    output reg [31:0] id_pc4,     // ID阶段使用的PC + 4
    output reg [31:0] id_instruction  // ID阶段使用的指令
    );

    always @ (posedge clk or posedge rst)  
    begin
		if (rst == `RST_ENABLED) begin  
		    id_pc4 <= `ZERO_32BIT;      // 将ID阶段的PC + 4重置为0
		    id_instruction <= `ZERO_32BIT; // 将ID阶段的指令重置为0       
		end

        else if(is_branch == 1'b1) begin 
            id_pc4 <= 32'h0;              // 将ID阶段的PC + 4重置为0
            id_instruction <= 32'h0;      // 将ID阶段的指令重置为0
        end

        else if(stall == `RUN) begin 
		    id_pc4 <= if_pc4;         // 将IF阶段的PC + 4传递给ID阶段
		    id_instruction <= if_instruction; // 将IF阶段的指令传递给ID阶段
		end
	end

endmodule
