#!/usr/bin/env bash
# tmux-poll.sh — codex の出力完了をポーリングで待機し、結果を stdout に返す
# Usage: tmux-poll.sh [pane_index] [timeout] [before_snapshot_path]
# pane_index 省略時は /tmp/tmux-codex-pane.txt から自動読み取り
# ステータスメッセージは stderr、クリーニング済み出力は stdout
# Exit codes: 0=完了検出, 1=タイムアウト

PANE_FILE="/tmp/tmux-codex-pane.txt"
PANE="${1:-$(cat "$PANE_FILE" 2>/dev/null)}"
if [ -z "$PANE" ]; then
    echo "ERROR: pane index が不明です。先に tmux-pane-setup.sh を実行してください。" >&2
    exit 1
fi
TIMEOUT=${2:-120}
BEFORE_FILE=${3:-/tmp/tmux-before-snapshot.txt}

ELAPSED=0
PREV=""
STABLE=0

# 初回待機
sleep 5
ELAPSED=5

while [ $ELAPSED -lt $TIMEOUT ]; do
    CURRENT=$(tmux capture-pane -t .$PANE -p -S -200 2>/dev/null | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')

    # tmux 取得失敗チェック（空出力は安定化と誤判定しない）
    if [ -z "$(echo "$CURRENT" | sed '/^[[:space:]]*$/d')" ]; then
        STABLE=0
        PREV=""
        sleep 3
        ELAPSED=$((ELAPSED + 3))
        continue
    fi

    # 第1層: Working パターン検出 → 処理中
    if echo "$CURRENT" | grep -q "Working"; then
        sleep 3
        ELAPSED=$((ELAPSED + 3))
        STABLE=0
        PREV="$CURRENT"
        continue
    fi

    # "context left" 検出 + 行数比較で完了判定
    LAST_LINES=$(echo "$CURRENT" | grep -v '^$' | tail -3)
    if echo "$LAST_LINES" | grep -q "context left"; then
        BEFORE_LINES=$(wc -l < "$BEFORE_FILE" 2>/dev/null | tr -d ' ' || echo 0)
        AFTER_LINES=$(echo "$CURRENT" | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')
        if [ "$AFTER_LINES" -gt "$BEFORE_LINES" ]; then
            echo "[POLL] 完了検出 (${ELAPSED}秒)" >&2
            break
        fi
    fi

    # 第2層: 出力安定化検出
    if [ "$CURRENT" = "$PREV" ]; then
        STABLE=$((STABLE + 1))
        if [ $STABLE -ge 3 ]; then
            echo "[POLL] 安定化検出 (${ELAPSED}秒)" >&2
            break
        fi
    else
        STABLE=0
    fi

    PREV="$CURRENT"
    sleep 3
    ELAPSED=$((ELAPSED + 3))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "[POLL] タイムアウト (${TIMEOUT}秒)" >&2
fi

# 最終出力をクリーニングして stdout に
tmux capture-pane -t .$PANE -p -S -200 \
    | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
    | sed 's/\x1b\][^\x07]*\x07//g' \
    | sed 's/\r//g'

[ $ELAPSED -lt $TIMEOUT ] && exit 0 || exit 1
