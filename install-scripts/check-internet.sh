#!/bin/bash

LOG_FILE="script_output.log"

echo "${INFO} Checking internet connection..." | tee -a "$LOG_FILE"

# Check if there is an active internet connection
if ! ping -c 1 -W 3 archlinux.org &> /dev/null; then
    echo "${ERROR} No internet connection detected. Aborting..." | tee -a "$LOG_FILE"
    exit 1
fi

echo "${OK} Internet connection is active." | tee -a "$LOG_FILE"