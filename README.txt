An implimentation of the Subleq OISC using only linear operations on
half-precision (16 bit) IEEE-754 floats (and a loop).

Also contains a hfluint8 implimentation.

Dependencies:
- zig
 - Built on 0.14.1

Instructions:
$ zig build -Doptimize=ReleaseSafe
$ zig-out/bin/subleq-linear <program> [iterations [output file]]

Based on http://tom7.org/grad/murphy2023grad.pdf
