`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2023 06:28:16 PM
// Design Name: 
// Module Name: mux_3bit_sel
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


module mux_3bit_sel(
    input [31:0] A,
    input [31:0] B,
    input [31:0] C,
    input [31:0] D,
    input [31:0] E,
    input [31:0] F,
    input [2:0] sel,
    output logic [31:0] O
    );
    
    always_comb begin
        case (sel)
            0: O = A;
            1: O = B;
            2: O = C;
            3: O = D;
            4: O = E;
            5: O = F;
            default: O = 0;
        endcase
    end
    
endmodule
