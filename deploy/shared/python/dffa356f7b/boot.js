// Shared by every country page (W6): the host bridge, then Pyodide (self-hosted by build.py), the shared core zip and the country's own zip.
// The bridge speaks first (hello, progress) and queues the host's messages until the Python shell listens.
const PYODIDE = new URL('../../pyodide/0.28.3/', import.meta.url).href;

export async function boot({ country, version, archive, galleryOrigin = location.origin, pyodideURL = PYODIDE }) {
  const queue = [];
  let handler = null;
  const send = (type, payload, origin = galleryOrigin) =>
    parent.postMessage({ ns: 'plate-embed', v: 1, type, payload }, origin);
  addEventListener('message', (e) => {
    const args = [e.source === parent, e.origin, JSON.stringify(e.data)];
    handler ? handler(...args) : queue.push(args);
  });
  globalThis.plateBridge = {
    greeted: true,
    galleryOrigin,
    post: (text, origin) => parent.postMessage(JSON.parse(text), origin),
    listen: (fn) => { handler = fn; queue.splice(0).forEach((a) => fn(...a)); },
  };
  const stage = (text, fraction) => {
    const p = document.querySelector('#splash p:last-child');
    if (p) p.textContent = text;
    send('progress', { stage: text, fraction });
  };
  const fetchBytes = async (url) => {
    const r = await fetch(url);
    if (!r.ok) throw new Error(`${url}: ${r.status}`);
    return r.arrayBuffer();
  };
  send('hello', { lang: 'python', country, version });
  // The runtime's own files are fetched inside loadPyodide, after pyodide.mjs has loaded; asking now overlaps them.
  for (const f of ['pyodide.asm.wasm', 'python_stdlib.zip']) fetch(pyodideURL + f).catch(() => {});
  try {
    stage('Starting Python…', 0);
    const [{ loadPyodide }, core, own] = await Promise.all([
      import(pyodideURL + 'pyodide.mjs'),
      fetchBytes(new URL('./plates.zip', import.meta.url)),
      fetchBytes(archive),
    ]);
    const py = await loadPyodide({ indexURL: pyodideURL });
    stage('Loading plates…', 0.6);
    py.unpackArchive(core, 'zip');
    py.unpackArchive(own, 'zip');
    await py.runPythonAsync(
      `from plates.embed.shell import start\nfrom plates.embed.browser import BrowserEnv\nstart(${JSON.stringify(country)}, BrowserEnv())`);
  } catch (e) {
    send('error', { code: 'load_failed', message: String(e), fatal: true });
    throw e;
  }
}
