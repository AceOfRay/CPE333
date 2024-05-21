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
    input CLK
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
                if (input_signal)
                    nxt = COMPARE;
            end
            COMPARE: begin
                if (input_signal)
                    nxt = CHECK;
                else
                    nxt = START;
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
