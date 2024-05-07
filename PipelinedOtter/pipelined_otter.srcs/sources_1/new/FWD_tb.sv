`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ray Valenzuela
// 
// Create Date: 05/06/2024 01:16:47 PM
// Design Name: 
// Module Name: FWD_tb
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


module FWD_tb(
    );
    logic [4:0] R_OUT1;
    logic [4:0] R_OUT2;
    logic [4:0] EX_MEM_RD_ADDR;
    logic [4:0] WB_RD_ADDR;
    logic EX_MEM_REG_WRITE;
    logic MEM_WB_REG_WRITE;
    logic [1:0] FWD_A_SEL;
    logic [1:0] FWD_B_SEL;

    FWD_UNIT DUT (.*);

    initial begin
        // 1st test
        EX_MEM_REG_WRITE = 1'b1;
        EX_MEM_RD_ADDR = 5'b10001;
        R_OUT1 = 5'b10001;
        // expect FWD_A_SEL = 2'b10
        #10
        EX_MEM_REG_WRITE = 0;
        EX_MEM_RD_ADDR = 0;
        R_OUT1 = 0;
        #1

        // 2nd test
        MEM_WB_REG_WRITE = 1'b1;
        WB_RD_ADDR = 5'b10001;
        R_OUT1 = 5'b10001;
        // expect FWD_A_SEL = 2'b01
        #10

        EX_MEM_REG_WRITE = 0;
        EX_MEM_RD_ADDR = 0;
        R_OUT1 = 0;
        #1
        // 3rd test

        EX_MEM_REG_WRITE = 1'b1;
        EX_MEM_RD_ADDR = 5'b10001;
        R_OUT2 = 5'b10001;
        // expect FWD_B_SEL = 2'b10
        #10
        EX_MEM_REG_WRITE = 0;
        EX_MEM_RD_ADDR = 0;
        R_OUT2 = 0;
        #1
        // 4th test
        
        MEM_WB_REG_WRITE = 1'b1;
        WB_RD_ADDR = 5'b10001;
        R_OUT2 = 5'b10001;
        // expect FWD_B_SEL = 2'b01      
    end 


endmodule
