#!/bin/bash

LOG_FILE="script_output.log"
MAX_ATTEMPTS=15
DELAY=1

echo "${INFO} Checking internet connection..." | tee -a "$LOG_FILE"

attempt=1
while ! ping -c 1 -W 3 archlinux.org &> /dev/null; do
    echo "${WARN} No internet connection detected. Attempt $attempt/$MAX_ATTEMPTS..." | tee -a "$LOG_FILE"

    if [ "$attempt" -ge "$MAX_ATTEMPTS" ]; then
        echo "${ERROR} No internet after $MAX_ATTEMPTS attempts. Aborting..." | tee -a "$LOG_FILE"
        exit 1
    fi

    attempt=$((attempt + 1))
    sleep "$DELAY"
done

echo "${OK} Internet connection is active." | tee -a "$LOG_FILE"
