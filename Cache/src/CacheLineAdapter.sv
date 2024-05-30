`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cow Poly
// Engineer: Danny Gutierrez
// 
// Create Date: 04/07/2024 12:16:02 AM
// Design Name: 
// Module Name: CacheLineAdapter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:
//         This module is responsible for interfacing between the cache and the memory. The middle man if you will.
//         It will be responsible for reading and writing to the memory
//         It will also be responsible for reading and writing to the cache
//         It will be responsible for the cache line size
// 
// Instantiated by:
//      CacheLineAdapter myCacheLineAdapter (
//          .CLK        ()
//      );
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CacheLineAdapter (
    input CLK,
    input RST,
    input re,
    input we,
    input memValid,
    input [255:0] cacheDataIn, // data from cache to memory
    input [31:0] memDataIn,
    output logic ready,
    output [255:0] cacheDataOut, // data from memory to cache
    output [31:0] memDataOut //
    );

    logic [2:0] count;
    logic [255:0] line;
    integer currentBit;

    typedef enum logic[1:0] {
        WAIT,
        READ,
        WRITE
    } state;

    state current, nxt;

    always_ff @(posedge CLK) begin 
        if (RST) begin 
            current <= WAIT;
        end 
        else begin 
            current <= nxt;
        end
    end

    always_comb begin 
        nxt = current;
        ready = 1'b0;
        memDataOut = 0;
        cacheDataOut = 0;
        currentBit = count << 5;

        case (current)
            WAIT: begin 
                if (re) begin
                    nxt = READ;
                    count = 0;
                end 
                else if (we) begin
                    nxt = WRITE;
                    count = 0;
                end
            end 
            READ: begin 

                line[currentBit: currentBit - 32] = memDataIn;
                if (count == 3'd7) begin 
                    cacheDataOut = line;
                    ready = 1;
                    nxt = WAIT;
                end else begin 
                    count = count + 3'd1;
                end
            end
            WRITE: begin 

                cacheDataOut = line[currentBit: currentBit - 32];
                if (count == 3'd7) begin
                    ready = 1'b1;
                    nxt = IDLE;
                end else begin
                    count = count + 3'd1;
                end

            end


        endcase
    end

    
endmodule
