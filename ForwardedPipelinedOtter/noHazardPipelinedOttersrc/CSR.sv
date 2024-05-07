`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ryken Thompson
// 
// Create Date: 11/20/2023 04:55:07 PM
// Design Name: CSR
// Module Name: CSR
// Target Devices: Basys3
// Description: CSR for OTTER MCU
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CSR(
    input clk,
    input RST,
    input mret_exec,
    input INT_TAKEN,
    input [11:0] ADDR,
    input WR_EN,
    input [31:0] PC,
    input [31:0] WD,
    output logic [31:0] RD,
    output logic [31:0] MSTATUS = 0,
    output logic [31:0] MEPC = 0,
    output logic [31:0] MTVEC = 0
    );
    
    always_ff @(posedge clk) begin
        if (RST) begin
            MSTATUS <= 0;
            MEPC <= 0;
            MTVEC <= 0;
        end
        else if (INT_TAKEN) begin
            MEPC <= PC;
            MSTATUS[7] <= MSTATUS[3];
            MSTATUS[3] <= 0;
        end
        else if (WR_EN) begin
            case (ADDR)
                12'h300: MSTATUS <= WD;
                12'h305: MTVEC <= WD;
                12'h341: MEPC <= WD;
            endcase
        end
        else if (mret_exec) begin
            MSTATUS[3] <= MSTATUS[7];
            MSTATUS[7] <= 0;
        end
    end
    
    always_comb begin
        case (ADDR)
            12'h300: RD = MSTATUS;
            12'h305: RD = MTVEC;
            12'h341: RD = MEPC;
            default: RD = 0;
        endcase
    end
    
endmodule
