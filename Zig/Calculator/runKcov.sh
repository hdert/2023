#!/bin/dash

rm -r zig-cache
rm -r kcov-output
zig build test
kcov --exclude-path=/usr/lib/zig/lib/,src/CalculatorLibTests.zig,../Stack/src/,src/Tokenizer.zig kcov-output zig-cache/o/*/test
xdg-open kcov-output/index.html