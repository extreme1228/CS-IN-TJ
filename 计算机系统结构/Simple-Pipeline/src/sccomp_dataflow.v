`timescale 1ns / 1ps

module sccomp_dataflow(
    input clk_in,
    input rst,
    output [7:0]o_seg,
    output [7:0]o_sel
    );
 
// 声明指令内存数据的线
wire [31:0] inst;
// 声明程序计数器的线
wire [31:0] pc;
// 声明数据存储器写和读的信号线
wire dw, dr;
// 声明写和读数据的线
wire [31:0] w_data, r_data;
// 声明指令的线
wire [31:0] instr;
// 声明数据存储器和指令存储器地址的线
wire [31:0] dm_addr;
wire [31:0] im_addr;
// 声明ALU结果的线
wire [31:0] alu_res;
// 声明时钟信号的线
wire clk;
// 声明字节使能信号的线
wire [3:0] byteEna;
// 将指令线赋值给inst
assign inst = instr;

assign dm_addr =(alu_res - 32'h1001_0000);
//这里不同于cpu31，我们选择DMEM存储数据采用标准的8位是为了方便LB等取字节指令的执行
   
//ROM
IMEM rom(
    .addr(im_addr[10:0]),
    .instr(instr)
);
assign im_addr = (pc - 32'h0040_0000)/4;

//CPU
CPU sc_cpu(
    .clk(clk),.rst(rst), .IM_inst(instr), .DM_rdata(r_data),
    .DM_W(dw), .DM_R(dr), .DM_wdata(w_data), .PC_out(pc),.DM_addr(alu_res),.Byte_ena(byteEna)
);
//RAM
DMEM ram(
    .clk(clk),.rst(rst),.ena(1'b1), .DM_W(dw), .DM_R(dr),.byteEna(byteEna) , .DM_addr(dm_addr), .DM_wdata(w_data),
    .DM_rdata(r_data)
);

//Seg
seg7x16 seg(
    .clk(clk_in),.reset(rst),.cs(1'b1),.i_data(pc),.o_seg(o_seg),.o_sel(o_sel)
);

//DIV
CLK_DIV div(
.clk_in(clk_in),.rst(rst),.clk_out(clk)
);

endmodule

