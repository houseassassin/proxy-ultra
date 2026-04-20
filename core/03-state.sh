#!/usr/bin/env bash
# File: core/03-state.sh

# A simplistic state manager that writes to a local simple KV file
PXU_STATE_FILE="/etc/pxu/.state"

pxu_state_init() {
    if [[ ! -d "/etc/pxu" ]]; then
        mkdir -p "/etc/pxu" 2>/dev/null || sudo mkdir -p "/etc/pxu"
    fi
    if [[ ! -f "$PXU_STATE_FILE" ]]; then
        touch "$PXU_STATE_FILE" 2>/dev/null || sudo touch "$PXU_STATE_FILE"
    fi
}

pxu_state_save() {
    local service=$1
    local key=$2
    local value=$3
    echo "${service}_${key}=\"${value}\"" | sudo tee -a "$PXU_STATE_FILE" >/dev/null
}

pxu_state_get() {
    local service=$1
    local key=$2
    grep -sh "^${service}_${key}=" "$PXU_STATE_FILE" | cut -d'"' -f2 || true
}
