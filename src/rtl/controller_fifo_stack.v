//===============================================================================
//
// controller_fifo_stack.v
// -------------- 
// Enhanced FIFO Stack for black2's controller.v
//
//
// Author: Ashan Shanaka Liyanage
// Copyright (c) 2017, CRISP.
// All rights reserved.
//===============================================================================
module controller_fifo_stack #	(
	parameter 	abits,				// Address bits  Ex: if you need 16 addresses then abits = 4,
	parameter	dbits,				// Data bits
	parameter	rd_pkt	)(			// How much packets need to read. Condition (abits**2)/rd_pkt = integer
    
	input 		clk,
	input 		reset_n,
	input 		wr,				// write to the stack 
	input 		rd,				// read from the stack
	input 		[dbits-1:0] din,		
	output reg	empty,				// stack empty
	output reg 	full,				// stack full
	output reg	[(dbits*rd_pkt)-1:0] dout	// Data output = dbits * rd_pkt
	);
			

	reg 		[dbits-1:0] regarray[2**abits-1:0]; 	// number of words in fifo = 2^(number of address bits)
	reg		[abits:0] rd_ptr; 			// note MSB is not really address
	reg		[abits:0] wr_ptr;			// note MSB is not really address
	wire		[abits-1:0] rd_loc;			// without MSB
	wire		[abits-1:0] wr_loc;			// without MSB
	
	
	assign		rd_loc = rd_ptr[abits-1:0];
	assign		wr_loc = wr_ptr[abits-1:0];
	
	
	// Initial start and normal increment 
	integer i;
	always @ (posedge clk or negedge reset_n) begin
		if (!reset_n) begin			
			rd_ptr 	<= 'h0;
			wr_ptr 	<= 'h0;
			for (i=0; i<2**abits; i=i+1) regarray[i] <= 'h0;	// Initial zero padding
		end
		else begin
			if (wr && !full) begin		
				wr_ptr	<= wr_ptr + 1;
			end
			if (rd && !empty) begin
				rd_ptr	<= rd_ptr + rd_pkt;
			end
			// Below line represent when rd_ptr overtakes the wr_ptr 
			if ((wr_ptr[abits]==rd_ptr[abits] && wr_loc < rd_loc) || (wr_ptr[abits]!=rd_ptr[abits]  && wr_loc > rd_loc )) begin
				wr_ptr	<=	rd_ptr;
			end
		end	
	end
	
	//empty if all the bits of rd_ptr and wr_ptr are the same.
	//full if all bits except the MSB are equal and MSB differes
	//Combinational logic  
	always @ (*) begin
		if (rd_ptr[abits-1:0] == wr_ptr[abits-1:0]) begin
			if (rd_ptr[abits:0] == wr_ptr[abits:0]) begin
				empty	= 1'b1;
				full	= 1'b0;
			end
			else begin
				empty	= 1'b0;
				full	= 1'b1;
			end
		end
		// Below line represent when rd_ptr overtakes the wr_ptr 
		else if ((wr_ptr[abits]==rd_ptr[abits] && wr_loc < rd_loc) || (wr_ptr[abits]!=rd_ptr[abits]  && wr_loc > rd_loc )) begin
			empty	= 1'b1;
			full	= 1'b0;
			
		end
		else begin
			empty	= 1'b0;
			full	= 1'b0;
		end
	end

	//always block for write operation
	always @ (posedge clk) begin
		if(wr && !full) begin
			regarray[wr_loc] 	<= din;  //at wr_loc location of regarray store what is given at din
		end
	end
			
	//always block for read operation
	integer j;
	always @ (posedge clk) begin
		if(rd && !empty) begin
			for (j=0; j<rd_pkt; j=j+1) begin
				dout[dbits*j +: dbits]	<= regarray[rd_loc+j];	// Verilog 2001 "variable part select"
			end
			for (j=0; j<rd_pkt; j=j+1) begin
				regarray[rd_loc+j] 	<= 'h0;
			end
		end
	end
		
endmodule
