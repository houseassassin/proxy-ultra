#!/usr/bin/env bash
# File: lib/lib_ssl.sh

lib_ssl_issue_cert() {
    local domain=$1
    local email=${2:-$PXU_DEFAULT_EMAIL}
    
    pxu_logger_info "Issuing SSL certificate for ${domain} via acme.sh..."
    
    # Check if acme.sh is installed
    if [[ ! -f "$HOME/.acme.sh/acme.sh" ]]; then
        pxu_logger_info "Installing acme.sh..."
        curl -s https://get.acme.sh | sh -s email="$email" >/dev/null
    fi
    
    # Check if it already exists to be idempotent
    if "$HOME/.acme.sh/acme.sh" --list | grep -q "$domain"; then
        pxu_logger_success "SSL certificate for ${domain} already exists."
        return 0
    fi
    
    # Issue standalone cert (requires port 80 to be free)
    lib_network_check_port 80 || pxu_logger_fatal "Port 80 must be free to issue a standalone SSL cert."
    
    if "$HOME/.acme.sh/acme.sh" --issue -d "$domain" --standalone --server letsencrypt; then
         pxu_logger_success "Successfully issued cert for ${domain}"
    else
         pxu_logger_fatal "Failed to issue SSL cert for ${domain}"
    fi
}
