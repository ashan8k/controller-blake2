//`timescale 1ns/ 10ps

module tb_controller_with_simulator # (
	parameter 	BUS_WIDTH	= 32,
	parameter 	BLOCK_WIDTH 	= 1024,
	parameter 	DATA_LENGTH 	= 128)();
    
	reg	clk;
	reg 	reset_n;
	reg 	[BUS_WIDTH-1:0] din;		
	reg 	valid_in;					
	reg 	new_hash_request;
	//wire	cont_buf_empty;
	//wire	cont_buf_full;
	//reg	hash_ready;
	//reg	digest_valid;
	wire	init;
	wire	next;
	wire	final;				
	wire	[BLOCK_WIDTH-1:0] block;	// 1024 in Blake2 
	wire 	[DATA_LENGTH-1:0] data_length;
	wire 	[87:0] digest;
initial begin        

	clk = 1;       	
  	reset_n = 1;   
	din = 0;
	valid_in =0;
	new_hash_request =0;
	din = 32'h61616161;
// reset system	
  	#10 
  	reset_n = 0;    
  	#20 
	reset_n = 1;
	#10;

// case1 0 data, new_hash_request 		// can not verfy  
	@(posedge clk); new_hash_request =1;valid_in=0;
		#10
	@(posedge clk); new_hash_request =0;
		#10

// case2, 4 byte data, new_hash_request  
	@(posedge clk); valid_in =1;
		#10;
	@(posedge clk); new_hash_request =1;valid_in=0;
		#10;
	@(posedge clk); new_hash_request =0;
		#10;

// case3 124 byte data, new_hash_request
	@(posedge clk); valid_in =1;
		#310;
	@(posedge clk); new_hash_request =1;valid_in=0;
		#10;
	@(posedge clk); new_hash_request =0;
		#10;

// case4 128 byte data, new_hash_request
	@(posedge clk); valid_in =1;
		#320;
	@(posedge clk); new_hash_request =1;valid_in=0;
		#10;
	@(posedge clk); new_hash_request =0;
		#10;

//case5 132 byte data, new_hash_request -> init, then final
	@(posedge clk); valid_in =1;
		#330;
	@(posedge clk); new_hash_request =1;valid_in=0;
		#10;
	@(posedge clk); new_hash_request =0;
		#10;

//case6 252 byte data, new_hash_request -> init, then 31 clocks final
	@(posedge clk); valid_in =1; 	
		#630;
	@(posedge clk); new_hash_request =1;valid_in=0;
		#10;
	@(posedge clk); new_hash_request =0;
		#10;

//case7 256 byte data, new_hash_request -> init, then 32 clocks final
	@(posedge clk); valid_in =1; 	
		#640;
	@(posedge clk); new_hash_request =1;valid_in=0;
		#10;
	@(posedge clk); new_hash_request =0;
		#10;		

//case8 260 byte data, new_hash_request -> init, then 32 clocks next, then final
	@(posedge clk); valid_in =1; 	
		#650;
	@(posedge clk); new_hash_request =1;valid_in=0;
		#10;
	@(posedge clk); new_hash_request =0;
		#10;		 

//case9 380 byte data, new_hash_request -> init, then 32 clocks next, then 31 clocks final
	@(posedge clk); valid_in =1; 	
		#950;
	@(posedge clk); new_hash_request =1;valid_in=0;
		#10;
	@(posedge clk); new_hash_request =0;
		#10;
		
//case10 384 byte data, new_hash_request -> init, then 32 clocks next, then 32 clocks final
	@(posedge clk); valid_in =1; 	
		#960;
	@(posedge clk); new_hash_request =1;valid_in=0;
		#10;
	@(posedge clk); new_hash_request =0;
		#10;

//case11 388 byte data, new_hash_request -> init, then 32 clocks next, then 32 clocks next, then final
	@(posedge clk); valid_in =1; 	
		#970;
	@(posedge clk); new_hash_request =1;valid_in=0;
		#10;
	@(posedge clk); new_hash_request =0;
		#10;
// case 200 bytes 
	@(posedge clk); valid_in =1; 	
		#250;
	@(posedge clk); valid_in =0; 	
		#50;
	@(posedge clk); valid_in =1; 	
		#250;

	@(posedge clk); valid_in=0;
		#10;
	@(posedge clk); new_hash_request =1;
		 #10;
	@(posedge clk); new_hash_request =0;


end

always begin
  #5 clk = ~clk; 
end

//always begin
//  #15 @(posedge clk); din = din+32'h11111111; 
//end

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
	
sim U_simulator (
	.clk(clk),
	.init(init), 
	.next(next),
	.final(final),
	.block(block), 
	.length(data_length),
	.ready(hash_ready),
	.digest_valid(digest_valid),
	.digest(digest)
	);

endmodule
