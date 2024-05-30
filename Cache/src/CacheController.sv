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
    input cache_ready,
    output toggle
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
                if (rden) begin
                    nxt = START;
                    // update lru : cache
                end
                else if (wen) begin
                    nxt = START;
                    // set dirty &update lru : cache
                 end
                else
                    nxt = CHECK;
                    busy = 1;
                    // use lru bit and assert busy/stall
            end
            CHECK: begin
                if (cache_ready) nxt = COMPARE;
            end
            default: nxt = START;
        endcase
    end

endmodule
