`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ryken Thompson
// 
// Create Date: 10/30/2023 10:49:26 AM
// Design Name: OTTER MCU Compute Unit FSM
// Module Name: CU_FSM
// Project Name: OTTER MCU
// Target Devices: Basys3
// Description: Finite state machine for controlling synchronous
//              read and write signals in the OTTER MCU
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CU_FSM(
    input clk,
    input RST,
    input INTR,
    input [6:0] opcode,
    input [2:0] funct3,
    output logic PCWrite,
    output logic regWrite,
    output logic memWE2,
    output logic memRDEN1,
    output logic memRDEN2,
    output logic reset,
    output logic csr_WE,
    output logic int_taken,
    output logic mret_exec
    );
    
    typedef enum{INIT, FETCH, EXEC, WB, INTRPT} state;
    
    state NS, PS;
    
    always_ff @(posedge clk) begin
        if (RST) PS <= INIT;
        else PS <= NS;
    end
    
    always_comb begin
        PCWrite = 0;
        regWrite = 0;
        memWE2 = 0;
        memRDEN1 = 0;
        memRDEN2 = 0;
        reset = 0;
        mret_exec = 0;
        int_taken = 0;
        csr_WE = 0;
        
        case (PS)
            INIT: begin
                reset = 1;
                NS = FETCH;
            end
            FETCH: begin
                memRDEN1 = 1;
                NS = EXEC;
            end
            EXEC: begin
                case (opcode)
                    7'b0110011: begin //R-TYPE
                        PCWrite = 1;
                        regWrite = 1;
                        if (INTR) NS = INTRPT;
                        else NS = FETCH;
                    end
                    7'b0010011: begin //I-TYPE arithmetic ops
                        PCWrite = 1;
                        regWrite = 1;
                        if (INTR) NS = INTRPT;
                        else NS = FETCH;
                    end
                    7'b1100111: begin //I-TYPE jalr
                        PCWrite = 1;
                        regWrite = 1;
                        if (INTR) NS = INTRPT;
                        else NS = FETCH;
                    end
                    7'b0000011: begin //I-TYPE loads
                        memRDEN2 = 1;
                        NS = WB;
                    end
                    7'b0100011: begin //S-TYPE
                        memWE2 = 1;
                        PCWrite = 1;
                        if (INTR) NS = INTRPT;
                        else NS = FETCH;
                    end
                    7'b1100011: begin //B-TYPE
                        PCWrite = 1;
                        if (INTR) NS = INTRPT;
                        else NS = FETCH;
                    end
                    7'b0110111: begin //U-TYPE lui
                        PCWrite = 1;
                        regWrite = 1;
                        if (INTR) NS = INTRPT;
                        else NS = FETCH;
                    end
                    7'b0010111: begin //U-TYPE auipc
                        PCWrite = 1;
                        regWrite = 1;
                        if (INTR) NS = INTRPT;
                        else NS = FETCH;
                    end
                    7'b1101111: begin //J-TYPE
                        PCWrite = 1;
                        regWrite = 1;
                        if (INTR) NS = INTRPT;
                        else NS = FETCH;
                    end
                    7'b1110011: begin //CSR
                        case (funct3)
                            3'b000: begin //MRET
                                mret_exec = 1;
                                PCWrite = 1;
                            end
                            3'b001: begin //CSRRW
                                PCWrite = 1;
                                regWrite = 1;
                                csr_WE = 1;
                            end  
                            3'b010: begin //CSRRS
                                PCWrite = 1;
                                regWrite = 1;
                                csr_WE = 1;
                            end
                            3'b011: begin //CSRRC
                                PCWrite = 1;
                                regWrite = 1;
                                csr_WE = 1;
                            end
                            default: begin
                            end
                        endcase
                        if (INTR) NS = INTRPT;
                        else NS = FETCH;
                    end
                    default: begin
                        NS = INIT;
                    end
                endcase
            end
            WB: begin
                PCWrite = 1;
                regWrite = 1;
                if (INTR) NS = INTRPT;
                else NS = FETCH;
            end
            INTRPT: begin
                int_taken = 1;
                PCWrite = 1;
                NS = FETCH;
            end
            default: begin
                NS = INIT;
            end
        endcase
    end
    
endmodule
