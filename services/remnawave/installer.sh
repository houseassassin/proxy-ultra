#!/usr/bin/env bash
# File: services/remnawave/installer.sh

svc_remnawave_preflight() {
    pxu_logger_info "Preflight checks for Remnawave..."
    lib_network_check_port 3000 || pxu_logger_fatal "Port 3000 is reserved for Remnawave Backend API"
    lib_network_check_port 3001 || pxu_logger_fatal "Port 3001 is reserved for Subscription Page"
}

svc_remnawave_install() {
    pxu_logger_info "Installing Remnawave Panel..."
    local dest_dir="${PXU_INSTALL_DIR}/data/remnawave"
    mkdir -p "$dest_dir" "${dest_dir}/data/db" "${dest_dir}/data/valkey"
    
    cp "${PXU_INSTALL_DIR}/services/remnawave/templates/docker-compose.yml" "${dest_dir}/"
    
    # Generate Secrets
    local pass_pg
    pass_pg=$(lib_crypto_generate_string 24)
    local pass_redis
    pass_redis=$(lib_crypto_generate_string 24)
    local secret_jwt
    secret_jwt=$(lib_crypto_generate_string 48)

    cat <<EOF > "${dest_dir}/.env"
POSTGRES_USER=remnawave
POSTGRES_PASSWORD=$pass_pg
REDIS_PASSWORD=$pass_redis
JWT_SECRET=$secret_jwt
EOF

    pxu_state_save "remnawave" "postgres_pwd" "$pass_pg"
    pxu_state_save "remnawave" "redis_pwd" "$pass_redis"

    cd "$dest_dir" || exit 1
    if command -v docker-compose &>/dev/null; then
        docker-compose pull >/dev/null 2>&1
    else
        docker compose pull >/dev/null 2>&1
    fi
}

svc_remnawave_configure() {
    pxu_logger_info "Configuring Remnawave components..."
    
    local domain
    domain=${PXU_DOMAIN:-}
    if [[ -n "$domain" ]]; then
        lib_ssl_issue_cert "$domain"
        lib_proxy_setup_vhost "$domain" 3000
    else
        pxu_logger_warn "No PXU_DOMAIN provided. Reverse proxy binding skipped."
    fi

    lib_firewall_allow_port 80 tcp
    lib_firewall_allow_port 443 tcp

    pxu_state_save "remnawave" "installed" "true"
}

svc_remnawave_start() {
    local dest_dir="${PXU_INSTALL_DIR}/data/remnawave"
    cd "$dest_dir" || exit 1
    
    if command -v docker-compose &>/dev/null; then
        docker-compose up -d >/dev/null 2>&1
    else
        docker compose up -d >/dev/null 2>&1
    fi
    
    pxu_logger_success "Remnawave Panel started."
}

svc_remnawave_update() {
    pxu_logger_info "Updating Remnawave image..."
    local dest_dir="${PXU_INSTALL_DIR}/data/remnawave"
    cd "$dest_dir" || exit 1
    
    if command -v docker-compose &>/dev/null; then
        docker-compose pull && docker-compose up -d
    else
        docker compose pull && docker compose up -d
    fi
}

svc_remnawave_remove() {
    pxu_logger_warn "Removing Remnawave..."
    local dest_dir="${PXU_INSTALL_DIR}/data/remnawave"
    if [[ -d "$dest_dir" ]]; then
        cd "$dest_dir" || exit 1
        if command -v docker-compose &>/dev/null; then
            docker-compose down -v >/dev/null 2>&1
        else
            docker compose down -v >/dev/null 2>&1
        fi
        cd / && sudo rm -rf "$dest_dir"
    fi
    pxu_state_save "remnawave" "installed" "false"
}

svc_remnawave_doctor() {
    if docker ps --format '{{.Names}}' | grep -q "backend"; then
        pxu_logger_success "Remnawave backend is running."
    else
        pxu_logger_error "Remnawave backend is NOT running."
    fi
}

svc_remnawave_backup() {
    local dest_dir="${PXU_INSTALL_DIR}/data/remnawave"
    local backup_dir="${PXU_INSTALL_DIR}/backups/remnawave_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    pxu_logger_info "Running pg_dump on remnawave database..."
    if docker ps --format '{{.Names}}' | grep -q "db"; then
        local db_container=$(docker ps --format '{{.Names}}' | grep "db" | grep "remnawave" | head -1)
        docker exec "$db_container" pg_dump -U remnawave remnawave > "${backup_dir}/remnawave_db.sql" || true
    else
        pxu_logger_error "Remnawave DB container not active."
    fi
    
    cp "${dest_dir}/.env" "${backup_dir}/" 2>/dev/null || true
    cp "${dest_dir}/docker-compose.yml" "${backup_dir}/" 2>/dev/null || true
    
    tar -czf "${backup_dir}.tar.gz" -C "${PXU_INSTALL_DIR}/backups" "$(basename "$backup_dir")"
    rm -rf "$backup_dir"
    pxu_logger_success "Backup archived into ${backup_dir}.tar.gz"
}

svc_remnawave_restore() {
    local archive_path=${PXU_RESTORE_FILE:-}
    if [[ ! -f "$archive_path" ]]; then
        pxu_logger_fatal "Restore failed. Specify PXU_RESTORE_FILE=/path/to/backup.tar.gz"
    fi
    pxu_logger_warn "To restore, unpack ${archive_path} and replace .env, then run docker exec -i db_container psql -U remnawave -d remnawave < remnawave_db.sql"
}
