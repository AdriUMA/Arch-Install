#!/bin/bash
# Global Functions for Scripts #

set -e

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

# Log file variable
LOG_FILE="log"

# Define the directory where your scripts are located
script_directory=install-scripts

# If $use_preset is provided and if exists, then use it
if [[ ! -z "$use_preset" ]]; then
  if [ -f "$use_preset" ]; then
    source "$use_preset"
  else
    echo "${WARNING} Preset $use_preset not found. The script will continue in ask mode."
  fi
fi

custom_read(){
  if [[ ! -z "${!2}" ]]; then
    echo "$(colorize_prompt "$CAT"  "$1 (Preset): ${!2}")" 
  else 
    read -p "$(colorize_prompt "$CAT"  "$1: ")" $2
  fi
}

# Function to colorize prompts
colorize_prompt() {
    local color="$1"
    local message="$2"
    echo -n "${color}${message}$(tput sgr0)"
}

# Function to ask a yes/no question and set the response in a variable
ask_yes_no() {
  if [[ ! -z "${!2}" ]]; then
    echo "$(colorize_prompt "$CAT"  "$1 (Preset): ${!2}")" 
    return;
  else
    eval "$2=''" 
  fi

  while true; do
    read -p "$(colorize_prompt "$CAT"  "$1 (y/n): ")" choice
    case "$choice" in
      [Yy]* ) eval "$2='Y'"; return 0;;
      [Nn]* ) eval "$2='N'"; return 0;;
      * ) echo "Please answer with y or n.";;
    esac
  done
}

# Function to ask a custom question with specific options and set the response in a variable
ask_custom_option() {
    local prompt="$1"
    local valid_options="$2"
    local response_var="$3"

    if [[ ! -z "${!3}" ]]; then
      return 0
    else
     eval "$3=''" 
    fi

    while true; do
        read -p "$(colorize_prompt "$CAT"  "$prompt ($valid_options): ")" choice
        if [[ " $valid_options " == *" $choice "* ]]; then
            eval "$response_var='$choice'"
            return 0
        else
            echo "Please choose one of the provided options: $valid_options"
        fi
    done
}

# Function to execute a script if it exists and make it executable
execute_script() {
    local script="$1"
    local script_path="$script_directory/$script"
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        if [ -x "$script_path" ]; then
            echo "${INFO} Running script '$script'..."
            if ! source "$script_path"; then
                echo "${ERROR} Failed to execute script '$script'. Aborting..."
                return 1
            fi
            echo "${OK} Script '$script' executed successfully."
        else
            echo "Failed to make script '$script' executable."
        fi
    else
        echo "Script '$script' not found in '$script_directory'."
    fi
}


# Function to execute a command and handle logging
command() {
    local cmd="$1"

    echo "${INFO} Running: $cmd" | tee -a "$LOG_FILE"
    
    if eval "$cmd" > "$LOG_FILE" 2>&1; then
        echo "${OK} Success." | tee -a "$LOG_FILE"
    else
        echo "${ERROR} Error. Aborting..." | tee -a "$LOG_FILE"
        cat "$LOG_FILE"
        return 1
    fi
}

command_verbose(){
  local cmd="$1"

  echo "${INFO} Running verbose: $cmd" | tee -a "$LOG_FILE"

  if [ ! -z "$2" ]; then
    sleep "$2"
  fi

  if eval "$cmd"; then 
      echo "${OK} Success." | tee -a "$LOG_FILE"
  else
      echo "${ERROR} Error. Aborting..." | tee -a "$LOG_FILE"
      return 1
  fi
}
