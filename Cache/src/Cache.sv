module Cache (
    input [31:0] address,
    input [255:0] dataIn,
    input we,
    input re,
    input clk,
    input reset,
    output reg [31:0] dataOut,
    output reg miss // Signals if the operation is complete
);
    // Address breakdown
    logic [23:0] tag;
    logic [2:0] set;
    logic [4:0] offset;

    // Cache memory, tag arrays, and LRU bits
    logic [255:0] mem [7:0][1:0]; // 8 sets, 2 ways each, 256 bits per way (8 words)
    logic [23:0] tagArray [7:0][1:0];  // Tag array for each way in each set
    logic [1:0] lruArray [7:0];        // LRU bits for each set (0: way0 is LRU, 1: way1 is LRU)
    logic dirty [7:0][1:0];       // Dirty bits for each way in each set

    // Intermediate variables
    logic [255:0] line;
    logic [23:0] curTag;
    logic hitW0, hitW1;
    logic [1:0] correctWay;
    logic validW0, validW1;
    logic dirty_way0, dirty_way1;

    // Address decoding
    always_comb begin
        tag = address[31:8];
        set = address[7:5];
        offset = address[4:0];
    end

    // Determine hit/miss and select way
    always_comb begin
        curTag = tag;
        validW0 = (tagArray[set][0] == curTag);
        validW1 = (tagArray[set][1] == curTag);

        hitW0 = validW0;
        hitW1 = validW1;

        if (hitW0) begin
            correctWay = 2'b00;
        end else if (hitW1) begin
            correctWay = 2'b01;
        end else begin
            correctWay = lruArray[set]; // Select LRU way for replacement
        end
    end

    // Read and Write operations
    always_ff @(posedge clk) begin
        if (reset) begin
            // Reset logic (initialize cache, tag, LRU, and dirty arrays)
            integer i, j;
            for (i = 0; i < 8; i = i + 1) begin
                lruArray[i] <= 2'b00; // Initialize LRU to way 0
                for (j = 0; j < 2; j = j + 1) begin
                    // clearing out the important arrays
                    mem[i][j] <= 0;
                    tagArray[i][j] <= 0;
                    dirty[i][j] <= 0;
                end
            end
            miss <= 1'b0;
        end else if (re) begin
            // Read operation
            miss <= 1'b0;
            if (hitW0 || hitW1) begin
                // Hit
                line = mem[set][correctWay];
                case (offset[4:2]) // Select the word within the line
                    3'd0: dataOut <= line[31:0];
                    3'd1: dataOut <= line[63:32];
                    3'd2: dataOut <= line[95:64];
                    3'd3: dataOut <= line[127:96];
                    3'd4: dataOut <= line[159:128];
                    3'd5: dataOut <= line[191:160];
                    3'd6: dataOut <= line[223:192];
                    3'd7: dataOut <= line[255:224];
                endcase
                lruArray[set] <= (correctWay == 2'b00) ? 2'b01 : 2'b00; // Update LRU
                miss <= 1'b0;
            end else begin
                // Miss - handle miss (e.g., fetch from memory) - not implemented here
                miss <= 1'b1;
            end
        end else if (we) begin
            // Write operation
            miss <= 1'b0;
            if (hitW0 || hitW1) begin
                // Hit
                line = mem[set][correctWay];
                case (offset[4:2]) // Write the word within the line
                    3'd0: mem[set][correctWay][31:0] <= dataIn[31:0];
                    3'd1: mem[set][correctWay][63:32] <= dataIn[63:32];
                    3'd2: mem[set][correctWay][95:64] <= dataIn[95:64];
                    3'd3: mem[set][correctWay][127:96] <= dataIn[127:96];
                    3'd4: mem[set][correctWay][159:128] <= dataIn[159:128];
                    3'd5: mem[set][correctWay][191:160] <= dataIn[191:160];
                    3'd6: mem[set][correctWay][223:192] <= dataIn[223:192];
                    3'd7: mem[set][correctWay][255:224] <= dataIn[255:224];
                endcase
                dirty[set][correctWay] <= 1'b1; // Mark as dirty
                lruArray[set] <= (correctWay == 2'b00) ? 2'b01 : 2'b00; // Update LRU
                miss <= 1'b0;
            end else begin
                // Miss - handle miss (write-allocate, potentially evict dirty) - not implemented here
                miss <= 1'b1;
            end
        end
    end

endmodule
