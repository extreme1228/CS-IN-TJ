`timescale 1ns / 1ps

module test_bench(
    );
    reg clk,rst;
    wire [7:0] o_seg,o_sel;
    wire [31:0] res;
    initial begin
        clk = 1'b0;
        rst = 1'b1;
        #10 rst = ~rst;
    end
    always 
    begin
        #0.1 clk = ~clk;
    end
    pipeline_top uut(
        .clk(clk),
        .rst(rst),
        .switch_res(0),
        .stop(0),
        .res(res),
        .o_seg(o_seg),
        .o_sel(o_sel)    
    );
endmodule
