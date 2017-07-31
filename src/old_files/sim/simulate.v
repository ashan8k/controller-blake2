// Simulates blake2b function
// depends on: https://github.com/BLAKE2/BLAKE2

module sim(clk, init, next, final, block, length, ready, digest_valid, digest);

parameter BUFFER_SIZE = 8;

input clk, init, next, final;
input [127 : 0] length;
input [1023 : 0] block;
output reg ready, digest_valid;
output reg [87 : 0] digest;

integer file, outerr, idx;

reg  [1024*32-1:  0] WRTMP; // increase size depending on digest length

reg [1024*BUFFER_SIZE-1:0] buffer;
reg [127 : 0] tmp_length;

task simulate(); begin
  //  $display("executing:\n%s", WRTMP);
    $system(WRTMP);
    $system("/usr/local/bin/b2sum -ablake2s -l88 /tmp/b2_dat | cut -d\" \" -f1 > /tmp/b2_dgst");
    file = $fopen("/tmp/b2_dgst", "r");
    outerr = $fscanf(file, "%h", digest);
    if (file == 0) begin
        $display("Could not read file!");
        //$finish;
    end
    $display("################## DIGEST ##################");
    $display("datalen: %d", tmp_length);
    $display("%h", digest);

    $display("################## SUCCESS #################");
    $fclose(file);
	@(posedge clk); buffer = 0;idx = 0;
    // $finish;
end
endtask

initial begin
    idx = 0;
	buffer ='h0;
	buffer ='h0;
end

//always @(*) begin
//    if (init) begin
// //       $display("Entering [[___<init>___]]");
// //       $display("[FEEDING BUFFER]: %s", block);
//        buffer[1023:0] = block;
////        $display("[BUF]: {%s}", buffer);
//    end
//    if (next)  begin
//        idx = idx + 1;
//  //      $display("Entering [[___<next>___]]");
//  //      $display("[FEEDING BUFFER]: %s at index '%d'", block, idx);
//        buffer[(1024*(idx+1))-1-:1024] = block;
//   //     $display("[BUF]: {%s}", buffer);
//    end
//    if (final) begin
//    //    $display("Entering [[___<final>___]]");
//    //    $display("[BUF]: {%s}", buffer);
//        
//        WRTMP = {"echo -n '", buffer, "' > /tmp/b2_dat"};
//        simulate();
//        digest_valid = 1;
//        //$finish();
//    end
//end


always @ (posedge clk) begin
    if (init) begin
 //       $display("Entering [[___<init>___]]");
 //       $display("[FEEDING BUFFER]: %s", block);
        buffer[1023:0] <= block;
//        $display("[BUF]: {%s}", buffer);
    end

	
    else if (next || (final && !init))  begin
        idx = idx + 1;
  //      $display("Entering [[___<next>___]]");
  //      $display("[FEEDING BUFFER]: %s at index '%d'", block, idx);
        //buffer[(1024*(idx+1))-1-:1024] = block;
        buffer[(1024*(idx+1))-1-:1024] <= block;
   //     $display("[BUF]: {%s}", buffer);
    end

end

always @ (negedge final) begin

        WRTMP = {"echo -n '", buffer, "' > /tmp/b2_dat"};
        simulate();
        digest_valid = 1;
	tmp_length <= length;
end




endmodule
