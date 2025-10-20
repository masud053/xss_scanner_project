#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:-http://testphp.vulnweb.com}"
OUTDIR="outputs"
mkdir -p "$OUTDIR"

echo "Target = $TARGET"
echo "Reconnaissance"
./recon.sh "$TARGET" "$OUTDIR"

echo "Parameter discovery and simple reflected checks"
./xss_checks.sh "$OUTDIR/all_urls.txt" "$OUTDIR"

echo "Automated dalfox scans (requires dalfox installed)"
./dalfox_scan.sh "$OUTDIR/urls_with_params.txt" "$OUTDIR"

echo "Parse results"
./parse_results.sh "$OUTDIR"

echo "Done. Check $OUTDIR and $OUTDIR/parsed for findings."
