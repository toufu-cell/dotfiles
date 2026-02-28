#!/usr/bin/env bash
# tmux-send-enter.sh — pane ファイルを内部で読み、Enter キーを送信
# Usage: tmux-send-enter.sh
# Exit codes: 0=成功, 1=pane ファイル不正または送信失敗

PANE_FILE="/tmp/tmux-codex-pane.txt"

if [ ! -s "$PANE_FILE" ]; then
    echo "ERROR: pane ファイルが空または存在しません。先に tmux-pane-setup.sh を実行してください。" >&2
    exit 1
fi

PANE=$(cat "$PANE_FILE")
if [ -z "$PANE" ]; then
    echo "ERROR: pane index が空です" >&2
    exit 1
fi

tmux send-keys -t ."$PANE" Enter
