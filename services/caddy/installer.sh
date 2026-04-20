#!/usr/bin/env bash

svc_caddy_preflight() {
    pxu_logger_info "Running preflight checks for Caddy..."
    lib_network_check_port 80 || pxu_logger_fatal "Port 80 must be free for Caddy."
    lib_network_check_port 443 || pxu_logger_fatal "Port 443 must be free for Caddy."
}

svc_caddy_install() {
    pxu_logger_info "Installing Caddy..."
    if command -v caddy &>/dev/null; then
        pxu_logger_success "Caddy is already installed."
        return 0
    fi
    
    sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https >/dev/null 2>&1 || true
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list >/dev/null
    sudo apt-get update >/dev/null 2>&1 || true
    sudo apt-get install -y caddy >/dev/null 2>&1 || true
}

svc_caddy_configure() {
    pxu_logger_info "Configuring firewall for Caddy..."
    lib_firewall_allow_port 80 tcp
    lib_firewall_allow_port 443 tcp
    pxu_state_save "caddy" "installed" "true"
}

svc_caddy_start() {
    sudo systemctl enable --now caddy >/dev/null 2>&1 || true
    pxu_logger_success "Caddy service started."
}

svc_caddy_update() {
    pxu_logger_info "Updating Caddy via apt..."
    sudo apt-get update >/dev/null 2>&1 || true
    sudo apt-get install -y caddy >/dev/null 2>&1 || true
}

svc_caddy_remove() {
    pxu_logger_warn "Removing Caddy..."
    sudo apt-get remove -y caddy >/dev/null 2>&1 || true
    pxu_state_save "caddy" "installed" "false"
}

svc_caddy_doctor() {
    if command -v systemctl &>/dev/null && systemctl is-active --quiet caddy; then
        pxu_logger_success "Caddy is running."
    else
        pxu_logger_error "Caddy is not running or systemctl unavailable."
    fi
}
