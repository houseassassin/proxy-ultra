#!/usr/bin/env bash
# File: core/02-logger.sh

C_RESET="\033[0m"
C_RED="\033[1;38;5;196m"
C_GREEN="\033[1;38;5;46m"
C_YELLOW="\033[1;38;5;226m"
C_BLUE="\033[1;38;5;45m"
C_GRAY="\033[38;5;240m"

pxu_logger_log() {
    local icon=$1
    local color=$2
    local message=$3
    local timestamp=$(date +"%H:%M:%S")
    echo -e "${C_GRAY}${timestamp}${C_RESET} ${color}${icon}${C_RESET} ${message}"
}

pxu_logger_info() { pxu_logger_log "ℹ" "$C_BLUE" "$1"; }
pxu_logger_success() { pxu_logger_log "✔" "$C_GREEN" "$1"; }
pxu_logger_warn() { pxu_logger_log "⚠" "$C_YELLOW" "$1"; }
pxu_logger_error() { pxu_logger_log "✖" "$C_RED" "$1"; }
pxu_logger_fatal() { pxu_logger_log "☣" "$C_RED" "$1"; exit 1; }
