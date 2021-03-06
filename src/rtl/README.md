Table of contents
=================

* [Controller](#controller)
  * [Usage](#usage)
    * [Quick start](#quick-start)
* [Hash Simulator](#hash-simulator)
  * [Usage](#usage-of-hash-engine-simulator)
    * [Quick start](#quick-start-of-hash-engine-simulator)
  * [Further reading](#further-reading)




# Controller

This is a Verilog implementation of the Controller for BLAKE2 hash function simulator. Please refer <b>controller.v</b> file
## Usage

### Quick start

```verilog
controller #(

	// defining parameters
	.BUS_WIDTH(BUS_WIDTH),			// Width of the din, Ex: BUS_WIDTH = 32
	.BLOCK_WIDTH(BLOCK_WIDTH),		// Width of the block, if BLOCK_WIDTH = 1024, then 32 sets of BUS_WIDTH can fills the block
	.DATA_LENGTH(DATA_LENGTH)		// Byte length of data which is feeded to hash

) U_controller (
	.clk(clk),				// module clock
	.reset_n(reset_n),			// Reset (active LOW)

	// Processor related ports 
	.din(din),				// Input data to the controller from the processer
	.valid_in(valid_in),			// Validity of the provided data, (valid data need to be hashed, ignore invalid processer data)
	.new_hash_request(new_hash_request),	// Hash start signal to the controller
	.hash_corrupt(hash_corrupt),		// When Hash engine got corrupt this goes to HIGH.
	
	// Hash engine realated ports
	.hash_ready(hash_ready),		// HIGH when hash engine ready for hasing
	.digest_valid(digest_valid),		// HIGH when the digest output is valid
	.init(init),				// Initialize the hash engine (active HIGH)
	.next(next),				// Go to the next block (if data_length > 128 bytes)
	.final(final),				// This is the final block
	.block_out(block),			// The 128-byte block (padded if data_length < 128 bytes)
	.data_length_out(data_length)        	// The byte length of the input data  to the hash engine
);
```

# Hash Simulator

This is the Blake2b hash engine's simulator. please refer the <b>hash_engine_simulator.v </b>

## Usage of hash engine simulator

### Quick start of hash engine simulator

```verilog
hash_engine_simulator #(
	.BLOCK_WIDTH(BLOCK_WIDTH),	// Width of the block, if BLOCK_WIDTH = 1024, then 32 sets of BUS_WIDTH can fills the block
	.DATA_LENGTH(DATA_LENGTH),	// Byte length of data which is feeded to hash
	.DIGEST_LENGTH(DIGEST_LENGTH)	// The length of the digest in bytes
) U_hash_engine_simulator (
	.clk(clk),			// The module clock
	.reset_n(reset_n),		// Reset (active LOW)
	.init(init),			// Initialize the hasher (active HIGH)
	.next(next),			// Go to the next block (if data_length > 128 bytes)
	.final(final),			// This is the final block
	.block_in(block),		// The 128-byte block (padded if data_length < 128 bytes)
	.data_length(data_length),	// The byte length of the input data
	.hash_ready(hash_ready),	// HIGH when the core is ready to hash
	.digest_valid(digest_valid),	// HIGH when the digest output is valid
	.digest(digest)			// The digest output
);
```

### Further reading

- https://blake2.net/
- https://tools.ietf.org/html/draft-saarinen-blake2
- https://en.wikipedia.org/wiki/BLAKE_%28hash_function%29
