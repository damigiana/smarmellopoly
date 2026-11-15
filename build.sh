#!/bin/bash
# Ricostruisce index.html dal sorgente del gioco aggiungendo anteprima e icone.
set -e
SRC="${1:-gioco.html}"
{
cat <<'HEAD'
<!doctype html><html lang="it"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="description" content="Il gioco da tavolo delle città italiane: tabellone sulla TV, comandi sul telefono.">
<meta property="og:type" content="website">
<meta property="og:title" content="SMARMELLOPOLY 🧃">
<meta property="og:description" content="Il gioco da tavolo delle città italiane: tabellone sulla TV, comandi sul telefono.">
<meta property="og:url" content="https://smarmellopoly.vercel.app/">
<meta property="og:image" content="https://smarmellopoly.vercel.app/anteprima.jpg">
<meta property="og:image:width" content="1200"><meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:image" content="https://smarmellopoly.vercel.app/anteprima.jpg">
<link rel="icon" type="image/png" href="/favicon.png">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">
<link rel="manifest" href="/manifest.webmanifest">
<meta name="theme-color" content="#0b1416">
<meta name="apple-mobile-web-app-title" content="Smarmellopoly">
</head><body>
HEAD
cat "$SRC"
printf '</body></html>'
} > index.html
