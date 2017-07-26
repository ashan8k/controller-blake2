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
	parameter 	BUS_WIDTH   = 32,
	parameter	BLOCK_WIDTH = 1024,
	parameter	DATA_LENGTH = 128
	)(
//===============================================================================
	input wire	clk,
	input wire	reset_n,			

//===============================================================================
// Processor related ports  

	input wire	[BUS_WIDTH-1:0] din,
	input wire 	valid_in,
	input wire	new_hash_request,
	
	output wire 	hash_corrupt,					// To detect when hash corrupt (for debug purpose)
	
//===============================================================================
// ports related to the hash engine 
	input wire	hash_ready,					// Hash is ready 
	input wire	digest_valid,					// When finished
	
	output reg	init,
	output reg	next,
	output reg	final,				
	output reg	[BLOCK_WIDTH-1:0] block_out,			// 1024 in Blake2 
	output reg 	[DATA_LENGTH-1:0] data_length_out		// can give max. of 2^(DATA_LENGTH) bits of data
	);

	localparam	PACKETS_PER_BLOCK = BLOCK_WIDTH/BUS_WIDTH;
	localparam	BUS_BYTES = BUS_WIDTH/8;

	reg		[$clog2(PACKETS_PER_BLOCK)-1:0] block_ptr; 	// if BLOCK_WIDTH=1024,BUS_WIDTH=32, then PACKETS_PER_BLOCK=32.. so [4:0]

	reg 		[BLOCK_WIDTH-1:0] block;			// Ex: 32 set of 32bits = 1024
	reg		[DATA_LENGTH-1:0] data_length;			// cumilative length of the bytes 

	// system reset (negedge)	
	always @ (posedge clk or negedge reset_n) begin
		if (!reset_n) begin			
			block_ptr	<= 'h0;
			data_length     <= 1'b0;
			block		<= 'h0;
		end
	end


	//always block for write operation	
	always @ (negedge clk) begin
		if (valid_in) begin
			if(block_ptr==0) begin
				block <= 0+din; 	
			end
			else begin	
				block[block_ptr*BUS_WIDTH+:BUS_WIDTH] <= din; // +: Varible part select 2001 verilog
			end
			block_ptr	<= block_ptr + 1;
			data_length 	<= data_length +BUS_BYTES;
		end
	end
	
	// after new_hash_request system should be re-initialize 
	always @ (posedge clk) begin
		if(new_hash_request) begin
			block_ptr <= 0;
			data_length <=0;
			block	<= 'h0;
		end
	end
	
	// always block for reading operations
	always @ (posedge clk) begin

			if((new_hash_request == 1) && (data_length <= PACKETS_PER_BLOCK*BUS_BYTES)) begin 		// Final + Init 
				init	<= 1;
				next	<= 0;
				final	<= 1;
				block_out 	<= block;
				data_length_out	<= data_length;
			end
			else if((new_hash_request == 1) && (data_length > PACKETS_PER_BLOCK*BUS_BYTES)) begin	// Final
				init	<= 0;
				next	<= 0;
				final	<= 1;
				block_out 	<= block;
				data_length_out	<= data_length;
			end
			else if((block_ptr == 0) && (data_length == PACKETS_PER_BLOCK*BUS_BYTES))begin		// Init
				init	<= 1;
				next	<= 0;
				final	<= 0;
				block_out 	<= block;
				data_length_out	<= data_length;
			end
			else if((block_ptr == 0) && (data_length > 0) )begin		//Next
				init	<= 0;
				next	<= 1;
				final	<= 0;
				block_out 	<= block;
				data_length_out	<= data_length;

			end
			else begin					// INIT=0,NEXT=0,FINAL=0
      				init	<= 0;
      				next	<= 0;
      				final	<= 0;					
				block_out 	<= 0;
				data_length_out	<= 0;
			end
	end 

// Since this controller has 1 block of memory it can't buffered data so long if hash_ready and digest_valid took long time.
// in case to delect CORRUPT scenarios. follwing code is used 

	assign hash_corrupt = (next|init|final)&(!hash_ready|!digest_valid);

endmodule






