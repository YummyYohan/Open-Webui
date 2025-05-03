#!/bin/bash

# Script to expose the local dev server using ngrok and update vite.config.ts

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$( dirname "$SCRIPT_DIR" )

FRONTEND_PORT=${1:-5173} # Default to 5173, allow overriding with first argument
BACKEND_PORT=8080
NGROK_LOG_FILE="${PROJECT_ROOT}/ngrok.log"
NGROK_PID_FILE="${PROJECT_ROOT}/.ngrok_pid"
VITE_CONFIG_FILE="${PROJECT_ROOT}/vite.config.ts"

echo "Starting ngrok exposure script..."

# --- Cleanup previous ngrok --- 
if [ -f "$NGROK_PID_FILE" ]; then
    echo "Found previous ngrok PID file. Attempting to stop existing ngrok process..."
    sh "${SCRIPT_DIR}/stop_ngrok.sh"
    sleep 1
fi
rm -f "$NGROK_LOG_FILE"

# --- Check prerequisites ---
sh "${SCRIPT_DIR}/check_prereqs.sh"
if [ $? -ne 0 ]; then
    echo "Prerequisite check failed. Cannot continue."
    exit 1
fi

# --- Check if dev servers might be running (basic check) ---
echo "Checking if frontend/backend ports might be in use (basic check)..."
if ! lsof -i :"$FRONTEND_PORT" -sTCP:LISTEN > /dev/null; then
    echo "WARNING: Port $FRONTEND_PORT does not seem to be listening. Is the frontend (npm run dev) running?"
    # Optionally exit here: exit 1
fi
if ! lsof -i :"$BACKEND_PORT" -sTCP:LISTEN > /dev/null; then
    echo "WARNING: Port $BACKEND_PORT does not seem to be listening. Is the backend (sh backend/dev.sh) running?"
    # Optionally exit here: exit 1
fi

# --- Start ngrok ---
echo "Starting ngrok to forward port $FRONTEND_PORT..."
ngrok http "$FRONTEND_PORT" --log "$NGROK_LOG_FILE" > /dev/null &
NGROK_PID=$!
echo $NGROK_PID > "$NGROK_PID_FILE"
echo "ngrok process started with PID $NGROK_PID. Waiting for tunnel..."

sleep 5 # Give ngrok time to establish the tunnel

# --- Get ngrok URL ---
NGROK_API_URL="http://127.0.0.1:4040/api/tunnels"
NGROK_URL=""

for i in {1..5}; do # Retry fetching URL
    NGROK_URL=$(curl -s "$NGROK_API_URL" | jq -r '.tunnels[] | select(.proto=="https") | .public_url' 2>/dev/null)
    if [ -n "$NGROK_URL" ] && [[ "$NGROK_URL" == https://* ]]; then
        break
    fi
    echo "Failed to get ngrok URL (attempt $i/5). Retrying in 2 seconds..."
    sleep 2
done

if [ -z "$NGROK_URL" ] || [[ "$NGROK_URL" != https://* ]]; then
    echo "ERROR: Could not retrieve ngrok HTTPS URL after multiple attempts."
    echo "Check ngrok status: http://127.0.0.1:4040"
    echo "Check ngrok logs: ${NGROK_LOG_FILE}"
    sh "${SCRIPT_DIR}/stop_ngrok.sh"
    exit 1
fi

NGROK_HOSTNAME=$(echo $NGROK_URL | sed -e 's|^https://||')

echo "ngrok URL: $NGROK_URL"
echo "ngrok Hostname: $NGROK_HOSTNAME"

# --- Update vite.config.ts ---
echo "Checking vite.config.ts for allowed host..."
if ! grep -q "allowedHosts: \[" "$VITE_CONFIG_FILE"; then
    echo "ERROR: Could not find 'allowedHosts: [' array in ${VITE_CONFIG_FILE}. Cannot automatically add host."
    echo "Please add '${NGROK_HOSTNAME}' manually and restart the frontend (npm run dev)."
    # Optionally exit: exit 1
elif grep -q "'${NGROK_HOSTNAME}'" "$VITE_CONFIG_FILE"; then
    echo "Host '${NGROK_HOSTNAME}' already exists in allowedHosts."
else
    echo "Adding host '${NGROK_HOSTNAME}' to allowedHosts in ${VITE_CONFIG_FILE}..."
    # Use sed to add the host on a new line after 'allowedHosts: ['
    # Create a backup with .bak extension
    sed -i.bak "/allowedHosts: \[/a\\n\t\t\t'${NGROK_HOSTNAME}'," "$VITE_CONFIG_FILE"

    # Verify if sed worked
    if ! grep -q "'${NGROK_HOSTNAME}'" "$VITE_CONFIG_FILE"; then
        echo "ERROR: Failed to automatically add host to ${VITE_CONFIG_FILE}. sed command might have failed."
        echo "Please manually add '${NGROK_HOSTNAME}' to the allowedHosts array and restart the frontend (npm run dev)."
        # Restore from backup
        mv "${VITE_CONFIG_FILE}.bak" "$VITE_CONFIG_FILE"
    else
        echo "Host added successfully."
        echo "IMPORTANT: You MUST restart the frontend development server (npm run dev) for the changes to take effect!"
        rm "${VITE_CONFIG_FILE}.bak" # Remove backup on success
    fi
fi

# --- Remind about Proxy --- 
echo "\nVerifying Vite proxy configuration for backend..."
if ! grep -q "proxy: {" "$VITE_CONFIG_FILE"; then
    echo "WARNING: Could not find proxy configuration in ${VITE_CONFIG_FILE}. Backend requests might fail."
    echo "Ensure you have a proxy setting like: proxy: { '/api': { target: 'http://localhost:${BACKEND_PORT}', changeOrigin: true, secure: false } }"
elif ! grep -q "target: 'http://localhost:${BACKEND_PORT}'" "$VITE_CONFIG_FILE"; then
    echo "WARNING: Proxy target in ${VITE_CONFIG_FILE} might not point to the correct backend port (expected ${BACKEND_PORT})."
else
    echo "Proxy configuration looks okay (basic check)."
fi

echo "\nngrok is running in the background (PID: $(cat $NGROK_PID_FILE))."
echo "Public URL: $NGROK_URL"
echo "Press Ctrl+C to stop this script (ngrok will keep running)."
echo "Run 'sh scripts/stop_ngrok.sh' to stop the ngrok process later."

# Keep script alive to show messages, user can Ctrl+C
wait 