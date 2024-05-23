module Cache (
    input [31:0] address,
    input [255:0] data_in,
    input write_enable,
    input read_enable,
    input clk,
    input rst_n,
    output reg [31:0] data_out,
    output reg ready // Signals if the operation is complete
);
    // Address breakdown
    logic [23:0] tag;
    logic [2:0] set;
    logic [4:0] offset;

    // Cache memory, tag arrays, and LRU bits
    logic [255:0] cache_mem [7:0][1:0]; // 8 sets, 2 ways each, 256 bits per way (8 words)
    logic [23:0] tag_array [7:0][1:0];  // Tag array for each way in each set
    logic [1:0] lru_array [7:0];        // LRU bits for each set (0: way0 is LRU, 1: way1 is LRU)
    logic dirty_array [7:0][1:0];       // Dirty bits for each way in each set

    // Intermediate variables
    logic [255:0] line;
    logic [23:0] current_tag;
    logic hit_way0, hit_way1;
    logic [1:0] selected_way;
    logic valid_way0, valid_way1;
    logic dirty_way0, dirty_way1;

    // Address decoding
    always_comb begin
        tag = address[31:8];
        set = address[7:5];
        offset = address[4:0];
    end

    // Determine hit/miss and select way
    always_comb begin
        current_tag = tag;
        valid_way0 = (tag_array[set][0] == current_tag);
        valid_way1 = (tag_array[set][1] == current_tag);

        hit_way0 = valid_way0;
        hit_way1 = valid_way1;

        if (hit_way0) begin
            selected_way = 2'b00;
        end else if (hit_way1) begin
            selected_way = 2'b01;
        end else begin
            selected_way = lru_array[set]; // Select LRU way for replacement
        end
    end

    // Read and Write operations
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset logic (initialize cache, tag, LRU, and dirty arrays)
            integer i, j;
            for (i = 0; i < 8; i = i + 1) begin
                lru_array[i] <= 2'b00; // Initialize LRU to way 0
                for (j = 0; j < 2; j = j + 1) begin
                    cache_mem[i][j] <= 0;
                    tag_array[i][j] <= 0;
                    dirty_array[i][j] <= 0;
                end
            end
            ready <= 1'b0;
        end else if (read_enable) begin
            // Read operation
            ready <= 1'b0;
            if (hit_way0 || hit_way1) begin
                // Hit
                line = cache_mem[set][selected_way];
                case (offset[4:2]) // Select the word within the line
                    3'd0: data_out <= line[31:0];
                    3'd1: data_out <= line[63:32];
                    3'd2: data_out <= line[95:64];
                    3'd3: data_out <= line[127:96];
                    3'd4: data_out <= line[159:128];
                    3'd5: data_out <= line[191:160];
                    3'd6: data_out <= line[223:192];
                    3'd7: data_out <= line[255:224];
                endcase
                lru_array[set] <= (selected_way == 2'b00) ? 2'b01 : 2'b00; // Update LRU
                ready <= 1'b1;
            end else begin
                // Miss - handle miss (e.g., fetch from memory) - not implemented here
                ready <= 1'b0;
            end
        end else if (write_enable) begin
            // Write operation
            ready <= 1'b0;
            if (hit_way0 || hit_way1) begin
                // Hit
                line = cache_mem[set][selected_way];
                case (offset[4:2]) // Write the word within the line
                    3'd0: cache_mem[set][selected_way][31:0] <= data_in[31:0];
                    3'd1: cache_mem[set][selected_way][63:32] <= data_in[63:32];
                    3'd2: cache_mem[set][selected_way][95:64] <= data_in[95:64];
                    3'd3: cache_mem[set][selected_way][127:96] <= data_in[127:96];
                    3'd4: cache_mem[set][selected_way][159:128] <= data_in[159:128];
                    3'd5: cache_mem[set][selected_way][191:160] <= data_in[191:160];
                    3'd6: cache_mem[set][selected_way][223:192] <= data_in[223:192];
                    3'd7: cache_mem[set][selected_way][255:224] <= data_in[255:224];
                endcase
                dirty_array[set][selected_way] <= 1'b1; // Mark as dirty
                lru_array[set] <= (selected_way == 2'b00) ? 2'b01 : 2'b00; // Update LRU
                ready <= 1'b1;
            end else begin
                // Miss - handle miss (write-allocate, potentially evict dirty) - not implemented here
                ready <= 1'b0;
            end
        end
    end

endmodule
