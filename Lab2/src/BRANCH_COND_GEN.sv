`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ryken Thompson
// 
// Create Date: 10/24/2023 09:55:31 PM
// Design Name: OTTER MCU Branch Condition Generator
// Module Name: BRANCH_COND_GEN
// Target Devices: Basys3
// Description: Creates 3 signals based on the 3 possible branch comparisons in the OTTER MCU
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module BRANCH_COND_GEN(
    input [31:0] RS1,
    input [31:0] RS2,
    output logic BR_EQ,
    output logic BR_LT,
    output logic BR_LTU
    );
    
    always_comb begin
        BR_EQ = (RS1 == RS2); //Equal condition
        BR_LT = ($signed(RS1) < $signed(RS2)); //Signed less than
        BR_LTU = (RS1 < RS2); //Unsigned less than
    end
    
endmodule
