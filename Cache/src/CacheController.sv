`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cow Poly
// Engineer: Danny Gutierrez
// 
// Create Date: 04/07/2024 12:27:49 AM
// Design Name: 
// Module Name: CacheController
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      This module is the cache controller.
//      It is responsible for controlling the memory system.
//
// Instantiated by:
//      CacheController myCacheController (
//          .CLK        ()
//      );
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CacheController(
    input CLK,
    input rden,
    input wen,
    input [23:0] tag,
    input [2:0] set,
    input [4:0] offset,
    input comp_res,
    output busy,
    output read_res,
    output w_res
    );

    typedef enum logic [2:0] {
        START   = 3'b000,
        COMPARE = 3'b001,
        CHECK = 3'b010,
        REFILL = 3'b011,
        MEMRD = 3'b100
    } state_t;

    state_t current, nxt;

    always_ff @(posedge CLK) begin
        if (reset)
            current <= START;
        else
            current <= nxt;
    end
 

    always_comb begin
        nxt = current;
        case (current)
            START: begin
                if (rden || wen) nxt = COMPARE;
                   
                    //start reading from tag array, dataArray, and validArray
            end
            COMPARE: begin
                if (comp_res && rden) begin
                    nxt = START;
                    read_res = 1;
                    // update lru
                end
                else if (comp_res && wen) begin
                    nxt = START;
                    w_res = 1;
                    // set dirty &update lru
                 end
                else
                    nxt = CHECK;
                    // use lru bit and assert busy/stall
            end
            CHECK: begin
                if (input_signal)
                    nxt = REFILL;
                else
                    nxt = START;
            end
            REFILL: begin
                if (input_signal)
                    nxt = MEMRD;
                else
                    nxt = START;
            end
            MEMRD: begin
                if (!input_signal)
                    nxt = START;
            end
            default: nxt = START;
        endcase
    end

endmodule
