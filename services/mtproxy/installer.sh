#!/usr/bin/env bash

svc_mtproxy_preflight() {
    pxu_logger_info "Preflight checks for Telegram MTProxy..."
}

svc_mtproxy_install() {
    pxu_logger_info "Installing official Telegram MTProxy..."
    local dest_dir="${PXU_INSTALL_DIR}/data/mtproxy"
    mkdir -p "$dest_dir" 
    
    cp "${PXU_INSTALL_DIR}/services/mtproxy/templates/docker-compose.yml" "${dest_dir}/"
    
    local base_secret
    base_secret=$(openssl rand -hex 16)
    
    local proxy_port
    proxy_port=$(whiptail --inputbox "Enter external port for MTProxy (Default: 443):" 10 60 "443" 3>&1 1>&2 2>&3)
    if [[ -z "$proxy_port" ]]; then proxy_port=443; fi
    
    # By default, use fake-tls (ee) masking against a common domain to bypass DPI
    local domain_mask
    domain_mask=$(whiptail --inputbox "Enter a domain for Fake-TLS masking to combat DPI (e.g. google.com):" 10 60 "google.com" 3>&1 1>&2 2>&3)
    
    local final_secret="$base_secret"
    if [[ -n "$domain_mask" ]]; then
        # Format for Fake-TLS: 'ee' + 32-hex-secret + hex(domain)
        local hex_domain=$(echo -n "$domain_mask" | xxd -p | tr -d '\n')
        final_secret="ee${base_secret}${hex_domain}"
    fi
    
    cat <<EOF > "${dest_dir}/.env"
MTPROXY_PORT=${proxy_port}
MTPROXY_SECRET=${final_secret}
MTPROXY_WORKERS=1
EOF

    pxu_state_save "mtproxy" "port" "$proxy_port"
    pxu_state_save "mtproxy" "secret" "$final_secret"

    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose pull >/dev/null 2>&1
    else
        docker compose pull >/dev/null 2>&1
    fi
}

svc_mtproxy_configure() {
    local port
    port=$(pxu_state_get "mtproxy" "port")
    pxu_logger_info "Configuring Firewall for MTProxy on port $port..."
    lib_firewall_allow_port "$port" tcp
    pxu_state_save "mtproxy" "installed" "true"
}

svc_mtproxy_start() {
    local dest_dir="${PXU_INSTALL_DIR}/data/mtproxy"
    cd "$dest_dir" || exit 1
    
    if command -v docker-compose &>/dev/null; then
        docker-compose up -d >/dev/null 2>&1
    else
        docker compose up -d >/dev/null 2>&1
    fi
    
    local d_port=$(pxu_state_get "mtproxy" "port")
    local d_secret=$(pxu_state_get "mtproxy" "secret")
    local server_ip=$(curl -s https://api.ipify.org || echo "127.0.0.1")
    
    local invite_link="tg://proxy?server=${server_ip}&port=${d_port}&secret=${d_secret}"
    
    pxu_logger_success "MTProxy started successfully."
    pxu_logger_success "SHARE THIS LINK WITH USERS: ${invite_link}"
    
    lib_telegram_send_msg "🚀 ProxyUltra MTProxy Node Launched!
**Server IP:** \`${server_ip}\`
**Port:** \`${d_port}\`
**Secret:** \`${d_secret}\`
[Click here to connect in Telegram](${invite_link})"
}

svc_mtproxy_update() {
    pxu_logger_info "Updating MTProxy image..."
    local dest_dir="${PXU_INSTALL_DIR}/data/mtproxy"
    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose pull && docker-compose up -d
    else
        docker compose pull && docker compose up -d
    fi
}

svc_mtproxy_remove() {
    pxu_logger_warn "Removing MTProxy..."
    local dest_dir="${PXU_INSTALL_DIR}/data/mtproxy"
    
    if [[ -d "$dest_dir" ]]; then
        cd "$dest_dir" || exit 1
        if command -v docker-compose &>/dev/null; then
            docker-compose down -v >/dev/null 2>&1
        else
            docker compose down -v >/dev/null 2>&1
        fi
        cd / && sudo rm -rf "$dest_dir"
    fi
    pxu_state_save "mtproxy" "installed" "false"
}

svc_mtproxy_doctor() {
    if docker ps --format '{{.Names}}' | grep -q "^mtproxy$"; then
        pxu_logger_success "Telegram MTProxy is active."
    else
        pxu_logger_error "MTProxy is NOT running."
    fi
}
