`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/02 13:44:02
// Design Name: 
// Module Name: ALU_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU_tb();
    wire [31 : 0] res;
    reg [31 : 0] src0;
    reg [31 : 0] src1;
    reg [ 4 : 0] sel;
    
    ALU alu (
    .alu_src0(src0),
    .alu_src1(src1),
    .alu_op(sel),
    .alu_res(res)
    );
    
    initial begin
        src0=32'hffff; src1=32'hffff; sel=5'H0;
        repeat(32) begin
            sel = sel + 1;
            #20;
        end
    end
    
endmodule
