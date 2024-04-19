`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2018 08:37:20 AM
// Design Name: 
// Module Name: simTemplate
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

module OTTER_tb(
     );
    
     logic CLK=0,BTNL,BTNC;
     logic [15:0] SWITCHES,LEDS;
     logic [7:0] CATHODES;
     logic [3:0] ANODES;
   
    OTTER_Wrapper DUT (.*);

    initial forever  #5  CLK =  ! CLK; 
   
    
    initial begin
        BTNC=1;
        #600 
        BTNC=0;
        SWITCHES=15'd0;

      //$finish;
    end
    
    
       
  /*  initial begin
         if(ld_use_hazard)
            $display("%t -------> Stall ",$time);
        if(branch_taken)
            $display("%t -------> branch taken",$time); 
      end*/
endmodule