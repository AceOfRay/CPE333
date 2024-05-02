`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ryken Thompson
// 
// Create Date: 10/09/2023 10:47:59 AM
// Design Name: Register File
// Module Name: RF
// Target Devices: Basys3
// Description: Register file for OTTER MCU
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module RF(
    input [4:0] RF_ADR1,
    input [4:0] RF_ADR2,
    input [4:0] RF_WA,
    input [31:0] RF_WD,
    input RF_EN,
    input CLK,
    output logic [31:0] RF_RS1,
    output logic [31:0] RF_RS2
    );
    
    logic [31:0] ram [0:31]; //REGISTERS

    initial begin
        ram[0] = 0;
    end
    
    //Synchronous writing logic
    always_ff @ (posedge CLK) begin
        if (RF_EN && RF_WA) begin
            ram[RF_WA] <= RF_WD;
        end
    end
    
    //Continuous Reading logic
    always_comb begin
        RF_RS1 = ram[RF_ADR1];
        RF_RS2 = ram[RF_ADR2];
    end
    
endmodule
