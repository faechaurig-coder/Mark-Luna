// JARVIS PWA service worker — solo cachea el shell estático.
// Los websockets (/ws, /ws/phone-audio, /ws/assistant-audio) van directo a la red.
const CACHE = "jarvis-pwa-v1";
const SHELL = ["/", "/static/crypto.js", "/manifest.json", "/icon.svg"];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)));
  self.skipWaiting();
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((ks) =>
      Promise.all(ks.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (e) => {
  const url = new URL(e.request.url);
  if (url.pathname.startsWith("/ws") || url.pathname.startsWith("/api/") ||
      url.pathname.startsWith("/login") || url.pathname.startsWith("/uploads/")) {
    return; // sin cache — auth y streaming van directo
  }
  e.respondWith(
    caches.match(e.request).then((res) => res || fetch(e.request))
  );
});
