`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ryken Thompson
// 
// Create Date: 10/17/2023 07:22:08 PM
// Design Name: Immediate Generator
// Module Name: IMMED_GEN
// Target Devices: Basys3
// Description: Immediate Generator for OTTER MCU
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IMMED_GEN(
    input [24:0] INSTRUCT,
    output [31:0] U_TYPE,
    output [31:0] I_TYPE,
    output [31:0] S_TYPE,
    output [31:0] J_TYPE,
    output [31:0] B_TYPE
    );
    
    assign U_TYPE = {INSTRUCT[24:5], 12'b0};
    assign I_TYPE = {{21{INSTRUCT[24]}}, INSTRUCT[23:13]};
    assign S_TYPE = {{21{INSTRUCT[24]}}, INSTRUCT[23:18], INSTRUCT[4:0]};
    assign J_TYPE = {{12{INSTRUCT[24]}}, INSTRUCT[12:5], INSTRUCT[13], INSTRUCT[23:14], 1'b0};
    assign B_TYPE = {{20{INSTRUCT[24]}}, INSTRUCT[0], INSTRUCT[23:18], INSTRUCT[4:1], 1'b0};
    
endmodule
