---
name: tmux-agent
description: tmux 経由で隣接 pane の Codex CLI を自律操作するスキル。send-keys -l と Enter は必ず別々の Bash 呼び出しで実行すること。
---

詳細な手順は `INSTRUCTIONS.md` を参照（このスキルのディレクトリ内）。

## スクリプト（bin/）

複雑なロジック（pane 検出、ポーリング、スナップショット等）は `bin/` に外部化されている。
Claude Code からは `bash bin/スクリプト名.sh` の1行で呼び出すこと。

| スクリプト | 役割 |
|-----------|------|
| `bin/tmux-detect-codex.sh` | codex pane の検出 |
| `bin/tmux-pane-setup.sh` | pane 検出 + 作成 + codex 起動 |
| `bin/tmux-snapshot.sh` | スナップショット取得 |
| `bin/tmux-poll.sh` | 完了待機ポーリング |
| `bin/tmux-send-text.sh` | テキスト送信（pane ファイル検証込み） |
| `bin/tmux-send-enter.sh` | Enter キー送信（pane ファイル検証込み） |
| `bin/tmux-codex-recover.sh` | クラッシュ検出・リカバリー |
