#!/bin/bash
set -euo pipefail

# jq が無い場合はフォールバック通知を出して終了
if ! command -v jq &>/dev/null; then
    osascript -e 'display notification "jq が見つかりません" with title "Claude Code" sound name "default"' 2>/dev/null
    exit 0
fi

INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name' 2>/dev/null) || exit 0

# --- ntfy.sh configuration ---

NTFY_TOPIC=""
NTFY_SERVER="https://ntfy.sh"
NTFY_ENABLED=true
NTFY_TOKEN=""

load_ntfy_config() {
    local conf_file="${HOME}/.claude/hooks/ntfy.conf"
    [ -f "$conf_file" ] || return 0

    local allowed_keys="NTFY_TOPIC NTFY_SERVER NTFY_ENABLED NTFY_TOKEN"
    while IFS='=' read -r key value; do
        # skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue

        # trim whitespace
        key=$(echo "$key" | tr -d '[:space:]')
        # 1. trim leading/trailing whitespace
        value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        # 2. extract quoted value or strip inline comment for unquoted value
        if [[ "$value" =~ ^\"([^\"]*)\" ]] || [[ "$value" =~ ^\'([^\']*)\' ]]; then
            value="${BASH_REMATCH[1]}"
        else
            # unquoted: strip inline comment
            value=$(echo "$value" | sed 's/[[:space:]][[:space:]]*#.*$//')
        fi

        # whitelist check
        local is_allowed=false
        for allowed in $allowed_keys; do
            if [ "$key" = "$allowed" ]; then
                is_allowed=true
                break
            fi
        done
        $is_allowed || continue

        # assign
        case "$key" in
            NTFY_TOPIC)   NTFY_TOPIC="$value" ;;
            NTFY_SERVER)  NTFY_SERVER="$value" ;;
            NTFY_ENABLED) NTFY_ENABLED="$value" ;;
            NTFY_TOKEN)   NTFY_TOKEN="$value" ;;
        esac
    done < "$conf_file"

    # environment variable overrides
    NTFY_TOPIC="${NTFY_TOPIC_ENV:-$NTFY_TOPIC}"
    NTFY_SERVER="${NTFY_SERVER_ENV:-$NTFY_SERVER}"
    NTFY_ENABLED="${NTFY_ENABLED_ENV:-$NTFY_ENABLED}"
    NTFY_TOKEN="${NTFY_TOKEN_ENV:-$NTFY_TOKEN}"

    # macOS Keychain fallback for token
    if [ -z "$NTFY_TOKEN" ] && command -v security &>/dev/null; then
        NTFY_TOKEN=$(security find-generic-password -s "ntfy" -a "token" -w 2>/dev/null || true)
    fi
}

send_ntfy() {
    local title="$1"
    local message="$2"
    local priority="${3:-default}"
    local tags="${4:-}"

    [ "$NTFY_ENABLED" = "true" ] || return 0
    [ -n "$NTFY_TOPIC" ] || return 0

    local log_file="/tmp/ntfy-errors.log"

    (
        local curl_args=(
            -s -o /dev/null -w "%{http_code}"
            --max-time 5
            -d "$message"
            -H "Title: $title"
            -H "Priority: $priority"
        )
        [ -n "$tags" ] && curl_args+=(-H "Tags: $tags")
        [ -n "$NTFY_TOKEN" ] && curl_args+=(-H "Authorization: Bearer $NTFY_TOKEN")

        local http_code
        http_code=$(curl "${curl_args[@]}" "${NTFY_SERVER}/${NTFY_TOPIC}" 2>/dev/null) || http_code="error"

        if [ "$http_code" != "200" ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') ntfy send failed (status: $http_code)" >> "$log_file"
            # rotate log: keep last 100 lines
            if [ -f "$log_file" ]; then
                tail -n 100 "$log_file" > "${log_file}.tmp" && mv "${log_file}.tmp" "$log_file"
            fi
        fi
    ) & disown
}

# --- main ---

load_ntfy_config

DIRNAME=$(basename "${PWD:-unknown}")
PUSH_NTFY=false

case "$EVENT" in
    "Notification")
        TYPE=$(echo "$INPUT" | jq -r '.notification_type' 2>/dev/null) || exit 0
        case "$TYPE" in
            "permission_prompt")
                TITLE="Claude Code - 承認待ち"
                MSG="パーミッションの承認が必要です"
                PUSH_NTFY=true
                NTFY_PRIORITY="high"
                NTFY_TAGS="lock"
                ;;
            "elicitation_dialog")
                TITLE="Claude Code - 質問"
                MSG="質問への回答が必要です"
                PUSH_NTFY=true
                NTFY_PRIORITY="default"
                NTFY_TAGS="speech_balloon"
                ;;
            "idle_prompt")
                TITLE="Claude Code - 入力待ち"
                MSG="入力を待っています"
                ;;
            *)
                exit 0
                ;;
        esac
        ;;
    "Stop")
        TITLE="Claude Code - 完了"
        MSG="応答が完了しました"
        PUSH_NTFY=true
        NTFY_PRIORITY="default"
        NTFY_TAGS="checkered_flag"
        ;;
    *)
        exit 0
        ;;
esac

# macOS desktop notification (always)
osascript -e "display notification \"$MSG\" with title \"$TITLE\" sound name \"default\""

# ntfy.sh push notification (permission_prompt / elicitation_dialog only)
if [ "$PUSH_NTFY" = "true" ]; then
    send_ntfy "${TITLE} [${DIRNAME}]" "$MSG" "${NTFY_PRIORITY:-default}" "${NTFY_TAGS:-}"
fi

exit 0
