`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ryken Thompson
// 
// Create Date: 10/16/2023 10:00:44 PM
// Design Name: ALU
// Module Name: ALU
// Target Devices: Basys3 
// Description: Arithmetic Logic Unit for OTTER MCU
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input [31:0] srcA,
    input [31:0] srcB,
    input [3:0] ALU_FUN,
    output logic [31:0] RESULT
    );
    
    always_comb begin
        case (ALU_FUN)
            0: begin    //ADD
                RESULT = srcA + srcB;
            end
            1: begin    //SLL
                RESULT = srcA << srcB[4:0];
            end
            2: begin    //SLT
                RESULT = $signed(srcA) < $signed(srcB);
            end
            3: begin    //SLTU
                RESULT = srcA < srcB;
            end
            4: begin    //XOR
                RESULT = srcA ^ srcB;
            end
            5: begin    //SRL
                RESULT = srcA >> srcB[4:0];
            end
            6: begin    //OR
                RESULT = srcA | srcB;
            end
            7: begin    //AND
                RESULT = srcA & srcB;
            end
            8: begin    //SUB
                RESULT = srcA - srcB;
            end
            9: begin    //LUI-COPY
                RESULT = srcA;
            end
            13: begin   //SRA
                RESULT = $signed(srcA) >>> srcB[4:0];
            end
            default: begin
                RESULT = 'hDEADBEEF;
            end
        endcase
    end
endmodule
