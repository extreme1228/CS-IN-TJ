
`timescale 1ns / 1ps

module mux_4_32(
    input [31:0] C0,
    input [31:0] C1,
    input [31:0] C2,
    input [31:0] C3,
    input [1:0] S0,
    output [31:0] oZ
    );

    reg [31:0] tmp_res;

    always @(*) begin
        case(S0)
            2'b00: tmp_res <= C0;
            2'b01: tmp_res <= C1;
            2'b10: tmp_res <= C2;
            2'b11: tmp_res <= C3;
            default: tmp_res <= 31'bz;
        endcase
   end
   
   assign oZ = tmp_res;
   
endmodule