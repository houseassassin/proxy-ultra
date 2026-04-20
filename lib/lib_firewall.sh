#!/usr/bin/env bash
# File: lib/lib_firewall.sh

lib_firewall_allow_port() {
    local port=$1
    local protocol=${2:-tcp}
    
    if command -v ufw &>/dev/null && sudo ufw status | grep -q "Status: active"; then
        sudo ufw allow "${port}/${protocol}" >/dev/null
        pxu_logger_info "Firewall: Allowed ${port}/${protocol}"
    elif command -v iptables &>/dev/null; then
        # Check if rule exists before adding
        if ! sudo iptables -C INPUT -p "${protocol}" --dport "${port}" -j ACCEPT 2>/dev/null; then
            sudo iptables -I INPUT -p "${protocol}" --dport "${port}" -j ACCEPT
            pxu_logger_info "Firewall: Allowed ${port}/${protocol}"
        fi
    else
        pxu_logger_warn "No supported/active firewall (UFW/iptables) found. Port ${port} may already be exposed."
    fi
}

lib_firewall_deny_port() {
    local port=$1
    local protocol=${2:-tcp}
    
    if command -v ufw &>/dev/null && sudo ufw status | grep -q "Status: active"; then
        sudo ufw delete allow "${port}/${protocol}" >/dev/null 2>&1 || true
        pxu_logger_info "Firewall: Blocked ${port}/${protocol}"
    elif command -v iptables &>/dev/null; then
        sudo iptables -D INPUT -p "${protocol}" --dport "${port}" -j ACCEPT 2>/dev/null || true
        pxu_logger_info "Firewall: Removed rule for ${port}/${protocol}"
    fi
}
