#!/usr/bin/env bash
# tmux-detect-codex.sh — codex が動作している pane を検出して pane index を stdout + ファイルに出力
# Exit codes: 0=検出成功, 1=tmux外, 2=codex未検出
# 検出成功時は /tmp/tmux-codex-pane.txt にも書き出す（プロセス間共有用）

PANE_FILE="/tmp/tmux-codex-pane.txt"

if [ -z "$TMUX" ]; then
    echo "ERROR: tmux セッション外です" >&2
    exit 1
fi

CODEX_PANE=""
while IFS='|' read -r idx pid cmd; do
    if pgrep -P "$pid" -f "codex" > /dev/null 2>&1; then
        CODEX_PANE=$idx
        break
    fi
done < <(tmux list-panes -F '#{pane_index}|#{pane_pid}|#{pane_current_command}')

if [ -z "$CODEX_PANE" ]; then
    echo "codex pane が見つかりません" >&2
    exit 2
fi

echo "$CODEX_PANE" | tee "$PANE_FILE"
