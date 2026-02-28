#!/usr/bin/env bash
# tmux-pane-setup.sh — codex pane を検出、なければ作成して起動待機
# 最終的に pane index を stdout + /tmp/tmux-codex-pane.txt に出力
# Exit codes: 0=成功（タイムアウトでもpane作成済みなら0）, 1=tmux外

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PANE_FILE="/tmp/tmux-codex-pane.txt"

if [ -z "$TMUX" ]; then
    echo "ERROR: tmux セッション外です" >&2
    rm -f "$PANE_FILE"
    exit 1
fi

# 既存の codex pane を検出
CODEX_PANE=$("$SCRIPT_DIR/tmux-detect-codex.sh" 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$CODEX_PANE" ]; then
    echo "既存の codex pane を使用: pane $CODEX_PANE" >&2
    echo "$CODEX_PANE" | tee "$PANE_FILE"
    exit 0
fi

# なければ作成
echo "codex pane を作成します..." >&2
if ! tmux split-window -h -p 40 -c "$(pwd)" 2>/dev/null; then
    echo "ERROR: tmux split-window に失敗しました" >&2
    rm -f "$PANE_FILE"
    exit 1
fi
CODEX_PANE=$(tmux list-panes -F '#{pane_index}' | tail -1)
if [ -z "$CODEX_PANE" ]; then
    echo "ERROR: pane index の取得に失敗しました" >&2
    rm -f "$PANE_FILE"
    exit 1
fi
echo "pane $CODEX_PANE を作成しました" >&2

# codex を起動
tmux send-keys -t .$CODEX_PANE "codex --no-alt-screen --full-auto" Enter
echo "codex を起動中..." >&2

# 起動完了を待機
TIMEOUT=30
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
    OUTPUT=$(tmux capture-pane -t .$CODEX_PANE -p -S -10 2>/dev/null | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
    if echo "$OUTPUT" | grep -q "context left"; then
        echo "codex が起動しました" >&2
        echo "$CODEX_PANE" | tee "$PANE_FILE"
        exit 0
    fi
    sleep 2
    ELAPSED=$((ELAPSED + 2))
done

echo "WARNING: codex の起動確認がタイムアウトしました（pane $CODEX_PANE は作成済み）" >&2
echo "$CODEX_PANE" | tee "$PANE_FILE"
exit 0
