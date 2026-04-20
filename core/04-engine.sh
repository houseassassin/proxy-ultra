#!/usr/bin/env bash
# File: core/04-engine.sh

pxu_engine_load_module() {
    local service=$1
    local module_path="${PXU_INSTALL_DIR}/services/${service}/installer.sh"
    
    if [[ ! -f "$module_path" ]]; then
        pxu_logger_fatal "Service module '${service}' not found at ${module_path}"
    fi
    
    if [[ -f "${PXU_INSTALL_DIR}/services/${service}/manifest.env" ]]; then
        source "${PXU_INSTALL_DIR}/services/${service}/manifest.env"
    fi
    
    source "$module_path"
}

pxu_engine_install() {
    local service=$1
    shift || true
    
    if [[ -z "$service" ]]; then
        pxu_logger_fatal "Must specify a service to install."
    fi
    
    pxu_logger_info "Initiating installation sequence for [${service}]..."
    pxu_engine_load_module "${service}"
    
    "svc_${service}_preflight"
    "svc_${service}_install"
    "svc_${service}_configure"
    "svc_${service}_start"
    pxu_logger_success "Successfully installed ${service}!"
}

pxu_engine_remove() {
    local service=$1
    shift || true
    
    if [[ -z "$service" ]]; then
        pxu_logger_fatal "Must specify a service to remove."
    fi
    
    pxu_logger_warn "Initiating removal sequence for [${service}]..."
    pxu_engine_load_module "${service}"
    "svc_${service}_remove"
    pxu_logger_success "Successfully removed ${service}."
}

pxu_engine_update() {
    local service=$1
    shift || true
    pxu_engine_load_module "${service}"
    "svc_${service}_update"
}

pxu_engine_backup() {
    local service=$1
    shift || true
    if [[ -z "$service" ]]; then
        pxu_logger_fatal "Must specify a service to backup."
    fi
    pxu_logger_info "Initiating backup sequence for [${service}]..."
    pxu_engine_load_module "${service}"
    if declare -f "svc_${service}_backup" > /dev/null; then
        "svc_${service}_backup"
        pxu_logger_success "Backup completed for ${service}."
        lib_telegram_send_msg "📦 ProxyUltra Backup successfully generated for \`${service}\` on \`$(hostname)\`"
    else
        pxu_logger_warn "Service ${service} lacks svc_${service}_backup hook."
    fi
}

pxu_engine_restore() {
    local service=$1
    shift || true
    if [[ -z "$service" ]]; then
        pxu_logger_fatal "Must specify a service to restore."
    fi
    pxu_logger_info "Initiating restore sequence for [${service}]..."
    pxu_engine_load_module "${service}"
    if declare -f "svc_${service}_restore" > /dev/null; then
        "svc_${service}_restore"
        pxu_logger_success "Restore completed for ${service}."
    else
        pxu_logger_warn "Service ${service} lacks svc_${service}_restore hook."
    fi
}

pxu_engine_doctor() {
    pxu_logger_info "Running system diagnostics..."
    
    # 1. OS Checks
    if [[ ! -f /etc/os-release ]]; then
        pxu_logger_warn "Could not determine OS version."
    else
        # shellcheck disable=SC1091
        source /etc/os-release
        pxu_logger_info "OS: $PRETTY_NAME"
    fi
    
    # 2. Dependency Checks
    for cmd in curl wget docker jq sudo sed awk grep; do
        if command -v "$cmd" &>/dev/null; then
            pxu_logger_info "Dependency OK: $cmd"
        else
            pxu_logger_warn "Dependency Missing: $cmd"
        fi
    done
    
    # 3. Firewalld / UFW Checks
    if command -v ufw &>/dev/null && sudo ufw status 2>/dev/null | grep -q "Status: active"; then
        pxu_logger_success "Firewall: UFW active"
    elif sudo iptables -L >/dev/null 2>&1; then
        pxu_logger_success "Firewall: iptables accessible"
    else
        pxu_logger_warn "Firewall: No active firewall manager detected."
    fi

    # 4. Iterating over installed services (from state file)
    if [[ -f "/etc/pxu/.state" ]]; then
        pxu_logger_info "Checking installed registry state..."
        local installed_services
        installed_services=$(grep -o '^[^_]*' "/etc/pxu/.state" | sort -u || true)
        
        for svc in $installed_services; do
            if [[ -n "$svc" && "$svc" != "PXU" ]]; then
                pxu_logger_info "Validating installed service: ${svc}"
                if [[ -f "${PXU_INSTALL_DIR}/services/${svc}/installer.sh" ]]; then
                     # shellcheck disable=SC1090
                     source "${PXU_INSTALL_DIR}/services/${svc}/installer.sh"
                     if declare -f "svc_${svc}_doctor" > /dev/null; then
                         "svc_${svc}_doctor"
                     else
                         pxu_logger_warn "Service ${svc} lacks svc_${svc}_doctor hook."
                     fi
                else
                     pxu_logger_error "State mismatch: ${svc} registered but module missing."
                fi
            fi
        done
    else
        pxu_logger_info "No services currently registered in state."
    fi

    pxu_logger_success "Diagnostics complete."
}

pxu_engine_cron_backup() {
    pxu_logger_info "Configuring Auto-Backups in crontab..."
    local cron_file="/etc/cron.daily/pxu-backup"
    
    cat <<EOF | sudo tee "$cron_file" >/dev/null
#!/usr/bin/env bash
${PXU_INSTALL_DIR}/bin/pxu backup remnawave
EOF
    sudo chmod +x "$cron_file" >/dev/null 2>&1 || true
    pxu_logger_success "Daily CRON backup enabled."
    lib_telegram_send_msg "🕒 ProxyUltra Auto-Backup CRON job successfully registered on \`$(hostname)\`."
}

pxu_engine_setup_tdl() {
    clear
    pxu_logger_info "Setting up MTProto (TDL) for large file uploads..."
    if ! command -v tdl &>/dev/null; then
        pxu_logger_info "Installing TDL client..."
        curl -sSL https://raw.githubusercontent.com/iyear/tdl/master/scripts/install.sh | bash
    fi
    
    echo ""
    pxu_logger_warn "You can use custom API ID and Hash, or press Enter to skip and use defaults."
    read -rp "Enter Telegram API ID (optional): " api_id
    read -rp "Enter Telegram API Hash (optional): " api_hash
    
    if [[ -n "$api_id" && -n "$api_hash" ]]; then
        export TDL_API_ID="${api_id}"
        export TDL_API_HASH="${api_hash}"
    fi
    
    pxu_logger_info "Launching interactive Telegram Login..."
    tdl login
    
    if [[ $? -eq 0 ]]; then
        pxu_state_save "core" "use_mtproto" "true"
        pxu_logger_success "TDL session saved successfully! Backups will now use MTProto."
    else
        pxu_logger_error "TDL login failed or was aborted."
    fi
    echo "Press Enter to return to menu..."
    read -r
}
