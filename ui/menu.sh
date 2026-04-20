#!/usr/bin/env bash
# File: ui/menu.sh

# UI Helpers
pxu_ui_header() {
    clear
    echo -e "\033[1;38;5;45m╔══════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;38;5;45m║\033[0m   \033[1;38;5;15mProxyUltra CLI Framework - Developed by Houseassassin\033[0m \033[1;38;5;45m║\033[0m"
    echo -e "\033[1;38;5;45m╚══════════════════════════════════════════════════════════╝\033[0m"
    echo ""
}

pxu_ui_menu_item() {
    local key=$1
    local desc=$2
    echo -e "  \033[1;38;5;45m[\033[1;38;5;15m${key}\033[1;38;5;45m]\033[0m ${desc}"
}

pxu_ui_ask() {
    local prompt=$1
    local default=$2
    local result
    echo -ne "\033[1;38;5;45m»\033[0m ${prompt} \033[38;5;240m[${default}]\033[0m: "
    read -r result
    echo "${result:-$default}"
}

ui_main_menu() {
    while true; do
        pxu_ui_header
        echo -e "\033[1;38;5;15mAvailable Components:\033[0m"
        echo "────────────────────────────────────────────────────────────"
        pxu_ui_menu_item "1" "Install Remnawave Panel"
        pxu_ui_menu_item "2" "Install RemnaNode Bridge"
        pxu_ui_menu_item "3" "Install 3x-ui Panel"
        pxu_ui_menu_item "4" "Install Marzban Panel"
        pxu_ui_menu_item "5" "Install 3DP-Manager (GUI for 3x-ui)"
        echo "────────────────────────────────────────────────────────────"
        pxu_ui_menu_item "w" "Install Wireguard VPN (wg-easy)"
        pxu_ui_menu_item "n" "Install Netbird VPN Node"
        pxu_ui_menu_item "s" "Install Selfsteal (Anti-DPI) Proxy"
        pxu_ui_menu_item "p" "Install Telegram MTProxy Node"
        pxu_ui_menu_item "c" "Install Cloudflare WARP SOCKS5"
        echo "────────────────────────────────────────────────────────────"
        pxu_ui_menu_item "f" "Enable Fail2Ban (Anti-DDoS Shield)"
        pxu_ui_menu_item "b" "Enable TCP BBR Tuning"
        pxu_ui_menu_item "t" "Configure Telegram Alerts & MTProto"
        pxu_ui_menu_item "d" "System Diagnostics (Doctor)"
        pxu_ui_menu_item "0" "Exit"
        echo "────────────────────────────────────────────────────────────"
        echo ""
        
        local choice
        echo -ne "\033[1;38;5;45mSelect option »\033[0m "
        read -r choice

        case $choice in
            1)
                export PXU_DOMAIN=$(pxu_ui_ask "Enter domain for Remnawave (or IP)" "example.com")
                pxu_engine_install "remnawave"
                ;;
            2)
                export PXU_REMNANODE_API_URL=$(pxu_ui_ask "Enter Remnawave API URL" "http://x.x.x.x:3000")
                export PXU_REMNANODE_KEY=$(pxu_ui_ask "Enter RemnaNode Secret Key" "secret")
                pxu_engine_install "remnanode"
                ;;
            3)
                pxu_engine_install "3x-ui"
                ;;
            4)
                export PXU_DOMAIN=$(pxu_ui_ask "Enter domain for Marzban" "example.com")
                pxu_engine_install "marzban"
                ;;
            5)
                export PXU_DOMAIN=$(pxu_ui_ask "Enter domain for 3DP Manager (optional)" "")
                pxu_engine_install "3dpmanager"
                ;;
            w)
                export PXU_DOMAIN=$(pxu_ui_ask "Enter Domain/IP for Wireguard Endpoint" "$(curl -s https://api.ipify.org)")
                pxu_engine_install "wireguard"
                ;;
            n)
                export PXU_NETBIRD_SETUP_KEY=$(pxu_ui_ask "Enter Netbird Setup Key" "")
                pxu_engine_install "netbird"
                ;;
            s)
                pxu_engine_install "selfsteal"
                ;;
            p)
                pxu_engine_install "mtproxy"
                ;;
            c)
                pxu_engine_install "warp"
                ;;
            f)
                pxu_engine_install "fail2ban"
                ;;
            b)
                lib_network_enable_bbr
                ;;
            t)
                local tg_token=$(pxu_ui_ask "Enter Telegram Bot Token" "")
                local tg_chat=$(pxu_ui_ask "Enter Telegram Chat ID" "")
                
                if [[ -n "$tg_token" && -n "$tg_chat" ]]; then
                    pxu_state_save "core" "tg_token" "$tg_token"
                    pxu_state_save "core" "tg_chat_id" "$tg_chat"
                    export PXU_TG_TOKEN="$tg_token"
                    export PXU_TG_CHAT_ID="$tg_chat"
                    lib_telegram_send_msg "✅ ProxyUltra CLI Telegram integration active!"
                fi
                
                echo -ne "Enable Daily CRON Auto-Backup? (y/n): "
                read -r cron_choice
                if [[ "$cron_choice" == "y" ]]; then pxu_engine_cron_backup; fi
                
                echo -ne "Setup High-Speed MTProto (TDL)? (y/n): "
                read -r tdl_choice
                if [[ "$tdl_choice" == "y" ]]; then pxu_engine_setup_tdl; fi
                ;;
            d)
                pxu_engine_doctor
                ;;
            0)
                pxu_logger_info "Exiting ProxyUltra CLI. Goodbye!"
                exit 0
                ;;
            *)
                pxu_logger_error "Invalid option '$choice'"
                sleep 1
                ;;
        esac
        echo -ne "\nPress Enter to return to menu..."
        read -r
    done
}
