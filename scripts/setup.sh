#!/bin/bash

# Script to set up the development environment

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$( dirname "$SCRIPT_DIR" )

echo "Running setup script..."

# 1. Check Prerequisites
echo "\n--- Checking Prerequisites ---"
sh "${SCRIPT_DIR}/check_prereqs.sh"
if [ $? -ne 0 ]; then
    echo "Prerequisite check failed. Please install missing dependencies."
    exit 1
fi

# 2. Install Frontend Dependencies
echo "\n--- Installing Frontend Dependencies ---"
cd "$PROJECT_ROOT"
if [ -f package-lock.json ]; then
    npm ci
else
    npm install
fi

if [ $? -ne 0 ]; then
    echo "npm install failed. Please check for errors."
    exit 1
fi

# --- Backend Environment Note ---
# The backend environment setup (e.g., Python virtual environment, dependencies)
# is assumed to be handled by the backend development script (e.g., backend/dev.sh)
# when it is run.

echo "\nSetup complete!"
echo "You can now run the backend and frontend in separate terminals."
echo "See INSTRUCTIONS.md for details."

exit 0 