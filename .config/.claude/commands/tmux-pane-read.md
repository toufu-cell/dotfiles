---
description: tmux pane からの出力キャプチャ
allowed-tools: Bash
---

# tmux Pane 読み取り

codex pane の出力をキャプチャし、クリーニングして返す。
ポーリングで完了を待機した後、差分を抽出する。

## 手順

### 1. 環境確認と pane 検出

```bash
if [ -z "$TMUX" ]; then
    echo "ERROR: tmux セッション外です"
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
    echo "ERROR: codex pane が見つかりません"
    exit 1
fi
```

### 2. 完了待機ポーリング

```bash
MAX_TIMEOUT=120
ELAPSED=0
PREV_OUTPUT=""
STABLE_COUNT=0

echo "出力の完了を待機中..."

# 初回は少し長めに待機（codex が処理を開始するまでの猶予）
sleep 5
ELAPSED=5

while [ $ELAPSED -lt $MAX_TIMEOUT ]; do
    CURRENT=$(tmux capture-pane -t .$CODEX_PANE -p -S -200 | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')

    # 第1層: "Working" が含まれていたら処理中 → 待機継続
    if echo "$CURRENT" | grep -q "Working"; then
        sleep 3
        ELAPSED=$((ELAPSED + 3))
        STABLE_COUNT=0
        PREV_OUTPUT="$CURRENT"
        continue
    fi

    # "Working" がなく "context left" があれば完了
    LAST_LINES=$(echo "$CURRENT" | grep -v '^$' | tail -3)
    if echo "$LAST_LINES" | grep -q "context left"; then
        BEFORE_LINES=$(wc -l < /tmp/tmux-before-snapshot.txt 2>/dev/null | tr -d ' ' || echo 0)
        AFTER_LINES=$(echo "$CURRENT" | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')
        if [ "$AFTER_LINES" -gt "$BEFORE_LINES" ]; then
            echo "完了検出 (${ELAPSED}秒)"
            break
        fi
    fi

    # 第2層: 出力安定化
    if [ "$CURRENT" = "$PREV_OUTPUT" ]; then
        STABLE_COUNT=$((STABLE_COUNT + 1))
        if [ $STABLE_COUNT -ge 3 ]; then
            echo "出力安定化 — 完了 (${ELAPSED}秒)"
            break
        fi
    else
        STABLE_COUNT=0
    fi

    PREV_OUTPUT="$CURRENT"
    sleep 3
    ELAPSED=$((ELAPSED + 3))
done

if [ $ELAPSED -ge $MAX_TIMEOUT ]; then
    echo "WARNING: タイムアウト (${MAX_TIMEOUT}秒). 現在の出力を返します。"
fi
```

### 3. 出力キャプチャ・クリーニング

```bash
AFTER_SNAPSHOT="/tmp/tmux-after-snapshot.txt"
tmux capture-pane -t .$CODEX_PANE -p -S -200 \
    | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
    | sed 's/\x1b\][^\x07]*\x07//g' \
    | sed 's/\r//g' \
    | sed '/^[[:space:]]*$/d' \
    > "$AFTER_SNAPSHOT"
```

### 4. 出力取得

```bash
# capture-pane の全出力を返す
# Claude Code 側で送信プロンプトと "•" で始まる応答行を識別する
echo "=== Codex pane の出力 ==="
cat "$AFTER_SNAPSHOT"
```

## 注意事項

- `/tmux-pane-send` と組み合わせて使用する
- capture-pane の全出力を返し、Claude Code が応答を識別する
- `•` で始まる行が codex の応答
- `›` で始まる行がユーザーの送信プロンプト
- タイムアウト時は部分的な出力になる可能性がある
