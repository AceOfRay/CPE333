`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ray Valenzuela
// 
// Create Date: 04/25/2024 09:33:31 AM
// Design Name: Forwarding Unit
// Module Name: FWD_UNIT
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


module FWD_UNIT(
    input logic [4:0] R_OUT1,
    input logic [4:0] R_OUT2,
    input logic [4:0] EX_MEM_RD_ADDR,
    input logic [4:0] WB_RD_ADDR,
    input logic EX_MEM_REG_WRITE,
    input logic MEM_WB_REG_WRITE,
    output logic [1:0] FWD_A_SEL,
    output logic [1:0] FWD_B_SEL
    );

    always_comb begin
		if (EX_MEM_REG_WRITE && (EX_MEM_RD_ADDR != 0) && (EX_MEM_RD_ADDR == R_OUT1)) begin
			FWD_A_SEL = 2'b10;
		end
		else if (MEM_WB_REG_WRITE && (WB_RD_ADDR != 0) && (WB_RD_ADDR ==  R_OUT1)) begin
			FWD_A_SEL = 2'b01;
		end
		else begin
			FWD_A_SEL = 2'b00;
		end

		if (EX_MEM_REG_WRITE && (EX_MEM_RD_ADDR != 0) && (EX_MEM_RD_ADDR == R_OUT2)) begin
			FWD_B_SEL = 2'b10;
		end
		else if (MEM_WB_REG_WRITE && (WB_RD_ADDR != 0) && (WB_RD_ADDR ==  R_OUT2)) begin
			FWD_B_SEL = 2'b01;
		end
		else begin
			FWD_B_SEL = 2'b00;
		end
	end
    
    
endmodule
