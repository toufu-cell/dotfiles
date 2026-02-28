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

### 1. codex pane 検出

pane index は `/tmp/tmux-codex-pane.txt` に自動保存される。

```bash
bash ~/.claude/skills/tmux-agent/bin/tmux-detect-codex.sh
```

### 2. 送信前スナップショット取得

```bash
bash ~/.claude/skills/tmux-agent/bin/tmux-snapshot.sh
```

### 3. プロンプト送信（2つの Bash 呼び出しに分ける）

**重要: テキスト入力と Enter 送信は必ず別々の Bash ツール呼び出しで実行すること。**
pane ファイルの検証・読み取りはスクリプト内部で行われる。

```bash
# Bash 呼び出し1: テキスト入力
bash ~/.claude/skills/tmux-agent/bin/tmux-send-text.sh "$ARGUMENTS"
```

```bash
# Bash 呼び出し2: Enter で送信確定
bash ~/.claude/skills/tmux-agent/bin/tmux-send-enter.sh
```

## 注意事項

- **テキスト入力と Enter 送信は必ず別々の Bash ツール呼び出しで行う**
- 送信前のスナップショットは `/tmp/tmux-before-snapshot.txt` に保存される
- `/tmux-pane-read` と組み合わせて差分抽出に使用する
- 特殊文字を含むプロンプトはシングルクォートでラップすること
