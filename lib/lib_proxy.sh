#!/usr/bin/env bash
# File: lib/lib_proxy.sh

lib_proxy_setup_vhost() {
    local domain=$1
    local upstream_port=$2
    local proxy_engine=${PXU_REVERSE_PROXY:-caddy}
    
    pxu_logger_info "Setting up reverse proxy for ${domain} -> 127.0.0.1:${upstream_port} using ${proxy_engine}"
    
    if [[ "$proxy_engine" == "caddy" ]]; then
        if ! command -v caddy &>/dev/null; then
             pxu_logger_error "Caddy is not installed. Run 'pxu install caddy' first."
             return 1
        fi
        
        local caddy_conf="/etc/caddy/Caddyfile"
        
        if [[ ! -f "$caddy_conf" ]]; then
            sudo touch "$caddy_conf" || true
        fi

        # Idempotency check
        if grep -q "${domain} {" "$caddy_conf" 2>/dev/null; then
             pxu_logger_warn "Vhost for ${domain} already exists in caddy."
        else
             # Append to caddyfile securely
             echo -e "\n${domain} {\n    reverse_proxy 127.0.0.1:${upstream_port}\n}" | sudo tee -a "$caddy_conf" >/dev/null
             pxu_logger_success "Added ${domain} to Caddy."
             sudo systemctl reload caddy || true
        fi
    elif [[ "$proxy_engine" == "nginx" ]]; then
        pxu_logger_warn "Nginx config proxy generation not fully implemented in MVP."
    else
        pxu_logger_warn "No supported proxy engine configured."
    fi
}
