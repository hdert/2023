const module = await WebAssembly.compileStreaming(
  fetch("./zig-out/Calculator/Calculator.wasm")
);

const encodeString = (string) => {
  const buffer = new TextEncoder().encode(string);
  const pointer = alloc(buffer.length + 1); // ask Zig to allocate memory
  if (pointer == 0) {
    throw allocationFailed;
  }
  const slice = new Uint8Array(
    memory.buffer, // memory exported from Zig
    pointer,
    buffer.length + 1
  );
  slice.set(buffer);
  slice[buffer.length] = 0; // null byte to null-terminate the string
  return pointer;
};

const decodeString = (pointer, length) => {
  const slice = new Uint8Array(
    memory.buffer, //
    pointer,
    length
  );
  return new TextDecoder().decode(slice);
};

const {
  exports: { memory, evaluate, alloc },
} = await WebAssembly.instantiate(module, {
  env: {
    print: (pointer, length) => {
      const string = decodeString(pointer, length);
      console.log(`${string}`);
    },
  },
});

console.log(evaluate(encodeString("10+10")));

var input = window.document.getElementById("input");
var button = window.document.getElementById("submit");
var form = window.document.getElementById("form");

form.addEventListener("submit", processSubmission);

function processSubmission(e) {
  e.preventDefault();
  input.value = evaluate(encodeString(input.value));
}
