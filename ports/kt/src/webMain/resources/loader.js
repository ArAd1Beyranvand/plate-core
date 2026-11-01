// Loads exactly one build: Wasm when WasmGC validates, JS IR otherwise (W5).
// The deploy step places the two distributions in ./wasm and ./js.
const gc = new Uint8Array([0,97,115,109,1,0,0,0,1,5,1,95,1,120,0]);
await import(WebAssembly.validate(gc) ? './wasm/plates.js' : './js/plates.js');
