#!/bin/bash
# PreCompact hook — compaction 前の状態を保存（保存のみ、stdout 出力なし）
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
    PROJECT_SLUG=$(basename "${CWD:-unknown}")
fi

# session-store ディレクトリを作成
STORE_DIR="${SESSION_STORE_DIR}/${PROJECT_SLUG}"
mkdir -p "$STORE_DIR"

SHORT_ID="${SESSION_ID:0:8}"
DATE_STR=$(date '+%Y-%m-%d')
TIME_STR=$(date '+%Y-%m-%d %H:%M:%S')
FILENAME="${DATE_STR}-${SHORT_ID}-session.md"
FILEPATH="${STORE_DIR}/${FILENAME}"

# git diff --stat の取得
GIT_STAT=""
if [ -n "$CWD" ] && [ -d "$CWD/.git" ]; then
    GIT_STAT=$(cd "$CWD" && git diff --stat HEAD 2>/dev/null || true)
fi

# compact マーカーを組み立て（ファイルに直接書き込み用）
build_marker() {
    echo "- [${TIME_STR}] compact"
    if [ -n "$GIT_STAT" ]; then
        echo '```'
        echo "$GIT_STAT"
        echo '```'
    fi
}

if [ -f "$FILEPATH" ]; then
    # 既存ファイルの末尾に compact マーカーを追記
    # Compact Log セクションが存在する前提（session-end.sh が作成）
    build_marker >> "$FILEPATH"
else
    # 新規作成（compact-only セッション — SessionEnd 前に compact が走った場合）
    {
        echo "## Session: $(basename "${CWD:-unknown}")"
        echo "### Date: ${TIME_STR}"
        echo "### Session ID: ${SESSION_ID}"
        echo "### CWD: ${CWD:-unknown}"
        echo "### Files Modified:"
        echo "(compact 時点 — SessionEnd で更新予定)"
        echo "### Compact Log:"
        build_marker
    } > "$FILEPATH"
fi

exit 0
