// JARVIS App — service worker con sistema de actualización.
// Subir APP_VERSION en cada release hace que la app detecte la nueva versión.
const APP_VERSION = "1.1.0";
const CACHE = "jarvis-app-" + APP_VERSION;
const SHELL = ["./", "./index.html", "./manifest.json", "./icon.svg", "./icon-192.png", "./icon-512.png"];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys()
      .then((ks) => Promise.all(ks.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("message", (e) => {
  if (e.data === "SKIP_WAITING") self.skipWaiting();
  if (e.data === "GET_VERSION") e.source.postMessage({ type: "VERSION", version: APP_VERSION });
});

self.addEventListener("fetch", (e) => {
  const url = new URL(e.request.url);
  // Las llamadas a Google van siempre a la red
  if (url.hostname.includes("googleapis.com")) return;
  // Network-first para el HTML: así las actualizaciones llegan solas
  if (e.request.mode === "navigate" || url.pathname.endsWith(".html")) {
    e.respondWith(fetch(e.request).then((res) => {
      const copy = res.clone();
      caches.open(CACHE).then((c) => c.put(e.request, copy));
      return res;
    }).catch(() => caches.match(e.request)));
    return;
  }
  e.respondWith(caches.match(e.request).then((res) => res || fetch(e.request)));
});
