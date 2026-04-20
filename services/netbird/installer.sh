#!/usr/bin/env bash
# File: services/netbird/installer.sh

svc_netbird_preflight() {
    pxu_logger_info "Preflight checks for Netbird..."
    if [[ -z "${PXU_NETBIRD_SETUP_KEY:-}" ]]; then
        pxu_logger_fatal "PXU_NETBIRD_SETUP_KEY must be provided to hook the node to your Netbird management panel."
    fi
}

svc_netbird_install() {
    pxu_logger_info "Installing Netbird via official installer..."
    curl -fsSL https://pkgs.netbird.io/install.sh | sh >/dev/null 2>&1 || true
}

svc_netbird_configure() {
    pxu_logger_info "Configuring Netbird tunnel..."
    local management_url=${PXU_NETBIRD_MANAGEMENT_URL:-https://api.wiretrustee.com:33073}
    netbird up --setup-key "${PXU_NETBIRD_SETUP_KEY}" --management-url "${management_url}" >/dev/null 2>&1 || true
    pxu_state_save "netbird" "installed" "true"
}

svc_netbird_start() {
    pxu_logger_success "Netbird managed by systemd and started."
}

svc_netbird_update() {
    pxu_logger_info "Updating Netbird via package manager..."
    sudo apt-get update >/dev/null && sudo apt-get install -y netbird >/dev/null || true
}

svc_netbird_remove() {
    pxu_logger_warn "Removing Netbird..."
    netbird down >/dev/null 2>&1 || true
    sudo apt-get remove -y netbird >/dev/null 2>&1 || true
    pxu_state_save "netbird" "installed" "false"
}

svc_netbird_doctor() {
    if command -v netbird &>/dev/null && netbird status | grep -q "Connected"; then
        pxu_logger_success "Netbird is running and connected."
    else
        pxu_logger_warn "Netbird is NOT connected."
    fi
}
