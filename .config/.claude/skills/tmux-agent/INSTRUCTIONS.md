# tmux Agent Skill

## 概要

Claude Code から tmux を仲介層として使い、隣接 pane で動作する Codex CLI を自律的に操作するスキル。
プロンプト送信・出力回収・反復的な双方向対話を実現する。

## モード

**常に対話モード（tmux pane 経由）を使用する。`codex exec` は使用禁止。**

対話モードは文脈を維持した複数ラウンドの議論が可能で、レビュー・議論用途に最適。

## 最重要ルール: send-keys の送信手順

**`send-keys -l` と `send-keys Enter` は必ず別々の Bash 呼び出しで実行すること。**
同一の Bash 呼び出し内で2行に書くと Enter が反映されないことがある。

```bash
# === 正しい手順: 別々の Bash 呼び出しで実行 ===

# Bash 呼び出し1: テキスト入力
tmux send-keys -t .$CODEX_PANE -l "プロンプトテキスト"

# Bash 呼び出し2: Enter で送信確定（別の Bash ツール呼び出しで実行！）
tmux send-keys -t .$CODEX_PANE Enter

# === 間違い1: Enter なし ===
tmux send-keys -t .$CODEX_PANE -l "テキスト"  # Enter がない！送信されない！

# === 間違い2: 同一 Bash 呼び出し内で2行にまとめる ===
tmux send-keys -t .$CODEX_PANE -l "テキスト"
tmux send-keys -t .$CODEX_PANE Enter
# ↑ 同一 Bash 呼び出しだと Enter が反映されないことがある！
```

**この2ステップは必ず別々の Bash ツール呼び出しで実行する。例外なし。**

## 自律操作の4フェーズ

### Phase 1: 環境検出

```bash
# tmux セッション内かどうか確認
echo $TMUX

# pane 一覧を取得
tmux list-panes -F '#{pane_index}|#{pane_pid}|#{pane_current_command}'

# codex が動作している pane を特定
# 各 pane の PID から子プロセスを走査
pgrep -P $PANE_PID -f "codex"
```

### Phase 2: セットアップ

codex pane が見つからない場合:

```bash
# 右側に新規 pane を作成
tmux split-window -h -c "#{pane_current_path}"

# 新しい pane のインデックスを取得
CODEX_PANE=$(tmux list-panes -F '#{pane_index}' | tail -1)

# codex を起動（--no-alt-screen が必須）
tmux send-keys -t .$CODEX_PANE "codex --no-alt-screen --full-auto" Enter

# 起動完了を待機（プロンプト表示まで）
sleep 3
```

### Phase 3: 送信 → 待機 → 回収

```bash
# ステップ1: 送信前のスナップショットを取得（行数を記録）
tmux capture-pane -t .$CODEX_PANE -p -S -200 \
    | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
    | sed '/^[[:space:]]*$/d' \
    > /tmp/tmux-before-snapshot.txt

# ステップ2: テキスト入力（Bash 呼び出し1）
tmux send-keys -t .$CODEX_PANE -l "ここにプロンプト"

# ステップ3: Enter で送信確定（Bash 呼び出し2 — 必ず別の呼び出し！）
tmux send-keys -t .$CODEX_PANE Enter

# ステップ4: ポーリングで完了を検出（output-parsing.md 参照）
#   - "Working" が含まれていたら処理中 → 待機継続
#   - "Working" がなく "context left" があれば完了

# ステップ5: capture-pane で出力回収 → 行番号ベースで差分抽出
```

### Phase 4: 結果解釈

- 出力をパースしてユーザーに報告
- 必要に応じて追加プロンプトを送信（Phase 3 に戻る）
- エラーが検出された場合はリカバリー処理

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
