`timescale 1ns / 1ps
`include "define.vh"

module pc_reg(
    input clk, 
    input rst, 
    input wena, 
    input stall,  // 暂停
    input [31:0] data_in,   // 下一个pc
    output [31:0] data_out   // 当前pc
    );

    reg [31:0] pc;

    always @ (posedge clk or posedge rst)
    begin
        if(rst == `RST_ENABLED) begin
            pc <= 32'h00400000;//MIPS标准下的初始pc值
        end

        else if(stall == `RUN) begin
            if(wena == `WRITE_ENABLED) begin
                pc <= data_in;
            end
        end
    end

    assign data_out = pc;

endmodule