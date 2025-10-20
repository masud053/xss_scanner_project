#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:?target required}"
OUTDIR="${2:-outputs}"
mkdir -p "$OUTDIR"

echo "Fetching homepage"
curl -s "$TARGET" -o "$OUTDIR/home.html"

echo "Extracting href links"
grep -Eo 'href=["\']?[^"\'\ >]+' "$OUTDIR/home.html" | sed -E 's/^href=//;s/^"|^\'//;s/"$|\'$//' | sort -u > "$OUTDIR/links_raw.txt" || true

echo "Normalizing relative URLs"
cat "$OUTDIR/links_raw.txt" | sed -E "s@^/@$TARGET/@g" | sort -u > "$OUTDIR/links.txt" || true

echo "Running hakrawler for deeper discovery (if installed)"
command -v hakrawler >/dev/null 2>&1 && hakrawler -url "$TARGET" -plain > "$OUTDIR/hakrawler_urls.txt" || echo "[!] hakrawler not found, skipping"

echo "Aggregating URLs"
cat "$OUTDIR/links.txt" "$OUTDIR/hakrawler_urls.txt" 2>/dev/null | sort -u > "$OUTDIR/all_urls.txt"

echo "Extracting URLs with params"
grep -E '\?.+=' "$OUTDIR/all_urls.txt" | sort -u > "$OUTDIR/urls_with_params.txt" || true

echo "Recon complete. totals:"
wc -l "$OUTDIR/all_urls.txt" || true
wc -l "$OUTDIR/urls_with_params.txt" || true
