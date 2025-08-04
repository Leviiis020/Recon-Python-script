script #!/bin/bash
# ===============================================================
#  Purple Hat Cybersecurity
#  info@purplehat.nl
#
#  🛠 Penetration Testing Utility
#  This script is a multifunctional reconnaissance and testing tool
#  that integrates:
#    • Subdomain enumeration
#    • HTTP probing
#    • Port scanning
#    • TLS analysis
#    • Vulnerability scanning
#    • Optional TOR routing
#
#  Usage:
#    ./purplehat_recon.sh <domain> [--tor]
#
#  Example:
#    ./purplehat_recon.sh example.com
#    ./purplehat_recon.sh example.com --tor
#
#  Why these parameters?
#    <domain>   = Target domain for reconnaissance.
#    --tor      = Routes traffic through TOR for stealth.
#
#  Requirements:
#    sudo apt install subfinder httpx nmap nuclei tor torsocks -y
#
# ===============================================================

# ========== CONFIGURATION AND SETUP ==========
TOR_MODE=false
OUTPUT_DIR="purplehat_output"
mkdir -p "$OUTPUT_DIR"
TOOLS=("subfinder" "httpx" "nmap" "nuclei" "torsocks")

# ========== CHECK FOR REQUIRED TOOLS ==========
echo "[*] Checking for required tools..."
for tool in "${TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "[!] Error: The tool '$tool' is not installed."
        echo "[!] Please install it with 'sudo apt install $tool' or check your PATH."
        exit 1
    fi
done

# ========== PARSE ARGUMENTS ==========
if [[ -z "$1" ]]; then
    echo "[!] Usage: $0 <domain> [--tor]"
    exit 1
fi

DOMAIN=$1
if [[ "$2" == "--tor" ]]; then
    TOR_MODE=true
    echo "[*] TOR mode enabled. All requests will be routed through TOR (127.0.0.1:9050)"
fi

# ========== FUNCTION: TOR WRAPPER ==========
# All tools will now be wrapped with this function for consistency.
run_tool() {
    local cmd=("$@")
    if $TOR_MODE; then
        # Check if the command is compatible with torsocks
        case "${cmd[0]}" in
            "subfinder" | "httpx" | "nuclei")
                torsocks "${cmd[@]}"
                ;;
            "nmap")
                # nmap does not fully support torsocks
                echo "[!] Warning: Nmap does not reliably work with torsocks. Skipping TOR routing for Nmap."
                "${cmd[@]}"
                ;;
            *)
                "${cmd[@]}"
                ;;
        esac
    else
        "${cmd[@]}"
    fi
}

# ========== RECONNAISSANCE STEPS ==========
echo "---"

# STEP 1: SUBDOMAIN ENUMERATION
echo "[*] Enumerating subdomains for $DOMAIN..."
run_tool subfinder -d "$DOMAIN" -all -silent -o "$OUTPUT_DIR/subdomains.txt"

# STEP 2: HTTP PROBING
echo "[*] Probing for live hosts..."
run_tool httpx -l "$OUTPUT_DIR/subdomains.txt" -mc 200,301,302 -o "$OUTPUT_DIR/live.txt"

# STEP 3: PORT SCANNING
echo "[*] Running full port scan on live hosts..."
nmap_target_file="$OUTPUT_DIR/nmap_targets.txt"
grep -oP '(?<=://)[^/]+' "$OUTPUT_DIR/live.txt" > "$nmap_target_file"
nmap -iL "$nmap_target_file" -p- --min-rate 5000 -T4 -oN "$OUTPUT_DIR/nmap_full_scan.txt"
rm "$nmap_target_file"

echo "---"

# STEP 4: TLS ANALYSIS
echo "[*] Performing TLS analysis on port 443..."
live_hosts=$(grep ":443" "$OUTPUT_DIR/live.txt" | sed 's|https://||')
if [ -n "$live_hosts" ]; then
    echo "$live_hosts" | xargs -P 10 -I {} nmap --script ssl-enum-ciphers -p 443 {} >> "$OUTPUT_DIR/tls_report.txt"
else
    echo "[!] No hosts with port 443 found. Skipping TLS analysis."
fi

echo "---"

# STEP 5: VULNERABILITY SCANNING
echo "[*] Running nuclei scans..."
run_tool nuclei -l "$OUTPUT_DIR/live.txt" -t cves/ -t misconfiguration/ -t exposed-panels/ -o "$OUTPUT_DIR/nuclei_report.txt"

echo "---"

# ========== CLEANUP AND COMPLETION ==========
echo "[+] Recon complete! Results stored in the '$OUTPUT_DIR' directory." 
