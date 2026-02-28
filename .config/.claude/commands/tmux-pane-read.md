---
description: tmux pane からの出力キャプチャ
allowed-tools: Bash
---

# tmux Pane 読み取り

codex pane の出力をキャプチャし、クリーニングして返す。
ポーリングで完了を待機した後、出力を返す。

## 手順

### 1. codex pane 検出

pane index は `/tmp/tmux-codex-pane.txt` に自動保存される。

```bash
bash ~/.claude/skills/tmux-agent/bin/tmux-detect-codex.sh
```

### 2. 完了待機 + 出力回収

```bash
bash ~/.claude/skills/tmux-agent/bin/tmux-poll.sh
```

## 注意事項

- `/tmux-pane-send` と組み合わせて使用する
- capture-pane の全出力を返し、Claude Code が応答を識別する
- `•` で始まる行が codex の応答
- `›` で始まる行がユーザーの送信プロンプト
- タイムアウト時は部分的な出力になる可能性がある
