#!/usr/bin/env bash
# File: services/3dpmanager/installer.sh

svc_3dpmanager_preflight() {
    pxu_logger_info "Preflight checks for 3dp-manager..."
}

svc_3dpmanager_install() {
    pxu_logger_info "Installing 3DP-Manager..."
    local dest_dir="${PXU_INSTALL_DIR}/data/3dpmanager"
    mkdir -p "$dest_dir" 
    
    cp "${PXU_INSTALL_DIR}/services/3dpmanager/templates/docker-compose.yml" "${dest_dir}/"
    
    local db_pass=$(lib_crypto_generate_string 12)
    local jwt_secret=$(lib_crypto_generate_string 32)
    local admin_user=$(lib_crypto_generate_string 8)
    local admin_pass=$(lib_crypto_generate_string 12)
    
    local final_port
    final_port=$(pxu_ui_ask "Enter a port to bind 3DP Manager UI locally" "8080")
    
    # Origins handling for CORS
    local domain=${PXU_DOMAIN:-$(curl -s https://api.ipify.org || echo "localhost")}
    local allowed_origins="https://${domain}"
    if [[ "$domain" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        allowed_origins="http://${domain}"
    fi

    cat <<EOF > "${dest_dir}/.env"
DB_PASS=${db_pass}
JWT_SECRET=${jwt_secret}
ADMIN_USER=${admin_user}
ADMIN_PASS=${admin_pass}
FINAL_PORT=${final_port}
ALLOWED_ORIGINS=${allowed_origins}
EOF

    pxu_state_save "3dpmanager" "admin_user" "$admin_user"
    pxu_state_save "3dpmanager" "admin_pass" "$admin_pass"
    pxu_state_save "3dpmanager" "port" "$final_port"

    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose pull >/dev/null 2>&1
    else
        docker compose pull >/dev/null 2>&1
    fi
}

svc_3dpmanager_configure() {
    local port=$(pxu_state_get "3dpmanager" "port")
    pxu_logger_info "Configuring Firewall for 3dpmanager on Port $port..."
    lib_firewall_allow_port "$port" tcp
    
    local domain=${PXU_DOMAIN:-}
    if [[ -n "$domain" ]]; then
        lib_ssl_issue_cert "$domain"
        lib_proxy_setup_vhost "$domain" "$port"
        lib_firewall_allow_port 80 tcp
        lib_firewall_allow_port 443 tcp
    fi
    
    pxu_state_save "3dpmanager" "installed" "true"
}

svc_3dpmanager_start() {
    local dest_dir="${PXU_INSTALL_DIR}/data/3dpmanager"
    cd "$dest_dir" || exit 1
    
    if command -v docker-compose &>/dev/null; then
        docker-compose up -d >/dev/null 2>&1
    else
        docker compose up -d >/dev/null 2>&1
    fi
    
    local au=$(pxu_state_get "3dpmanager" "admin_user")
    local ap=$(pxu_state_get "3dpmanager" "admin_pass")
    
    pxu_logger_success "3DP-Manager started successfully!"
    pxu_logger_success "Login Username: ${au}"
    pxu_logger_success "Login Password: ${ap}"
    pxu_logger_warn "PLEASE CHANGE YOUR PASSWORD IMMEDIATELY AFTER LOGIN."
    
    lib_telegram_send_msg "⚙️ ProxyUltra 3DP Manager deployed on \`$(hostname)\`
**Login**: \`${au}\`
**Password**: \`${ap}\`"
}

svc_3dpmanager_update() {
    pxu_logger_info "Updating 3DP-Manager image..."
    local dest_dir="${PXU_INSTALL_DIR}/data/3dpmanager"
    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose pull && docker-compose up -d
    else
        docker compose pull && docker compose up -d
    fi
}

svc_3dpmanager_remove() {
    pxu_logger_warn "Removing 3dp-manager..."
    local dest_dir="${PXU_INSTALL_DIR}/data/3dpmanager"
    if [[ -d "$dest_dir" ]]; then
        cd "$dest_dir" || exit 1
        if command -v docker-compose &>/dev/null; then
            docker-compose down -v >/dev/null 2>&1
        else
            docker compose down -v >/dev/null 2>&1
        fi
        cd / && sudo rm -rf "$dest_dir"
    fi
    pxu_state_save "3dpmanager" "installed" "false"
}

svc_3dpmanager_doctor() {
    if docker ps --format '{{.Names}}' | grep -q "3dp-backend"; then
        pxu_logger_success "3DP-Manager API Backend is active."
    else
        pxu_logger_error "3DP-Manager API Backend is NOT running."
    fi
}
