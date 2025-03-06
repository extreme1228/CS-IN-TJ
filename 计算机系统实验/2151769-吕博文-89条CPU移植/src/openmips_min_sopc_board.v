`timescale 1ns / 1ps



module openmips_min_sopc_board(
    input clk_in,
    input reset,
    input [1:0]res_choose,
    output [7:0] o_seg,
    output [7:0] o_sel
    );
    wire clk_new;
    wire [31:0]seg_data;
    wire [31:0] inst,pc,result;

    divider#(100000)div_cpu(clk_in,reset,clk_new);

    seg7x16 seg7 (clk_in,reset,1,seg_data,o_seg,o_sel);
    assign seg_data = (res_choose[1]?inst:(res_choose[0]?pc:result));

    openmips_min_sopc cpu_top(clk_new,reset,pc,inst,result);

endmodule
