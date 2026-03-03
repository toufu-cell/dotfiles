#!/usr/bin/env bash
# codex-review-init.sh — セッション開始時にレビューモード（tmux / exec）を判定
# モードファイル: /tmp/codex-review-mode-${PPID}.txt（セッション固有）

set -euo pipefail

MODE_FILE="/tmp/codex-review-mode-${PPID}.txt"

# codex コマンドの存在確認
if ! command -v codex >/dev/null 2>&1; then
    echo "ERROR: codex コマンドが見つかりません" >&2
    exit 1
fi

# tmux 利用可否の二段階判定
# 1. $TMUX 環境変数が設定されている
# 2. tmux list-panes が成功する（実際に tmux が動作中）
if [ -n "${TMUX:-}" ] && tmux list-panes >/dev/null 2>&1; then
    MODE="tmux"
else
    MODE="exec"
fi

# モードファイルに書き込み
echo "$MODE" > "$MODE_FILE"

# stdout にモードを出力
echo "$MODE"
