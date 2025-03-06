
`include "defines.v"

module LLbit_reg(

	input	wire				clk,
	input wire					rst,
	
	input wire                  flush,
	//д�˿�
	input wire					LLbit_i,
	input wire                  we,
	
	//���˿�1
	output reg                  LLbit_o
	
);


	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
					LLbit_o <= 1'b0;
		end else if((flush == 1'b1)) begin
					LLbit_o <= 1'b0;
		end else if((we == `WriteEnable)) begin
					LLbit_o <= LLbit_i;
		end
	end

endmodule