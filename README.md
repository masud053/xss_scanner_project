# XSS-Scanner-Project (safe, educational, test-targeted)

**Purpose:**  
A set of Bash scripts to automate safe, non-destructive checks for reflected and stored Cross-Site Scripting (XSS) and basic HTML/JS injection on **authorized/test** targets (default: `http://testphp.vulnweb.com`). This is intended for learning, lab use, and authorized security testing only.

**Legal & safety notice:**  
Only run these scripts against assets you own or where you have explicit written permission. The default target (`testphp.vulnweb.com`) is provided for public testing and learning. The project avoids destructive actions by default and uses simple marker payloads. Do not use against third-party production sites without authorization.


# Included files
- `run_all.sh` — orchestrator: reconnaissance -> parameter discovery -> reflected XSS tests -> dalfox scans -> parsing.
- `recon.sh` — collects URLs, extracts links, crawls endpoints.
- `xss_checks.sh` — performs manual reflected XSS checks with marker payloads and saves evidence.
- `dalfox_scan.sh` — wraps dalfox scans for single and bulk URLs (dalfox must be installed separately).
- `parse_results.sh` — extracts findings using grep/sed/awk into `outputs/parsed/`.
- `requirements.txt` — optional Python packages for helpers (requests, beautifulsoup4).
- `tools.txt` — external tools list (dalfox, hakrawler, gau, curl, gobuster).

# Quick start (Debian/Ubuntu)
 Install required system tools (example):
```bash
sudo apt update
sudo apt install -y curl jq git golang-go
go install github.com/hahwul/dalfox/v2@latest
go install github.com/hakluke/hakrawler@latest
go install github.com/lc/gau/v2/cmd/gau@latest
# ensure $GOPATH/bin or $HOME/go/bin is in your PATH
export PATH=$PATH:$(go env GOPATH)/bin:$HOME/.local/bin
```
 Make scripts executable:
```bash
chmod +x *.sh
mkdir -p outputs
```
 Run the orchestrator (default target is testphp.vulnweb.com):
```bash
./run_all.sh
# or ./run_all.sh http://testphp.vulnweb.com
```

Outputs will be stored in `outputs/` and parsed summaries in `outputs/parsed/`.

# Customization
- Edit `TARGET` variable in `run_all.sh` to change target.
- Edit `xss_checks.sh` to add/remove payloads or change throttling sleep.
- Enable or extend dalfox options in `dalfox_scan.sh` after reviewing.
