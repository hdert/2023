// Currently doesn't work because wasi code doesn't work on the browser
// and the freestanding target doesn't work, and we aren't passing the export
// memory flag to the wasm-linker when building with zig.



request = new XMLHttpRequest();
request.open('GET', 'zig-out/Calculator/Calculator.wasm');
request.responseType = 'arraybuffer';
request.send();

request.onload = function() {
    var bytes = request.response;
    WebAssembly.instantiate(bytes, {
        env: {
            print: (result) => {console.log('${result}');},
            // memory: new WebAssembly.Memory({initial: 16}),
        },
    }).then(result => {
        const evaluate = result.instance.exports.evaluate_quick;
        const allocateUint8 = result.instance.exports.allocateUint8;
        const memory = result.instance.exports.memory;

        const encodeString = (string) => {
            const buffer = new TextEncoder().encode(string);
            const pointer = allocateUint8(buffer.length + 1); // ask Zig to allocate memory
            const slice = new Uint8Array(
              memory.buffer, // memory exported from Zig
              pointer,
              buffer.length + 1
            );
            slice.set(buffer);
            slice[buffer.length] = 0; // null byte to null-terminate the string
            return pointer;
          };
        // console.log(result.instance.exports);

        console.log(evaluate(encodeString("10+10"), 0));
    });
};