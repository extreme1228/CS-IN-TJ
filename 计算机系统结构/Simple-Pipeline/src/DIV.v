`timescale 1ns / 1ps

module DIV(
    input [31:0]a,
    input [31:0]b,
    output[31:0]div_res_q,
    output[31:0]div_res_r,
    output[31:0]divu_res_q,
    output[31:0]divu_res_r,
    output div_busy,
    output divu_busy
    );
    wire signed[31:0]signed_a,signed_b;
    assign signed_a = a;
    assign signed_b = b;
    wire[31:0] signed_q,signed_r,unsigned_q,unsigned_r;
    
    assign signed_r = (b == 32'b0)?32'b0:(signed_a%signed_b);
    assign signed_q = (b == 32'b0)?32'b0:(signed_a/signed_b);

    assign unsigned_r = (b == 32'b0)?32'b0:(a%b);
    assign unsigned_q = (b == 32'b0)?32'b0:(a/b);

    assign div_res_q = signed_q;
    assign div_res_r = signed_r;
    assign divu_res_q = unsigned_q;
    assign divu_res_r = unsigned_r;
    assign div_busy = 0;
    assign divu_busy = 0;
endmodule
