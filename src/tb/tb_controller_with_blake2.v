//`timescale 1ns/ 10ps

module tb_controller_with_blake2 # (
	parameter 	BUS_WIDTH = 64,
	parameter 	BLOCK_WIDTH = 1024,
	parameter	MAX_BLOCKS= 4,
	parameter 	DATA_LENGTH=128)();
    
	reg		clk;
	reg 	reset_n;
	reg 	valid_in;					
	reg 	new_hash_request;
	reg 	[BUS_WIDTH-1:0] din;		
	wire	hash_started;				
	wire	cont_buf_empty;
	wire	cont_buf_full;
				
	wire	[BLOCK_WIDTH-1:0] w_block;	// 1024 in Blake2 
	wire 	[DATA_LENGTH-1:0] w_data_length;

	wire		[511:0]digest;

initial begin        

	clk = 1;       	
  	reset_n = 1;   
	din = 0;
	valid_in =0;
	new_hash_request =0;
// reset system	
  	#10 
  	reset_n = 0;    
  	#20 
	reset_n = 1;
	#10

	// 4 blocks 
	@(posedge clk); valid_in =1;
		#600
	@(posedge clk); valid_in=0;
		#40
	@(posedge clk); new_hash_request =1;
		#20
	@(posedge clk); new_hash_request =0;

		
		
 
end

always begin
  #5 clk = ~clk; 
end

always begin
  #15 @(posedge clk); din = din+1; 
end

controller #(
	.BUS_WIDTH(BUS_WIDTH),
	.BLOCK_WIDTH(BLOCK_WIDTH),
	.MAX_BLOCKS(MAX_BLOCKS),
	.DATA_LENGTH(DATA_LENGTH)
	) U_controller (
	.clk(clk),
	.reset_n(reset_n),
	.valid_in(valid_in),
	.new_hash_request(new_hash_request),
	.din(din),
	.init(w_init),
	.next(w_next),
	.final_block(w_final_block),				
	.block(w_block),
	.data_length(w_data_length),
	.hash_ready(w_hash_ready),
	.digest_valid(w_digest_valid),	
	.hash_started(hash_started),				
	.cont_buf_empty(cont_buf_empty),
	.cont_buf_full(cont_buf_full) );
	
	  // The BLAKE2b-88 core
  blake2_core #(
     .DIGEST_LENGTH(11)
  )
  dut (
    .clk(clk),
	.reset_n(reset_n),
	.init(w_init),
    .next(w_next),
    .final_block(w_final_block),
    .block(w_block),
    .data_length(w_data_length),
    .ready(w_hash_ready),
    .digest(digest),
    .digest_valid(w_digest_valid)
  );
endmodule
