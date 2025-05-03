#!/bin/bash

# Script to stop the background ngrok process started by expose_with_ngrok.sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$( dirname "$SCRIPT_DIR" )
NGROK_PID_FILE="${PROJECT_ROOT}/.ngrok_pid"

if [ -f "$NGROK_PID_FILE" ]; then
    NGROK_PID=$(cat "$NGROK_PID_FILE")
    echo "Stopping ngrok process with PID: $NGROK_PID..."
    if ps -p $NGROK_PID > /dev/null; then
        kill $NGROK_PID
        if [ $? -eq 0 ]; then
            echo "ngrok process stopped."
        else
            echo "Failed to stop ngrok process. It might have already exited."
        fi
    else
        echo "ngrok process with PID $NGROK_PID not found."
    fi
    rm -f "$NGROK_PID_FILE"
else
    echo "ngrok PID file (${NGROK_PID_FILE}) not found. No process to stop."
fi

exit 0 