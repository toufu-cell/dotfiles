#!/bin/bash
# 共通ユーティリティ関数

# JSON 文字列エスケープ（superpowers session-start から流用）
# bash parameter substitution で高速処理
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

# transcript_path の親ディレクトリ名から project slug を生成
# 例: /Users/k23062kk/.claude/projects/-Users-k23062kk-dotfiles/abc.jsonl → -Users-k23062kk-dotfiles
get_project_slug() {
    local transcript_path="$1"
    # transcript_path: ~/.claude/projects/<slug>/<session-id>.jsonl
    # 親を1段上がって slug を取得
    basename "$(dirname "$transcript_path")"
}

# session-store のベースディレクトリ
SESSION_STORE_DIR="${HOME}/.claude/session-store"
