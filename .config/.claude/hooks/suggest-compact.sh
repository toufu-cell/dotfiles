#!/bin/bash
# PostToolUse hook — ツール使用回数をカウントし compact を提案
# 軽量実装: jq 1回、テキストカウンター、条件不成立時は即 exit
set -euo pipefail

# jq が無い場合は終了
command -v jq &>/dev/null || exit 0

# stdin から tool_name と session_id を1回で取得
INPUT=$(cat)
eval "$(echo "$INPUT" | jq -r '@sh "TOOL_NAME=\(.tool_name // empty)", @sh "SESSION_ID=\(.session_id // empty)"' 2>/dev/null)" || exit 0

[ -n "$SESSION_ID" ] || exit 0

# カウンターファイル
COUNTER_FILE="/tmp/claude-compact-count-${SESSION_ID}.txt"

# 現在のカウンターを読み込み（なければ初期値）
if [ -f "$COUNTER_FILE" ]; then
    read -r TOTAL MUTATE LAST_SUGGEST < "$COUNTER_FILE" 2>/dev/null || { TOTAL=0; MUTATE=0; LAST_SUGGEST=0; }
else
    TOTAL=0
    MUTATE=0
    LAST_SUGGEST=0
fi

# ツール判定
TOTAL=$((TOTAL + 1))
case "$TOOL_NAME" in
    Edit|Write|NotebookEdit)
        MUTATE=$((MUTATE + 1))
        ;;
esac

# 提案条件チェック
SHOULD_SUGGEST=false
if [ "$LAST_SUGGEST" -eq 0 ] && [ "$MUTATE" -ge 20 ]; then
    SHOULD_SUGGEST=true
elif [ "$LAST_SUGGEST" -gt 0 ] && [ $((MUTATE - LAST_SUGGEST)) -ge 12 ]; then
    SHOULD_SUGGEST=true
fi

# カウンター更新
if [ "$SHOULD_SUGGEST" = true ]; then
    LAST_SUGGEST=$MUTATE
fi
echo "$TOTAL $MUTATE $LAST_SUGGEST" > "$COUNTER_FILE"

# 提案メッセージ出力
if [ "$SHOULD_SUGGEST" = true ]; then
    MSG="[suggest-compact] ツール使用回数が多くなっています（mutate: ${MUTATE}, total: ${TOTAL}）。コンテキストが肥大化している可能性があります。/compact を検討してください。"
    cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "${MSG}"
  }
}
EOF
fi

exit 0
