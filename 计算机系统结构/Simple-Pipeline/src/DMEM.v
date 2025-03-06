`timescale 1ns / 1ps
module DMEM(
    input clk,
    input rst,
    input ena,
    input DM_W,
    input DM_R,
    input[3:0]byteEna,
    input [31:0] DM_addr,
    input [31:0] DM_wdata,
    output [31:0] DM_rdata
    );
    wire[31:0]addr;
    reg [7:0] D_mem[0:1023];
    wire [10:0]addr0,addr1,addr2,addr3;
    wire[7:0]wByte0,wByte1,wByte2,wByte3;
    
    assign addr=DM_addr;
    assign addr0={addr[10:0]};
    assign addr1=addr0+11'd1;
    assign addr2=addr0+11'd2;
    assign addr3=addr0+11'd3;
    
   
    assign wByte0=byteEna[0]?DM_wdata[7:0]:D_mem[addr0];
    assign wByte1=byteEna[1]?DM_wdata[15:8]:D_mem[addr1];
    assign wByte2=byteEna[2]?DM_wdata[23:16]:D_mem[addr2];
    assign wByte3=byteEna[3]?DM_wdata[31:24]:D_mem[addr3];
    
    always @(negedge clk) begin
        if(rst)
        begin
        //
        end
        else if (DM_W && ena) begin
            D_mem[addr0] <= wByte0;
            D_mem[addr1] <= wByte1;
            D_mem[addr2] <= wByte2;
            D_mem[addr3] <= wByte3;
        end
    end

    assign DM_rdata[31:0] = (DM_R && ena) ? {D_mem[addr3],D_mem[addr2],D_mem[addr1],D_mem[addr0]} : 32'bz;
endmodule

