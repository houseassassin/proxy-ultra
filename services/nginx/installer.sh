#!/usr/bin/env bash

svc_nginx_preflight() {
    pxu_logger_info "Running preflight checks for Nginx..."
    lib_network_check_port 80 || pxu_logger_fatal "Port 80 must be free for Nginx."
    lib_network_check_port 443 || pxu_logger_fatal "Port 443 must be free for Nginx."
}

svc_nginx_install() {
    pxu_logger_info "Installing Nginx..."
    if command -v nginx &>/dev/null; then
        pxu_logger_success "Nginx is already installed."
        return 0
    fi
    sudo apt update >/dev/null 2>&1 || true
    sudo apt install -y nginx >/dev/null 2>&1 || true
}

svc_nginx_configure() {
    pxu_logger_info "Configuring firewall for Nginx..."
    lib_firewall_allow_port 80 tcp
    lib_firewall_allow_port 443 tcp
    pxu_state_save "nginx" "installed" "true"
}

svc_nginx_start() {
    sudo systemctl enable --now nginx >/dev/null 2>&1 || true
    pxu_logger_success "Nginx service started."
}

svc_nginx_update() {
    pxu_logger_info "Updating Nginx via apt..."
    sudo apt update >/dev/null 2>&1 || true
    sudo apt install -y nginx >/dev/null 2>&1 || true
}

svc_nginx_remove() {
    pxu_logger_warn "Removing Nginx..."
    sudo apt remove -y nginx >/dev/null 2>&1 || true
    pxu_state_save "nginx" "installed" "false"
}

svc_nginx_doctor() {
    if command -v systemctl &>/dev/null && systemctl is-active --quiet nginx; then
        pxu_logger_success "Nginx is running."
    else
        pxu_logger_error "Nginx is not running or systemctl unavailable."
    fi
}
