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
    intput reset,
    input wen,
    input cache_ready,
    input cacheHit,
    output logic toggle
    );

    typedef enum logic [2:0] {
        START   = 3'b000,
        COMPARE = 3'b001,
        REFILL = 3'b010,
        MEMRD = 3'b011
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
                if (cacheHit) begin
                    toggle = 0;
                    nxt = START;
                end else begin
                    nxt = REFILL;
                    // use lru bit and assert busy/stall
                end
            end
            REFILL: begin
                toggle = 1;

                if (cache_ready) begin
                    toggle = 0;
                    nxt = COMPARE;
                end else begin
                    nxt = REFILL;
                end
            end
            default: nxt = START;
        endcase
    end

endmodule
