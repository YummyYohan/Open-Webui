#!/bin/bash

# Script to check for necessary prerequisites

echo "Checking prerequisites..."

missing_prereqs=()

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# List of commands to check
commands=("git" "conda" "node" "npm" "ollama" "ngrok" "jq" "curl")

# Check each command
for cmd in "${commands[@]}"; do
    if ! command_exists "$cmd"; then
        echo "[-] MISSING: $cmd"
        missing_prereqs+=("$cmd")
    else
        echo "[✓] Found: $cmd"
    fi
done

# Print summary and exit if any are missing
if [ ${#missing_prereqs[@]} -ne 0 ]; then
    echo "--------------------------------------------------"
    echo "ERROR: The following prerequisites are missing:"
    for missing in "${missing_prereqs[@]}"; do
        echo "  - $missing"
    done
    echo "Please install the missing prerequisites and try again."
    echo "Refer to INSTRUCTIONS.md for installation links."
    echo "--------------------------------------------------"
    exit 1
else
    echo "--------------------------------------------------"
    echo "All prerequisites found."
    echo "--------------------------------------------------"
fi

exit 0 