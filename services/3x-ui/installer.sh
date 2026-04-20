#!/usr/bin/env bash
# File: services/3x-ui/installer.sh

svc_3xui_preflight() {
    pxu_logger_info "Preflight checks for 3x-ui..."
    lib_network_check_port 2053 || pxu_logger_fatal "Port 2053 (default panel port) is already in use."
}

svc_3xui_install() {
    pxu_logger_info "Installing 3x-ui via Docker Compose..."
    local dest_dir="${PXU_INSTALL_DIR}/data/3x-ui"
    mkdir -p "$dest_dir" "${dest_dir}/data/db" "${dest_dir}/data/cert"
    
    cp "${PXU_INSTALL_DIR}/services/3x-ui/templates/docker-compose.yml" "${dest_dir}/"
    
    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose pull >/dev/null 2>&1
    else
        docker compose pull >/dev/null 2>&1
    fi
}

svc_3xui_configure() {
    pxu_logger_info "Configuring 3x-ui components..."
    
    local domain
    domain=${PXU_DOMAIN:-}
    if [[ -n "$domain" ]]; then
        lib_ssl_issue_cert "$domain"
        lib_proxy_setup_vhost "$domain" 2053
    else
        pxu_logger_warn "No PXU_DOMAIN provided. Reverse proxy binding skipped."
    fi
    
    # Expose defaults
    lib_firewall_allow_port 2053 tcp
    lib_firewall_allow_port 80 tcp
    lib_firewall_allow_port 443 tcp

    pxu_state_save "3x-ui" "installed" "true"
}

svc_3xui_start() {
    local dest_dir="${PXU_INSTALL_DIR}/data/3x-ui"
    cd "$dest_dir" || exit 1
    
    if command -v docker-compose &>/dev/null; then
        docker-compose up -d >/dev/null 2>&1
    else
        docker compose up -d >/dev/null 2>&1
    fi
    
    pxu_logger_success "3x-ui service started."
}

svc_3xui_update() {
    pxu_logger_info "Updating 3x-ui image..."
    local dest_dir="${PXU_INSTALL_DIR}/data/3x-ui"
    cd "$dest_dir" || exit 1
    
    if command -v docker-compose &>/dev/null; then
        docker-compose pull && docker-compose up -d
    else
        docker compose pull && docker compose up -d
    fi
}

svc_3xui_remove() {
    pxu_logger_warn "Removing 3x-ui..."
    local dest_dir="${PXU_INSTALL_DIR}/data/3x-ui"
    if [[ -d "$dest_dir" ]]; then
        cd "$dest_dir" || exit 1
        if command -v docker-compose &>/dev/null; then
            docker-compose down -v >/dev/null 2>&1
        else
            docker compose down -v >/dev/null 2>&1
        fi
        cd / && rm -rf "$dest_dir"
    fi
    pxu_state_save "3x-ui" "installed" "false"
}

svc_3xui_doctor() {
    if docker ps --format '{{.Names}}' | grep -q "^3x-ui$"; then
        pxu_logger_success "3x-ui container is running."
    else
        pxu_logger_error "3x-ui container is NOT running."
    fi
}
