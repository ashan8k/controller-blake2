//===============================================================================
//
// controller.v
// -------------- 
// Verilog implementation of the cotrolling interface to the hash function Blake2.
//
//
// Author: Ashan Shanaka Liyanage
// Copyright (c) 2017, CRISP.
// All rights reserved.
//===============================================================================

module controller # (
	parameter 	proc_bus_width,
	parameter 	stack_depth)(
//===============================================================================
	input wire	clk,
	input wire	reset_n,			

//===============================================================================
// Processor related ports  

	input wire 	[proc_bus_width-1:0] data_in,
	input wire  	valid_in,
	input wire	new_hash_request,
	
	output wire	stop_sending,
	
//===============================================================================
// ports related to blake2 hash engine 

	output wire	init,
	output wire	next,
	output wire 	final_block,				
	output wire	[1023:0] block,		// Hardcoded value in blake2
	output wire 	[127:0] data_length,// Hardcoded value in blake2

	input wire 	hash_ready,
	input wire 	[511 : 0] digest,	// Hardcoded value in blake2 // Right now nothing to do with this
	input wire 	digest_valid		// Right now nothing to do with this
	);

	controller_core #(
	) U_controller_core (
	);

	controller_fifo_stack #(
	.abits(abits),
	.dbits(dbits),
	.rd_pkt(rd_pkt)
	) U_controller_fifo_stack (
	.clk(clk),
	.reset_n(reset_n),
	.wr(wr),
	.rd(rd),
	.din(din),
	.empty(empty),
	.full(full),
	.dout(dout));

endmodule	
			





