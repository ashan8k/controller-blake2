//======================================================================
//
// blake2_G.v
// -----------
// Verilog 2001 implementation of the G function in the
// blake2 hash function core. This is pure combinational logic in a
// separade module to allow us to build versions  with 1, 2, 4
// and even 8 parallel compression functions.
//
//
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

module blake2_G(
                input wire [63 : 0]  a,
                input wire [63 : 0]  b,
                input wire [63 : 0]  c,
                input wire [63 : 0]  d,
                input wire [63 : 0]  m0,
                input wire [63 : 0]  m1,

                output wire [63 : 0] a_prim,
                output wire [63 : 0] b_prim,
                output wire [63 : 0] c_prim,
                output wire [63 : 0] d_prim
               );


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [63 : 0] internal_a_prim;
  reg [63 : 0] internal_b_prim;
  reg [63 : 0] internal_c_prim;
  reg [63 : 0] internal_d_prim;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports.
  //----------------------------------------------------------------
  assign a_prim = internal_a_prim;
  assign b_prim = internal_b_prim;
  assign c_prim = internal_c_prim;
  assign d_prim = internal_d_prim;


  //----------------------------------------------------------------
  // G
  //
  // The actual G function.
  //----------------------------------------------------------------
  always @*
    begin : G

      internal_a_prim = a + b + m0;

      internal_d_prim = d ^ internal_a_prim;
      internal_d_prim = {internal_d_prim[31 : 0], internal_d_prim[63 : 32]};

      internal_c_prim = c + internal_d_prim;

      internal_b_prim = {b ^ internal_c_prim};
      internal_b_prim = {internal_b_prim[23 : 0], internal_b_prim[63 : 24]};

      internal_a_prim = internal_a_prim + internal_b_prim + m1;

      internal_d_prim = internal_d_prim ^ internal_a_prim;
      internal_d_prim = {internal_d_prim[15 : 0], internal_d_prim[63 : 16]};

      internal_c_prim = internal_c_prim + internal_d_prim;

      internal_b_prim = internal_b_prim ^ internal_c_prim;
      internal_b_prim = {internal_b_prim[62 : 0], internal_b_prim[63]};

    end // G
endmodule // blake2_G

//======================================================================
// EOF blake2_G.v
//======================================================================
