//===============================================================================
//
// controller.v
// -------------- 
// Verilog implementation of the cotrolling interface to the Blake2 simulator hash function.
//
//
// Author: Ashan Shanaka Liyanage
// Copyright (c) 2017, CRISP.
// All rights reserved.
//===============================================================================

module controller # (
	parameter 	BUS_WIDTH,
	parameter	BLOCK_WIDTH,
	parameter	DATA_LENGTH
	)(
//===============================================================================
	input wire	clk,
	input wire	reset_n,			

//===============================================================================
// Processor related ports  

	input wire	[BUS_WIDTH-1:0] din,
	input wire 	valid_in,
	input wire	new_hash_request,
	
	
//===============================================================================
// ports related to the hash engine 
	input wire	hash_ready,
	input wire	digest_valid,				// when finished
	
	output reg	init,
	output reg	next,
	output reg	final,				
	output reg	[BLOCK_WIDTH-1:0] block,		// 1024 in Blake2 
	output reg 	[DATA_LENGTH-1:0] data_length		// can give max. of 2^(DATA_LENGTH) bits of data
	);

	localparam	PACKETS_PER_BLOCK = BLOCK_WIDTH/BUS_WIDTH;

	reg		[$clog2(PACKETS_PER_BLOCK)-1:0] block_ptr; // if BLOCK_WIDTH=1024,BUS_WIDTH=32, then PACKETS_PER_BLOCK=32.. so [4:0]
	reg		corrupt;
	
	always @ (posedge clk or negedge reset_n) begin
		if (!reset_n) begin			
			block_ptr	<= 'h0;
			data_length     <= 1'b0;
		end
	end


	//always block for write operation	
	always @ (posedge clk) begin
		if (valid_in) begin
			if(block_ptr==0) begin
				block <= 0+din; 	
//				block[block_ptr*BUS_WIDTH+:BUS_WIDTH] <= din;
//				block[(PACKETS_PER_BLOCK-1)*BUS_WIDTH-:BUS_WIDTH] <= 'h0;
			end
			else begin	
				block[block_ptr*BUS_WIDTH+:BUS_WIDTH] <= din; // +: Varible part select 2001 verilog
			end
			block_ptr	<= block_ptr + 1;
			data_length 	<= data_length +1;
		end
	end
	
	always @ (posedge clk) begin
		if(new_hash_request) begin
			block_ptr <= 0;
			data_length <=0;
			block	<= 'h0;
		end
	end

	// always block for reading operations
	always @ (*) begin
		if(hash_ready)begin
			if(new_hash_request) begin
				if(data_length < PACKETS_PER_BLOCK) begin 		// Final + Init
					init	<= 1;
					next	<= 0;
					final	<= 1;
				end
				else begin					// Final
					init	<= 0;
					next	<= 0;
					final	<= 1;
				end
			end
			else begin
				if(block_ptr=='h0) begin
					if(data_length == PACKETS_PER_BLOCK) begin	// Init
						init	= 1;
						next	= 0;
						final	= 0;
					
					end
					else if (data_length > 0) begin	       		// Next 
						init	= 0;
						next	= 1;
						final	= 0;
					end
				end
				else begin					// INIT=0,NEXT=0,FINAL=0
					init	= 0;
					next	= 0;
					final	= 0;					
				end
			end
		end	
	end 

// Since this controller has 1 block of memory it can't buffered data so long if hash_ready and digest_valid took long time.
// in case to delect CORRUPT scenarios. follwing code is used 


	always @ (posedge clk) begin
		if(next==1 && hash_ready==0 || init==1 && hash_ready==0 || final==1 && hash_ready==0) begin
			corrupt =1;
		end
	end

endmodule






