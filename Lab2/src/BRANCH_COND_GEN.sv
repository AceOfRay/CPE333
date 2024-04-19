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
    input logic [31:0] RS1,
    input logic [31:0] RS2,
    input logic [31:0] instr,
    output logic [1:0] pcSource
    );

    logic [2:0] funct3 = instr[14:12];

    logic BR_EQ;
    logic BR_LT;
    logic BR_LTU;
    
    always_comb begin
        BR_EQ = (RS1 == RS2); //Equal condition
        BR_LT = ($signed(RS1) < $signed(RS2)); //Signed less than
        BR_LTU = (RS1 < RS2); //Unsigned less than
    

    case ({BR_EQ, BR_LT, BR_LTU})
        3'b100, 3'b010, 3'b001: begin 
            pcSource = 2'b10;
        end
        default: begin
        pcSource = 2'b00;
        end
    endcase


    case (instr[6:0])
        7'b1100111: pcSource = 1;
        7'b1101111:pcSource = 3;              
        7'b1100011: begin //B-TYPE
            case (funct3[2:1])
                2'b00: pcSource = {~(BR_EQ ^ ~funct3[0]), 1'b0};
                2'b10: pcSource = {~(BR_LT ^ ~funct3[0]), 1'b0};
                2'b11: pcSource = {~(BR_LTU ^ ~funct3[0]), 1'b0};
                default: begin
                end
            endcase
        end
        default: begin
            end
    endcase

    end
    
endmodule
