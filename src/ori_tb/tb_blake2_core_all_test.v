//======================================================================
//
// tb_blake2_core.v
// ----------------
// Testbench for the Blake2 core.
//
//
// Author: Joachim Strömbergson
// Copyright (c) 2014, Secworks Sweden AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

//------------------------------------------------------------------
// Simulator directives.
//------------------------------------------------------------------
`timescale 1ns/100ps

module tb_blake2_core_all_test();

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

  reg            tb_init_512, tb_init_256;
  reg            tb_next_512, tb_next_256;
  reg            tb_final_512, tb_final_256;
  reg [1023 : 0] tb_block_512, tb_block_256;
  reg [127 : 0]  tb_length_512, tb_length_256;
  wire           tb_ready_512, tb_ready_256;
  wire [511 : 0] tb_digest_512, tb_digest_256;
  wire           tb_digest_valid_512, tb_digest_valid_256;

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
  dut_512 (
    .clk(tb_clk),
    .reset_n(tb_reset_n),
    .init(tb_init_512),
    .next(tb_next_512),
    .final_block(tb_final_512),
    .block(tb_block_512),
    .data_length(tb_length_512),
    .ready(tb_ready_512),
    .digest(tb_digest_512),
    .digest_valid(tb_digest_valid_512)
  );

  // The BLAKE2b-256 core
  blake2_core #(
    .DIGEST_LENGTH(32)
  )
  dut_256 (
    .clk(tb_clk),
    .reset_n(tb_reset_n),
    .init(tb_init_256),
    .next(tb_next_256),
    .final_block(tb_final_256),
    .block(tb_block_256),
    .data_length(tb_length_256),
    .ready(tb_ready_256),
    .digest(tb_digest_256),
    .digest_valid(tb_digest_valid_256)
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


  //----------------------------------------------------------------
  // test_512_core
  //
  // Test the 512-bit hashing core
  //----------------------------------------------------------------
  task test_512_core(
      input [1023 : 0] block,
      input [127 : 0]  data_length,
      input [511 : 0]  expected
    );
    begin
      tb_block_512 = block;
      tb_length_512 = data_length;

      reset_dut();

      tb_init_512 = 1;
      tb_final_512 = 1;
      #(2 * CLK_PERIOD);
      tb_final_512 = 0;
      tb_init_512 = 0;

      while (!tb_digest_valid_512)
        #(CLK_PERIOD);
      #(CLK_PERIOD);

      if (tb_digest_512 == expected)
        tc_ctr = tc_ctr + 1;
      else
        begin
          error_ctr = error_ctr + 1;
          $display("Failed test:");
          $display("block[1023:0768] = 0x%032x", block[1023:0768]);
          $display("block[0767:0512] = 0x%032x", block[0767:0512]);
          $display("block[0511:0256] = 0x%032x", block[0511:0256]);
          $display("block[0255:0000] = 0x%032x", block[0255:0000]);
          $display("tb_digest_512 = 0x%064x", tb_digest_512);
          $display("expected      = 0x%064x", expected);
          $display("");
        end
    end
  endtask // test_512_core


//
  //----------------------------------------------------------------
  // test_512_core - 2 blocks
  //
  // Test the 512-bit hashing core
  //----------------------------------------------------------------
  task test_512_core_2blocks(
      input [1023 : 0] block1,
      input [1023 : 0] block2,
      input [127 : 0]  data_length,
      input [511 : 0]  expected
    );
    begin
      tb_block_512 = block1;
      tb_length_512 = data_length;

      reset_dut();

      tb_init_512 = 1;
      tb_final_512 = 0;
      tb_next_512 = 1;
      #(2 * CLK_PERIOD);
      tb_final_512 = 0;
      tb_init_512 = 0;
      tb_next_512 = 0;

      while (!tb_digest_valid_512)
        #(CLK_PERIOD);
      #(CLK_PERIOD);

      tb_block_512 = block2;

      tb_init_512 = 0;
      tb_final_512 = 1;
      tb_next_512 = 1;
      #(2 * CLK_PERIOD);
      tb_final_512 = 0;
      tb_init_512 = 0;
      tb_next_512 = 0;

      while (!tb_digest_valid_512)
        #(CLK_PERIOD);
      #(CLK_PERIOD);

      if (tb_digest_512 == expected)
        tc_ctr = tc_ctr + 1;
      else
        begin
          error_ctr = error_ctr + 1;
          $display("Failed test:");
    //      $display("block[1023:0768] = 0x%032x", block[1023:0768]);
    //      $display("block[0767:0512] = 0x%032x", block[0767:0512]);
    //      $display("block[0511:0256] = 0x%032x", block[0511:0256]);
    //      $display("block[0255:0000] = 0x%032x", block[0255:0000]);
          $display("tb_digest_512 = 0x%064x", tb_digest_512);
          $display("expected      = 0x%064x", expected);
          $display("");
        end
    end
  endtask // test_512_core
//

  //----------------------------------------------------------------
  // test_256_core
  //
  // Test the 256-bit hashing core
  //----------------------------------------------------------------
  task test_256_core(
      input [1023 : 0] block,
      input [127 : 0]  data_length,
      input [255 : 0]  expected
    );
    begin
      tb_block_256 = block;
      tb_length_256 = data_length;

      reset_dut();

      tb_init_256 = 1;
      tb_final_256 = 1;
      #(2 * CLK_PERIOD);
      tb_final_256 = 0;
      tb_init_256 = 0;

      while (!tb_digest_valid_256)
        #(CLK_PERIOD);
      #(CLK_PERIOD);

      if (tb_digest_256[511:256] == expected)
        tc_ctr = tc_ctr + 1;
      else
        begin
          error_ctr = error_ctr + 1;
          $display("Failed test:");
          $display("block[1023:0768] = 0x%032x", block[1023:0768]);
          $display("block[0767:0512] = 0x%032x", block[0767:0512]);
          $display("block[0511:0256] = 0x%032x", block[0511:0256]);
          $display("block[0255:0000] = 0x%032x", block[0255:0000]);
          $display("tb_digest_256[511:256] = 0x%032x", tb_digest_256[511:256]);
          $display("expected               = 0x%032x", expected);
          $display("");
        end
    end
  endtask // test_256_core


  //----------------------------------------------------------------
  // blake2_core
  //
  // The main test functionality.
  //----------------------------------------------------------------
  initial
    begin : blake2_core_test
      $display("   -- Testbench for blake2_core started --");
      init();

// Please reffer Excel sheet for case senarios
////case1
//      test_512_core(
//        1024'h6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
//        1,
//        512'h333fcb4ee1aa7c115355ec66ceac917c8bfd815bf7587d325aec1864edd24e34d5abe2c6b1b5ee3face62fed78dbef802f2a85cb91d455a8f5249d330853cb3c
//      );
//
////case2
//      test_512_core(
//        1024'h6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616100000000000000000000000000000000000000000000000000000000,
//        100,
//        512'hedd9e36b355fdacc63b23b6b522294f5d3ccd6ed8df37a2ff1c6d074634995c8c9d987365a237550ac2939feb38548f76ba54b5d6b6f80e3840e53fb1a8b67f7
//      );
////case3
//      test_512_core(
//        1024'h6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161,
//        128,
//        512'hfc6c71f688f43ea7d60817478808f3cac753e61571865c95adbc2d9122c943a76b92c2cb1047ef3fe7bf6e436ec1d0a99a9e5b216780bf7fed9d7ca91d3a8f3b 
//      );
////case3.1
//      test_512_core(
//        1024'h6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
//        64,
//        512'h29119322fbf7552c76c608d4d61bd648175dfc856f714992a950da978d5609bac2ce1dea8e12d06b1dba888c897ba37f905386620e08ec992b2ae7ffb68fd7ea
//      );
//
////case3.2
//      test_512_core(
//        1024'h6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616100,
//        127,
//        512'h94596b9d6199c807c40ae1a935f3633ba5a8dd5655f7f1bd44f5285b1ce8dbb0054771eba409539df85a963296d28788807105153c90fa3ec3d761228e90f8b8
//      );
//
////case3.3
//      test_512_core(
//        1024'h6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161610000,
//        126,
//        512'hb0b047fcb9aadd462298167659e0d3d83bef85f33451c5a8ba07ae96bb947a9bf9482bb8fd75a0c349155c27a6f56d22dacfc2a6e6603ca6a993ee39aa765ff3
//      );
//
////case4
// 	test_512_core(
//	1024'h6162630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
//	3,
//	512'hba80a53f981c4d0d6a2797b69f12f6e94c212f14685ac4b74b12bb6fdbffa2d17d87c5392aab792dc252d5de4533cc9518d38aa8dbf1925ab92386edd4009923
//	);
//
//// case5  
//	test_256_core(
//	1024'h6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
//	1,
//	256'h8928aae63c84d87ea098564d1e03ad813f107add474e56aedd286349c0c03ea4
//	);
//// case6  
//	test_256_core(
//	1024'h6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616100000000000000000000000000000000000000000000000000000000,
//	100,
//	256'hf70269abf9b3b4348e2b467d1aa2143543bedb20ca893844c64ec7de24a55389
//	);
//// case7  
//	test_256_core(
//	1024'h6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161,
//	128,
//	256'hae2aa48507885c4c950fb809b2076f959cde9f8ea6da260d9a3587df33dac450
//	);
//
//// case8  
//
	test_512_core_2blocks(
	1024'h6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161,
	1024'h6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161,
	256,
	512'h0eee13d0c73a2710c5015a8b4be0a16120bb88f826b662951ffe4b3b81441cfdce1f712c58e237dba72a0dad7f9c86b9745ea0b4b3b850ff3a260fb7df9d3e81
	);

	// 129 senario 512'h55e6e0eb418149a8af92fd9ddc99254781b2f522a131b4f4d984404b71a00e1167b8124d5dcddd4c6977b299392335d6edd303da6d344d74bbef2d38101b232b




      //test_256_core(
      //  1024'h610a4485ad561f80716d7b0ccb7d876c3eaacdf75e934266d061eb7b9f68d093fc756d945b0bbf822d71f4e5e9b733e7acf870a4b6c0e610145781beca04e63f1b22e0a1b048797e53d94d732567e8fc77cb4f5fe7cce5be3f915d9520879e17e6f4016be0228692da17256a9ea7c12c502954e1fa50d8f32bd30d7abe487872,
      //  128,
      //  256'h9cd77f477b8c2a97860c4b5e64519a1be27dcefbbec5a42b73644895fb22d23d
      //);

      display_test_result();
      $display("*** blake2_core simulation done.");
      $finish_and_return(error_ctr);
    end // blake2_core_test
endmodule // tb_blake2_core

//======================================================================
// EOF tb_blake2_core.v
//======================================================================
