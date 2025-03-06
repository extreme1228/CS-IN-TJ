
`include "defines.v"
`timescale 1ns/1ps

module openmips_min_sopc_tb();

  reg     CLOCK_50;
  reg     rst;
  wire [31:0] pc;
  wire [31:0] inst;
  wire [31:0] result;
       
  initial begin
    CLOCK_50 = 1'b0;
    forever #0.1 CLOCK_50 = ~CLOCK_50;
  end
      
  initial begin
    rst = `RstEnable;
    #20 rst= `RstDisable;
    #10000 $stop;
  end
       
  openmips_min_sopc openmips_min_sopc0(
		.clk(CLOCK_50),
		.rst(rst),
    .pc(pc),
    .inst(inst),
    .output_res(result)
	);

endmodule