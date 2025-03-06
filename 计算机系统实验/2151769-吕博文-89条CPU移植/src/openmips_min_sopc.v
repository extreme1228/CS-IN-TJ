`include "defines.v"

//模拟(simulation)顶层模块
module openmips_min_sopc(

	input wire	clk,
	input wire	rst,
	output [31:0] pc,
	output [31:0] inst,
	output [31:0] output_res
);

  wire rom_ce;
  wire mem_we_i;
  wire[`RegBus] mem_addr_i;
  wire[`RegBus] mem_data_i;
  wire[`RegBus] mem_data_o;
  wire[3:0] mem_sel_i; 
  wire mem_ce_i;   
  wire[5:0] int;
  wire timer_int;
 
  //assign int = {5'b00000, timer_int, gpio_int, uart_int};
  assign int = {5'b00000, timer_int};

 openmips openmips0(
		.clk(clk),
		.rst(rst),
	
		.rom_addr_o(pc),
		.rom_data_i(inst),
		.rom_ce_o(rom_ce),

    	.int_i(int),

		.ram_we_o(mem_we_i),
		.ram_addr_o(mem_addr_i),
		.ram_sel_o(mem_sel_i),
		.ram_data_o(mem_data_i),
		.ram_data_i(mem_data_o),
		.ram_ce_o(mem_ce_i),
		
		.timer_int_o(timer_int)			
	
	);
	
	wire [31:0] mips_pc ;
	assign mips_pc =  pc - `PcBegin;

	//指令存储器
	inst_rom imem(mips_pc[12:2],inst);

	//数据存储器
	data_ram data_ram0(
		.clk(clk),
		.ce(mem_ce_i),
		.we(mem_we_i),
		.addr_in(mem_addr_i),
		.sel(mem_sel_i),
		.data_i(mem_data_i),
		.data_o(mem_data_o),
		.result(output_res)
	);
endmodule