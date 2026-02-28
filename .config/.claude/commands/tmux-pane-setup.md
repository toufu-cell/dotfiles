---
description: tmux pane セットアップ / codex 検出・起動
allowed-tools: Bash
---

# tmux Pane セットアップ

tmux 環境を確認し、Codex CLI が動作する pane を検出または作成する。

## 手順

### 1. セットアップ実行

pane index は `/tmp/tmux-codex-pane.txt` に自動保存される。

```bash
bash ~/.claude/skills/tmux-agent/bin/tmux-pane-setup.sh
```

### 2. 状態確認

```bash
tmux list-panes -F 'pane #{pane_index}: #{pane_current_command} (#{pane_width}x#{pane_height})'
```

## 使用場面

- 初回セットアップ時
- codex pane が閉じてしまった場合の復旧
- `/tmux-codex-ask` の前提として自動実行される
