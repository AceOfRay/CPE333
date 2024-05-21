`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ray Valenzuela
// 
// Create Date: 05/07/2024 08:35:46 AM
// Design Name: 
// Module Name: HZD_DET
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


module HZD_DET(
    input ID_EX_MEM_READ,
    input [4:0] IF_ID_R_OUT1, // RS
    input [4:0] IF_ID_R_OUT2, // RT
    input [4:0] DC_EX_RD, //DC_EX_RD
    output logic BUBBLE
    );

    always_comb begin
        if (ID_EX_MEM_READ && ((DC_EX_RD == IF_ID_R_OUT1) || (DC_EX_RD == IF_ID_R_OUT2))) BUBBLE = 1;
        else BUBBLE = 0;
    end
endmodule
