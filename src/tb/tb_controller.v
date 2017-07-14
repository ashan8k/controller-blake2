//`timescale 1ns/ 10ps

module tb_controller # (
	parameter 	BUS_WIDTH	= 2,
	parameter 	BLOCK_WIDTH 	= 8,
	parameter 	DATA_LENGTH 	=8)();
    
	reg	clk;
	reg 	reset_n;
	reg 	[BUS_WIDTH-1:0] din;		
	reg 	valid_in;					
	reg 	new_hash_request;
	//wire	cont_buf_empty;
	//wire	cont_buf_full;
	reg	hash_ready;
	reg	digest_valid;
	wire	init;
	wire	next;
	wire	final;				
	wire	[BLOCK_WIDTH-1:0] block;	// 1024 in Blake2 
	wire 	[DATA_LENGTH-1:0] data_length;

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
		#20;
	@(posedge clk); new_hash_request =1;valid_in=0;
		#10
	@(posedge clk); new_hash_request =0;valid_in=1;
//	@(posedge clk);	hash_ready = 0;digest_valid = 0;
//		#20
//	@(posedge clk); new_hash_request =0;
//		#100 
//	@(posedge clk);	hash_ready = 1;
//		#10
//	@(posedge clk);	hash_ready = 0;
//		#30 
//	@(posedge clk);	hash_ready = 1;
//		#10
//	@(posedge clk);	hash_ready = 0;
//		#30 
//	@(posedge clk);	hash_ready = 1;
//		#10
//	@(posedge clk);	hash_ready = 0;
//		#30
//	@(posedge clk);	hash_ready = 1;digest_valid = 1;
//		#10
//		
//	// 1 block
//	@(posedge clk); valid_in =1;
//		#10
//	@(posedge clk); valid_in=0;
//		#40
//	@(posedge clk); new_hash_request =1;
//		#20
//	@(posedge clk);	hash_ready = 0;digest_valid = 0;
//		#20
//	@(posedge clk); new_hash_request =0;
//		#100 
//	@(posedge clk);	hash_ready = 1;digest_valid = 1;
//	#20
//	
//	// 2 block
//	@(posedge clk); valid_in =1;
//		#200
//	@(posedge clk); valid_in=0;
//		#40
//	@(posedge clk); new_hash_request =1;
//		#20
//	@(posedge clk);	hash_ready = 0;digest_valid = 0;
//		#20
//	@(posedge clk); new_hash_request =0;
//		#100 
//	@(posedge clk);	hash_ready = 1;
//		#10
//	@(posedge clk);	hash_ready = 0;
//		#30
//	@(posedge clk);	hash_ready = 1;digest_valid = 1;
	
	

		
		
		
 
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
	.DATA_LENGTH(DATA_LENGTH)
	) U_controller (
	.clk(clk),
	.reset_n(reset_n),
	.din(din),
	.valid_in(valid_in),
	.new_hash_request(new_hash_request),
	.hash_ready(hash_ready),
	.digest_valid(digest_valid),	
	.init(init),
	.next(next),
	.final(final),				
	.block(block),
	.data_length(data_length));
endmodule
