#!/usr/bin/env bash

svc_warp_preflight() {
    pxu_logger_info "Preflight checks for WARP..."
    lib_network_check_port 40000 || pxu_logger_fatal "Port 40000 is reserved for local SOCKS5 proxy."
}

svc_warp_install() {
    pxu_logger_info "Installing Cloudflare WARP Outbound Proxy..."
    local dest_dir="${PXU_INSTALL_DIR}/data/warp"
    mkdir -p "$dest_dir" 
    cp "${PXU_INSTALL_DIR}/services/warp/templates/docker-compose.yml" "${dest_dir}/"
    
    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose pull >/dev/null 2>&1
    else
        docker compose pull >/dev/null 2>&1
    fi
}

svc_warp_configure() {
    pxu_logger_info "Configuring WARP components..."
    pxu_logger_info "NOTE: This proxy is exposed locally securely at socks5://127.0.0.1:40000."
    pxu_state_save "warp" "installed" "true"
}

svc_warp_start() {
    local dest_dir="${PXU_INSTALL_DIR}/data/warp"
    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose up -d >/dev/null 2>&1
    else
        docker compose up -d >/dev/null 2>&1
    fi
    pxu_logger_success "WARP started."
    lib_telegram_send_msg "🌐 ProxyUltra WARP SOCKS5 Proxy started correctly on \`$(hostname)\`"
}

svc_warp_update() {
    pxu_logger_info "Updating WARP image..."
    local dest_dir="${PXU_INSTALL_DIR}/data/warp"
    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose pull && docker-compose up -d
    else
        docker compose pull && docker compose up -d
    fi
}

svc_warp_remove() {
    pxu_logger_warn "Removing WARP..."
    local dest_dir="${PXU_INSTALL_DIR}/data/warp"
    if [[ -d "$dest_dir" ]]; then
        cd "$dest_dir" || exit 1
        if command -v docker-compose &>/dev/null; then
            docker-compose down -v >/dev/null 2>&1
        else
            docker compose down -v >/dev/null 2>&1
        fi
        cd / && sudo rm -rf "$dest_dir"
    fi
    pxu_state_save "warp" "installed" "false"
}

svc_warp_doctor() {
    if docker ps --format '{{.Names}}' | grep -q "^warp$"; then
        pxu_logger_success "WARP outbound proxy is active."
    else
        pxu_logger_error "WARP container is NOT running."
    fi
}
