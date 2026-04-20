#!/usr/bin/env bash
# File: services/remnanode/installer.sh

svc_remnanode_preflight() {
    pxu_logger_info "Preflight checks for Remnanode..."
    if [[ -z "${PXU_REMNANODE_API_URL:-}" || -z "${PXU_REMNANODE_KEY:-}" ]]; then
        pxu_logger_fatal "RemnaNode requires PXU_REMNANODE_API_URL and PXU_REMNANODE_KEY environment variables to bridge to the panel."
    fi
}

svc_remnanode_install() {
    pxu_logger_info "Installing RemnaNode..."
    local dest_dir="${PXU_INSTALL_DIR}/data/remnanode"
    mkdir -p "$dest_dir" "${dest_dir}/data"
    
    cp "${PXU_INSTALL_DIR}/services/remnanode/templates/docker-compose.yml" "${dest_dir}/"
    
    cat <<EOF > "${dest_dir}/.env"
REMNA_API_URL=${PXU_REMNANODE_API_URL}
REMNA_NODE_KEY=${PXU_REMNANODE_KEY}
EOF

    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose pull >/dev/null 2>&1
    else
        docker compose pull >/dev/null 2>&1
    fi
}

svc_remnanode_configure() {
    pxu_logger_info "Configuring RemnaNode..."
    pxu_state_save "remnanode" "installed" "true"
}

svc_remnanode_start() {
    local dest_dir="${PXU_INSTALL_DIR}/data/remnanode"
    cd "$dest_dir" || exit 1
    
    if command -v docker-compose &>/dev/null; then
        docker-compose up -d >/dev/null 2>&1
    else
        docker compose up -d >/dev/null 2>&1
    fi
    
    pxu_logger_success "RemnaNode started."
}

svc_remnanode_update() {
    pxu_logger_info "Updating RemnaNode image..."
    local dest_dir="${PXU_INSTALL_DIR}/data/remnanode"
    cd "$dest_dir" || exit 1
    
    if command -v docker-compose &>/dev/null; then
        docker-compose pull && docker-compose up -d
    else
        docker compose pull && docker compose up -d
    fi
}

svc_remnanode_remove() {
    pxu_logger_warn "Removing RemnaNode..."
    local dest_dir="${PXU_INSTALL_DIR}/data/remnanode"
    if [[ -d "$dest_dir" ]]; then
        cd "$dest_dir" || exit 1
        if command -v docker-compose &>/dev/null; then
            docker-compose down -v >/dev/null 2>&1
        else
            docker compose down -v >/dev/null 2>&1
        fi
        cd / && sudo rm -rf "$dest_dir"
    fi
    pxu_state_save "remnanode" "installed" "false"
}

svc_remnanode_doctor() {
    if docker ps --format '{{.Names}}' | grep -q "remnanode"; then
        pxu_logger_success "RemnaNode is running."
    else
        pxu_logger_error "RemnaNode is NOT running."
    fi
}
