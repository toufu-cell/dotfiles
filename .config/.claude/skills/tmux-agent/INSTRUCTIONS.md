# tmux Agent Skill

## 概要

Claude Code から tmux を仲介層として使い、隣接 pane で動作する Codex CLI を自律的に操作するスキル。
プロンプト送信・出力回収・反復的な双方向対話を実現する。

## モード

**常に対話モード（tmux pane 経由）を使用する。`codex exec` は使用禁止。**

対話モードは文脈を維持した複数ラウンドの議論が可能で、レビュー・議論用途に最適。

## 最重要ルール: send-keys の送信手順

**テキスト入力と Enter 送信は必ず別々の Bash 呼び出しで実行すること。**
同一の Bash 呼び出し内で2行に書くと Enter が反映されないことがある。
**`tmux send-keys` を直接呼ばず、必ずラッパースクリプトを使うこと。**（`$()` コマンド置換による承認プロンプトを防ぐため）

```bash
# === 正しい手順: ラッパースクリプト経由で別々の Bash 呼び出し ===

# Bash 呼び出し1: テキスト入力
bash ~/.claude/skills/tmux-agent/bin/tmux-send-text.sh "プロンプトテキスト"

# Bash 呼び出し2: Enter で送信確定（別の Bash ツール呼び出しで実行！）
bash ~/.claude/skills/tmux-agent/bin/tmux-send-enter.sh

# === 間違い1: tmux send-keys を直接使う（承認プロンプトが出る） ===
tmux send-keys -t .$(cat /tmp/tmux-codex-pane.txt) -l "テキスト"  # NG！

# === 間違い2: Enter なし ===
bash ~/.claude/skills/tmux-agent/bin/tmux-send-text.sh "テキスト"  # Enter がない！送信されない！
```

**この2ステップは必ず別々の Bash ツール呼び出しで実行する。例外なし。**

## 自律操作の4フェーズ

すべての複雑なロジックは `bin/` のスクリプトに外部化されている。
Claude Code からは `bash スクリプト名` の1行で呼び出すこと。

### Phase 1+2: 環境検出 + セットアップ

pane index は `/tmp/tmux-codex-pane.txt` に自動保存される。以降のスクリプトはこのファイルから自動読み取りする。

```bash
# codex pane の検出 + なければ作成・起動（1コマンド）
bash ~/.claude/skills/tmux-agent/bin/tmux-pane-setup.sh
```

### Phase 3: 送信 → 待機 → 回収

```bash
# ステップ1: 送信前のスナップショットを取得（pane index は自動読み取り）
bash ~/.claude/skills/tmux-agent/bin/tmux-snapshot.sh
```

```bash
# ステップ2: テキスト入力（pane ファイル検証はスクリプト内部で実行）
bash ~/.claude/skills/tmux-agent/bin/tmux-send-text.sh "ここにプロンプト"
```

```bash
# ステップ3: Enter で送信確定（必ず別の Bash 呼び出し！）
bash ~/.claude/skills/tmux-agent/bin/tmux-send-enter.sh
```

```bash
# ステップ4: ポーリングで完了を待機 + 出力回収（pane index は自動読み取り）
bash ~/.claude/skills/tmux-agent/bin/tmux-poll.sh
```

### Phase 4: 結果解釈

- 出力をパースしてユーザーに報告
- 必要に応じて追加プロンプトを送信（Phase 3 に戻る）
- エラーが検出された場合はリカバリー: `bash ~/.claude/skills/tmux-agent/bin/tmux-codex-recover.sh`

## 前提条件

- tmux セッション内で Claude Code が動作していること
- `codex` コマンドがインストール済みであること
- `--no-alt-screen` フラグが使用可能な codex バージョンであること

## ガイドラインファイル

| ファイル | 内容 |
|---------|------|
| `tmux-commands.md` | tmux コマンドリファレンス |
| `output-parsing.md` | ポーリング戦略・出力パース手法 |
| `codex-integration.md` | Codex CLI 固有の統合ガイド |

## 関連コマンド

| コマンド | 内容 |
|---------|------|
| `/tmux-pane-setup` | Pane セットアップ / codex 検出 |
| `/tmux-pane-send` | コマンド送信 |
| `/tmux-pane-read` | 出力キャプチャ |
| `/tmux-codex-ask` | 統合コマンド（送信→待機→回収） |

## エラーハンドリング

| 状況 | 対処 |
|------|------|
| tmux 外で実行 | エラーメッセージを表示して終了 |
| codex pane が見つからない | `/tmux-pane-setup` で自動作成 |
| codex がクラッシュ | pane を再作成して codex を再起動 |
| 出力取得タイムアウト | exec モードにフォールバック |
| プロンプトに特殊文字 | シングルクォートでエスケープ |
| send-keys でテキストが送信されない | `-l` フラグでリテラル送信 + Enter を分離 |
