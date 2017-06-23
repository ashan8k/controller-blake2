//`timescale 1ns/ 10ps

module	tb_enhanced_fifo_logic # (
	parameter 	abits = 3,
	parameter 	dbits = 2,
	parameter	rd_pkt = 2)();
    
	reg	clk;
	reg 	reset_n;
	reg 	wr;					// write to the stack 
	reg 	rd;					// read from the stack
	reg 	[1:0] din;		
	wire	empty;				// stack empty
	wire	full;				// stack full
	wire	[7:0] dout;  	// ram

initial begin        

	clk = 1;       	
  	reset_n = 1;   
  	wr = 'x;
	rd = 'x;
	din= 1;
// reset system	
  	#10 
  	reset_n = 0;    
  	#20 
	reset_n = 1;
	#10
// wring data
	wr = 1;
	#20
	din=2;
	#20
	din=3;
	#20
	wr=1;


//	rd=0;
//	#10
//	din=1;
//	wr=0;
//	rd=1;
//	#40
//	din=2;
//	wr=1;
//	rd=0;
//	#10
//	din=3;
//	wr=1;
//	rd=0;
//	#20
//	din=1;
//	wr=1;
//	rd=0;
//	#100
//	din=5;
//	wr=0;
//	rd=1;
//	#10
//	din=3;
//	wr=0;
//	rd=1;
//	#40
//	din=4;
//	wr=1;
//	rd=0;
//	#10
//	din=5;
//	wr=1;
//	rd=0;
//	#20
//	din=6;
//	wr=1;
//	rd=0;
//	#40
//	din=4;
//	wr=1;
//	rd=1;
	
	

 
end

always begin
  #5 clk = ~clk; 
end


enhanced_fifo_logic U_fifo (
	.clk(clk),
	.reset_n(reset_n),
	.write(wr),
	.read(rd),
	.din(din),
	.empty(empty),
	.full(full),
	.dout(dout));

endmodule
