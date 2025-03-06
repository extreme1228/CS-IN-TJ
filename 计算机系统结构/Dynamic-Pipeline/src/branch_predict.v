`timescale 1ns / 1ps
`include "define.vh"

module branch_predict(
    input clk,                
    input rst,                
    input [31:0] data_in1,   
    input [31:0] data_in2,    
    input [5:0] op,           // 操作码
    input [5:0] func,         // 功能码
    input exception,          // 异常信号
    output reg is_branch      // 输出的分支信号
    );

	always @ (*) begin
	    if(rst == `RST_ENABLED)
	        is_branch <= 1'b0; // 复位时，分支信号为0
		else if(op == `BEQ_OP) 
			is_branch <= (data_in1 == data_in2) ? 1'b1 : 1'b0; // 如果是BEQ指令，根据数据比较结果设置分支信号
        else if(op == `BNE_OP) 
			is_branch <= (data_in1 != data_in2) ? 1'b1 : 1'b0; // 如果是BNE指令，根据数据比较结果设置分支信号
		else if(op == `BGEZ_OP) 
			is_branch <= (data_in1 >= 0) ? 1'b1 : 1'b0;	// 如果是BGEZ指令，根据数据比较结果设置分支信号
		else if(op == `TEQ_OP && func == `TEQ_FUNC)
			is_branch <= (data_in1 == data_in2) ? 1'b1 : 1'b0; // 如果是TEQ指令，根据数据比较结果设置分支信号
		else if(op == `J_OP)
			is_branch <= 1'b1; // 如果是J指令，设置分支信号为1
	    else if(op == `JAL_OP)
	        is_branch <= 1'b1; // 如果是JAL指令，设置分支信号为1
	    else if(op == `JR_OP && func == `JR_FUNC)
            is_branch <= 1'b1; // 如果是JR指令，设置分支信号为1
        else if(op == `JALR_OP && func == `JALR_FUNC)
            is_branch <= 1'b1; // 如果是JALR指令，设置分支信号为1
        else if(exception)
            is_branch <= 1'b1; // 如果有异常信号，设置分支信号为1
        else
            is_branch <= 1'b0; // 其他情况下，分支信号为0
	end      
endmodule
