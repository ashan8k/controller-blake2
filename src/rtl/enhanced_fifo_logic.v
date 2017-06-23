module enhanced_fifo_logic	(
	input		clk,
	input		reset_n,
	input		write,
	input		read,
	input		[1:0] din,
	
	output reg	empty,
	output reg	full,
	output reg		[7:0] dout
	);
	
	reg		[1:0] arrayblock [15:0];
	reg		[4:0] next_wr_ptr;
	reg		[4:0] next_rd_ptr;
	reg		[4:0] curr_wr_ptr;
	reg		[4:0] curr_rd_ptr;
	reg 		overtake;
	
	always @ (posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			next_wr_ptr <= 'h0;
			next_rd_ptr <= 'h0;
			curr_wr_ptr <= 'h0;
			curr_rd_ptr <= 'h0;
		end
		
		else begin
			curr_wr_ptr <= next_wr_ptr;
			curr_rd_ptr <= next_rd_ptr;
		end	
	end
	
	always @ (posedge clk) begin
		if (write && !full) begin
			arrayblock [curr_wr_ptr[3:0]]	<= din;
		end
	end
	integer j;
	always @ (posedge clk) begin
		if(read && !empty) begin
			for (j=0; j<4; j=j+1) begin
				dout[2*j +: 2]	<= arrayblock[curr_rd_ptr[3:0]+j];	// Verilog 2001 "variable part select"
			end
//			for (j=0; j<rd_pkt; j=j+1) begin
//				regarray[rd_loc+j] 	<= 'h0;
//			end
		end
	end
	always @ (*) begin
		
		if (write && !full) begin
			next_wr_ptr = curr_wr_ptr + 1;
		end
		if (overtake) begin
			next_wr_ptr = curr_rd_ptr;
		end
		
		if (read && !empty) begin
			next_rd_ptr = curr_rd_ptr + 4;
		end
	end
	
	always @ (*) begin
		if (curr_wr_ptr == curr_rd_ptr) begin
			empty 	= 1'b1;
			full	= 1'b0;
			overtake= 1'b0;
		end
		else if (curr_wr_ptr[3:0] == curr_rd_ptr[3:0]) begin
			empty 	= 1'b0;
			full  	= 1'b1;
			overtake= 1'b0;
		end
		else if (curr_wr_ptr[4]==curr_rd_ptr[4] && curr_wr_ptr[3:0] < curr_rd_ptr[3:0]) begin
			empty	= 1'b1;
			full	= 1'b0;
			overtake= 1'b1;
			
		end
		else if (curr_wr_ptr[4]!=curr_rd_ptr[4] && curr_wr_ptr[3:0] > curr_rd_ptr[3:0]) begin
			empty 	= 1'b1;
			full 	= 1'b0;
			overtake= 1'b1;
		end
		else begin
			empty 	= 1'b0;
			full  	= 1'b0;
			overtake= 1'b0;
		end
	end
	
endmodule
