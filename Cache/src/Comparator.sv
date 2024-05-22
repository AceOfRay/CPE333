
module Comparator (
    input [23:0] tag1
    input [23:0] tag2
    output result;

    always_comb begin
        result = tag1 == tag2;
    end
    );
    
endmodule