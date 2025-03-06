`timescale 1ns / 1ps

//Multiply and Division Unit  乘除法器
module MDU(
    input clk,
    input rst,
    input [2:0]mduc,//控制乘除法的类型
    input [31:0] a,
    input [31:0] b,
    output [63:0] mul_res,
    output reg [31:0] high,
    output reg [31:0] low,
    output reg pc_ena
    );
    //定义常量
    parameter MDU_multu = 3'h2;
    parameter MDU_div = 3'h3;
    parameter MDU_divu = 3'h4;
    parameter MDU_mthi = 3'h5;
    parameter MDU_mtlo = 3'h6;

    //定义乘法的相关接口
    wire [63:0] mult_res,multu_res;
    assign mul_res = mult_res;

    //除法相关接口
    wire [63:0]div_res,divu_res;
    wire div_start,divu_start;
    wire div_busy,divu_busy;
    wire div_over,divu_over;
    assign div_over = ~ div_busy;
    assign divu_over = ~ divu_busy;

    assign div_start = (mduc == MDU_div&&div_busy == 0)?1:0;
    assign divu_start = (mduc == MDU_divu&&divu_busy == 0)?1:0;

    always @(*)
    begin
        case(mduc)
            MDU_div:pc_ena = (div_over == 1||mduc!=MDU_div)?1:0;
            MDU_divu:pc_ena = (divu_over ==1||mduc!=MDU_divu)?1:0;
            default:pc_ena = 1;
        endcase
    end

    always @(negedge clk or posedge rst)
    begin
        if(rst == 1)begin
            high<=32'b0;
            low<=32'b0;
        end
        else
        begin
            case (mduc)
                MDU_multu:{high,low}<=multu_res;
                MDU_div:{low,high}<=div_res;
                MDU_divu:{low,high}<=divu_res;
                MDU_mthi:high<=a;
                MDU_mtlo:low<=a;
            endcase
        end
    end

    //乘法器
    MUL mul_unit(
        .a(a),
        .b(b),
        .mult_res(mult_res),
        .multu_res(multu_res)
    );

    //除法器
    DIV div_unit(
        .a(a),
        .b(b),
        .div_res(div_res),
        .divu_res(divu_res),
        .div_busy(div_busy),
        .divu_busy(divu_busy)
    );

endmodule
