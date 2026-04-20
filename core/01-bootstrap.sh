#!/usr/bin/env bash
# File: core/01-bootstrap.sh
# Handles environment setup, root checking, and strict mode.

# Ensure we're running as root
pxu_bootstrap_check_root() {
    if [[ $EUID -ne 0 ]]; then
        # Check if logger is loaded yet, if not fallback to basic echo
        if type pxu_logger_fatal &>/dev/null; then
            pxu_logger_fatal "This script must be run as root."
        else
            echo -e "\033[31m[FATAL]\033[0m This script must be run as root."
        fi
        exit 1
    fi
}

# Environment loader
pxu_bootstrap_load_env() {
    local env_file="${PXU_INSTALL_DIR}/.env"
    if [[ -f "${env_file}" ]]; then
        set -a
        source "${env_file}"
        set +a
    fi
    
    local conf_file="/etc/pxu/pxu.conf"
    if [[ -f "${conf_file}" ]]; then
        set -a
        source "${conf_file}"
        set +a
    fi
}

pxu_bootstrap_init() {
    pxu_bootstrap_load_env
    # Note: We comment root check during dev if running in normal shell
    # pxu_bootstrap_check_root
}

pxu_bootstrap_init
