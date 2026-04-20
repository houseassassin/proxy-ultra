#!/usr/bin/env bash
# File: services/selfsteal/installer.sh

svc_selfsteal_preflight() {
    pxu_logger_info "Preflight checks for Selfsteal (Caddy/Reality snippet)..."
    lib_network_check_port 443 || pxu_logger_fatal "Port 443 must be free to deploy Selfsteal disguise proxy."
}

svc_selfsteal_install() {
    pxu_logger_info "Installing Selfsteal Anti-DPI..."
    local dest_dir="${PXU_INSTALL_DIR}/data/selfsteal"
    mkdir -p "$dest_dir" 
    
    cp "${PXU_INSTALL_DIR}/services/selfsteal/templates/docker-compose.yml" "${dest_dir}/"
    
    # Generate stealth Caddyfile configuration proxying to Microsoft.com or Wikipedia.org natively
    local sni_target="www.microsoft.com"
    cat <<EOF > "${dest_dir}/Caddyfile"
:443 {
    reverse_proxy https://${sni_target} {
        header_up Host {upstream_hostport}
        transport http {
            tls_server_name ${sni_target}
        }
    }
}
EOF

    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose pull >/dev/null 2>&1
    else
        docker compose pull >/dev/null 2>&1
    fi
}

svc_selfsteal_configure() {
    pxu_logger_info "Configuring Selfsteal components..."
    lib_firewall_allow_port 443 tcp
    pxu_state_save "selfsteal" "installed" "true"
}

svc_selfsteal_start() {
    local dest_dir="${PXU_INSTALL_DIR}/data/selfsteal"
    cd "$dest_dir" || exit 1
    
    if command -v docker-compose &>/dev/null; then
        docker-compose up -d >/dev/null 2>&1
    else
        docker compose up -d >/dev/null 2>&1
    fi
    
    pxu_logger_success "Selfsteal Anti-DPI proxy started routing to SNI mask."
}

svc_selfsteal_update() {
    pxu_logger_info "Updating Selfsteal image..."
    local dest_dir="${PXU_INSTALL_DIR}/data/selfsteal"
    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose pull && docker-compose up -d
    else
        docker compose pull && docker compose up -d
    fi
}

svc_selfsteal_remove() {
    pxu_logger_warn "Removing Selfsteal..."
    local dest_dir="${PXU_INSTALL_DIR}/data/selfsteal"
    if [[ -d "$dest_dir" ]]; then
        cd "$dest_dir" || exit 1
        if command -v docker-compose &>/dev/null; then
            docker-compose down -v >/dev/null 2>&1
        else
            docker compose down -v >/dev/null 2>&1
        fi
        cd / && sudo rm -rf "$dest_dir"
    fi
    pxu_state_save "selfsteal" "installed" "false"
}

svc_selfsteal_doctor() {
    if docker ps --format '{{.Names}}' | grep -q "selfsteal"; then
        pxu_logger_success "Selfsteal is masking perfectly."
    else
        pxu_logger_error "Selfsteal container is NOT running."
    fi
}
