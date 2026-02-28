#!/bin/bash
set -euo pipefail

# jq が無い場合はフォールバック通知を出して終了
if ! command -v jq &>/dev/null; then
    osascript -e 'display notification "jq が見つかりません" with title "Claude Code" sound name "default"' 2>/dev/null
    exit 0
fi

INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name' 2>/dev/null) || exit 0

case "$EVENT" in
    "Notification")
        TYPE=$(echo "$INPUT" | jq -r '.notification_type' 2>/dev/null) || exit 0
        case "$TYPE" in
            "permission_prompt")
                TITLE="Claude Code - 承認待ち"
                MSG="パーミッションの承認が必要です"
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
        ;;
    *)
        exit 0
        ;;
esac

osascript -e "display notification \"$MSG\" with title \"$TITLE\" sound name \"default\""
exit 0
