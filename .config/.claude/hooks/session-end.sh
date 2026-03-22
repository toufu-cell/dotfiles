#!/bin/bash
# SessionEnd hook — セッション終了時にサマリーを保存
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

# jq が無い場合は終了
command -v jq &>/dev/null || exit 0

INPUT=$(cat)

# stdin JSON から必要な情報を取得
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null) || exit 0
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null) || true
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null) || true

# session_id が取れなければ終了
[ -n "$SESSION_ID" ] || exit 0

# project slug を生成
if [ -n "$TRANSCRIPT_PATH" ]; then
    PROJECT_SLUG=$(get_project_slug "$TRANSCRIPT_PATH")
else
    # fallback: cwd の basename
    PROJECT_SLUG=$(basename "${CWD:-unknown}")
fi

# session-store ディレクトリを作成
STORE_DIR="${SESSION_STORE_DIR}/${PROJECT_SLUG}"
mkdir -p "$STORE_DIR"

# short-id を session_id の先頭8文字から生成
SHORT_ID="${SESSION_ID:0:8}"
DATE_STR=$(date '+%Y-%m-%d')
TIME_STR=$(date '+%Y-%m-%d %H:%M')
FILENAME="${DATE_STR}-${SHORT_ID}-session.md"
FILEPATH="${STORE_DIR}/${FILENAME}"

# 変更ファイルの取得（git リポジトリ内の場合）
FILES_MODIFIED=""
if [ -n "$CWD" ] && [ -d "${CWD}/.git" ] || [ -f "${CWD}/.git" ]; then
    FILES_MODIFIED=$(cd "$CWD" && git diff --name-only HEAD 2>/dev/null || true)
fi

# 会話サマリーの抽出（transcript 末尾200行から text block のみ、各500文字に truncate）
# 全体を 2000 文字に制限してコンテキスト肥大化を防止
CONVERSATION=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    CONVERSATION=$(tail -n 200 "$TRANSCRIPT_PATH" | jq -r '
        select(.type == "user" or .type == "assistant") |
        . as $msg |
        (.message.content // []) | if type == "array" then .[] else {type: "text", text: .} end |
        select(.type == "text") |
        .text // "" |
        .[0:500]
    ' 2>/dev/null | grep -v '^\[Request interrupted' | tail -20 || true)
    # 2000 文字に truncate
    if [ ${#CONVERSATION} -gt 2000 ]; then
        CONVERSATION="${CONVERSATION:0:2000}
...(truncated)"
    fi
fi

# Compact Log の保持（upsert: 既存ファイルから Compact Log を引き継ぐ）
COMPACT_LOG=""
if [ -f "$FILEPATH" ]; then
    COMPACT_LOG=$(sed -n '/^### Compact Log:/,/^### [^C]/{ /^### Compact Log:/d; /^### [^C]/d; p; }' "$FILEPATH" 2>/dev/null || true)
fi

# サマリーファイルを生成（upsert）
{
    echo "## Session: $(basename "${CWD:-unknown}")"
    echo "### Date: ${TIME_STR}"
    echo "### Session ID: ${SESSION_ID}"
    echo "### CWD: ${CWD:-unknown}"
    echo "### Transcript: ${TRANSCRIPT_PATH}"
    echo "### Files Modified:"
    if [ -n "$FILES_MODIFIED" ]; then
        echo "$FILES_MODIFIED" | while IFS= read -r f; do echo "- ${f}"; done
    else
        echo "(none)"
    fi
    echo "### Conversation Summary:"
    if [ -n "$CONVERSATION" ]; then
        echo "$CONVERSATION"
    else
        echo "(no conversation captured)"
    fi
    echo "### Compact Log:"
    if [ -n "$COMPACT_LOG" ]; then
        echo "$COMPACT_LOG"
    fi
} > "$FILEPATH"

# プロジェクトごと最大5ファイルに制限（古い順に削除）+ 30日超も削除
{
    # 30日超の古いファイルを削除
    find "$STORE_DIR" -name "*-session.md" -mtime +30 -delete 2>/dev/null || true
    # ファイル数が5を超える場合、古い順に削除
    FILE_COUNT=$(ls -1 "$STORE_DIR"/*-session.md 2>/dev/null | wc -l)
    if [ "$FILE_COUNT" -gt 5 ]; then
        ls -t "$STORE_DIR"/*-session.md 2>/dev/null | tail -n +"6" | xargs rm -f 2>/dev/null || true
    fi
} & disown

exit 0
