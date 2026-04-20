#!/usr/bin/env bash
# File: lib/lib_network.sh

lib_network_check_port() {
    local port=$1
    if command -v ss &>/dev/null; then
        if sudo ss -tulpn | grep -q ":${port} "; then
            return 1 # Port in use
        fi
    elif command -v netstat &>/dev/null; then
        if sudo netstat -tulpn | grep -q ":${port} "; then
            return 1 # Port in use
        fi
    else
        # Try bash socket as fallback
        if timeout 1 bash -c "</dev/tcp/127.0.0.1/${port}" &>/dev/null; then
            return 1 # Port in use
        fi
    fi
    return 0 # Port available
}

lib_network_enable_bbr() {
    pxu_logger_info "Checking TCP BBR status..."
    if ! sudo sysctl net.ipv4.tcp_congestion_control 2>/dev/null | grep -q "bbr"; then
        pxu_logger_info "Enabling TCP BBR for improved network throughput..."
        echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf >/dev/null
        echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf >/dev/null
        sudo sysctl -p >/dev/null || true
        pxu_logger_success "TCP BBR enabled."
    else
        pxu_logger_info "TCP BBR is already enabled."
    fi
}
