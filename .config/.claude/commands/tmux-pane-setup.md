---
description: tmux pane セットアップ / codex 検出・起動
allowed-tools: Bash
---

# tmux Pane セットアップ

tmux 環境を確認し、Codex CLI が動作する pane を検出または作成する。

## 手順

### 1. tmux セッション確認

```bash
if [ -z "$TMUX" ]; then
    echo "ERROR: tmux セッション外で実行されています。tmux 内で Claude Code を起動してください。"
    exit 1
fi
echo "tmux セッション内で動作中"
```

### 2. 既存 pane の確認と codex 検出

```bash
echo "=== pane 一覧 ==="
tmux list-panes -F '#{pane_index}|#{pane_pid}|#{pane_current_command}'

echo ""
echo "=== codex pane 検索 ==="
CODEX_PANE=""
while IFS='|' read -r idx pid cmd; do
    if pgrep -P "$pid" -f "codex" > /dev/null 2>&1; then
        CODEX_PANE=$idx
        echo "codex が pane $idx で動作中 (parent PID: $pid)"
        break
    fi
done < <(tmux list-panes -F '#{pane_index}|#{pane_pid}|#{pane_current_command}')

if [ -n "$CODEX_PANE" ]; then
    echo "既存の codex pane を使用: pane $CODEX_PANE"
else
    echo "codex pane が見つかりません。新規作成します。"
fi
```

### 3. codex pane がない場合は作成

```bash
if [ -z "$CODEX_PANE" ]; then
    # 右側に40%幅で新規 pane を作成
    tmux split-window -h -p 40 -c "#{pane_current_path}"
    CODEX_PANE=$(tmux list-panes -F '#{pane_index}' | tail -1)

    echo "pane $CODEX_PANE を作成しました"

    # codex を起動
    tmux send-keys -t .$CODEX_PANE "codex --no-alt-screen --full-auto" Enter
    echo "codex を起動中..."

    # 起動完了を待機
    TIMEOUT=30
    ELAPSED=0
    while [ $ELAPSED -lt $TIMEOUT ]; do
        OUTPUT=$(tmux capture-pane -t .$CODEX_PANE -p -S -10 2>/dev/null | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
        if echo "$OUTPUT" | grep -qE '(^>|^❯|codex>)'; then
            echo "codex が起動しました (pane $CODEX_PANE)"
            break
        fi
        sleep 2
        ELAPSED=$((ELAPSED + 2))
    done

    if [ $ELAPSED -ge $TIMEOUT ]; then
        echo "WARNING: codex の起動確認がタイムアウトしました。pane $CODEX_PANE の状態を確認してください。"
    fi
fi
```

### 4. 状態サマリー

```bash
echo ""
echo "=== セットアップ完了 ==="
echo "Codex pane: $CODEX_PANE"
tmux list-panes -F 'pane #{pane_index}: #{pane_current_command} (#{pane_width}x#{pane_height})'
```

## 使用場面

- 初回セットアップ時
- codex pane が閉じてしまった場合の復旧
- `/tmux-codex-ask` の前提として自動実行される
