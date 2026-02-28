#!/usr/bin/env bash
# tmux-codex-recover.sh — codex のクラッシュ検出とリカバリー
# Usage: tmux-codex-recover.sh [pane_index]
# pane_index 省略時は /tmp/tmux-codex-pane.txt から自動読み取り
# 正常動作中ならそのまま pane index を返す
# クラッシュ検出時は pane を再作成して新しい pane index を返す
# Exit codes: 0=正常/リカバリー成功, 1=失敗

PANE_FILE="/tmp/tmux-codex-pane.txt"
PANE="${1:-$(cat "$PANE_FILE" 2>/dev/null)}"
if [ -z "$PANE" ]; then
    echo "ERROR: pane index が不明です。先に tmux-pane-setup.sh を実行してください。" >&2
    rm -f "$PANE_FILE"
    exit 1
fi

# クラッシュ検出
PANE_PID=$(tmux list-panes -F '#{pane_index}|#{pane_pid}' | grep "^${PANE}|" | cut -d'|' -f2)

if [ -n "$PANE_PID" ] && pgrep -P "$PANE_PID" -f "codex" > /dev/null 2>&1; then
    echo "codex は正常に動作中 (pane $PANE)" >&2
    echo "$PANE" | tee "$PANE_FILE"
    exit 0
fi

# リカバリー
echo "codex クラッシュ検出。リカバリー中..." >&2
tmux kill-pane -t .$PANE 2>/dev/null

if ! tmux split-window -h -p 40 -c "$(pwd)" 2>/dev/null; then
    echo "ERROR: tmux split-window に失敗しました" >&2
    rm -f "$PANE_FILE"
    exit 1
fi
NEW_PANE=$(tmux list-panes -F '#{pane_index}' | tail -1)
if [ -z "$NEW_PANE" ]; then
    echo "ERROR: pane index の取得に失敗しました" >&2
    rm -f "$PANE_FILE"
    exit 1
fi

tmux send-keys -t .$NEW_PANE "codex --no-alt-screen --full-auto" Enter
echo "codex を再起動中 (pane $NEW_PANE)..." >&2
sleep 5

echo "$NEW_PANE" | tee "$PANE_FILE"
