---
description: Codex CLI への質問（セットアップ→送信→待機→回収の統合コマンド）
allowed-tools: Bash
---

# tmux Codex Ask

Codex CLI にプロンプトを送信し、応答を回収する統合コマンド。
**常に対話モード（tmux pane 経由）を使用する。`codex exec` は使用禁止。**

## 引数

- `$ARGUMENTS` — Codex に送信するプロンプト

## 手順

### 1. セットアップ確認

```bash
if [ -z "$TMUX" ]; then
    echo "ERROR: tmux セッション外です。tmux 内で実行してください。"
    exit 1
fi

# codex pane を検出
CODEX_PANE=""
while IFS='|' read -r idx pid cmd; do
    if pgrep -P "$pid" -f "codex" > /dev/null 2>&1; then
        CODEX_PANE=$idx
        break
    fi
done < <(tmux list-panes -F '#{pane_index}|#{pane_pid}|#{pane_current_command}')

# pane がなければ作成
if [ -z "$CODEX_PANE" ]; then
    echo "codex pane を作成します..."
    tmux split-window -h -p 40 -c "$(pwd)"
    CODEX_PANE=$(tmux list-panes -F '#{pane_index}' | tail -1)
    tmux send-keys -t .$CODEX_PANE "codex --no-alt-screen --full-auto" Enter

    # 起動待機
    TIMEOUT=30
    ELAPSED=0
    while [ $ELAPSED -lt $TIMEOUT ]; do
        OUTPUT=$(tmux capture-pane -t .$CODEX_PANE -p -S -10 2>/dev/null | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
        if echo "$OUTPUT" | grep -q "context left"; then
            break
        fi
        sleep 2
        ELAPSED=$((ELAPSED + 2))
    done
fi

echo "codex pane: $CODEX_PANE"
```

### 2. 送信前スナップショット

```bash
BEFORE="/tmp/tmux-before-snapshot.txt"
tmux capture-pane -t .$CODEX_PANE -p -S -200 \
    | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
    | sed '/^[[:space:]]*$/d' \
    > "$BEFORE"
```

### 3. プロンプト送信（2つの Bash 呼び出しに分ける）

**重要: テキスト入力と Enter 送信は必ず別々の Bash ツール呼び出しで実行すること。**

```bash
# Bash 呼び出し1: テキスト入力
PROMPT="$ARGUMENTS"
echo "送信: $PROMPT"
tmux send-keys -t .$CODEX_PANE -l "$PROMPT"
echo "テキスト入力完了 — 次に Enter を別の Bash 呼び出しで送信すること！"
```

```bash
# Bash 呼び出し2: Enter で送信確定
tmux send-keys -t .$CODEX_PANE Enter
echo "送信完了"
```

### 4. 完了待機

```bash
MAX_TIMEOUT=120
PREV=""
STABLE=0

# 初回は少し長めに待機（codex が処理を開始するまでの猶予）
sleep 5
ELAPSED=5

while [ $ELAPSED -lt $MAX_TIMEOUT ]; do
    CURRENT=$(tmux capture-pane -t .$CODEX_PANE -p -S -200 | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')

    # "Working" が含まれていたら処理中 → 待機継続
    if echo "$CURRENT" | grep -q "Working"; then
        sleep 3
        ELAPSED=$((ELAPSED + 3))
        STABLE=0
        PREV="$CURRENT"
        continue
    fi

    # "Working" がなく "context left" があれば完了
    LAST_LINES=$(echo "$CURRENT" | grep -v '^$' | tail -3)
    if echo "$LAST_LINES" | grep -q "context left"; then
        BEFORE_LINES=$(wc -l < "$BEFORE" 2>/dev/null | tr -d ' ' || echo 0)
        AFTER_LINES=$(echo "$CURRENT" | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')
        if [ "$AFTER_LINES" -gt "$BEFORE_LINES" ]; then
            echo "完了検出 (${ELAPSED}秒)"
            break
        fi
    fi

    # 第2層: 出力安定化
    if [ "$CURRENT" = "$PREV" ]; then
        STABLE=$((STABLE + 1))
        [ $STABLE -ge 3 ] && echo "安定化検出 (${ELAPSED}秒)" && break
    else
        STABLE=0
    fi

    PREV="$CURRENT"
    sleep 3
    ELAPSED=$((ELAPSED + 3))
done
```

### 5. 出力回収

```bash
# capture-pane の全出力を返す
# Claude Code が送信プロンプト（› で始まる行）と応答（• で始まる行）を識別する
echo ""
echo "=== Codex pane の出力 ==="
tmux capture-pane -t .$CODEX_PANE -p -S -200 \
    | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
    | sed 's/\x1b\][^\x07]*\x07//g'
```

## 使用例

```
/tmux-codex-ask このコードの設計方針をレビューしてください

# 追加ラウンドは /tmux-pane-send + /tmux-pane-read を使う
```
