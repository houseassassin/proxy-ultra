#!/usr/bin/env bash
# File: lib/lib_telegram.sh

lib_telegram_send_msg() {
    local text=$1
    local tg_token
    local tg_chat_id
    
    tg_token=${PXU_TG_TOKEN:-$(pxu_state_get "core" "tg_token")}
    tg_chat_id=${PXU_TG_CHAT_ID:-$(pxu_state_get "core" "tg_chat_id")}
    
    if [[ -z "$tg_token" || -z "$tg_chat_id" ]]; then
        return 0
    fi
    
    if command -v curl &>/dev/null; then
        local escaped_text="${text//\"/\\\"}"
        curl -s -X POST "https://api.telegram.org/bot${tg_token}/sendMessage" \
            -H "Content-Type: application/json" \
            -d "{\"chat_id\": \"${tg_chat_id}\", \"text\": \"${escaped_text}\", \"parse_mode\": \"Markdown\"}" >/dev/null
    fi
}

lib_telegram_send_document() {
    local file_path=$1
    local caption=${2:-"Backup Archive"}
    
    local tg_token=${PXU_TG_TOKEN:-$(pxu_state_get "core" "tg_token")}
    local tg_chat_id=${PXU_TG_CHAT_ID:-$(pxu_state_get "core" "tg_chat_id")}
    local use_mtproto=$(pxu_state_get "core" "use_mtproto")
    
    if [[ "$use_mtproto" == "true" ]] && command -v tdl &>/dev/null; then
        # Try TDL MTProto upload first for files > 50MB
        tdl up -p "${file_path}" -c "${tg_chat_id}" --caption "${caption}" >/dev/null 2>&1
        local exit_status=$?
        if [[ $exit_status -eq 0 ]]; then
            return 0
        fi
    fi
    
    if [[ -z "$tg_token" || -z "$tg_chat_id" ]]; then
        return 0
    fi
    
    if [[ -f "$file_path" ]] && command -v curl &>/dev/null; then
        curl -s -F chat_id="${tg_chat_id}" \
             -F document=@"${file_path}" \
             -F caption="${caption}" \
             "https://api.telegram.org/bot${tg_token}/sendDocument" >/dev/null
    fi
}
