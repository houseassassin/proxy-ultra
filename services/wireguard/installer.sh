#!/usr/bin/env bash
# File: services/wireguard/installer.sh

svc_wireguard_preflight() {
    pxu_logger_info "Preflight checks for Wireguard (wg-easy)..."
    lib_network_check_port 51820 || pxu_logger_fatal "Port 51820 (UDP) must be free."
    lib_network_check_port 51821 || pxu_logger_fatal "Port 51821 (TCP) must be free for UI."
}

svc_wireguard_install() {
    pxu_logger_info "Installing Wireguard (wg-easy)..."
    local dest_dir="${PXU_INSTALL_DIR}/data/wireguard"
    mkdir -p "$dest_dir" "${dest_dir}/data"
    
    cp "${PXU_INSTALL_DIR}/services/wireguard/templates/docker-compose.yml" "${dest_dir}/"
    
    local wg_host=${PXU_DOMAIN:-}
    if [[ -z "$wg_host" ]]; then
        # Fetch public IP as fallback if domain is not provided
        wg_host=$(curl -s https://api.ipify.org || echo "127.0.0.1")
    fi

    local web_password
    web_password=$(lib_crypto_generate_string 12)
    pxu_logger_info "Generated Web UI Password: ${web_password}"
    
    # Pre-pulling image to generate bcrypt hash securely without sending data externally
    if command -v docker &>/dev/null; then
        pxu_logger_info "Generating secure bcrypt hash for UI..."
        docker pull ghcr.io/wg-easy/wg-easy >/dev/null 2>&1
        local pass_hash
        pass_hash=$(docker run --rm ghcr.io/wg-easy/wg-easy wgpw "$web_password" | tr -d "'" | xargs)
    else
        pxu_logger_fatal "Docker is required before setup can continue."
    fi

    cat <<EOF > "${dest_dir}/.env"
WG_HOST=${wg_host}
PASSWORD_HASH='${pass_hash}'
EOF

    pxu_state_save "wireguard" "ui_password" "$web_password"
    pxu_state_save "wireguard" "wg_host" "$wg_host"

    cd "$dest_dir" || exit 1
}

svc_wireguard_configure() {
    pxu_logger_info "Configuring Firewall for Wireguard..."
    lib_firewall_allow_port 51820 udp
    pxu_logger_info "Note: Web UI is bound to 127.0.0.1:51821. Consider using a reverse proxy to expose it securely."
    
    local domain=${PXU_DOMAIN:-}
    if [[ -n "$domain" ]]; then
        lib_ssl_issue_cert "$domain"
        lib_proxy_setup_vhost "$domain" 51821
        lib_firewall_allow_port 80 tcp
        lib_firewall_allow_port 443 tcp
    fi
    
    pxu_state_save "wireguard" "installed" "true"
}

svc_wireguard_start() {
    local dest_dir="${PXU_INSTALL_DIR}/data/wireguard"
    cd "$dest_dir" || exit 1
    
    if command -v docker-compose &>/dev/null; then
        docker-compose up -d >/dev/null 2>&1
    else
        docker compose up -d >/dev/null 2>&1
    fi
    
    pxu_logger_success "Wireguard (wg-easy) started."
}

svc_wireguard_update() {
    pxu_logger_info "Updating Wireguard image..."
    local dest_dir="${PXU_INSTALL_DIR}/data/wireguard"
    cd "$dest_dir" || exit 1
    
    if command -v docker-compose &>/dev/null; then
        docker-compose pull && docker-compose up -d
    else
        docker compose pull && docker compose up -d
    fi
}

svc_wireguard_remove() {
    pxu_logger_warn "Removing Wireguard..."
    local dest_dir="${PXU_INSTALL_DIR}/data/wireguard"
    if [[ -d "$dest_dir" ]]; then
        cd "$dest_dir" || exit 1
        if command -v docker-compose &>/dev/null; then
            docker-compose down -v >/dev/null 2>&1
        else
            docker compose down -v >/dev/null 2>&1
        fi
        cd / && sudo rm -rf "$dest_dir"
    fi
    pxu_state_save "wireguard" "installed" "false"
}

svc_wireguard_doctor() {
    if docker ps --format '{{.Names}}' | grep -q "^wg-easy$"; then
        pxu_logger_success "Wireguard is running."
    else
        pxu_logger_error "Wireguard container is NOT running."
    fi
}
