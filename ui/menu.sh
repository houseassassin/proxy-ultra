#!/usr/bin/env bash
# File: ui/menu.sh

ui_main_menu() {
    if ! command -v whiptail &>/dev/null; then
        pxu_logger_warn "whiptail is required for the interactive menu. Please install it (e.g. apt install whiptail)."
        exit 1
    fi

    local OPTION
    OPTION=$(whiptail --title " ProxyUltra (pxu) by Houseassassin " \
                     --menu "Select a framework component to deploy:" 20 70 11 \
                     "1" "Install Remnawave Panel" \
                     "2" "Install RemnaNode Bridge" \
                     "3" "Install 3x-ui Panel" \
                     "4" "Install Selfsteal (Anti-DPI) Proxy" \
                     "5" "Install Netbird VPN Node" \
                     "6" "Backup Remnawave Panel" \
                     "7" "Install Wireguard VPN (wg-easy)" \
                     "8" "Install Marzban Panel" \
                     "9" "Install Cloudflare WARP SOCKS5" \
                     "a" "Install Telegram MTProxy Node" \
                     "b" "Install 3DP-Manager (3x-ui GUI)" \
                     "f" "Install Fail2Ban (Anti-DDoS Shield)" \
                     "t" "Configure TG Alerts & Auto-Backups" \
                     "m" "Setup MTProto (TDL) for Huge Backups" \
                     "d" "Run System Diagnostics (Doctor)" \
                     "b" "Enable TCP BBR Tuning" \
                     "0" "Exit" 3>&1 1>&2 2>&3)

    local exit_status=$?
    if [ $exit_status -ne 0 ]; then
        pxu_logger_info "Process aborted."
        return 0
    fi

    case $OPTION in
        1)
            export PXU_DOMAIN=$(whiptail --inputbox "Enter domain for Remnawave (or leave blank if IP-only):" 10 60 3>&1 1>&2 2>&3)
            pxu_engine_install "remnawave"
            ;;
        2)
            export PXU_REMNANODE_API_URL=$(whiptail --inputbox "Enter Remnawave API URL (e.g., http://x.x.x.x:3000):" 10 60 3>&1 1>&2 2>&3)
            export PXU_REMNANODE_KEY=$(whiptail --inputbox "Enter RemnaNode Secret Key:" 10 60 3>&1 1>&2 2>&3)
            pxu_engine_install "remnanode"
            ;;
        3)
            pxu_engine_install "3x-ui"
            ;;
        4)
            pxu_engine_install "selfsteal"
            ;;
        5)
            export PXU_NETBIRD_SETUP_KEY=$(whiptail --inputbox "Enter Netbird Setup Key:" 10 60 3>&1 1>&2 2>&3)
            pxu_engine_install "netbird"
            ;;
        6)
            pxu_engine_backup "remnawave"
            ;;
        7)
            export PXU_DOMAIN=$(whiptail --inputbox "Enter Domain/IP for Wireguard Endpoint:" 10 60 3>&1 1>&2 2>&3)
            pxu_engine_install "wireguard"
            ;;
        8)
            export PXU_DOMAIN=$(whiptail --inputbox "Enter domain for Marzban (or leave blank if IP-only):" 10 60 3>&1 1>&2 2>&3)
            pxu_engine_install "marzban"
            ;;
        9)
            pxu_engine_install "warp"
            ;;
        a)
            pxu_engine_install "mtproxy"
            ;;
        b)
            export PXU_DOMAIN=$(whiptail --inputbox "Enter a domain to proxy 3DP-Manager (optional):" 10 60 3>&1 1>&2 2>&3)
            pxu_engine_install "3dpmanager"
            ;;
        f)
            pxu_engine_install "fail2ban"
            ;;
        t)
            local tg_token=$(whiptail --inputbox "Enter Telegram Bot Token (or leave blank to skip):" 10 60 3>&1 1>&2 2>&3)
            local tg_chat=$(whiptail --inputbox "Enter Telegram Chat ID (or leave blank to skip):" 10 60 3>&1 1>&2 2>&3)
            
            if [[ -n "$tg_token" && -n "$tg_chat" ]]; then
                pxu_state_save "core" "tg_token" "$tg_token"
                pxu_state_save "core" "tg_chat_id" "$tg_chat"
                export PXU_TG_TOKEN="$tg_token"
                export PXU_TG_CHAT_ID="$tg_chat"
                lib_telegram_send_msg "✅ ProxyUltra Telegram integration linked successfully!"
                pxu_logger_success "Telegram Configured."
            fi
            
            if whiptail --yesno "Enable Daily CRON Auto-Backup?" 10 60; then
                pxu_engine_cron_backup
            fi
            ;;
        m)
            pxu_engine_setup_tdl
            ;;
        d)
            pxu_engine_doctor
            ;;
        b)
            lib_network_enable_bbr
            ;;
        0)
            pxu_logger_info "Exited gracefully."
            ;;
    esac
}
