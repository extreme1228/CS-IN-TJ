`timescale 1ns / 1ps
`include "define.vh"
module ID_EX_Reg(
    input clk,                           
    input rst,                           
    input wena,                          // 输入写使能信号
    input [31:0] id_pc4,                // 输入来自ID阶段的下一条PC值
    input [31:0] id_rs_data_out,         // 输入来自ID阶段的rs寄存器数据
    input [31:0] id_rt_data_out,         // 输入来自ID阶段的rt寄存器数据
    input [31:0] id_imm,                
    input [31:0] id_shamt,              
    input [31:0] id_cp0_out,            // 输入来自ID阶段的CP0输出
    input [31:0] id_hi_out,             // 输入来自ID阶段的hi寄存器输出
    input [31:0] id_lo_out,             // 输入来自ID阶段的lo寄存器输出
    input [4:0] id_rf_waddr,            // 输入来自ID阶段的寄存器写地址
    input id_clz_ena,                   // 输入来自ID阶段的clz使能信号
    input id_mul_ena,                   
    input id_div_ena,                 
    input id_dmem_ena,                 
    input id_mul_sign,                  
    input id_div_sign,                
    input id_cutter_sign,               
    input [3:0] id_aluc,                // 输入来自ID阶段的ALU控制信号
    input id_rf_wena,                   // 输入来自ID阶段的寄存器文件写使能信号
    input id_hi_wena,                  
    input id_lo_wena,                 
    input id_dmem_wena,                 // 输入来自ID阶段的数据存储器写使能信号
    input [1:0] id_dmem_w_cs,           // 输入来自ID阶段的数据存储器写控制信号
    input [1:0] id_dmem_r_cs,           // 输入来自ID阶段的数据存储器读控制信号
    input stall,                        // 输入流水线暂停信号
    input id_cutter_mux_sel,            // 输入来自ID阶段的截断器选择信号
    input id_alu_mux1_sel,              
    input [1:0] id_alu_mux2_sel,        
    input [1:0] id_hi_mux_sel,          // 输入来自ID阶段的hi寄存器写入选择信号
    input [1:0] id_lo_mux_sel,          // 输入来自ID阶段的lo寄存器写入选择信号
    input [2:0] id_cutter_sel,          // 输入来自ID阶段的截断器选择信号
    input [2:0] id_rf_mux_sel,          
    input [5:0] id_op,                  // 输入来自ID阶段的操作码
    input [5:0] id_func,                // 输入来自ID阶段的功能码
    output reg [31:0] exe_pc4,         
    output reg [31:0] exe_rs_data_out,   
    output reg [31:0] exe_rt_data_out,  
    output reg [31:0] exe_imm,          // 输出到EX阶段的立即数
    output reg [31:0] exe_shamt,       
    output reg [31:0] exe_cp0_out,      // 输出到EX阶段的CP0输出
    output reg [31:0] exe_hi_out,      
    output reg [31:0] exe_lo_out,      
    output reg [4:0] exe_rf_waddr,      
    output reg exe_clz_ena,             // 输出到EX阶段的clz使能信号
    output reg exe_mul_ena,             // 输出到EX阶段的乘法器使能信号
    output reg exe_div_ena,             // 输出到EX阶段的除法器使能信号
    output reg exe_dmem_ena,           
    output reg exe_mul_sign,            // 输出到EX阶段的乘法器符号扩展信号
    output reg exe_div_sign,            // 输出到EX阶段的除法器符号扩展信号
    output reg exe_cutter_sign,         
    output reg [3:0] exe_aluc,          // 输出到EX阶段的ALU控制信号
    output reg exe_rf_wena,             // 输出到EX阶段的寄存器文件写使能信号
    output reg exe_hi_wena,             // 输出到EX阶段的hi寄存器写使能信号
    output reg exe_lo_wena,             
    output reg exe_dmem_wena,           // 输出到EX阶段的数据存储器写使能信号
    output reg [1:0] exe_dmem_w_cs,     
    output reg [1:0] exe_dmem_r_cs,     // 输出到EX阶段的数据存储器读控制信号
    output reg exe_alu_mux1_sel,       
    output reg [1:0] exe_alu_mux2_sel,  
    output reg exe_cutter_mux_sel,      // 输出到EX阶段的截断器选择信号
    output reg [1:0] exe_hi_mux_sel,    
    output reg [1:0] exe_lo_mux_sel,    // 输出到EX阶段的lo寄存器写入选择信号
    output reg [2:0] exe_cutter_sel,    // 输出到EX阶段的截断器选择信号
    output reg [2:0] exe_rf_mux_sel,   
    output reg [5:0] exe_op,            // 输出到EX阶段的操作码
    output reg [5:0] exe_func           // 输出到EX阶段的功能码
    );

    always @ (posedge clk or posedge rst) begin
        if(rst == `RST_ENABLED || stall == `STOP) begin
            exe_imm <= 32'b0;
            exe_shamt <= 32'b0;
            exe_cp0_out <= 32'b0;
            exe_mul_sign <= 1'b0;
            exe_div_sign <= 1'b0;
            exe_cutter_sign <= 1'b0;
            exe_aluc <= 4'b0;
            exe_dmem_r_cs <= 2'b0;
            exe_alu_mux1_sel <= 1'b0;
            exe_alu_mux2_sel <= 1'b0;
            exe_rf_wena <= 1'b0;
            exe_pc4 <= 32'b0;
            exe_rs_data_out <= 32'b0;
            exe_rt_data_out <= 32'b0;
            exe_hi_wena <= 1'b0;
            exe_lo_wena <= 1'b0;
            exe_hi_out <= 32'b0;
            exe_lo_out <= 32'b0;
            exe_rf_waddr <= 5'b0;
            exe_clz_ena <= 1'b0;
            exe_mul_ena <= 1'b0;
            exe_div_ena <= 1'b0;
            exe_dmem_ena <= 1'b0;
          
            exe_dmem_wena <= 1'b0;
            exe_dmem_w_cs <= 2'b0;
          
            exe_cutter_mux_sel <= 1'b0;
            exe_hi_mux_sel <= 2'b0;
            exe_lo_mux_sel <= 2'b0;
            exe_cutter_sel <= 3'b0;
            exe_rf_mux_sel <= 3'b0;
            exe_op <= 6'b0;
            exe_func <= 6'b0;
        end
        
        else if(wena == `WRITE_ENABLED) begin
           
            exe_alu_mux1_sel <= id_alu_mux1_sel;
            exe_mul_sign <= id_mul_sign;
            exe_div_sign <= id_div_sign;
            exe_cutter_sign <= id_cutter_sign;
            exe_aluc <= id_aluc;
            exe_rf_wena <= id_rf_wena;
            exe_hi_wena <= id_hi_wena;
           
            exe_lo_mux_sel <= id_lo_mux_sel;
            exe_cutter_sel <= id_cutter_sel;
            exe_rf_mux_sel <= id_rf_mux_sel;
            exe_alu_mux2_sel <= id_alu_mux2_sel;
            exe_imm <= id_imm;
            exe_shamt <= id_shamt;
            exe_cp0_out <= id_cp0_out;
            exe_lo_wena <= id_lo_wena;
            exe_dmem_wena <= id_dmem_wena;
            exe_dmem_w_cs <= id_dmem_w_cs;
            exe_dmem_r_cs <= id_dmem_r_cs;
            exe_cutter_mux_sel <= id_cutter_mux_sel;
            exe_hi_mux_sel <= id_hi_mux_sel;
            exe_hi_out <= id_hi_out;
            exe_lo_out <= id_lo_out;
            exe_rf_waddr <= id_rf_waddr;
            exe_clz_ena <= id_clz_ena;
            exe_mul_ena <= id_mul_ena;
            exe_div_ena <= id_div_ena;
            exe_pc4 <= id_pc4;
            exe_rs_data_out <= id_rs_data_out;
            exe_rt_data_out <= id_rt_data_out;
            exe_dmem_ena <= id_dmem_ena;
         
            exe_op <= id_op;
            exe_func <= id_func;
        end
    end 

endmodule