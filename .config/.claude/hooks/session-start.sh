#!/bin/bash
# SessionStart hook — 前回セッション情報 + learned パターンを注入
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

# jq が無い場合は空 JSON を返す
if ! command -v jq &>/dev/null; then
    echo '{}'
    exit 0
fi

INPUT=$(cat)

# stdin JSON から情報を取得
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null) || true
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null) || true
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null) || true
SOURCE=$(echo "$INPUT" | jq -r '.source // "startup"' 2>/dev/null) || true

# project slug を生成
if [ -n "$TRANSCRIPT_PATH" ]; then
    PROJECT_SLUG=$(get_project_slug "$TRANSCRIPT_PATH")
else
    PROJECT_SLUG=$(basename "${CWD:-unknown}")
fi

STORE_DIR="${SESSION_STORE_DIR}/${PROJECT_SLUG}"

# セッションサマリーの検索
SUMMARY_CONTENT=""
if [ -d "$STORE_DIR" ]; then
    case "$SOURCE" in
        resume|compact)
            # 現在の session_id でファイルを検索
            if [ -n "$SESSION_ID" ]; then
                SHORT_ID="${SESSION_ID:0:8}"
                MATCH=$(find "$STORE_DIR" -name "*-${SHORT_ID}-session.md" -type f 2>/dev/null | head -1)
                if [ -n "$MATCH" ] && [ -f "$MATCH" ]; then
                    SUMMARY_CONTENT=$(cat "$MATCH")
                fi
            fi
            # fallback: 最新ファイル
            if [ -z "$SUMMARY_CONTENT" ]; then
                LATEST=$(ls -t "$STORE_DIR"/*-session.md 2>/dev/null | head -1)
                if [ -n "$LATEST" ] && [ -f "$LATEST" ]; then
                    SUMMARY_CONTENT=$(cat "$LATEST")
                fi
            fi
            ;;
        *)
            # startup: project 内の最新サマリー
            LATEST=$(ls -t "$STORE_DIR"/*-session.md 2>/dev/null | head -1)
            if [ -n "$LATEST" ] && [ -f "$LATEST" ]; then
                SUMMARY_CONTENT=$(cat "$LATEST")
            fi
            ;;
    esac
fi

# learned パターンの収集（最新10件、name + description のみ）
LEARNED_CONTENT=""
LEARNED_DIR="${HOME}/.claude/skills/learned"
if [ -d "$LEARNED_DIR" ]; then
    LEARNED_LIST=""
    COUNT=0
    for f in $(ls -t "$LEARNED_DIR"/*.md 2>/dev/null); do
        [ "$COUNT" -ge 10 ] && break
        NAME=$(sed -n 's/^name: *//p' "$f" 2>/dev/null | head -1)
        DESC=$(sed -n 's/^description: *//p' "$f" 2>/dev/null | head -1)
        # 引用符を除去
        NAME="${NAME#\"}" ; NAME="${NAME%\"}"
        DESC="${DESC#\"}" ; DESC="${DESC%\"}"
        if [ -n "$NAME" ]; then
            LEARNED_LIST="${LEARNED_LIST}
- ${NAME}: ${DESC}"
            COUNT=$((COUNT + 1))
        fi
    done
    if [ -n "$LEARNED_LIST" ]; then
        LEARNED_CONTENT="
## Learned Patterns${LEARNED_LIST}"
    fi
fi

# コンテキストを raw text で組み立て、最後に1回だけ escape_for_json する
# これにより escape 後の truncate による JSON 破損を防止する

POLICY="<previous-session-policy>
If the user asks about the previous session, what was done, or anything they asked to remember, FIRST inspect the Previous Session section below.
Use auto memory only if the requested fact is missing from Previous Session.
When answering from Previous Session, state that explicitly.
</previous-session-policy>"

# サマリーから Compact Log を直近3エントリに制限（末尾3件を保持）
if [ -n "$SUMMARY_CONTENT" ]; then
    BEFORE_COMPACT=$(echo "$SUMMARY_CONTENT" | sed -n '1,/^### Compact Log:/p' 2>/dev/null || echo "$SUMMARY_CONTENT")
    COMPACT_ENTRIES=$(echo "$SUMMARY_CONTENT" | sed -n '/^### Compact Log:/,$ { /^### Compact Log:/d; p; }' 2>/dev/null || true)
    if [ -n "$COMPACT_ENTRIES" ]; then
        # 末尾3エントリを保持（"- [" で始まる行がエントリ区切り）
        TRIMMED_COMPACT=$(echo "$COMPACT_ENTRIES" | awk '
            /^- \[/ { entry_count++ }
            { lines[NR] = $0; entry_line[NR] = entry_count }
            END {
                start = (entry_count > 3) ? entry_count - 2 : 1
                for (i = 1; i <= NR; i++) if (entry_line[i] >= start) print lines[i]
            }
        ')
        SUMMARY_CONTENT="${BEFORE_COMPACT}
${TRIMMED_COMPACT}"
    fi
    # サマリーを 1500 文字に制限（raw text 段階で切るので JSON 安全）
    if [ ${#SUMMARY_CONTENT} -gt 1500 ]; then
        SUMMARY_CONTENT="${SUMMARY_CONTENT:0:1500}
...(truncated)"
    fi
fi

# raw text で CONTEXT 全体を組み立て
RAW_CONTEXT=""
if [ -n "$SUMMARY_CONTENT" ]; then
    RAW_CONTEXT="${POLICY}

## Previous Session
${SUMMARY_CONTENT}"
fi
if [ -n "$LEARNED_CONTENT" ]; then
    RAW_CONTEXT="${RAW_CONTEXT}${LEARNED_CONTENT}"
fi

# 何も注入するものがなければ空 JSON
if [ -z "$RAW_CONTEXT" ]; then
    echo '{}'
    exit 0
fi

# raw CONTEXT 全体に最終上限（2000文字）を適用してから escape
if [ ${#RAW_CONTEXT} -gt 2000 ]; then
    RAW_CONTEXT="${RAW_CONTEXT:0:2000}
...(truncated)"
fi

# 最後に1回だけ escape_for_json を実行（JSON 破損を防止）
ESCAPED_CONTEXT=$(escape_for_json "$RAW_CONTEXT")

# additionalContext として出力
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${ESCAPED_CONTEXT}"
  }
}
EOF

exit 0
