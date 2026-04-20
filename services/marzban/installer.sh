#!/usr/bin/env bash

svc_marzban_preflight() {
    pxu_logger_info "Preflight checks for Marzban..."
    lib_network_check_port 8000 || pxu_logger_fatal "Port 8000 must be free for Marzban panel."
}

svc_marzban_install() {
    pxu_logger_info "Installing Marzban Panel..."
    local dest_dir="${PXU_INSTALL_DIR}/data/marzban"
    mkdir -p "$dest_dir" 
    sudo mkdir -p /var/lib/marzban || true
    
    cp "${PXU_INSTALL_DIR}/services/marzban/templates/docker-compose.yml" "${dest_dir}/"
    
    local sudo_user="admin"
    local sudo_pass
    sudo_pass=$(lib_crypto_generate_string 16)
    
    cat <<EOF > "${dest_dir}/.env"
SUDO_USERNAME=${sudo_user}
SUDO_PASSWORD=${sudo_pass}
UVICORN_PORT=8000
EOF

    pxu_state_save "marzban" "username" "$sudo_user"
    pxu_state_save "marzban" "password" "$sudo_pass"

    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose pull >/dev/null 2>&1
    else
        docker compose pull >/dev/null 2>&1
    fi
}

svc_marzban_configure() {
    pxu_logger_info "Configuring Firewall for Marzban..."
    lib_firewall_allow_port 8000 tcp
    lib_firewall_allow_port 80 tcp
    lib_firewall_allow_port 443 tcp
    
    local domain=${PXU_DOMAIN:-}
    if [[ -n "$domain" ]]; then
        lib_ssl_issue_cert "$domain"
        lib_proxy_setup_vhost "$domain" 8000
    fi
    
    pxu_state_save "marzban" "installed" "true"
}

svc_marzban_start() {
    local dest_dir="${PXU_INSTALL_DIR}/data/marzban"
    cd "$dest_dir" || exit 1
    
    if command -v docker-compose &>/dev/null; then
        docker-compose up -d >/dev/null 2>&1
    else
        docker compose up -d >/dev/null 2>&1
    fi
    
    pxu_logger_success "Marzban started."
    lib_telegram_send_msg "🚀 ProxyUltra Marzban Panel started successfully."
}

svc_marzban_update() {
    pxu_logger_info "Updating Marzban image..."
    local dest_dir="${PXU_INSTALL_DIR}/data/marzban"
    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose pull && docker-compose up -d
    else
        docker compose pull && docker compose up -d
    fi
}

svc_marzban_remove() {
    pxu_logger_warn "Removing Marzban..."
    local dest_dir="${PXU_INSTALL_DIR}/data/marzban"
    if [[ -d "$dest_dir" ]]; then
        cd "$dest_dir" || exit 1
        if command -v docker-compose &>/dev/null; then
            docker-compose down -v >/dev/null 2>&1
        else
            docker compose down -v >/dev/null 2>&1
        fi
        cd / && sudo rm -rf "$dest_dir" /var/lib/marzban
    fi
    pxu_state_save "marzban" "installed" "false"
}

svc_marzban_doctor() {
    if docker ps --format '{{.Names}}' | grep -q "marzban"; then
        pxu_logger_success "Marzban is running."
    else
        pxu_logger_error "Marzban is NOT running."
    fi
}
