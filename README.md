#  Usage:
#    ./recon.sh <domain>
#
#  Example:
#    ./recon.sh example.com
#
#  Why these parameters?
#    <domain>   = Target domain for reconnaissance.
#
#  Requirements:
#    The following tools are required. You must install them using
#    their respective methods.
#
#    Go-based tools (install via `go install` after installing Go):
#    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
#    go install github.com/projectdiscovery/httpx/cmd/httpx@latest
#    go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
#    go install github.com/sensepost/gowitness@latest
#    go install github.com/ffuf/ffuf/v2@latest
#
#    System-based tools (install via `sudo apt install`):
#    sudo apt install nmap tor torsocks -y
#
# ===============================================================
#
# ## How to Run
#
# To use this script, follow these steps:
#
# **1. Install Prerequisites**
#
# Ensure you have Go, Nmap, Tor, and Torsocks installed on your system.
#
# - **Go-based tools:** Run the `go install` commands listed in the "Requirements" section.
# - **System-based tools:** Use `sudo apt install nmap tor torsocks` to install them.
#
# **2. Make the Script Executable**
#
# Give the script execute permissions using the `chmod` command:
#
# ```bash
# chmod +x recon.sh
# ```
#
# **3. Run the Script**
#
# Execute the script with your target domain as the first argument.
#
# ```bash
# ./recon.sh example.com
# ```
#
# **4. Choose Reconnaissance Mode**
#
# The script will then prompt you to choose between "Normal Reconnaissance"
# and "TOR Reconnaissance." Enter `1` for normal or `2` for TOR.
#
# The script will run and save all output files into the `purplehat_output` directory.
#
# ===============================================================

