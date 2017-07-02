//===============================================================================
//
// controller.v
// -------------- 
// Verilog implementation of the cotrolling interface to the modified Blake2 hash function.
//
//
// Author: Ashan Shanaka Liyanage
// Copyright (c) 2017, CRISP.
// All rights reserved.
//===============================================================================

module controller # (
	parameter 	BUS_WIDTH,		// bus width of processer ex: 64
	parameter	BLOCK_WIDTH,	// Block width of Blake2 ex: 1024
	parameter 	MAX_BLOCKS, 	// Ex: if you are using 5 blocks of hashing as maximum then make this to 5
	parameter 	DATA_LENGTH)(	// Data Length. of Block(s)
//===============================================================================
	input wire	clk,
	input wire	reset_n,			

//===============================================================================
// Processor related ports  

	input		[BUS_WIDTH-1:0] din,
	input		valid_in,
	input		new_hash_request,
	
	output reg	hash_started,	// goes to low until hasing finished
	output reg	cont_buf_empty,
	output reg	cont_buf_full,
	
//===============================================================================
// ports related to blake2 hash engine 

	output reg	init,
	output reg	next,
	output reg	final_block,				
	output reg	[BLOCK_WIDTH-1:0] block,	// 1024 in Blake2 
	output reg 	[DATA_LENGTH-1:0] data_length,			// can give max. of 2^(DATA_LENGTH) bits of data

	input		hash_ready,
	//input		[511 : 0] digest,			// Hardcoded value in blake2 // Right now nothing to do with this
	input		digest_valid				// when finished
	);
	//----------------------------------------------------------------
	// Internal constant and parameter definitions.
	//----------------------------------------------------------------
	parameter PACKETS = BLOCK_WIDTH/BUS_WIDTH;
	parameter MAX_DEPTH = PACKETS*MAX_BLOCKS;
	parameter EMPTY	= 0;
	
	reg 		[BUS_WIDTH-1:0] array_block[MAX_DEPTH-1:0];
	reg			[$clog2(MAX_DEPTH):0] counter;
	reg			[$clog2(MAX_BLOCKS):0] current_blocks,block_sent;
	reg sent;
	
	// Initial start and normal increment 
	integer i;
	always @ (posedge clk or negedge reset_n) begin
		if (!reset_n) begin			
			counter	<= 'h0;
			for (i=0; i<MAX_DEPTH; i=i+1) array_block[i] <= 'h0;	// Initial zero padding
			cont_buf_empty	<= 1'b1;
			cont_buf_full	<= 1'b0;
			hash_started	<= 1'b0;	// When hash started is not equal to 1, then init, next and final_block will be zero on next always block
		end
		else begin
			if (valid_in && !new_hash_request && !cont_buf_full && !hash_started) begin		
				if(counter < MAX_DEPTH) begin
					counter	<= counter + 1;
				end
				else begin
					counter	<= 0;
				end
			end
			else if (!valid_in && new_hash_request && !cont_buf_empty && !hash_started) begin
				hash_started <= 1;
				current_blocks <= ((counter-1)/PACKETS)+1;
				block_sent	<=0;
				data_length <= counter*BUS_WIDTH;
				sent <=0;
			end
		end	
		
	end
	//always block for write operation	
	always @ (posedge clk) begin
		if (valid_in && !new_hash_request && !cont_buf_full && !hash_started) begin	
			array_block[counter] <= din;
		end
	end
	
	//always block for read operation

	
	always @ (posedge clk) begin
		if(hash_ready==0) 		sent <= 0;
	end
	
	integer j;
	
	always @ (posedge clk) begin
		if(hash_started) begin
			if(hash_ready==1 && sent == 0)begin // send data only when hash is ready
			
				//  When only one block
				if(current_blocks==1 && block_sent==0) begin
					init <= 1;
					next <= 0;
					final_block <= 1;
					counter <= 'h0;
					
				end
				//  when 2 or more blocks 
				
				else begin 
					// last block sending
					if(current_blocks == 1) begin
						init <= 0;
						next <= 0;
						final_block <= 1;
						counter <= 'h0;
					end
					// first block sending
					else if(block_sent == 0) begin
						init <= 1;
						next <= 0;
						final_block <= 0;
					end
					// next block sending
					else begin
						init <= 0;
						next <= 1;
						final_block <= 0;						
					end
				end
									block_sent <= block_sent+1;
					current_blocks <= current_blocks-1;
					sent <= 1;
				// write data to block and after that zero padding
				for (j=0; j<PACKETS; j=j+1) begin
						block[BUS_WIDTH*j +: BUS_WIDTH]	<= array_block[block_sent*PACKETS+j];	// Verilog 2001 "variable part select"
						array_block[block_sent*PACKETS+j] <= 'h0;
				end				
			end
			else begin
				init <=0;
				next <=0;
				final_block <= 0;
			end
		end
		else begin
			init <=0;
			next <=0;
			final_block <= 0;
		end
	end
	
	always @ (*) begin
		if(counter==MAX_DEPTH) begin
			cont_buf_full = 1;
		end
		else begin
			cont_buf_full = 0;
		end
	end
	
	always @ (*) begin
	
		if(counter != EMPTY) begin
			cont_buf_empty = 0;
		end
		else begin
			cont_buf_empty = 1;
		end
	end
	
//	always @ (negedge hash_ready) begin
	//always @ (negedge final_block) begin
	//	hash_started <= 0;
	//	data_length	 <= 'h0;
	//	
	//end
	
	//always @ (posedge digest_valid) begin
	//	hash_started <= 0;
	//	data_length	 <= 'h0;
	//	
	//end
	always @ (posedge digest_valid) begin
		if( current_blocks==EMPTY) begin
			hash_started <= 0;
			data_length	 <= 'h0;
		end	
	end
	
	
endmodule		





