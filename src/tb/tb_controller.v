//`timescale 1ns/ 10ps

module tb_controller # (
	parameter 	BUS_WIDTH = 64,
	parameter 	BLOCK_WIDTH = 1024,
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
	wire 	[63:0] data_length;
	reg		hash_ready;
	reg		digest_valid;

initial begin        

	clk = 1;       	
  	reset_n = 1;   
	din = 0;
	valid_in =0;
	new_hash_request =0;
	hash_ready = 1;
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
	@(posedge clk);	hash_ready = 0;digest_valid = 0;
		#20
	@(posedge clk); new_hash_request =0;
		#100 
	@(posedge clk);	hash_ready = 1;
		#10
	@(posedge clk);	hash_ready = 0;
		#30 
	@(posedge clk);	hash_ready = 1;
		#10
	@(posedge clk);	hash_ready = 0;
		#30 
	@(posedge clk);	hash_ready = 1;
		#10
	@(posedge clk);	hash_ready = 0;
		#30
	@(posedge clk);	hash_ready = 1;digest_valid = 1;
		#10
		
	// 1 block
	@(posedge clk); valid_in =1;
		#10
	@(posedge clk); valid_in=0;
		#40
	@(posedge clk); new_hash_request =1;
		#20
	@(posedge clk);	hash_ready = 0;digest_valid = 0;
		#20
	@(posedge clk); new_hash_request =0;
		#100 
	@(posedge clk);	hash_ready = 1;digest_valid = 1;
	#20
	
	// 2 block
	@(posedge clk); valid_in =1;
		#200
	@(posedge clk); valid_in=0;
		#40
	@(posedge clk); new_hash_request =1;
		#20
	@(posedge clk);	hash_ready = 0;digest_valid = 0;
		#20
	@(posedge clk); new_hash_request =0;
		#100 
	@(posedge clk);	hash_ready = 1;
		#10
	@(posedge clk);	hash_ready = 0;
		#30
	@(posedge clk);	hash_ready = 1;digest_valid = 1;
	
	

		
		
		
 
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
