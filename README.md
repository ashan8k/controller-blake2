# controller-blake2

This is the controlling interface to the blake2b hash engine [Black2](https://github.com/secworks/blake2). However [Black2](https://github.com/secworks/blake2) does not support multiple block serios. Hence we have developed blake2 hash engine simulator which is exactly behaves like original harware implemenntation which is taken 26 clock cycles (not sure 26 or 27) to digest one blocks of data.  
Assumption: we assume hash engine consume same number of clock cycle to digest each and every blocks in multiple block senario.

## Jump Start

[Controller and Hash engine simulator](https://github.com/ashan8k/controller-blake2/tree/master/src/rtl)  
[Test Benches](https://github.com/ashan8k/controller-blake2/tree/master/src/tb)

