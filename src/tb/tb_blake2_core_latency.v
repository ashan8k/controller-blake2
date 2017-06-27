//======================================================================
//
// tb_blake2_core.v
// ----------------
// Testbench for the Blake2 core.
//


//------------------------------------------------------------------
// Simulator directives.
//------------------------------------------------------------------
`timescale 1ns/100ps

module tb_blake2_core_latency();

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

  reg            tb_init;
  reg            tb_next;
  reg            tb_final;
  reg [1023 : 0] tb_block;
  reg [127 : 0]  tb_length;
  wire           tb_ready;
  wire [511 : 0] tb_digest;
  wire           tb_digest_valid;

  reg            error_found;
  reg [31 : 0]   read_data;

  reg [511 : 0]  extracted_data;

  reg            display_cycle_ctr;


  //----------------------------------------------------------------
  // blake2_core devices under test.
  //----------------------------------------------------------------
  // The BLAKE2b-512 core
  blake2_core #(
    .DIGEST_LENGTH(64)
  )
  dut (
    .clk(tb_clk),
    .reset_n(tb_reset_n),
    .init(tb_init),
    .next(tb_next),
    .final_block(tb_final),
    .block(tb_block),
    .data_length(tb_length),
    .ready(tb_ready),
    .digest(tb_digest),
    .digest_valid(tb_digest_valid)
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
    end
  endtask // init 
                  
                  

  // Test the 1 hashing core
  //----------------------------------------------------------------
  integer i; 
  task test_1_blocks(
      input [1023 : 0] block,
      input [127 : 0]  data_length
    );
    begin
      tb_block = block;
      tb_length = data_length;

      reset_dut();

      tb_init = 1;
      tb_final = 1;
      #(2 * CLK_PERIOD);
      tb_final = 0;
      tb_init = 0;
      i = 1;// since 2 clock periods has used above
      while (!tb_digest_valid) begin
        #(CLK_PERIOD);
	i = i+1;
      end
      $display("clock cycle to digest = ",i);
      #(CLK_PERIOD);

      
    end
  endtask 
  task test_2_blocks(
      input [1023 : 0] block1,[1023 : 0] block2,
      input [127 : 0]  data_length
    );
    begin
      tb_block = block1;
      tb_length = data_length;

      reset_dut();

      tb_init = 1;
      tb_next =1;
      #(2 * CLK_PERIOD);
      tb_init = 0;
      tb_next = 0;
      i = 1;// since 2 clock periods has used above
      while (!tb_digest_valid) begin
        #(CLK_PERIOD);
	i = i+1;
      end
      $display("clock cycle to digest = ",i);
      // sending last block
      tb_block = block2;
      tb_length = data_length;
      tb_init = 1;
      tb_final = 1;
      #(1 * CLK_PERIOD);
      tb_init = 0;
      tb_final = 0;
      i = 0;// since 1 clock periods has used above
      while (!tb_digest_valid) begin
        #(CLK_PERIOD);
	i = i+1;
      end
      $display("clock cycle to digest = ",i);
      #(CLK_PERIOD);


      
    end
  endtask 

  task test_3_blocks(
      input [1023 : 0] block1,[1023 : 0] block2,[1023 : 0] block3,
      input [127 : 0]  data_length
    );
    begin
      tb_block = block1;
      tb_length = data_length;

      reset_dut();

      tb_init = 1;
      tb_next =1;
      #(2 * CLK_PERIOD);
      tb_init = 0;
      tb_next = 0;
      i = 1;// since 2 clock periods has used above
      while (!tb_digest_valid) begin
        #(CLK_PERIOD);
	i = i+1;
      end
      $display("clock cycle to digest = ",i);
      // second block
      tb_block = block2;
      tb_length = data_length;
      tb_init = 1;
      tb_next = 1;
      #(1 * CLK_PERIOD);
      tb_init = 0;
      tb_next = 0;
      i = 0;// since 2 clock periods has used above
      while (!tb_digest_valid) begin
        #(CLK_PERIOD);
	i = i+1;
      end
      $display("clock cycle to digest = ",i);
      #(CLK_PERIOD);      
	// sending last block
      tb_block = block3;
      tb_length = data_length;
      tb_init = 1;
      tb_final = 1;
      #(1 * CLK_PERIOD);
      tb_init = 0;
      tb_final = 0;
      i =0;// since 2 clock periods has used above
      while (!tb_digest_valid) begin
        #(CLK_PERIOD);
	i = i+1;
      end
      $display("clock cycle to digest = ",i);
      #(CLK_PERIOD);



      
    end
  endtask 
  //----------------------------------------------------------------
  // blake2_core
  //
  // The main test functionality.
  //----------------------------------------------------------------
  initial
    begin : blake2_core_test
      $display("   -- Testbench for blake2_core started --");
      init();
 	
	test_1_blocks(
        {16{64'h0000000000000000}},
        128
	);
     	test_2_blocks(
        {16{64'h0000000000000000}},{16{64'h0000000000000000}},
        128
	);
      	test_3_blocks(
        {16{64'h0000000000000000}},{16{64'h0000000000000000}},{16{64'h0000000000000000}},
        128
	);


      display_test_result();
      $display("*** blake2_core simulation done.");
    end // blake2_core_test
endmodule // tb_blake2_core

//======================================================================
// EOF tb_blake2_core.v
//======================================================================
