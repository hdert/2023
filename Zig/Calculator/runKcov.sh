#!/bin/dash

rm -r zig-cache
rm -r kcov-output
zig build test
kcov --exclude-path=/usr/lib/zig/lib/,src/tests.zig,src/Tokenizer.zig,src/Io.zig,src/addons.zig,../Stack/src/ kcov-output zig-cache/o/*/test
xdg-open kcov-output/index.html