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

module controller # 	(
			parameter 	proc_bus_width,
			parameter 	stack_depth
			)

			(
//===============================================================================
			input wire	clk,
			input wire	reset_n,			

//===============================================================================
// Processor related ports  

			input wire 	[proc_bus_width-1:0] data_in,
			input wire  valid_in,
			input wire	new_hash_request,
			
			output wire	stop_sending,

		
//===============================================================================
// ports related to blake2 hash engine 

			output wire	init,
			output wire	next,
			output wire final_block,				
			output wire	[1023:0] block,		// Hardcoded value in blake2
			output wire [127:0] data_length,// Hardcoded value in blake2

			input wire 	hash_ready,

			input wire 	[511 : 0] digest,	// Hardcoded value in blake2 // Right now nothing to do with this
			input wire 	digest_valid		// Right now nothing to do with this

		     );

//===============================================================================
// Internal registers and local parameters
			
//			reg 		[stack_depth-1:0] pointr [$clog2(1024/proc_bus_width) -1 :0];
			reg 		[1:0] pointr [3:0];
//			reg 		[1023:0] stack [0:stack_depth-1];
			reg 		[1023:0] stack [0:1];
			
			reg 		[1:0]controller_state;
		
			localparam 	idle  = 2'b00;
			localparam 	read_stack  = 2'b01;
			localparam 	write_stack = 2'b10;

//===============================================================================
// Initialization

			always @ (posedge clk or negedge reset_n)
    				begin : reg_update
      					if (!reset_n)
        					begin
							controller_state<= idle;
							pointr[*][*] 	<= 0;
							stack		<= 0;
						end
					else
						begin: state_diagram
							case(controller_state)

							idle: 	
								if (valid_in && !new_hash_request)
									begin
										controller_state <= write_stack;
									end
								else if (!valid_in && new_hash_request && hash_ready)
									begin
										controller_state <= read_stack;
									end
								else
									begin
										controller_state <= idle;
									end
									

							read_stack:
								if (valid_in && !new_hash_request)
									begin
										controller_state <= write_stack;
									end
								else
									begin
										controller_state <= idle;
									end
								
							write_stack: 	
								if (valid_in && !new_hash_request)
									begin
										controller_state <= write_stack;
									end
								else if (!valid_in && new_hash_request && hash_ready)
									begin
										controller_state <= read_stack;
									end
								else
									begin
										controller_state <= idle;
									end
							endcase

						end
				end

//===============================================================================
// Stack
//===============================================================================
 
//			always @(posedge clk) begin
//				if (reset) begin
//					pointr	<= 0;
//					end
//				else begin
//				if (push) begin 	 
//					stack[pointr] <= din;
//					pointr <= pointr + 1;
//					dout 	<= din;
//			end
//			else if (pop) begin
//				pointr 	<= pointr - 1;
//				dout	<= stack[pointr-1]; 
//				stack[pointr-1] <= 'x;
//			end 
//			else begin
//				dout	<= stack[pointr-1];
//			end
//
//		end
//	end


endmodule	
			





