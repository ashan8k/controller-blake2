//`timescale 1ns/ 10ps

module test_bench_controller_fifo_stack # (
	parameter 	abits = 3,
	parameter 	dbits = 2,
	parameter	rd_pkt = 2)();
    
	reg		clk;
	reg 	reset_n;
	reg 	wr;					// write to the stack 
	reg 	rd;					// read from the stack
	reg 	[dbits-1:0] din;		
	wire	empty;				// stack empty
	wire	full;				// stack full
	wire	[dbits*rd_pkt-1:0] dout;  	// ram

initial begin        

	clk = 1;       	
  	reset_n = 1;   
  	wr = 'x;
	rd = 'x;
	din= 1;
	
  	#10 
  	reset_n = 0;    
  	#20 
	reset_n = 1;
	rd = 1;
	#10
	din=1;
	wr=1;
	rd=0;
	#10
	din=1;
	wr=0;
	rd=1;
	#40
	din=2;
	wr=1;
	rd=0;
	#10
	din=3;
	wr=1;
	rd=0;
	#20
	din=1;
	wr=1;
	rd=0;
	#100
	din=5;
	wr=0;
	rd=1;
	#10
	din=3;
	wr=0;
	rd=1;
	#40
	din=4;
	wr=1;
	rd=0;
	#10
	din=5;
	wr=1;
	rd=0;
	#20
	din=6;
	wr=1;
	rd=0;
	#40
	din=4;
	wr=1;
	rd=1;
	
	

 
end

always begin
  #5 clk = ~clk; 
end


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
