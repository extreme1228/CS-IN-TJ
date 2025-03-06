`timescale 1ns / 1ps
`include "define_cpu.vh"
//cpu模块
module CPU(
    input rst,
    input clk,
    output DM_W,//DM写信号
    output DM_R,//DM读信号
    input [31:0] IM_inst,
    output [31:0] DM_addr,//DM地址
    input [31:0] DM_rdata,//DM读到的数据
    output [31:0] PC_out,//PC输出结果
    output [31:0] DM_wdata,    
    output [3:0] Byte_ena
    );

//IF阶段
// 声明程序计数器（if_pc）和指令（if_inst）的线路
wire[31:0] if_pc;
wire[31:0] if_inst;

// IF-ID 阶段寄存器
// 保存下一个程序计数器和 ID 阶段的指令
reg[31:0] if_id_npc;
reg[31:0] if_id_inst;

// ID 阶段
// 用于符号扩展和零扩展数据的线路，以及控制信号
wire[31:0] if_sext_16, id_uext_16, id_uext_5, id_sext_18;
wire[4:0] id_rsc, id_rtc;
wire [31:0] id_rs, id_rt;
wire id_pc_ena;
wire[31:0] id_pc_in, id_npc;
wire[31:0] id_alu_a, id_alu_b;
wire[4:0] id_cp0_raddr;
wire[31:0] id_cp0_rdata, id_cp0_epcout, id_cp0_status;
wire[31:0] id_pass_data;

//ID-EX
reg[31:0] id_ex_alua,id_ex_alub;
reg[31:0] id_ex_pass_data; 
reg[31:0] id_ex_inst;

//EX
// 执行阶段（EX）的算术运算单元 A、B、和输出 O 的线路
wire[31:0] ex_alua, ex_alub, ex_aluo;
// 执行阶段的乘法器输入 A、B、无符号输入 A、B、以及输出 Z 的线路
wire[31:0] ex_mula, ex_mulb, ex_multua, ex_multub;
wire[63:0] ex_mulz, ex_multuz;
// 执行阶段的除法器和除法器（无符号）控制信号
wire ex_div_start, ex_div_busy, ex_divu_start, ex_divu_busy;
// 执行阶段的除法器输入：被除数、除数、商和余数（有符号）
wire[31:0] ex_div_dividend, ex_div_divisor, ex_div_q, ex_div_r;
// 执行阶段的除法器输入：被除数、除数、商和余数（无符号）
wire[31:0] ex_divu_dividend, ex_divu_divisor, ex_divu_q, ex_divu_r;

// EX-MEM 阶段寄存器
// 存储除法器结果的商和余数
reg[31:0] ex_mem_div_q, ex_mem_div_r;
// 存储乘法器结果
reg[63:0] ex_mem_mulz;
// 存储 ALU 的输出
reg[31:0] ex_mem_aluo;
// 存储传递给下一阶段的数据
reg[31:0] ex_mem_pass_data;
// 存储指令
reg[31:0] ex_mem_inst;
// 存储 ALU 溢出标志
reg ex_mem_overflowFlag;  // ALU 溢出标志

// MEM 阶段
// 存储器数据的字节和半字扩展
wire[31:0] mem_byte_ext, mem_half_ext;
// 数据存储器（Data Memory）读写控制信号
wire mem_dm_r, mem_dm_w;
// 数据存储器读取和写入的数据、以及地址
wire[31:0] mem_dm_rdata, mem_dm_wdata, mem_dm_addr;
// 用于指定字节使能的线路
wire[3:0] mem_byte_ena;



// MEM-WB 阶段寄存器
// 存储传递给下一阶段的数据
reg[31:0] mem_wb_pass_data;
// 存储除法器结果的商和余数
reg[31:0] mem_wb_div_q, mem_wb_div_r;
// 存储 ALU 溢出标志
reg mem_wb_overflowFlag;  // ALU 溢出标志
// 存储乘法器结果
reg[63:0] mem_wb_mulz;
// 存储 ALU 的输出
reg[31:0] mem_wb_aluo;
// 存储指令
reg[31:0] mem_wb_inst;


//WB
wire wb_rf_wena;
wire[4:0]wb_rdc,wb_cp0_waddr;
wire[31:0]wb_rd,wb_cp0_wdata;
wire wb_hi_wena,wb_lo_wena;
wire[31:0]wb_hi_wdata,wb_lo_wdata;

//others
reg[31:0]HI,LO;
reg[4:0]stall;


//IF阶段的译码
wire [31:0]lbw_tmp1;
wire [4:0] ifRt = if_inst[20:16];
wire [5:0] ifFunc = if_inst[5:0];
wire [5:0] ifOp =if_inst[31:26];
wire [4:0] ifRs = if_inst[25:21];


wire ifOpLui = (ifOp == `OP_LUI);
wire ifOpXori = (ifOp == `OP_XORI);
wire ifOpSlti = (ifOp == `OP_SLTI);
wire ifOpAddu = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_ADDU);
wire ifOpAnd = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_AND);
wire ifOpBeq = (ifOp == `OP_BEQ);
wire ifOpAddi = (ifOp == `OP_ADDI);
wire ifOpAddiu = (ifOp == `OP_ADDIU);
wire ifOpJ = (ifOp == `OP_J);
wire ifOpJal = (ifOp == `OP_JAL);
wire ifOpJr = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_JR);
wire ifOpAndi = (ifOp == `OP_ANDI);
wire ifOpOri = (ifOp == `OP_ORI);
wire ifOpSltiu = (ifOp == `OP_SLTIU);
wire ifOpBne = (ifOp == `OP_BNE);
wire ifOpLw = (ifOp == `OP_LW);



wire ifOpSll = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_SLL && if_inst != 32'b0);
wire ifOpSllv = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_SLLV);
wire ifOpSltu = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_SLTU);
wire ifOpSra = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_SRA);
wire ifOpSrl = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_SRL);
wire ifOpSubu = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_SUBU);

wire ifOpAdd = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_ADD);
wire ifOpSub = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_SUB);

wire ifOpSlt = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_SLT);
wire ifOpSrlv = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_SRLV);
wire ifOpSrav = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_SRAV);
wire ifOpClz = (ifOp == `OP_SPECIAL2 && ifFunc == `FUNCT_CLZ);

wire ifOpDivu = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_DIVU);
wire ifOpSw = (ifOp == `OP_SW);
wire ifOpXor = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_XOR);
wire ifOpNor = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_NOR);
wire ifOpOr = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_OR);
wire ifOpEret = (ifOp == `OP_COP0 && ifFunc == `FUNCT_ERET);
wire ifOpJalr = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_JALR);
wire ifOpLbu = (ifOp == `OP_LBU);
wire ifOpLhu = (ifOp == `OP_LHU);
wire ifOpSb = (ifOp == `OP_SB);
wire ifOpSh = (ifOp == `OP_SH);
wire ifOpLb = (ifOp == `OP_LB);

wire ifOpLh = (ifOp == `OP_LH);
wire ifOpMfc0 = (ifOp == `OP_COP0 && ifRs == `RS_MF);
wire ifOpMthi = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_MTHI);
wire ifOpMtlo = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_MTLO);
wire ifOpMul = (ifOp == `OP_SPECIAL2 && ifFunc == `FUNCT_MUL);
wire ifOpMfhi = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_MFHI);
wire ifOpMflo = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_MFLO);

wire ifOpTeq = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_TEQ);
wire ifOpBreak = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_BREAK);
wire ifOpDiv = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_DIV);
wire ifOpBgez = (ifOp == `OP_REGIMM && ifRt == `RT_BGEZ);
wire ifOpMtc0 = (ifOp == `OP_COP0 && ifRs == `RS_MT);
wire ifOpMultu = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_MULTU);
wire ifOpSyscall = (ifOp == `OP_SPECIAL && ifFunc == `FUNCT_SYSCALL);


//ID阶段的译码
wire [5:0] idOp =if_id_inst[31:26];
wire [4:0] idRt = if_id_inst[20:16];
wire [5:0] idFunc = if_id_inst[5:0];
wire [4:0] idRs = if_id_inst[25:21];
wire [31:0]lbw_tmp2;


wire idOpAndi = (idOp == `OP_ANDI);
wire idOpOri = (idOp == `OP_ORI);
wire idOpSltiu = (idOp == `OP_SLTIU);
wire idOpAddi = (idOp == `OP_ADDI);
wire idOpAddiu = (idOp == `OP_ADDIU);
wire idOpLui = (idOp == `OP_LUI);

wire idOpAddu = (idOp == `OP_SPECIAL && idFunc == `FUNCT_ADDU);
wire idOpAnd = (idOp == `OP_SPECIAL && idFunc == `FUNCT_AND);
wire idOpXori = (idOp == `OP_XORI);
wire idOpSlti = (idOp == `OP_SLTI);
wire idOpBne = (idOp == `OP_BNE);
wire idOpJ = (idOp == `OP_J);

wire idOpBeq = (idOp == `OP_BEQ);
wire idOpJal = (idOp == `OP_JAL);
wire idOpJr = (idOp == `OP_SPECIAL && idFunc == `FUNCT_JR);
wire idOpXor = (idOp == `OP_SPECIAL && idFunc == `FUNCT_XOR);
wire idOpNor = (idOp == `OP_SPECIAL && idFunc == `FUNCT_NOR);
wire idOpOr = (idOp == `OP_SPECIAL && idFunc == `FUNCT_OR);
wire idOpLw = (idOp == `OP_LW);

wire idOpSll = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SLL && if_id_inst != 32'b0);
wire idOpSllv = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SLLV);

wire idOpSubu = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SUBU);
wire idOpSrav = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SRAV);
wire idOpClz = (idOp == `OP_SPECIAL2 && idFunc == `FUNCT_CLZ);
wire idOpSw = (idOp == `OP_SW);
wire idOpAdd = (idOp == `OP_SPECIAL && idFunc == `FUNCT_ADD);
wire idOpSltu = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SLTU);

wire idOpSub = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SUB);
wire idOpSlt = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SLT);
wire idOpSrlv = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SRLV);
wire idOpSra = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SRA);
wire idOpSrl = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SRL);


wire idOpLhu = (idOp == `OP_LHU);
wire idOpSb = (idOp == `OP_SB);
wire idOpSh = (idOp == `OP_SH);
wire idOpLb = (idOp == `OP_LB);
wire idOpLbu = (idOp == `OP_LBU);
wire idOpLh = (idOp == `OP_LH);
wire idOpDivu = (idOp == `OP_SPECIAL && idFunc == `FUNCT_DIVU);
wire idOpEret = (idOp == `OP_COP0 && idFunc == `FUNCT_ERET);
wire idOpMfhi = (idOp == `OP_SPECIAL && idFunc == `FUNCT_MFHI);
wire idOpMflo = (idOp == `OP_SPECIAL && idFunc == `FUNCT_MFLO);
wire idOpMtc0 = (idOp == `OP_COP0 && idRs == `RS_MT);
wire idOpSyscall = (idOp == `OP_SPECIAL && idFunc == `FUNCT_SYSCALL);
wire idOpTeq = (idOp == `OP_SPECIAL && idFunc == `FUNCT_TEQ);
wire idOpMthi = (idOp == `OP_SPECIAL && idFunc == `FUNCT_MTHI);
wire idOpMtlo = (idOp == `OP_SPECIAL && idFunc == `FUNCT_MTLO);

wire idOpMultu = (idOp == `OP_SPECIAL && idFunc == `FUNCT_MULTU);

wire idOpJalr = (idOp == `OP_SPECIAL && idFunc == `FUNCT_JALR);
wire idOpMul = (idOp == `OP_SPECIAL2 && idFunc == `FUNCT_MUL);
wire idOpBgez = (idOp == `OP_REGIMM && idRt == `RT_BGEZ);
wire idOpBreak = (idOp == `OP_SPECIAL && idFunc == `FUNCT_BREAK);
wire idOpDiv = (idOp == `OP_SPECIAL && idFunc == `FUNCT_DIV);
wire idOpMfc0 = (idOp == `OP_COP0 && idRs == `RS_MF);


    // EX阶段译码
    wire [31:0]lbw_tmp3;
    wire [5:0] exOp = id_ex_inst[31:26];
    wire [5:0] exRs = id_ex_inst[25:21];
    wire [4:0] exRt = id_ex_inst[20:16];
    wire [4:0] exRd = id_ex_inst[15:11];
    wire [5:0] exFunc = id_ex_inst[5:0];
 
    //给信号赋值
    wire exOpAddiu = (exOp == `OP_ADDIU);
    wire exOpAndi = (exOp == `OP_ANDI);
    wire exOpAddi = (exOp == `OP_ADDI);


    wire[15:0] lbw_tmp4;
    wire exOpXori = (exOp == `OP_XORI);
    wire exOpSlti = (exOp == `OP_SLTI);
    wire exOpOri = (exOp == `OP_ORI);
    wire exOpSltiu = (exOp == `OP_SLTIU);
    wire exOpLui = (exOp == `OP_LUI);
    wire exOpAddu = (exOp == `OP_SPECIAL && exFunc == `FUNCT_ADDU);

    wire exOpJal = (exOp == `OP_JAL);
    wire exOpAnd = (exOp == `OP_SPECIAL && exFunc == `FUNCT_AND);

    wire exOpLw = (exOp == `OP_LW);
    wire exOpXor = (exOp == `OP_SPECIAL && exFunc == `FUNCT_XOR);
    wire exOpBeq = (exOp == `OP_BEQ);
    wire exOpBne = (exOp == `OP_BNE);
    wire exOpJ = (exOp == `OP_J);
    wire exOpJr = (exOp == `OP_SPECIAL && exFunc == `FUNCT_JR);
    wire exOpNor = (exOp == `OP_SPECIAL && exFunc == `FUNCT_NOR);
    wire exOpOr = (exOp == `OP_SPECIAL && exFunc == `FUNCT_OR);

    wire exOpSra = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SRA);
    wire exOpSrl = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SRL);
    wire exOpSltu = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SLTU);
    wire exOpSubu = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SUBU);
    wire exOpSw = (exOp == `OP_SW);
    wire exOpSll = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SLL && id_ex_inst != 32'b0);
    wire exOpSllv = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SLLV);


    wire exOpSrav = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SRAV);
    wire exOpClz = (exOp == `OP_SPECIAL2 && exFunc == `FUNCT_CLZ);
    wire exOpAdd = (exOp == `OP_SPECIAL && exFunc == `FUNCT_ADD);
    wire exOpSlt = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SLT);
    wire exOpSrlv = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SRLV);
    wire exOpDivu = (exOp == `OP_SPECIAL && exFunc == `FUNCT_DIVU);
    wire exOpEret = (exOp == `OP_COP0 && exFunc == `FUNCT_ERET);
    wire exOpSub = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SUB);
  
    wire[31:0]yff_tmp1;
    wire exOpJalr = (exOp == `OP_SPECIAL && exFunc == `FUNCT_JALR);
    wire exOpLb = (exOp == `OP_LB);
    wire exOpLhu = (exOp == `OP_LHU);
    wire exOpSb = (exOp == `OP_SB);
    wire exOpSh = (exOp == `OP_SH);
    wire exOpLh = (exOp == `OP_LH);
    wire exOpLbu = (exOp == `OP_LBU);
  
    wire[31:0]icpc_tmp1;
    wire exOpMfc0 = (exOp == `OP_COP0 && exRs == `RS_MF);
    wire exOpMfhi = (exOp == `OP_SPECIAL && exFunc == `FUNCT_MFHI);
    wire exOpMthi = (exOp == `OP_SPECIAL && exFunc == `FUNCT_MTHI);
    wire exOpMtlo = (exOp == `OP_SPECIAL && exFunc == `FUNCT_MTLO);
    wire exOpMul = (exOp == `OP_SPECIAL2 && exFunc == `FUNCT_MUL);
   

    wire exOpSyscall = (exOp == `OP_SPECIAL && exFunc == `FUNCT_SYSCALL);
    wire exOpTeq = (exOp == `OP_SPECIAL && exFunc == `FUNCT_TEQ);
    wire exOpMultu = (exOp == `OP_SPECIAL && exFunc == `FUNCT_MULTU);
    wire exOpMflo = (exOp == `OP_SPECIAL && exFunc == `FUNCT_MFLO);
    wire exOpMtc0 = (exOp == `OP_COP0 && exRs == `RS_MT);
    wire exOpBgez = (exOp == `OP_REGIMM && exRt == `RT_BGEZ);
    wire exOpBreak = (exOp == `OP_SPECIAL && exFunc == `FUNCT_BREAK);
    wire exOpDiv = (exOp == `OP_SPECIAL && exFunc == `FUNCT_DIV);

    // ME阶段译码
    wire [5:0] meOp = ex_mem_inst[31:26];
    wire [5:0] meFunc = ex_mem_inst[5:0];
    wire [5:0] meRs = ex_mem_inst[25:21];
    wire [4:0] meRt = ex_mem_inst[20:16];
    wire [4:0] meRd = ex_mem_inst[15:11];
    wire[7:0]cpu_tmp0;


    wire meOpSltiu = (meOp == `OP_SLTIU);
    wire meOpLui = (meOp == `OP_LUI);
    wire meOpAddi = (meOp == `OP_ADDI);
    wire meOpAddiu = (meOp == `OP_ADDIU);
    wire meOpAndi = (meOp == `OP_ANDI);
    wire meOpOri = (meOp == `OP_ORI);
  
    wire meOpAddu = (meOp == `OP_SPECIAL && meFunc == `FUNCT_ADDU);
    wire meOpAnd = (meOp == `OP_SPECIAL && meFunc == `FUNCT_AND);
   
    wire meOpJr = (meOp == `OP_SPECIAL && meFunc == `FUNCT_JR);
    wire meOpLw = (meOp == `OP_LW);
    wire meOpXor = (meOp == `OP_SPECIAL && meFunc == `FUNCT_XOR);
    wire meOpNor = (meOp == `OP_SPECIAL && meFunc == `FUNCT_NOR);
    wire meOpSlti = (meOp == `OP_SLTI);
    wire meOpBne = (meOp == `OP_BNE);
    wire meOpJ = (meOp == `OP_J);
    wire meOpJal = (meOp == `OP_JAL);
   
    wire meOpOr = (meOp == `OP_SPECIAL && meFunc == `FUNCT_OR);
    
    wire meOpSubu = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SUBU);
    wire meOpSll = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SLL && ex_mem_inst != 32'b0);
    wire meOpSllv = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SLLV);
    wire meOpSw = (meOp == `OP_SW);
    wire meOpAdd = (meOp == `OP_SPECIAL && meFunc == `FUNCT_ADD);
    wire meOpSub = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SUB);
    wire meOpSltu = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SLTU);
     wire meOpBeq = (meOp == `OP_BEQ);
    wire meOpXori = (meOp == `OP_XORI);
    wire meOpSra = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SRA);
    wire meOpSrav = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SRAV);
    wire meOpClz = (meOp == `OP_SPECIAL2 && meFunc == `FUNCT_CLZ);
    wire meOpDivu = (meOp == `OP_SPECIAL && meFunc == `FUNCT_DIVU);
    wire meOpSrl = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SRL);
    
    wire meOpSlt = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SLT);
    wire meOpSrlv = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SRLV);
    
    wire meOpEret = (meOp == `OP_COP0 && meFunc == `FUNCT_ERET);
    wire meOpJalr = (meOp == `OP_SPECIAL && meFunc == `FUNCT_JALR);
    wire meOpLb = (meOp == `OP_LB);
    wire meOpLbu = (meOp == `OP_LBU);
  
    wire meOpMfc0 = (meOp == `OP_COP0 && meRs == `RS_MF);
    wire meOpBgez = (meOp == `OP_REGIMM && meRt == `RT_BGEZ);
    wire meOpBreak = (meOp == `OP_SPECIAL && meFunc == `FUNCT_BREAK);
    wire meOpDiv = (meOp == `OP_SPECIAL && meFunc == `FUNCT_DIV);
    wire meOpMfhi = (meOp == `OP_SPECIAL && meFunc == `FUNCT_MFHI);
    wire meOpLhu = (meOp == `OP_LHU);
  
    wire meOpMflo = (meOp == `OP_SPECIAL && meFunc == `FUNCT_MFLO);
    wire meOpMtlo = (meOp == `OP_SPECIAL && meFunc == `FUNCT_MTLO);
    wire meOpMul = (meOp == `OP_SPECIAL2 && meFunc == `FUNCT_MUL);
    wire meOpMultu = (meOp == `OP_SPECIAL && meFunc == `FUNCT_MULTU);
    wire meOpMtc0 = (meOp == `OP_COP0 && meRs == `RS_MT);
    wire meOpMthi = (meOp == `OP_SPECIAL && meFunc == `FUNCT_MTHI);
    wire meOpSb = (meOp == `OP_SB);
    wire meOpSh = (meOp == `OP_SH);
    wire meOpLh = (meOp == `OP_LH);
    
    wire meOpSyscall = (meOp == `OP_SPECIAL && meFunc == `FUNCT_SYSCALL);
    wire meOpTeq = (meOp == `OP_SPECIAL && meFunc == `FUNCT_TEQ);
  
    
     // WB阶段写入
    wire [5:0] wbOp = mem_wb_inst[31:26];
    wire [5:0] wbRs = mem_wb_inst[25:21];
    wire [4:0] wbRt = mem_wb_inst[20:16];
    wire [5:0] wbFunc = mem_wb_inst[5:0];
    wire [4:0] wbRd = mem_wb_inst[15:11];
    wire[15:0] cpu_tmp2;

    wire wbOpAddi = (wbOp == `OP_ADDI);
    wire wbOpAddu = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_ADDU);
    wire wbOpAnd = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_AND);
    wire wbOpBeq = (wbOp == `OP_BEQ);
    wire wbOpAddiu = (wbOp == `OP_ADDIU);
  
    wire wbOpLui = (wbOp == `OP_LUI);
    wire wbOpXori = (wbOp == `OP_XORI);
    wire wbOpSlti = (wbOp == `OP_SLTI);
  
    wire wbOpBne = (wbOp == `OP_BNE);
    wire wbOpJ = (wbOp == `OP_J);
    wire wbOpJal = (wbOp == `OP_JAL);
    wire wbOpJr = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_JR);
    wire wbOpLw = (wbOp == `OP_LW);

    wire wbOpOri = (wbOp == `OP_ORI);
    wire wbOpSltiu = (wbOp == `OP_SLTIU);
    wire wbOpSll = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_SLL && mem_wb_inst != 32'b0);
    wire wbOpSllv = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_SLLV);
    wire wbOpSltu = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_SLTU);
    wire wbOpSra = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_SRA);
    wire wbOpAndi = (wbOp == `OP_ANDI);
    wire wbOpAdd = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_ADD);
    wire wbOpSub = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_SUB);
    wire wbOpSlt = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_SLT);
    wire wbOpXor = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_XOR);
    wire wbOpNor = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_NOR);
    wire wbOpOr = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_OR);
    
    wire wbOpSrl = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_SRL);
    wire wbOpSubu = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_SUBU);
    wire wbOpSw = (wbOp == `OP_SW);
    
    wire[31:0] cpu_tmp3;
    wire wbOpSrlv = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_SRLV);
    wire wbOpSrav = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_SRAV);
    wire wbOpLbu = (wbOp == `OP_LBU);
    wire wbOpClz = (wbOp == `OP_SPECIAL2 && wbFunc == `FUNCT_CLZ);

    wire wbOpJalr = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_JALR);
    wire wbOpLb = (wbOp == `OP_LB);
    wire wbOpBgez = (wbOp == `OP_REGIMM && wbRt == `RT_BGEZ);
    wire wbOpBreak = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_BREAK);
    wire wbOpDiv = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_DIV);
   
    wire wbOpLhu = (wbOp == `OP_LHU);
    wire wbOpSb = (wbOp == `OP_SB);
    wire wbOpDivu = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_DIVU);
    wire wbOpEret = (wbOp == `OP_COP0 && wbFunc == `FUNCT_ERET);
  
    wire[7:0] cpu_tmp5;
    wire wbOpMfc0 = (wbOp == `OP_COP0 && wbRs == `RS_MF);
    wire wbOpMfhi = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_MFHI);
    wire wbOpSh = (wbOp == `OP_SH);
    wire wbOpMthi = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_MTHI);
    wire wbOpMtlo = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_MTLO);
    wire wbOpLh = (wbOp == `OP_LH);
    wire wbOpMflo = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_MFLO);

    wire wbOpMultu = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_MULTU);
    wire wbOpMtc0 = (wbOp == `OP_COP0 && wbRs == `RS_MT);
    wire wbOpMul = (wbOp == `OP_SPECIAL2 && wbFunc == `FUNCT_MUL);
    
  
    wire wbOpSyscall = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_SYSCALL);
    wire wbOpTeq = (wbOp == `OP_SPECIAL && wbFunc == `FUNCT_TEQ);
  

//ALU
parameter LUI    =    4'b1000;    //r={b[15:0],16'b0}
parameter SLT    =    4'b1011;    //r=(a-b<0)?1:0 signed
parameter SLTU    =    4'b1010;    //r=(a-b<0)?1:0 unsigned
parameter OR    =    4'b0101;    //r=a|b
parameter ADDU    =    4'b0000;    //r=a+b unsigned
parameter ADD    =    4'b0010;    //r=a+b signed
parameter XOR    =    4'b0110;    //r=a^b
parameter NOR    =    4'b0111;    //r=~(a|b)

parameter SLL    =    4'b1110;    //r=b<<a
parameter SRA   =    4'b1100;    //r=b>>>a 
parameter SUBU    =    4'b0001;    //r=a-b unsigned
parameter SUB    =    4'b0011;    //r=a-b signed
parameter AND    =    4'b0100;    //r=a&b
parameter SRL    =    4'b1101;    //r=b>>a
parameter CLZ   =   4'b1111;           

//写入DM
assign DM_wdata = mem_dm_wdata;
assign DM_addr = mem_dm_addr;
assign DM_W = mem_dm_w;
assign DM_R = mem_dm_r;

assign Byte_ena = mem_byte_ena;

//cp0的相关变量
wire exception;
wire[4:0] cause;
assign cause=idOpSyscall?5'b01000:idOpBreak?5'b01001:idOpTeq?5'b01101:5'b11111;
assign exception = idOpSyscall||idOpBreak||idOpTeq;
reg[31:0] cpu_exec;

wire[4:0] cp0_addr;
assign cp0_addr = wbOpMtc0?wb_cp0_waddr:idOpMfc0?id_cp0_raddr:5'bz;

// 程序计数器（PC）相关信号
// 输出当前 PC 的值
wire[31:0] pc_out, pc_in;  // pc_reg
// 控制 PC 使能信号
wire pc_ena;
// 将 ID 阶段的 PC 使能信号传递给 PC 使能
assign pc_ena = id_pc_ena;
// 将 PC 输出连接到 pc_out
assign PC_out = pc_out;
// 根据 ID 阶段的 PC 使能信号选择输入，如果不使能则输入为未知（32'bz）
assign pc_in = id_pc_ena ? id_pc_in : 32'bz;



//alu
// 算术逻辑单元（ALU）信号
wire[31:0] alua, alub, aluo;

// 将执行阶段的 ALU 输入连接到 ALU 输入 A 和 B
assign alua = ex_alua;
assign alub = ex_alub;
// ALU 标志信号
wire zeroFlag, negFlag, overflowFlag, carryFlag;

// ALU 控制信号
wire[3:0] aluc;

// 根据执行阶段的操作码选择 ALU 的操作
assign aluc = (exOpAddi || exOpLw ||exOpJal  || exOpSw || exOpJalr  || exOpAdd|| exOpLb || exOpLbu
               || exOpLhu || exOpSb || exOpSh || exOpLh) ? ADD :
               (exOpAddiu || exOpAddu) ? ADDU : (exOpSubu) ? SUBU : (exOpSub) ? SUB :
               (exOpAndi || exOpAnd) ? AND :
               (exOpOr || exOpOri) ? OR : (exOpXor || exOpXori) ? XOR : (exOpNor) ? NOR : (exOpLui) ? LUI :
               (exOpSlt || exOpSlti) ? SLT : (exOpSltu || exOpSltiu) ? SLTU : (exOpSra || exOpSrav) ? SRA :
               (exOpSll || exOpSllv) ? SLL : (exOpSrl || exOpSrlv) ? SRL : (exOpClz) ? CLZ : 4'bz;



// 寄存器文件（Register File）的定义变量
// 用于指定读取的目的寄存器编号
wire[4:0] rdc, rtc, rsc;
wire[4:0] rkc;
// 寄存器写使能信号
wire RF_W;
// 连接 WB 阶段的寄存器写使能信号
assign RF_W = wb_rf_wena;
// 用于连接 ID 阶段的目的寄存器编号
assign rtc = id_rtc;
assign rsc = id_rsc;
// 用于连接 WB 阶段的目的寄存器编号
assign rdc = wb_rdc;
// 用于连接 WB 阶段的目的寄存器数据
assign rd = wb_rd;


// 乘法器相关信号
wire[63:0] mulz, multuz;
wire[31:0] mula, mulb, multua, multub;

// 将执行阶段的乘法器输入连接到乘法器输入 A、B、无符号输入 A、B
assign multua = ex_multua;
assign multub = ex_multub;
assign mula = ex_mula;
assign mulb = ex_mulb;

// 除法器相关信号
wire divBusy, divuBusy;
wire divStart, divuStart;
wire[63:0] div_res_lbw,divu_res_lbw;
wire[31:0] divisor, udivisor;
wire[31:0] dividend, udividend, divq, divr, divuq, divur;

// 连接执行阶段的除法器控制信号和输入
assign dividend = ex_div_dividend;
assign divStart = ex_div_start;
assign divuStart = ex_divu_start;
assign udividend = ex_divu_dividend;

assign divisor = ex_div_divisor;
assign udivisor = ex_divu_divisor;

    

//IF阶段赋值
assign if_pc = pc_out;
assign if_inst = IM_inst;

// 从指令中提取并零扩展 5 位立即数
wire[4:0] imm5 = if_id_inst[10:6];
assign id_uext_5 = {27'b0, imm5};
wire[17:0] imm18 = {if_id_inst[15:0], 2'b0};
wire[15:0] imm16 = if_id_inst[15:0];
// 从指令中提取并零扩展 16 位立即数
assign if_sext_16 = imm16[15] == 0 ? {16'b0, imm16} : {16'hffff, imm16};
assign id_uext_16 = {16'b0, imm16};
assign id_sext_18 = imm18[17] == 0 ? {14'b0, imm18} : {14'b11111111111111, imm18};

// 设置 ID 阶段的程序计数器使能信号为 1
assign id_pc_ena = 1'b1;
// 将 ID 阶段的下一个程序计数器连接到当前程序计数器
assign id_npc = if_id_npc;

// 将 ID 阶段的寄存器编号连接到相应的目的寄存器
assign id_rsc = idRs;
assign id_rtc = idRt;
// 将 ID 阶段的寄存器数据连接到相应的目的寄存器
assign id_rs = rs;
assign id_rt = rt;


assign id_pc_in =((!idOpBne)&&(!idOpBeq)&&(!idOpJ)&&(!idOpJal)&&(!idOpJr)
                    &&(!idOpEret)&&(!idOpBgez)&&(!idOpJalr))?id_npc:
                    idOpBeq?id_rs==id_rt?id_npc+id_sext_18:id_npc:
                    idOpBne?id_rs==id_rt?id_npc:id_npc+id_sext_18:
                    idOpJ?{id_npc[31:28],if_id_inst[25:0],2'b0}:
                    idOpJal?{id_npc[31:28],if_id_inst[25:0],2'b0}:
                    idOpJr?id_rs:idOpEret?id_cp0_epcout:idOpJalr?id_rs:
                    idOpBgez?$signed(id_rs)>=0?id_npc+id_sext_18:id_npc:32'bz;
assign id_alu_b = idOpClz?id_rs:(idOpAddi||idOpAddiu||idOpSltiu||idOpSlti||idOpLw||idOpSw||idOpLb
                  ||idOpLbu||idOpLhu||idOpSb||idOpSh||idOpLh)?if_sext_16:
                  (idOpAndi||idOpOri||idOpXori||idOpLui)?id_uext_16:(idOpJal||idOpJalr)?32'd0:id_rt;

reg[31:0] alu_c;
assign id_alu_a = (idOpLui||idOpClz)?32'bz:(idOpJal||idOpJalr)?id_npc:(idOpSll||idOpSra||idOpSrl)?
                id_uext_5:id_rs;   

wire[7:0] alu_d;
assign id_cp0_raddr = if_id_inst[15:11];
assign id_pass_data = idOpMfc0?id_cp0_rdata:idOpMfhi?HI:idOpMflo?LO:(idOpMtc0||idOpSw||idOpSb||idOpSh)?id_rt:
                      (idOpMthi||idOpMtlo)?id_rs:32'bz;
                      
             
//EX
reg div_start_reg,divu_start_reg;

always@(*)begin
    divu_start_reg = 0;
    div_start_reg = 0; 
    if(exOpDivu&&!stall[`STAGE_EX]&&!divuBusy)begin
        divu_start_reg = 1;
    end
    if(exOpDiv&&!stall[`STAGE_EX]&&!divBusy)begin
        div_start_reg = 1;
    end
end



// 将 ID 阶段的 ALU 输入连接到执行阶段的 ALU 输入 A 和 B
assign ex_alua = id_ex_alua;
assign ex_alub = id_ex_alub;

// 将 ALU 的输出连接到执行阶段的 ALU 输出
assign ex_aluo = aluo;

// 将 ID 阶段的乘法器输入连接到执行阶段的乘法器输入 A 和 B
assign ex_mula = id_ex_alua;
assign ex_mulb = id_ex_alub;
// 将执行阶段的乘法器输出和无符号输出连接到相应的输出信号
assign ex_mulz = mulz;
assign ex_multuz = multuz;
assign ex_multua = id_ex_alua;
assign ex_multub = id_ex_alub;

// 将除法器的繁忙状态和启动信号连接到执行阶段的相应信号
assign ex_divu_busy = divuBusy;
assign ex_div_start = div_start_reg;
assign ex_divu_start = divu_start_reg;
assign ex_div_busy = divBusy;
// 将 ID 阶段的 ALU 输入连接到执行阶段的除法器输入和无符号除法器输入
assign ex_div_dividend = id_ex_alua;
assign ex_div_divisor = id_ex_alub;
// 将除法器的输出结果和无符号输出结果连接到相应的输出信号
assign ex_divu_dividend = id_ex_alua;
assign ex_divu_divisor = id_ex_alub;
assign ex_div_q = divq;
assign ex_div_r = divr;
assign ex_divu_q = divuq;
assign ex_divu_r = divur;


// MEM 阶段

// 判断是否为读操作
assign mem_dm_r = meOpLw || meOpLb || meOpLbu || meOpLh || meOpLhu;
// 判断是否为写操作
assign mem_dm_w = meOpSw || meOpSb || meOpSh;
assign mem_dm_rdata = DM_rdata;
// 将数据存储器的读取数据和执行阶段传递的数据连接到 MEM 阶段的数据输入
assign mem_dm_wdata = ex_mem_pass_data;
// 根据指令类型设置字节使能信号
assign mem_byte_ena = meOpSw ? 4'b1111 : meOpSb ? 4'b0001 : meOpSh ? 4'b0011 : 4'b0000;

// 对于 lb 操作，进行符号或零扩展
assign mem_byte_ext = meOpLb ? (mem_dm_rdata[7] == 0 ? {24'b0, mem_dm_rdata[7:0]} : {24'hffffff, mem_dm_rdata[7:0]})
                          : meOpLbu ? {24'b0, mem_dm_rdata[7:0]} : 32'bz;
// 对于 lh 操作，进行符号或零扩展
assign mem_half_ext = meOpLh ? (mem_dm_rdata[15] == 0 ? {16'b0, mem_dm_rdata[15:0]} : {16'hffff, mem_dm_rdata[15:0]})
                           : meOpLhu ? {16'b0, mem_dm_rdata[15:0]} : 32'bz;
// 将执行阶段的 ALU 输出作为 MEM 阶段的数据存储器地址
assign mem_dm_addr = ex_mem_aluo;


// 写回阶段的寄存器文件写使能信号
assign wb_rf_wena = (!mem_wb_overflowFlag && wbOpAddi) || wbOpAndi || wbOpAddiu || wbOpOri || wbOpSltiu || wbOpLui || wbOpXori || wbOpSlti
                    || wbOpAddu || wbOpJal || wbOpAnd || wbOpLw || wbOpXor || wbOpNor || wbOpOr || wbOpSll || wbOpSllv || wbOpSltu
                    || wbOpSra || wbOpSrl || wbOpSubu || (wbOpAdd && !mem_wb_overflowFlag) || wbOpSub || 0 || wbOpSlt || wbOpSrlv || wbOpSrav || wbOpClz
                    || wbOpJalr || wbOpLb || wbOpLbu || wbOpLhu || wbOpLh || wbOpMfc0 || wbOpMfhi || wbOpMflo || wbOpMul;

wire[31:0]wb_tmp0;
// 写回阶段的目的寄存器编号
assign wb_rdc = (wbOpAddi || wbOpAddiu || wbOpAndi || wbOpOri || wbOpSltiu || wbOpLui || wbOpXori || wbOpSlti || wbOpLw
                || wbOpLb || wbOpLbu || wbOpLhu || wbOpLh || wbOpMfc0) ? wbRt : (wbOpAddu || wbOpAnd || wbOpXor || wbOpNor
                || wbOpOr || wbOpSll || wbOpSllv || wbOpSltu || wbOpSra || wbOpSrl || wbOpSubu || wbOpAdd || wbOpSub || wbOpSlt
                || wbOpSrlv || wbOpSrav || wbOpClz || (wbOpJalr && wbRd != 5'b0) || wbOpMfhi || wbOpMflo || wbOpMul) ? wbRd : (wbOpJal || (wbOpJalr && wbRd == 5'b0)) ? 5'd31 : 32'bz;
wire[31:0] wb_tmp1;
// 写回阶段的 CP0 写地址
assign wb_cp0_waddr = wbOpMtc0 ? wbRd : 5'bz;

// 写回阶段的目的寄存器数据
assign wb_rd = ((wbOpAddi && !mem_wb_overflowFlag) || wbOpAddiu || wbOpAndi || wbOpOri || wbOpSltiu || wbOpLui || wbOpXori || wbOpSlti
                    || wbOpAddu || wbOpJal || wbOpAnd || wbOpXor || wbOpNor || wbOpOr || wbOpSll || wbOpSllv || wbOpSltu
                    || wbOpSra || wbOpSrl || wbOpSubu || (wbOpAdd && !mem_wb_overflowFlag) || wbOpSub || wbOpSlt || wbOpSrlv || wbOpSrav || wbOpClz
                    || wbOpJalr) ? mem_wb_aluo : (wbOpLw || wbOpLb || wbOpLbu || wbOpLhu || wbOpLh || wbOpMfc0 || wbOpMfhi || wbOpMflo) ? mem_wb_pass_data :
                    (wbOpMul) ? mem_wb_mulz[31:0] : 32'bz;
wire[31:0]wb_tmp2;
// 写回阶段的 CP0 写数据
assign wb_cp0_wdata = wbOpMtc0 ? mem_wb_pass_data : 32'bz;


// 写回阶段的 HI 寄存器数据
assign wb_hi_wdata = (wbOpDivu || wbOpDiv) ? mem_wb_div_r : wbOpMultu ? mem_wb_mulz[63:32] : wbOpMthi ? mem_wb_pass_data : 32'bz;

wire wb_tmp5;
assign wb_tmp5 = 1;
// 写回阶段的 HI 寄存器写使能
assign wb_hi_wena = wbOpDivu || wbOpDiv || wbOpMultu || wbOpMthi;

// 写回阶段的 LO 寄存器写使能
assign wb_lo_wena = wbOpDivu || wbOpDiv || wbOpMultu || wbOpMtlo;
// 写回阶段的 LO 寄存器数据
assign wb_lo_wdata = (wbOpDivu || wbOpDiv) ? mem_wb_div_q : wbOpMultu ? mem_wb_mulz[31:0] : wbOpMtlo ? mem_wb_pass_data : 32'bz;

wire wRegId,wRegEx,wRegMe,rRsId,rRtId;

wire[4:0] wAddrId,wAddrEx,wAddrMe;
wire[4:0] wb_cnt0;
wire wb_kase;
assign wb_kase = 0;

//写会寄存器选择信号

assign wRegEx = exOpAddi||exOpAddiu||exOpAndi||exOpOri||exOpSltiu||exOpLui||exOpXori||exOpSlti
                    ||exOpAddu||exOpJal||exOpAnd||exOpLw||exOpXor||exOpNor||exOpOr||wb_kase||exOpSll||exOpSllv||exOpSltu
                    ||exOpSra||exOpSrl||exOpSubu||exOpAdd||exOpSub||exOpSlt||exOpSrlv||exOpSrav||exOpClz
                    ||exOpJalr||exOpLb||exOpLbu||exOpLhu||exOpLh||exOpMfc0||exOpMfhi||exOpMflo||exOpMul;

wire[31:0] wb_a;
assign wRegId = idOpMul||idOpAddi||idOpAddiu||idOpAndi||idOpOri||idOpSltiu||idOpLui||idOpSrav||idOpXori||idOpSlti
                    ||idOpAddu||idOpJal||idOpAnd||idOpLw|| wb_kase||idOpXor||idOpNor||idOpOr||idOpSll||idOpSllv||idOpSltu
                    ||idOpSra||idOpSrl||idOpSubu||idOpAdd||idOpSub||idOpSlt||idOpSrlv||idOpClz
                    ||idOpJalr||idOpLb|| wb_kase||idOpLbu||idOpLhu||idOpLh||idOpMfc0||idOpMfhi||idOpMflo;

assign rRsId = idOpAdd||idOpAddi||idOpAddiu||idOpAddu||idOpAnd||idOpAndi||idOpBeq||idOpBgez||idOpBne||idOpClz||idOpDiv||idOpDivu||idOpJalr||idOpJr||idOpLb
                ||idOpLbu||idOpLh||idOpLhu||idOpLw||idOpMthi||idOpMtlo||idOpMul||idOpMultu||idOpNor||idOpOr||idOpOri||idOpSb||idOpSh||idOpSllv
                ||idOpSlt||idOpSlti||idOpSltiu||idOpSltu||idOpSrav||idOpSrlv||idOpSub||idOpSubu||idOpSw||idOpXor||idOpXori;
wire[31:0] wb_b;
assign wRegMe = (meOpAddi&&!ex_mem_overflowFlag)||meOpAddiu||wb_kase||meOpAndi||meOpOri||meOpSltiu||meOpLui||meOpXori||meOpSlti
                                        ||meOpAddu||meOpJal||meOpAnd||meOpLw||meOpXor||meOpNor||meOpOr||meOpSll||meOpSllv||meOpSltu
                                        ||meOpSra||meOpSrl||meOpSubu||(meOpAdd&&!ex_mem_overflowFlag)||meOpSub||meOpSlt||meOpSrlv||meOpSrav||meOpClz
                                        ||meOpJalr||meOpLb||wb_kase||meOpLbu||meOpLhu||meOpLh||meOpMfc0||meOpMfhi||meOpMflo||meOpMul;
wire wRs_id;
assign rRtId = idOpSlt||idOpAdd||idOpAddu||idOpAnd||idOpBeq||idOpBne||idOpDiv||idOpDivu||idOpMul||idOpMultu||idOpNor||idOpOr||idOpSb||idOpSh||idOpSllv
               ||idOpSltu||idOpSrav||idOpSrlv||idOpSub||idOpSubu||idOpSw||idOpXor
               ||idOpMtc0||idOpSll||idOpSra||idOpSrl||wb_kase;

//
assign wAddrEx = (exOpAddi||exOpAddiu||exOpAndi||exOpOri||exOpSltiu||exOpLui||exOpXori||exOpSlti||exOpLw
                ||exOpLb||exOpLbu||exOpLhu||exOpLh||exOpMfc0)?exRt:(exOpAddu||exOpAnd||exOpXor||exOpNor
                ||exOpOr||exOpSll||exOpSllv||exOpSltu||exOpSra||exOpSrl||exOpSubu||exOpAdd||exOpSub||exOpSlt
                ||exOpSrlv||exOpSrav||exOpClz||(exOpJalr&&exRd!=5'b0)||exOpMfhi||exOpMflo||exOpMul)?exRd:(exOpJal||(exOpJalr&&exRd==5'b0))?5'd31:32'bz;
//
assign wAddrId = (idOpAddi||wb_kase||idOpAddiu||idOpAndi||idOpOri||idOpSltiu||idOpLui||idOpXori||idOpSlti||idOpLw
                ||idOpLb||idOpLbu||idOpLhu||idOpLh||idOpMfc0)?idRt:(idOpAddu||idOpAnd||idOpXor||idOpNor
                ||idOpOr||idOpSll||idOpSllv||idOpSltu||idOpSra||idOpSrl||idOpSubu||idOpAdd||idOpSub||idOpSlt
                ||idOpSrlv||idOpSrav||wb_kase||idOpClz||(idOpJalr&&if_id_inst[15:11]!=5'b0)||idOpMfhi||idOpMflo||idOpMul)?if_id_inst[15:11]:(idOpJal||(idOpJalr&&if_id_inst[15:11]==5'b0))?5'd31:32'bz;
//
assign wAddrMe = (meOpAddi||meOpAddiu||meOpAndi||wb_kase||meOpOri||meOpSltiu||meOpLui||meOpXori||meOpSlti||meOpLw
                                ||meOpLb||meOpLbu||meOpLhu||meOpLh||meOpMfc0)?meRt:(meOpAddu||meOpAnd||meOpXor||meOpNor
                                ||meOpOr||meOpSll||meOpSllv||meOpSltu||meOpSra||meOpSrl||meOpSubu||meOpAdd||meOpSub||meOpSlt
                                ||meOpSrlv||meOpSrav||wb_kase||meOpClz||(meOpJalr&&meRd!=5'b0)||meOpMfhi||meOpMflo||meOpMul)?meRd:(meOpJal||(meOpJalr&&meRd==5'b0))?5'd31:32'bz;


//处理竞争冒险
always @ (*) begin
    stall = `CTRL_STALLW'b0;
    // 检查IF阶段的冒险
    if (ifOpJr || ifOpBne || ifOpBeq || ifOpBgez||ifOpJalr) begin
        if (wRegEx && (wAddrEx == ifRs || ((ifOpBne || ifOpBeq) && wAddrEx == ifRt))) begin
            stall = `CTRL_STALL_IF;
        end
        if (wRegId && (wAddrId == ifRs || ((ifOpBne || ifOpBeq) && wAddrId == ifRt))) begin
            stall = `CTRL_STALL_IF;
        end
        if (wRegMe && (wAddrMe == ifRs || ((ifOpBne || ifOpBeq) && wAddrMe == ifRt))) begin
            stall = `CTRL_STALL_IF;
        end
    end
    // 检查ID阶段的冒险
    if (wRegEx) begin                           
        if (rRsId && wAddrEx == idRs ||  wAddrEx == idRt && rRtId ) begin
            stall = `CTRL_STALL_ID;    
        end
    end
    
    // 检查涉及协处理器指令的冒险
    if ((exOpMthi || exOpDiv || exOpMultu|| exOpDivu) && idOpMfhi) begin      
        stall = `CTRL_STALL_ID;
    end
    if ((exOpMtlo || exOpDiv ||  exOpMultu|| exOpDivu) && idOpMflo) begin      
        stall = `CTRL_STALL_ID;    
    end
    if (idOpMfc0 && exOpMtc0) begin    
        stall = `CTRL_STALL_ID;    
    end
    
    // 检查ME阶段涉及协处理器指令的冒险
    if ((meOpMthi || meOpMultu || meOpDiv || meOpDivu) && idOpMfhi) begin    
        stall = `CTRL_STALL_ID;    
    end
    if ((meOpMtlo || meOpMultu || meOpDiv || meOpDivu) && idOpMflo) begin   
        stall = `CTRL_STALL_ID;    
    end
    if (meOpMtc0 && idOpMfc0) begin    
        stall = `CTRL_STALL_ID;    
    end
    
    // 检查ME阶段的冒险
    if (wRegMe) begin                  
        if (rRsId && wAddrMe == idRs || rRtId && wAddrMe == idRt) begin
            stall = `CTRL_STALL_ID;
        end
    end
    // 检查EX阶段涉及除法指令的冒险
    if ((exOpDiv && divBusy) || (exOpDivu && divuBusy)) begin
        stall = `CTRL_STALL_EX;
    end
end


 // IF/ID 寄存器更新
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // 复位时，将 IF/ID 寄存器清零
        if_id_npc <= 32'b0;
        if_id_inst <= 32'b0;
    end
    else if (stall[`STAGE_IF] && (!stall[`STAGE_ID])) begin
        // 如果有流水线暂停信号，清零 IF/ID 寄存器
        if_id_inst <= 32'b0;
    end
    else if (!stall[`STAGE_IF]) begin
        // 如果没有流水线暂停信号，则更新 IF/ID 寄存器
        if_id_inst <= if_inst;
        
        // 根据指令类型更新下一条指令地址
        if (ifOpSyscall || ifOpTeq || ifOpBreak) begin
            if_id_npc <= 32'h00400004;
        end
        else begin   
            if_id_npc <= if_pc + 32'h4;
        end   
    end
end


// ID_EX 寄存器更新
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        // 复位时，将 ID_EX 寄存器清零
        id_ex_pass_data <= 32'b0;
        id_ex_inst <= 32'b0;
        id_ex_alua <= 32'b0;
        id_ex_alub <= 32'b0;
    end
    else if (!stall[`STAGE_EX] && stall[`STAGE_ID]) begin
        // 如果有流水线暂停信号，清零 ID_EX 寄存器
        id_ex_alua <= 32'b0;
        id_ex_alub <= 32'b0;
        id_ex_pass_data <= 32'b0;
        id_ex_inst <= 32'b0;
    end
    else if (!stall[`STAGE_ID]) begin
        // 如果没有流水线暂停信号，则更新 ID_EX 寄存器
        id_ex_alua <= id_alu_a;
        id_ex_alub <= id_alu_b;
        id_ex_pass_data <= id_pass_data;
        id_ex_inst <= if_id_inst;
    end
end


// EX_MEM 寄存器更新
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        // 复位时，将 EX_MEM 寄存器清零
        ex_mem_div_r <= 32'b0;
        ex_mem_mulz <= 64'b0;
        ex_mem_aluo <= 32'b0;

        ex_mem_inst <= 32'b0;
        ex_mem_overflowFlag <= 1'b0;
        ex_mem_div_q <= 32'b0;
        ex_mem_pass_data <= 32'b0;

    end
    else if (stall[`STAGE_EX] && !stall[`STAGE_ME]) begin
        // 如果有流水线暂停信号，清零 EX_MEM 寄存器
        ex_mem_div_r <= 32'b0;
        ex_mem_mulz <= 64'b0;
        ex_mem_aluo <= 32'b0;
        ex_mem_pass_data <= 32'b0;
        ex_mem_div_q <= 32'b0;
        ex_mem_inst <= 32'b0;
        ex_mem_overflowFlag <= 1'b0;
    end
    else if (!stall[`STAGE_EX]) begin
        // 如果没有流水线暂停信号，则更新 EX_MEM 寄存器
        ex_mem_div_r <= exOpDiv ? ex_div_r : exOpDivu ? ex_divu_r : 32'b0;
        ex_mem_mulz <= exOpMul ? ex_mulz : exOpMultu ? ex_multuz : 64'b0;
        ex_mem_div_q <= exOpDiv ? ex_div_q : exOpDivu ? ex_divu_q : 32'b0;

        ex_mem_pass_data <= id_ex_pass_data;
        ex_mem_inst <= id_ex_inst;
        ex_mem_aluo <= ex_aluo;
        ex_mem_overflowFlag <= overflowFlag;
    end
end

// MEM_WB 寄存器更新
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        // 复位时，将 MEM_WB 寄存器清零
        mem_wb_div_q <= 32'b0;
        mem_wb_div_r <= 32'b0;
        mem_wb_aluo <= 32'b0;
        mem_wb_mulz <= 64'b0;
        mem_wb_pass_data <= 32'b0;
        mem_wb_inst <= 32'b0;
        mem_wb_overflowFlag <= 32'b0;
    end
    else if (stall[`STAGE_ME] && !stall[`STAGE_WB]) begin
        // 如果有流水线暂停信号，清零 MEM_WB 寄存器
        mem_wb_div_q <= 32'b0;
        mem_wb_div_r <= 32'b0;
        mem_wb_aluo <= 32'b0;
        mem_wb_mulz <= 64'b0;
        mem_wb_pass_data <= 32'b0;
        mem_wb_inst <= 32'b0;
        mem_wb_overflowFlag <= 32'b0;
    end
    else if (!stall[`STAGE_ME]) begin
        // 如果没有流水线暂停信号，则更新 MEM_WB 寄存器
        mem_wb_mulz <= ex_mem_mulz;
        mem_wb_div_q <= ex_mem_div_q;
        mem_wb_div_r <= ex_mem_div_r;
        mem_wb_aluo <= ex_mem_aluo;
        if (meOpLw) begin
            mem_wb_pass_data <= mem_dm_rdata;
        end
        else if (meOpLb || meOpLbu) begin
            mem_wb_pass_data <= mem_byte_ext;
        end
        else if (meOpLh || meOpLhu) begin
            mem_wb_pass_data <= mem_half_ext;
        end
        else begin
            mem_wb_pass_data <= ex_mem_pass_data;
        end
        mem_wb_inst <= ex_mem_inst;
        mem_wb_overflowFlag <= ex_mem_overflowFlag;
    end
end


//HI,LO
always @ (negedge clk or posedge rst) begin
    if(rst)begin
        LO<=32'b0;
    end
    else if(wb_lo_wena)begin
        LO<=wb_lo_wdata;
    end
end

always @ (negedge clk or posedge rst) begin
    if(rst)begin
        HI<=32'b0;
    end
    else if(wb_hi_wena)begin
        HI<=wb_hi_wdata;
    end
end





 CP0 cp0(
    .clk(clk),				
    .rst(rst),				
    .mfc0(idOpMfc0),				
    .mtc0(wbOpMtc0),				
    .eret(idOpEret),				
    .exception(exception),		
    .cause(cause),		
    .addr(cp0_addr),		
    .wdata(wb_cp0_wdata),		
    .pc(id_npc),			
    .rdata(id_cp0_rdata),		
    .status(id_cp0_status),	
    .exc_addr(id_cp0_epcout)	
);
  
PCReg pcreg(
   .clk(clk),
   .rst(rst),
   .ena(pc_ena),
   .pc_in(pc_in),
   .pc_out(pc_out)
);
           
 ALU cpu_alu(
    .a(alua),
    .b(alub),
    .aluc(aluc),
    .r(aluo),
    .zero(zeroFlag),
    .carry(carryFlag),
    .negative(negFlag),
    .overflow(overflowFlag)
    );
           
RegFile cpu_ref(
    .RF_ena(1'b1), 
    .RF_rst(rst),
    .RF_clk(clk),
    .Rdc(rdc),
    .Rsc(rsc),
    .Rtc(rtc),
    .Rd(rd),
    .Rs(rs),
    .Rt(rt),
    .RF_W(RF_W)
    );
    
DIV cpu_div(
    .dividend(dividend),
    .divisor(divisor),
    .div_res_q(divq),
    .div_res_r(divr),
    .div_busy(divBusy),
    .divu_res_q(divuq),
    .divu_res_r(divur),
    .divu_busy(divuBusy)
);

MUL cpu_mul(
    .a(multa),
    .b(multb),
    .mult_res(mulz),
    .multu_res(multuz)
);
            


endmodule





