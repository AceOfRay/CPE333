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
    input [31:0] INSTR,
    output logic [2:0] pcSource
    );

    localparam JAL = 7'b1101111;
    localparam JALR = 7'b1100111;
    localparam BRANCH = 1100011;
    
    always_comb begin
        pcSource = 0;
 
        begin
            case (INSTR[6:0])
                JAL: begin
                    pcSource = 3;
                end
                JALR: begin
                    pcSource = 1;
                end
                BRANCH: begin
                    case (INSTR[14:13])
                        2'b00: pcSource = {1'b0, ~((RS1 == RS2) ^ ~INSTR[12]), 1'b0};
                        2'b10: pcSource = {1'b0, ~(($signed(RS1) < $signed(RS2)) ^ ~INSTR[12]), 1'b0};
                        2'b11: pcSource = {1'b0, ~((RS1 < RS2) ^ ~INSTR[12]), 1'b0};
                        default: pcSource = 0;
                    endcase
                end       
                default: begin
                    pcSource = 0;
                end
            endcase
        end
    end

endmodule
