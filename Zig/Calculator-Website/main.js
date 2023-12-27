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
            // print: (result) => {console.log('${result}');},
            // memory: new WebAssembly.Memory({initial: 16}),
        }
    }).then(result => {
        var evaluate = result.instance.exports.evaluate;

        console.log(evaluate("10+10", 0));
    });
};