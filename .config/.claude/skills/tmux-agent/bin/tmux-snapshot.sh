#!/usr/bin/env bash
# tmux-snapshot.sh — pane の出力を ANSI 除去してファイルに保存
# Usage: tmux-snapshot.sh [pane_index] [output_file]
# pane_index 省略時は /tmp/tmux-codex-pane.txt から自動読み取り
# stdout にもクリーニング済み出力を出力（tee）

PANE_FILE="/tmp/tmux-codex-pane.txt"
PANE="${1:-$(cat "$PANE_FILE" 2>/dev/null)}"
if [ -z "$PANE" ]; then
    echo "ERROR: pane index が不明です。先に tmux-pane-setup.sh を実行してください。" >&2
    exit 1
fi
OUTPUT_FILE=${2:-/tmp/tmux-before-snapshot.txt}

tmux capture-pane -t .$PANE -p -S -200 \
    | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
    | sed 's/\x1b\][^\x07]*\x07//g' \
    | sed 's/\r//g' \
    | sed '/^[[:space:]]*$/d' \
    | tee "$OUTPUT_FILE"
