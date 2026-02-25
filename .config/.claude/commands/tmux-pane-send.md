---
description: tmux pane へのコマンド送信
allowed-tools: Bash
---

# tmux Pane 送信

指定した pane にプロンプトまたはコマンドを送信する。
送信前にスナップショットを取得し、差分抽出の基準点とする。

## 引数

- `$ARGUMENTS` — 送信するプロンプト文字列

## 手順

### 1. 環境確認

```bash
if [ -z "$TMUX" ]; then
    echo "ERROR: tmux セッション外です"
    exit 1
fi
```

### 2. codex pane の検出

```bash
CODEX_PANE=""
while IFS='|' read -r idx pid cmd; do
    if pgrep -P "$pid" -f "codex" > /dev/null 2>&1; then
        CODEX_PANE=$idx
        break
    fi
done < <(tmux list-panes -F '#{pane_index}|#{pane_pid}|#{pane_current_command}')

if [ -z "$CODEX_PANE" ]; then
    echo "ERROR: codex pane が見つかりません。/tmux-pane-setup を先に実行してください。"
    exit 1
fi

echo "codex pane: $CODEX_PANE"
```

### 3. 送信前スナップショット取得

```bash
BEFORE_SNAPSHOT="/tmp/tmux-before-snapshot.txt"
tmux capture-pane -t .$CODEX_PANE -p -S -200 \
    | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
    | sed 's/\x1b\][^\x07]*\x07//g' \
    | sed '/^[[:space:]]*$/d' \
    > "$BEFORE_SNAPSHOT"

echo "スナップショットを保存: $BEFORE_SNAPSHOT ($(wc -l < "$BEFORE_SNAPSHOT") 行)"
```

### 4. プロンプト送信（2つの Bash 呼び出しに分ける）

**重要: テキスト入力と Enter 送信は必ず別々の Bash ツール呼び出しで実行すること。**
同一 Bash 呼び出し内でまとめると Enter が反映されず、テキストが入力欄に留まる。

```bash
# Bash 呼び出し1: テキスト入力
PROMPT="$ARGUMENTS"

if [ -z "$PROMPT" ]; then
    echo "ERROR: 送信するプロンプトが指定されていません"
    exit 1
fi

echo "送信中: $PROMPT"
tmux send-keys -t .$CODEX_PANE -l "$PROMPT"
echo "テキスト入力完了 — 次に Enter を別の Bash 呼び出しで送信すること！"
```

```bash
# Bash 呼び出し2: Enter で送信確定
tmux send-keys -t .$CODEX_PANE Enter
echo "送信完了"
```

## 注意事項

- **テキスト入力と Enter 送信は必ず別々の Bash ツール呼び出しで行う**
- 送信前のスナップショットは `/tmp/tmux-before-snapshot.txt` に保存される
- `/tmux-pane-read` と組み合わせて差分抽出に使用する
- 特殊文字を含むプロンプトはシングルクォートでラップすること
- 非常に長いプロンプトは tmux のバッファ制限に注意
