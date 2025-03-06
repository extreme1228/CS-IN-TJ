`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/13 21:20:36
// Design Name: 
// Module Name: Control_Unit
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

//本模块作用是分析指令确定所有控制信号
module Control_Unit(
    input [31:0] inst,//得到的cpu指令
    input [31:0] pc,//上一条pc
    output reg [31:0] pc_out,//因为涉及到转移指令，所以需要分情况讨论下一条pc的值

    output [4:0] rs,
    output [4:0] rt,//解析指令得到寄存器编码并输出方便RegFile模块调用

    input[31:0] rdata1,
    input [31:0] rdata2,//从RegFile里读取到的数据

    output reg[5:0] alu_func,//分析指令得到的alu执行操作类型信号
    output reg[31:0] alu_a,
    output reg[31:0] alu_b,

    input [31:0] ram_rdata,//从DMEM中读取到的数据
    input [31:0] alu_res,//从ALU模块中计算得到的数据

    output reg w_ena,//RegFile写使能信号
    output [4:0] waddr,//写寄存器信号,指出是哪个寄存器
    output reg [31:0] wdata,//具体要写入寄存器中的值

    output ram_ena,//RAM使能信号，控制读和写
    output [31:0] ram_addr,//RAM写入的地址
    output reg [31:0] ram_wdata //RAM写入的值
    );

    //接下来首先定义几个有关指令具体类型的常量，方便接下来继续编写代码
    //alu_func的类型
    parameter ADD = 0 ;
    parameter ADDU =1;
    parameter SUB = 2;
    parameter SUBU = 3;
    parameter AND = 4;
    parameter OR = 5;
    parameter XOR = 6;
    parameter NOR = 7;
    parameter SLT = 8;
    parameter SLTU = 9;
    parameter SLL = 10;
    parameter SRL = 11;
    parameter SRA = 12;
    parameter SLLV = 13;
    parameter SRLV = 14;
    parameter SRAV = 15 ;
    parameter LUI = 16;
    //三种指令类型及其具体分类
    parameter No_op = 6'b111111;
    parameter No_func = 6'b111111;
    parameter R_type_op = 6'b000000;
    parameter add_func = 6'b100000;
    parameter addu_func = 6'b100001;
    parameter sub_func = 6'b100010;
    parameter subu_func = 6'b100011;
    parameter and_func = 6'b100100;
    parameter or_func = 6'b100101;
    parameter xor_func = 6'b100110;
    parameter nor_func = 6'b100111;
    parameter slt_func = 6'b101010;
    parameter sltu_func = 6'b101011;
    parameter sll_func = 6'b000000;
    parameter srl_func = 6'b000010;
    parameter sra_func = 6'b000011;
    parameter sllv_func = 6'b000100;
    parameter srlv_func = 6'b000110;
    parameter srav_func = 6'b000111;
    parameter jr_func = 6'b001000;

    parameter addi_op = 6'b001000;
    parameter addiu_op = 6'b001001;
    parameter andi_op = 6'b001100;
    parameter ori_op = 6'b001101;
    parameter xori_op = 6'b001110;
    parameter lw_op = 6'b100011;
    parameter sw_op = 6'b101011;
    parameter beq_op = 6'b000100;
    parameter bne_op = 6'b000101;
    parameter slti_op = 6'b001010;
    parameter sltiu_op = 6'b001011;
    parameter lui_op = 6'b001111;

    parameter j_op = 6'b000010;
    parameter jal_op = 6'b000011;

    //首先，我们按照所有可能的指令格式将指令分解为可能有意义的几段
    wire[5:0]op;
    wire [4:0]shamt;
    wire [5:0]func;
    wire [15:0] imm;
    wire [25:0] addr;
    wire [5:0] rd;
    assign op = inst[31:26];
    assign shamt = inst[10:6];
    assign func = inst[5:0];
    assign imm = inst[15:0];
    assign addr = inst[25:0];
    assign rs = inst[25:21];
    assign rt = inst[20:16];
    assign rd = inst[15:11];
    wire [31:0] shamt_ex;//shamt的32位扩充
    wire [31:0] imm_ex;//imm的32位扩充
    assign shamt_ex = {27'b0,shamt};
    assign imm_ex = (op == andi_op||op == ori_op||op == xori_op)?{16'b0,imm}:{{16{imm[15]}},imm};

    //确定指令需要写入哪个寄存器
    assign waddr = (op == R_type_op)?rd:((op == jal_op)?5'b11111:rt);

    //确定所有可能的下一个pc的值
    wire[31:0]npc;
    wire [31:0]pc_jump;
    wire [31:0] pc_branch;
    assign npc = pc+4;
    assign pc_jump = {npc[31:28],addr,2'b00};
    assign pc_branch = npc +{{14{imm[15]}},imm,2'b00};

    //根据指令确定DMEM的信号
    assign ram_ena = (op == sw_op)?1:0;//1是写信号，0是读信号
    assign ram_addr = rdata1 + imm_ex;//lw或sw指令需要的DMEM地址
    reg [31:0]load_data;//向DMEM中写入的值

    //ALU部分信号
    always@(*)
    begin
        //首先给ALU_data赋值
        case(op)
        R_type_op:
        begin
            case(func)
            add_func,sub_func,
            addu_func,subu_func,
            and_func,or_func,xor_func,
            nor_func,slt_func,sltu_func,
            sllv_func,srlv_func,srav_func:
            begin
                alu_a<=rdata1;
                alu_b<=rdata2;
            end
            sll_func,srl_func,sra_func:
            begin
                alu_a<=shamt_ex;
                alu_b<=rdata2;
            end
            default:
            begin
                alu_a<=rdata1;
                alu_b<=rdata2;
            end
            endcase
        end
        addi_op,addiu_op,andi_op,
        ori_op,xori_op,slti_op,
        sltiu_op,lui_op:
        begin
            alu_a<=rdata1;
            alu_b<=imm_ex;
        end
        default:
        begin
            alu_a<=rdata1;
            alu_b<=rdata2;
        end
        endcase

        //接下来给ALU_func赋值
        case(op)
            R_type_op:
            begin
                case(func)
                    add_func : alu_func<=ADD;
                    addu_func : alu_func<=ADDU;
                    sub_func : alu_func<=SUB;
                    subu_func : alu_func<=SUBU;
                    and_func : alu_func<=AND;
                    or_func : alu_func<=OR;
                    xor_func : alu_func<=XOR;
                    nor_func : alu_func<=NOR;
                    slt_func : alu_func<=SLT;
                    sltu_func : alu_func<=SLTU;
                    sll_func : alu_func<=SLL;
                    sllv_func : alu_func<=SLLV;
                    srl_func : alu_func<=SRL;
                    srlv_func : alu_func<=SRLV;
                    sra_func : alu_func<=SRA;
                    srav_func : alu_func<=SRAV;
                    default :alu_func<=ADDU;
                endcase
            end
            addi_op : alu_func<=ADD;
            addiu_op : alu_func<=ADDU;
            andi_op : alu_func<=AND;
            ori_op : alu_func<=OR;
            xori_op : alu_func<=XOR;
            slti_op : alu_func<=SLT;
            sltiu_op : alu_func<=SLTU;
            lui_op : alu_func<=LUI;
            default : alu_func<=ADDU;
        endcase
    end

    //RAM部分信号
    always@(*)
    begin
        //load信号
        case(op)
            lw_op : load_data<=ram_rdata;
            default : load_data<=ram_rdata;
        endcase
        //sw信号
        case(op)
            sw_op : ram_wdata<=rdata2;
            default : ram_wdata<=rdata2;
        endcase
    end

    //RegFile部分信号
    always@(*)
    begin
        case(op)
            sw_op,beq_op,bne_op,
            j_op : w_ena<=0;
            default : w_ena<=1;
        endcase

        case(op)
            R_type_op : wdata<=alu_res;
            jal_op : wdata<=npc;
            lw_op : wdata<=load_data;
            default : wdata<=alu_res;
        endcase
    end

    //PCRegFile
    always@(*)
    begin
        case(op)
            R_type_op :
            begin
                case(func)
                    jr_func : pc_out<=rdata1;
                    default : pc_out<=npc;
                endcase
            end
            j_op,jal_op : pc_out<=pc_jump;
            beq_op : pc_out<=(rdata1 == rdata2)?pc_branch:npc;
            bne_op : pc_out<=(rdata1!=rdata2)?pc_branch:npc;
            default : pc_out<=npc;
        endcase
    end
endmodule
