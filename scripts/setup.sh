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
echo "\n--- Backend Python Environment Setup (Manual Steps) ---"
echo "The frontend dependencies are installed. For the backend:"
echo "1. Create a Conda environment: conda create -n open-webui python=3.11"
echo "2. Activate the environment: conda activate open-webui"
echo "3. Install dependencies: pip install -r backend/requirements.txt"
echo "(These steps are usually performed before running 'sh backend/dev.sh' for the first time)"

# The backend environment setup (e.g., Python virtual environment, dependencies)
# is assumed to be handled by the backend development script (e.g., backend/dev.sh)
# when it is run.

echo "\nFrontend setup complete!"
echo "Remember to set up the backend environment separately."
echo "See setup.md for full details."

exit 0 