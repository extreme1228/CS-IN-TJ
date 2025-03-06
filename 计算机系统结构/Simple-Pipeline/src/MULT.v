`timescale 1ns / 1ps


module MUL(
    input [31:0]a,//乘数a
    input [31:0]b,//乘数b
    output [63:0]mult_res,//有符号乘
    output [63:0]multu_res//无符号乘
    );
		wire [63:0] unsigned_a,unsigned_b;
		wire signed [63:0] signed_a,signed_b;
		assign unsigned_a = {32'b0,a};
		assign unsigned_b = {32'b0,b};
		
		assign signed_a = {{32{a[31]}},a};
		assign signed_b = {{32{b[31]}},b};

		assign mult_res = signed_a*signed_b;
		assign multu_res = unsigned_a*unsigned_b;
endmodule
