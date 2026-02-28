# tmux コマンドリファレンス

## pane 操作

### pane 一覧取得

```bash
# 基本的な pane 情報
tmux list-panes -F '#{pane_index}|#{pane_pid}|#{pane_current_command}'

# 詳細情報（サイズ含む）
tmux list-panes -F '#{pane_index}|#{pane_pid}|#{pane_current_command}|#{pane_width}x#{pane_height}'
```

### pane 作成

```bash
# 右側に分割
tmux split-window -h -c "#{pane_current_path}"

# 下側に分割
tmux split-window -v -c "#{pane_current_path}"

# 特定のサイズで分割（パーセント指定）
tmux split-window -h -p 40 -c "#{pane_current_path}"
```

### pane 終了

```bash
# 特定の pane を終了
tmux kill-pane -t .$PANE_INDEX
```

## ターゲット指定

tmux のターゲット指定形式:

| 形式 | 意味 |
|------|------|
| `.$N` | 現在ウィンドウの pane N |
| `$SESSION:$WINDOW.$PANE` | 完全指定 |
| `.+1` / `.-1` | 隣接 pane（相対指定） |

```bash
# 現在のウィンドウの pane 1 を指定
tmux send-keys -t .1 "command" Enter

# 相対指定（次の pane）
tmux send-keys -t .+1 "command" Enter
```

## キー送信

### send-keys

```bash
# シェルへの送信（テキスト + Enter を一括）
tmux send-keys -t .$PANE "シェルコマンド" Enter

# TUI アプリ（codex 等）への送信
# 重要: Claude Code からは直接呼ばず、ラッパースクリプトを使うこと
# bash ~/.claude/skills/tmux-agent/bin/tmux-send-text.sh "プロンプトテキスト"
# bash ~/.claude/skills/tmux-agent/bin/tmux-send-enter.sh
# 参考（低レベル API）:
tmux send-keys -t .$PANE -l "プロンプトテキスト"
tmux send-keys -t .$PANE Enter

# 特殊キー
tmux send-keys -t .$PANE C-c      # Ctrl+C
tmux send-keys -t .$PANE C-d      # Ctrl+D
tmux send-keys -t .$PANE Escape   # Escape

# リテラルモード（-l: 特殊キー解釈を無効化）
tmux send-keys -t .$PANE -l "C-c is a shortcut"
```

**注意**: codex のような TUI アプリでは `send-keys "text" Enter` だと
テキストが正しく入力されないことがある。必ず `-l` + 別途 `Enter` を使うこと。

### 特殊文字のエスケープ

```bash
# シングルクォートを含む場合
tmux send-keys -t .$PANE "it'\''s a test" Enter

# ダブルクォートを含む場合
tmux send-keys -t .$PANE 'say "hello"' Enter

# 複数行テキスト（改行を含む場合は分割送信）
tmux send-keys -t .$PANE "line1" Enter
tmux send-keys -t .$PANE "line2" Enter
```

## 出力キャプチャ

### capture-pane

```bash
# 最近200行をキャプチャ
tmux capture-pane -t .$PANE -p -S -200

# 全スクロールバックバッファ
tmux capture-pane -t .$PANE -p -S -

# 特定範囲（開始行〜終了行）
tmux capture-pane -t .$PANE -p -S -50 -E -1
```

**オプション**:

| フラグ | 意味 |
|--------|------|
| `-p` | stdout に出力（バッファではなく） |
| `-S N` | 開始行（負数 = スクロールバック、`-` = 全て） |
| `-E N` | 終了行（`-1` = 最後の行） |
| `-e` | ANSI エスケープを含む |
| `-J` | 折り返し行を結合 |

### ANSI エスケープ除去

```bash
# capture-pane の出力からエスケープシーケンスを除去
tmux capture-pane -t .$PANE -p -S -200 | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g'

# より包括的なクリーニング
tmux capture-pane -t .$PANE -p -S -200 \
    | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
    | sed 's/\x1b\][^\x07]*\x07//g' \
    | sed '/^$/d'
```

## プロセス確認

```bash
# pane 内のプロセス確認
pgrep -P $PANE_PID

# 特定コマンドの子プロセス検索
pgrep -P $PANE_PID -f "codex"

# プロセスツリー表示
ps -o pid,ppid,comm -p $(pgrep -P $PANE_PID) 2>/dev/null
```

## レイアウト管理

```bash
# 均等水平分割
tmux select-layout even-horizontal

# メイン pane + サイド pane
tmux select-layout main-vertical

# pane サイズ変更
tmux resize-pane -t .$PANE -x 80    # 幅80列
tmux resize-pane -t .$PANE -R 10    # 右に10列拡大
```
