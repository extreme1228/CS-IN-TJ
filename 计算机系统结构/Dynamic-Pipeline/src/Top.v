`timescale 1ns / 1ps

//整个动态流水线的顶层程序
module pipeline_top(
    input clk,
    input rst,
    input switch_res,// 选择输出结果信号
    input stop,//外部中断信号
    //output [31:0]res,//输出的结果
    output [7:0] o_seg,//七段数码管参数
    output [7:0] o_sel //七段数码管参数                                                                                                
    );

    parameter K = 99_999;

    reg [31:0] cnt;
    reg clk_new;

    wire [31:0] output_res;//计算结果
    wire [31:0] clear_res;// 全零值，清空结果
    wire [31:0] seg7_in;//七段数码管输入值
    wire [31:0] instruction;
    wire [31:0] pc;
    

    //时钟分频程序，方便下板演示
    always @ (posedge clk or posedge rst) 
    begin
        if(rst) begin
            clk_new <= 0;
            cnt<=0;
        end
        else if(cnt == K) begin
            cnt <= 0;
            clk_new <= ~clk_new;
        end
        else
            cnt<=cnt+1;
    end

    //cpu顶层程序，负责五个阶段IF-ID-EX-ME-WE
    cpu_top cpu(
        .clk(clk),   //分频之后的时钟信号
        .rst(rst),
        .instruction(instruction),
        .pc(pc),
        .reg28(output_res),//输出结果存储在28号寄存器
        .reg29(clear_res),//29号寄存器没有使用过，所以值为0
        .stop(stop) //外部中断信号
    );

    //选择器，选择一个结果输出
    mux_2_32 res_mux(
        .C0(output_res),
        .C1(clear_res),
        .S0(switch_res),
        .oZ(seg7_in)
    );
    assign res = seg7_in;
    //七段数码管输出最终结果
    seg7x16 seg7(clk, rst, 1, seg7_in, o_seg, o_sel);

endmodule
