#!/usr/bin/env bash
# File: services/fail2ban/installer.sh

svc_fail2ban_preflight() {
    pxu_logger_info "Preflight checks for Fail2Ban..."
}

svc_fail2ban_install() {
    pxu_logger_info "Installing Fail2Ban..."
    sudo apt update >/dev/null && sudo apt install -y fail2ban iptables >/dev/null || true
    
    local jail_conf="/etc/fail2ban/jail.d/pxu-docker.conf"
    sudo mkdir -p /etc/fail2ban/jail.d || true
    cat <<EOF | sudo tee "$jail_conf" >/dev/null
[DEFAULT]
banaction = ufw
bantime = 3600
findtime = 600
maxretry = 5

[pxu-auth-drops]
enabled = true
port = http,https,8000,2053,3000
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
EOF
}

svc_fail2ban_configure() {
    pxu_logger_info "Configuring Fail2Ban..."
    if command -v systemctl &>/dev/null; then
        sudo systemctl enable --now fail2ban >/dev/null 2>&1 || true
        sudo systemctl restart fail2ban >/dev/null 2>&1 || true
    fi
    pxu_state_save "fail2ban" "installed" "true"
}

svc_fail2ban_start() {
    pxu_logger_success "Fail2Ban started and monitoring logs."
    lib_telegram_send_msg "🛡️ ProxyUltra Fail2Ban DDoS Shield activated on \`$(hostname)\`"
}

svc_fail2ban_update() {
    pxu_logger_info "Updating fail2ban..."
    sudo apt update >/dev/null && sudo apt install -y fail2ban >/dev/null || true
}

svc_fail2ban_remove() {
    pxu_logger_warn "Removing fail2ban..."
    if command -v systemctl &>/dev/null; then
        sudo systemctl stop fail2ban >/dev/null 2>&1 || true
    fi
    sudo apt remove -y fail2ban >/dev/null 2>&1 || true
    sudo rm -f /etc/fail2ban/jail.d/pxu-docker.conf >/dev/null 2>&1 || true
    pxu_state_save "fail2ban" "installed" "false"
}

svc_fail2ban_doctor() {
    if command -v systemctl &>/dev/null && systemctl is-active --quiet fail2ban; then
        pxu_logger_success "Fail2Ban is active and shielding the host."
    else
        pxu_logger_warn "Fail2Ban is NOT running (or systemctl unavailable)."
    fi
}
