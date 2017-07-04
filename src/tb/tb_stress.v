`timescale 1ns/100ps

module tb_blake2_core();

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter DISPLAY_STATE = 0;

  parameter CLK_HALF_PERIOD = 2;
  parameter CLK_PERIOD      = 2 * CLK_HALF_PERIOD;


  //----------------------------------------------------------------
  // Register and Wire declarations.
  //----------------------------------------------------------------
  reg [63 : 0]   cycle_ctr;
  reg [31 : 0]   error_ctr;
  reg [31 : 0]   tc_ctr;

  reg            tb_clk;
  reg            tb_reset_n;

  reg            tb_init_88;
  reg            tb_next_88;
  reg            tb_final_88;
  reg [1023 : 0] tb_block_88;
  reg [63 	: 0] tb_length_88;
  wire           tb_ready_88;

  wire [87	: 0] tb_digest_88;
  wire           tb_digest_valid_88;

  //----------------------------------------------------------------
  // blake2_core devices under test.
  //----------------------------------------------------------------


  // The BLAKE2b-88 core
  blake2_core #(
     .DIGEST_LENGTH(11)
  )
  dut_88 (
    .clk(tb_clk),
	 .reset_n(tb_reset_n),
	 .init(tb_init_88),
    .next(tb_next_88),
    .final_block(tb_final_88),
    .block(tb_block_88),
    .data_length(tb_length_88),
    .ready(tb_ready_88),
    .digest(tb_digest_88),
    .digest_valid(tb_digest_valid_88)
  );



  //----------------------------------------------------------------
  // clk_gen
  //
  // Clock generator process.
  //----------------------------------------------------------------
  always
    begin : clk_gen
      #CLK_HALF_PERIOD tb_clk = !tb_clk;
    end // clk_gen


  //----------------------------------------------------------------
  // reset_dut
  //----------------------------------------------------------------
  task reset_dut;
    begin
      tb_reset_n = 0;
      #(2 * CLK_PERIOD);
      tb_reset_n = 1;
    end
  endtask // reset_dut


  //----------------------------------------------------------------
  // display_test_result()
  //
  // Display the accumulated test results.
  //----------------------------------------------------------------
  task display_test_result;
    begin
      if (error_ctr == 0)
        begin
          $display("*** All %02d test cases completed successfully", tc_ctr);
        end
      else
        begin
          $display("*** %02d test cases did not complete successfully.", error_ctr);
        end
    end
  endtask // display_test_result


  //----------------------------------------------------------------
  // init()
  //
  // Set the input to the DUT to defined values.
  //----------------------------------------------------------------
  task init;
    begin
      cycle_ctr  = 0;
      error_ctr  = 0;
      tc_ctr     = 0;
      tb_clk     = 0;
      tb_reset_n = 1;
		
		tb_next_88 = 0;
    end
  endtask // init

  //----------------------------------------------------------------
  // test_88_core
  //
  // Test the 88-bit hashing core
  //----------------------------------------------------------------
  task test_88_core(
      input [1023 : 0] block,
      input [63 : 0]  data_length,
      input [87  : 0]  expected
    );
    begin
      tb_block_88 = block;
      tb_length_88 = data_length;
		
		cycle_ctr = 0;

      reset_dut();
		
		// *vvvvvvvvvvvvv* ???
      tb_init_88 = 1;
      tb_final_88 = 1;
      #(2 * CLK_PERIOD);
		cycle_ctr = cycle_ctr + 2;
      tb_final_88 = 0;
      tb_init_88 = 0;

      while (!tb_digest_valid_88) begin
        #(CLK_PERIOD);
		  cycle_ctr = cycle_ctr + 1;
		end
      #(CLK_PERIOD);
		cycle_ctr = cycle_ctr + 1;

      if (tb_digest_88 == expected) begin
		  $display("#######################");
		  $display("DATA = %s", block);
        $display("DGST = 0x%011x", tb_digest_88);
		  $display("#######################");
        tc_ctr = tc_ctr + 1;
		  $display("clk count: ", cycle_ctr);
		end
      else
        begin
          error_ctr = error_ctr + 1;
          $display("Failed test:");
          $display("block[1023:0768] = 0x%032x", block[1023:0768]);
          $display("block[0767:0512] = 0x%032x", block[0767:0512]);
          $display("block[0511:0256] = 0x%032x", block[0511:0256]);
          $display("block[0255:0000] = 0x%032x", block[0255:0000]);
          $display("tb_digest_88 = 0x%032x", tb_digest_88);
          $display("expected					= 0x%032x", expected);
          $display("");
        end
    end
  endtask // test_88_core

 //----------------------------------------------------------------
  // test_88_core (Muli-block test wrapper)
  //
  // Test the 88-bit hashing core
  //----------------------------------------------------------------
  task test_88_core_multi(
      input [1023 : 0] block,
		input [1023 : 0] next,
      input [63 : 0]  data_length,
      input [87  : 0]  expected
    );
    begin
      tb_block_88 = block;
      tb_length_88 = data_length;
		tb_next_88 = next;
		
		cycle_ctr = 0;

      reset_dut();
		
      tb_init_88 = 1;
      tb_final_88 = 0;
      #(2 * CLK_PERIOD);
		cycle_ctr = cycle_ctr + 2;
      tb_init_88 = 0;

      while (!tb_digest_valid_88) begin
        #(CLK_PERIOD);
		  cycle_ctr = cycle_ctr + 1;
		end
      #(CLK_PERIOD);
		cycle_ctr = cycle_ctr + 1;
		
		tb_init_88 = 1;
      tb_final_88 = 1;
      #(2 * CLK_PERIOD);
		cycle_ctr = cycle_ctr + 2;
      tb_init_88 = 0;
		tb_final_88 = 0;

		while (!tb_digest_valid_88) begin
        #(CLK_PERIOD);
		  cycle_ctr = cycle_ctr + 1;
		end
      #(CLK_PERIOD);
		cycle_ctr = cycle_ctr + 1;
		
		

      if (tb_digest_88 == expected) begin
		  $display("#######################");
		  $display("DATA = %s", block);
        $display("DGST = 0x%011x", tb_digest_88);
		  $display("#######################");
        tc_ctr = tc_ctr + 1;
		  $display("clk count: ", cycle_ctr);
		end
      else
        begin
          error_ctr = error_ctr + 1;
          $display("Failed test:");
          $display("block[1023:0768] = 0x%032x", block[1023:0768]);
          $display("block[0767:0512] = 0x%032x", block[0767:0512]);
          $display("block[0511:0256] = 0x%032x", block[0511:0256]);
          $display("block[0255:0000] = 0x%032x", block[0255:0000]);
          $display("tb_digest_88 = 0x%032x", tb_digest_88);
          $display("expected					= 0x%032x", expected);
          $display("");
        end
    end
  endtask // test_88_core


  //----------------------------------------------------------------
  // blake2_core
  //
  // The main test functionality.
  //----------------------------------------------------------------
  initial
    begin : blake2_core_test
      $display("   -- Testbench for blake2_core started --");
      init();
/*
      test_88_core( // abc
        1024'h6162630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
        3,
        88'hac7b0972cbd915185ac929
      );		
		
      test_88_core( // flamingo
        1024'h666c616d696e676f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
        8,
        88'h8799874c79a16d50742428
      );

      test_88_core( // cranberry
        1024'h6372616e62657272790000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
        9,
        88'h3ca6d159ecf58601c23db7
      );
	
		test_88_core(
			1024'h6f6e65626c6f636b20697320656e6f7567680000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
			18,
			88'h1c59659a7716eb11e698e1
		);
		*/	
		
		test_88_core(
		   1024'h6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
			64,
			88'hf8dbc62fc7a114a81a868a
		);		
				
		test_88_core(
		   1024'h6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161610000,
			126,
			88'h68aa27135b5b179b976803
		);	
		test_88_core(
		   1024'h6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616100,
			127,
			88'heb59aae8be4ddf872f1e14
		);			
		
		/*
		test_88_core_multi(
		  1024'h6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161,
        1024'h6262620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
        128,
        88'hc3278d11dd62c060bea0b9
		);
*/

      display_test_result();
      $display("*** blake2_core simulation done.");
      //$finish_and_return(error_ctr);
    end // blake2_core_test
endmodule // tb_blake2_core

//======================================================================
// EOF tb_blake2_core.v
//======================================================================