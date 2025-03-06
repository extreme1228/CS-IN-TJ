

`timescale 1ns / 1ps

module mux_8_32(
    input [31:0] C0,
    input [31:0] C1,
    input [31:0] C2,
    input [31:0] C3,
    input [31:0] C4,
    input [31:0] C5,
    input [31:0] C6,
    input [31:0] C7,
    input [2:0] S0,
    output [31:0] oZ
    );

    reg [31:0] tmp_res;

    always @(*) begin
        case(S0)
            3'b000: tmp_res <= C0;
            3'b001: tmp_res <= C1;
            3'b010: tmp_res <= C2;
            3'b011: tmp_res <= C3;
            3'b100: tmp_res <= C4;
            3'b101: tmp_res <= C5;
            3'b110: tmp_res <= C6;
            3'b111: tmp_res <= C7;
            default: tmp_res <= 32'bz;
        endcase
   end
   
   assign oZ = tmp_res;
   
endmodule