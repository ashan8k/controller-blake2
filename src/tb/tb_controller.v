//`timescale 1ns/ 10ps

module tb_controller # (
	parameter 	BUS_WIDTH = 2,
	parameter 	BLOCK_WIDTH = 16,
	parameter	MAX_BLOCKS= 4)();
    
	reg		clk;
	reg 	reset_n;
	reg 	valid_in;					
	reg 	new_hash_request;
	reg 	[BUS_WIDTH-1:0] din;		
	wire	hash_started;				
	wire	cont_buf_empty;
	wire	cont_buf_full;
	wire	init;
	wire	next;
	wire	final_block;				
	wire	[BLOCK_WIDTH-1:0] block;	// 1024 in Blake2 
	wire 	[127:0] data_length;
	reg		hash_ready;
	reg		digest_valid;

initial begin        

	clk = 1;       	
  	reset_n = 1;   
	din = 0;
// reset system	
  	#10 
  	reset_n = 0;    
  	#20 
	reset_n = 1;
	#10
// wring data until full

	valid_in =1;
	new_hash_request =0;
		#150
		valid_in=0;
		#40
		new_hash_request =1;
		#10
		new_hash_request =0;
		#30 
		hash_ready = 1;
		new_hash_request =1;
		#10
		hash_ready = 0;
		#30 
		hash_ready = 1;
		#10
		hash_ready = 0;
		#30 
		digest_valid = 1;
		#10
		digest_valid =0;
		
		
		
 
end

always begin
  #5 clk = ~clk; 
end

always begin
  #15 din = din+1; 
end

controller #(
	.BUS_WIDTH(BUS_WIDTH),
	.BLOCK_WIDTH(BLOCK_WIDTH),
	.MAX_BLOCKS(MAX_BLOCKS)
	) U_controller (
	.clk(clk),
	.reset_n(reset_n),
	.valid_in(valid_in),
	.new_hash_request(new_hash_request),
	.din(din),
	.init(init),
	.next(next),
	.final_block(final_block),				
	.block(block),
	.data_length(data_length),
	.hash_ready(hash_ready),
	.digest_valid(digest_valid),	
	.hash_started(hash_started),				
	.cont_buf_empty(cont_buf_empty),
	.cont_buf_full(cont_buf_full) );
endmodule
