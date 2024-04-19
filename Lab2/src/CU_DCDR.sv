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
    input br_eq,
    input br_lt,
    input br_ltu,
    input int_taken,
    output logic [3:0] alu_fun,
    output logic [1:0] alu_srcA,
    output logic [2:0] alu_srcB,
    output logic [2:0] pcSource,
    output logic [1:0] rf_wr_sel
    );
    
    always_comb begin
        alu_fun = 0;
        alu_srcA = 0;
        alu_srcB = 0;
        pcSource = 0;
        rf_wr_sel = 0;
        
        //Check if intterupt
        if (int_taken) begin
            pcSource = 4;
        end 
        else begin
        case (opcode)
            7'b0110011: begin   //R-TYPE
                //All R-TYPE functions write alu result to reg
                rf_wr_sel = 3;

                //Funct3 corresponds to alu_fun kinda epic
                alu_fun = {funct7, funct3};
            end
            7'b0010011: begin //I-TYPE arithmetic ops
                //Artihmetic ops so write alu result to reg file
                rf_wr_sel = 3;
                alu_srcB = 1; //I-TYPE immediate
                if (funct3 == 3'b101) alu_fun = {funct7, funct3};
                else alu_fun = {1'b0, funct3};
            end
            7'b1100111: begin //I-TYPE jalr
                pcSource = 1;
            end
            7'b0000011: begin //I-TYPE loads
                alu_srcB = 1; //I-TYPE immediate
                rf_wr_sel = 2; //load data from DOUT2
            end
            7'b0100011: begin //S-TYPE
                alu_srcB = 2; //S-Type immediate for alu add
            end
            7'b1100011: begin //B-TYPE
                case (funct3[2:1])
                    2'b00: pcSource = {~(br_eq ^ ~funct3[0]), 1'b0};
                    2'b10: pcSource = {~(br_lt ^ ~funct3[0]), 1'b0};
                    2'b11: pcSource = {~(br_ltu ^ ~funct3[0]), 1'b0};
                    default: begin
                    end
                endcase
            end
            7'b0110111: begin //U-TYPE lui
                alu_fun = 4'b1001;
                alu_srcA = 1;
                rf_wr_sel = 3;
            end
            7'b0010111: begin //U-TYPE auipc
                //Add immediate to pc
                alu_srcA = 1;
                alu_srcB = 3;
                rf_wr_sel = 3;
            end
            7'b1101111: begin //J-TYPE
                pcSource = 3;
            end
            7'b1110011: begin //CSR
                case (funct3)
                    3'b000: begin //MRET
                        pcSource = 5;
                    end
                    3'b001: begin //CSSRW
                        rf_wr_sel = 1;
                        alu_fun = 4'b1001;
                    end 
                    3'b010: begin //CSRRS
                        rf_wr_sel = 1;
                        alu_srcB = 4; //OR with current csr value to only set new bits
                        alu_fun = 4'b0110;
                    end
                    3'b011: begin
                        rf_wr_sel = 1;
                        alu_srcA = 2;
                        alu_srcB = 4; //AND inverse of set bits with current csr value to clear bits
                        alu_fun = 4'b0111;
                    end
                    default: begin
                    end
                endcase
            end
            default: begin
            end
        endcase
        end
    end
    
    
endmodule
