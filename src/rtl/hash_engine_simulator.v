//===============================================================================
//
// hash_engine_simulator.v
// -------------- 
// Verilog implementation of the Blake2 simulator hash function. https://github.com/BLAKE2/BLAKE2
//
//
// Author: Ashan Shanaka Liyanage
// Copyright (c) 2017, CRISP.
// All rights reserved.
//===============================================================================


module hash_engine_simulator # (
	parameter	BLOCK_WIDTH,	// 1024
	parameter	DATA_LENGTH,	// 128
	parameter	DIGEST_LENGTH	// 88
	)(
//===============================================================================
	input wire 	clk,
	input wire 	reset_n,
//===============================================================================
	
	input wire 	init,
	input wire 	next,
	input wire 	final,
	input wire	[BLOCK_WIDTH-1:0] block_in,
	input wire 	[DATA_LENGTH-1:0] data_length,
	
	output reg 	hash_ready,
	output reg 	digest_valid,
	output reg 	[DIGEST_LENGTH-1:0] digest);
	
	reg		[DATA_LENGTH-1:0] counter;
	reg 		[BLOCK_WIDTH*BLOCK_WIDTH-1:0] temp_buf;	//1k Blocks of data 
	
	always @ (posedge clk or negedge reset_n) begin
		if (!reset_n) begin			
			digest		<= 'h0;
			temp_buf	<= 'h0;
			counter		<= 'h0;
			hash_ready	<= 1'b1;
			digest_valid	<= 1'b1;
		end
	end

	always @ (negedge clk) begin
		if ( init == 1 || next == 1 || final == 1 ) begin
			temp_buf[counter*BLOCK_WIDTH +: BLOCK_WIDTH] <= block_in;
			counter  <= counter + 1;
		end
	end

	// Fake hash_ready and digest ready signals 	
	always @ (posedge clk) begin
		if (init|next|final) begin
			hash_ready <= 0;
			digest_valid <= 0;
		end
		else begin
			hash_ready <= 1'b1;
			digest_valid <= 1'b1;
		end

	end

	integer file,outerr;	
	always @ (negedge final) begin
			$system ({"echo -n '", temp_buf, "' > /tmp/b2_dat"});
			$system("/usr/local/bin/b2sum -ablake2s -l88 /tmp/b2_dat | cut -d\" \" -f1 > /tmp/b2_dgst");
			file = $fopen("/tmp/b2_dgst", "r");
		    	outerr = $fscanf(file, "%h", digest);
    			if (file == 0) begin
        			digest = 'hx;
    			end
	end

endmodule

