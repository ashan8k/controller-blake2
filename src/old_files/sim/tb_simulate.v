// Simulates blake2b function
// depends on: https://github.com/BLAKE2/BLAKE2
include simulate.v;

module tb_simulate;

// input: init, next, final, block[1024]
// output: ready, digest_valid, digest[88-bits]
//
// init, next, final
//   1     0     1 // produce directly
//   1     0     0 // write to buffer and wait
//   0     1     0 ....

reg             clk;
reg             init;
reg             next;
reg             final;
reg [1023:  0]  block;      // set as IO when integrating
reg [127 :  0]  length;     // set as IO when integrating
wire            ready;
wire [87 :  0]  digest;
wire            digest_valid;

sim uut (.clk(clk),
         .init(init),
         .next(next),
         .final(final),
         .block(block),
         .length(length),
         .ready(ready),
         .digest_valid(digest_valid),
         .digest(digest));

parameter CLK_PERIOD = 2;

parameter BUFFER_SIZE = 8;

reg [1024*BUFFER_SIZE-1:0] buffer;

reg  [7   :  0] cycle_ctr;

always begin
    #CLK_PERIOD clk = !clk;
end

initial begin
    $display("starting simulation...");
    clk = 0;
    block = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
    length = 1024;
    
    init = 1; next = 0; final = 0;
    #(CLK_PERIOD);
//    init = 0; next = 1; final = 0;
    #(CLK_PERIOD);
    init = 0; next = 1; final = 0;
    block = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
    #(CLK_PERIOD);
    init = 0; next = 0; final = 1;

    while (!digest_valid) begin
        #(CLK_PERIOD);
    end
end

endmodule
