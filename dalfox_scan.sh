#!/usr/bin/env bash
set -euo pipefail
URL_FILE="${1:?file of urls with params required}"
OUTDIR="${2:-outputs}"
mkdir -p "$OUTDIR/dalfox"

if ! command -v dalfox >/dev/null 2>&1; then
  echo "dalfox not installed. Install via 'go install github.com/hahwul/dalfox/v2@latest' or use the binary."
  exit 1
fi

echo "Running dalfox on each URL (parallel=3, adjust as needed)"
cat "$URL_FILE" | grep -E "\?.+=" | while IFS= read -r url; do
  safe=$(echo "$url" | sed 's/[^a-zA-Z0-9]/_/g')
  echo "[*] dalfox -> $url"
  dalfox url "$url" --skip-bav --output "$OUTDIR/dalfox/${safe}.txt" || true
  sleep 0.2
done

echo "Dalfox scans complete. Grep for 'XSS' flags:"
grep -RIn "XSS" "$OUTDIR/dalfox" || true
