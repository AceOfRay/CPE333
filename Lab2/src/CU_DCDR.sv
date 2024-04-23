`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ryken Thompson
// 
// Create Date: 10/30/2023 10:49:26 AM
// Design Name: OTTER MCU Compute Unit Decoder
// Module Name: CU_DCDR
// Project Name: OTTER MCU
// Target Devices: Basys3
// Description: Compute unit decoder for otter mcu
//              controls mux selectors
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CU_DCDR(
    input [6:0] opcode,
    input [2:0] funct3,
    input funct7,
    output logic [3:0] alu_fun,
    output logic [1:0]alu_srcA,
    output logic [1:0] alu_srcB,
    output logic [1:0] rf_wr_sel,
    output logic regWrite,
    output logic memWrite,
    output logic memRead2,
    output logic csr_WE,
    output logic mret_exec,
    output logic memRead1
    );
    
    always_comb begin
        alu_fun = 0;
        alu_srcA = 0;
        alu_srcB = 0;
        rf_wr_sel = 0;

        regWrite = 0;
        memWrite = 0;
        memRead1 = 1;
        memRead2 = 1;

        case (opcode)
            7'b0110011: begin   //R-TYPE
                //All R-TYPE functions write alu result to reg
                rf_wr_sel = 3;
                regWrite = 1;

                //Funct3 corresponds to alu_fun kinda epic
                alu_fun = {funct7, funct3};
            end
            7'b0010011: begin //I-TYPE arithmetic ops
                //Artihmetic ops so write alu result to reg file
                rf_wr_sel = 3;
                regWrite = 1;

                alu_srcB = 1; //I-TYPE immediate
                if (funct3 == 3'b101) alu_fun = {funct7, funct3};
                else alu_fun = {1'b0, funct3};
            end
            7'b1100111: begin //I-TYPE jalr
                regWrite = 1;
            end
            7'b0000011: begin //I-TYPE loads
                memRead2 = 1;
                regWrite = 1;
                alu_srcB = 1; //I-TYPE immediate
                rf_wr_sel = 2; //load data from DOUT2
            end
            7'b0100011: begin //S-TYPE
                memWrite = 1;
                alu_srcB = 2; //S-Type immediate for alu add
            end
            7'b0110111: begin //U-TYPE lui
                regWrite = 1;
                alu_fun = 4'b1001;
                alu_srcA = 1;
                rf_wr_sel = 3;
            end
            7'b0010111: begin //U-TYPE auipc
                //Add immediate to pc
                regWrite = 1;
                alu_srcA = 1;
                alu_srcB = 3;
                rf_wr_sel = 3;
            end
            7'b1101111: begin //J-TYPE
                regWrite = 1;
            end
            // 7'b1110011: begin //CSR
            //     case (funct3)
            //         3'b000: begin //MRET
            //             mret_exec = 1;
            //         end
            //         3'b001: begin //CSSRW
            //             csr_WE = 1;
            //             regWrite = 1;
            //             rf_wr_sel = 1;
            //             alu_fun = 4'b1001;
            //         end 
            //         3'b010: begin //CSRRS
            //             csr_WE = 1;
            //             regWrite = 1;
            //             rf_wr_sel = 1;
            //             alu_srcB = 4; //OR with current csr value to only set new bits
            //             alu_fun = 4'b0110;
            //         end
            //         3'b011: begin
            //             csr_WE = 1;
            //             regWrite = 1;
            //             rf_wr_sel = 1;
            //             alu_srcA = 2;
            //             alu_srcB = 4; //AND inverse of set bits with current csr value to clear bits
            //             alu_fun = 4'b0111;
            //         end
            //         default: begin
            //         end
            //     endcase
            // end
            default: begin
            end
        endcase
    end
    
    
endmodule