#!/usr/bin/env python
# generate Little-Endian 1024-bit blocks
import sys
if len(sys.argv) < 2:
    print "./genblock.py <block>"
    exit(-1)
m = sys.argv[1]
b = ""
for i in m:
    b = b + hex(ord(i))[2:]
while len(b) < 256:
    b = b + "0"
print b
