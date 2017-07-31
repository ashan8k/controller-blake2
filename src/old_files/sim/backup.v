// Simulates blake2b function
// depends on: https://github.com/BLAKE2/BLAKE2

module main;

// input: init, next, final, block[1024]
// output: ready, digest_valid, digest[88-bits]
//
// init, next, final
//   1     0     1 // produce directly
//   1     0     0 // write to buffer and wait
//   0     1     0 ....


parameter CLK_PERIOD = 5;

parameter BUFFER_SIZE = 8;

reg clk = 0;
reg  [7   :  0] cycle_ctr;

reg             init_88;
reg             next_88;
reg             final;
reg [1023:  0]  block;      // set as IO when integrating
reg [127 :  0]  length_512; // set as IO when integrating
wire            ready_512;
reg  [87 :  0]  digest_88;
wire            digest_valid;

integer file, outerr;

reg  [511:  0] WRTMP; // increase size depending on digest length


task init(); begin
    block = "flamingo"; // remove before integration
    length_512 = 8;     // remove before integration
 
    WRTMP = {"echo -n '", block[length_512*8-1 -: 64], "' > /tmp/b2_dat"};
end
endtask

task simulate(); begin
    $display("executing:\n%s", WRTMP);
    $system(WRTMP);
    $system("/usr/local/bin/b2sum -ablake2s -l88 /tmp/b2_dat | cut -d\" \" -f1 > /tmp/b2_dgst");
    file = $fopen("/tmp/b2_dgst", "r");
    outerr = $fscanf(file, "%h", digest_88);
    if (file == 0) begin
        $display("Could not read file!");
        $finish;
    end
    $display("################## DIGEST ##################");
    $display("datalen: %d", length_512);
    $display("%h", digest_88);

    while (cycle_ctr < 28) begin
        cycle_ctr = cycle_ctr + 1;
    end
    $display("cycle count: %d", cycle_ctr);
    $display("################## SUCCESS #################");
    $fclose(file);
    $finish;
end
endtask

initial begin
    cycle_ctr = 0;
    init();
    simulate();
end

always @(*) begin
    #CLK_PERIOD clk = !clk;
end


endmodule
