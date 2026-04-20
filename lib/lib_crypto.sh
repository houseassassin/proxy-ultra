#!/usr/bin/env bash
# File: lib/lib_crypto.sh

lib_crypto_generate_string() {
    local length=${1:-16}
    # Securely generate a random alphanumeric string
    if [ -c /dev/urandom ]; then
        # Extract alphanumeric characters and truncate to length
        LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$length"
    else
        # Fallback
        openssl rand -base64 48 | tr -dc 'A-Za-z0-9' | head -c "$length"
    fi
}
