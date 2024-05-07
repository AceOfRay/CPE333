`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ryken Thompson
// 
// Create Date: 10/02/2023 09:47:53 AM
// Design Name: Program Counter
// Module Name: PC
// Target Devices: Basys3
// Description: Program Counter for OTTER MCU
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PC(
    //PC IN OUTS
    input PC_WRITE,
    input PC_RST,
    input [31:0] PC_DIN,
    input CLK,
    output logic [31:0] PC_COUNT
    
    //MUX IN OUTS
    /*input [31:0] JALR,
    input [31:0] BRANCH,
    input [31:0] JAL,
    input [31:0] MTVEC,
    input [31:0] MEPC,
    input [2:0] PC_SOURCE*/
    );
    
    /*reg [31:0] PC_DIN;
    
    //PC SWITCH
    always_comb begin
        case(PC_SOURCE)
            0: begin
                PC_DIN = PC_COUNT + 4;
            end
            1: begin
                PC_DIN = JALR;
            end
            2: begin
                PC_DIN = BRANCH;
            end
            3: begin
                PC_DIN = JAL;
            end
            4: begin
                PC_DIN = MTVEC;
            end
            5: begin
                PC_DIN = MEPC;
            end
            default: begin
                PC_DIN = 'hB16B00B5; //Should not get here
            end
        endcase
    end */
    
    always_ff @ (posedge CLK) begin
        if (PC_RST) begin //RESET
            PC_COUNT <= 0;
        end
        else if (PC_WRITE) begin // ENABLE
            PC_COUNT <= PC_DIN;
        end
        //Else hold value
    end
    
endmodule
