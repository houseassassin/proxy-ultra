#!/usr/bin/env bash
# File: core/02-logger.sh

C_RESET="\033[0m"
C_RED="\033[31m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_BLUE="\033[36m"

pxu_logger_log() {
    local level=$1
    local color=$2
    local message=$3
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${color}[${level}]${C_RESET} [${timestamp}] ${message}"
}

pxu_logger_info() { pxu_logger_log "INFO" "$C_BLUE" "$1"; }
pxu_logger_success() { pxu_logger_log "SUCCESS" "$C_GREEN" "$1"; }
pxu_logger_warn() { pxu_logger_log "WARN" "$C_YELLOW" "$1"; }
pxu_logger_error() { pxu_logger_log "ERROR" "$C_RED" "$1"; }
pxu_logger_fatal() { pxu_logger_log "FATAL" "$C_RED" "$1"; exit 1; }
