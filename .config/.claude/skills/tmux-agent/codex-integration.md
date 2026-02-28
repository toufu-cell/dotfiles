# Codex CLI 統合ガイド

## スクリプトによる実行

以下の関数は `bin/` のスクリプトに実装済み。実際の操作ではスクリプトを直接呼び出すこと。

| スクリプト | 対応する関数 |
|-----------|-------------|
| `bin/tmux-pane-setup.sh` | `wait_for_codex_ready()` |
| `bin/tmux-codex-recover.sh` | `detect_codex_crash()`, `recover_codex()` |

## 概要

OpenAI の Codex CLI を Claude Code から操作するための固有情報。
起動オプション、プロンプトパターン、エラーハンドリングを定義する。

## 必須フラグ

### `--no-alt-screen`

**必須**。Codex CLI はデフォルトで alternate screen buffer を使用する。
これが有効だと `tmux capture-pane` で出力を取得できない。

```bash
# 正しい起動方法
codex --no-alt-screen --full-auto

# NG: capture-pane が空になる
codex --full-auto
```

### `--full-auto`

承認なしの自動実行モード。対話的な承認プロンプトを回避する。
内部的に `-a on-request --sandbox workspace-write` と同等。

```bash
codex --no-alt-screen --full-auto
```

## exec モード（推奨）

対話セッションを経由せず、単発で実行して結果を取得する。
**出力取得の確実性が最も高い**。

### ファイル出力

```bash
# 結果をファイルに出力
codex exec -o /tmp/codex-out.md "現在のディレクトリのファイル一覧を教えて"

# 結果を読み取り
cat /tmp/codex-out.md
```

### JSONL 出力

```bash
# 構造化された出力を取得
codex exec --json "ファイル一覧を表示" 2>/dev/null

# JSONL の各行を解析
codex exec --json "prompt" 2>/dev/null | while IFS= read -r line; do
    TYPE=$(echo "$line" | jq -r '.type // empty')
    case "$TYPE" in
        message)
            CONTENT=$(echo "$line" | jq -r '.content // empty')
            echo "$CONTENT"
            ;;
    esac
done
```

### exec モードの使い分け

| 方法 | 用途 |
|------|------|
| `codex exec -o <file> "prompt"` | Markdown 形式の出力が欲しい場合 |
| `codex exec --json "prompt"` | プログラム的に処理したい場合 |
| `codex exec "prompt"` | 単純に stdout で確認したい場合 |

## 対話モード

### プロンプトパターン検出

Codex CLI の対話モードで表示されるプロンプトパターン:

```
>              # 基本プロンプト
❯              # Unicode プロンプト
codex>         # 名前付きプロンプト
```

検出用正規表現:
```bash
CODEX_PROMPT_RE='(^>|^❯|codex>)'
```

### 起動完了の検出

```bash
wait_for_codex_ready() {
    local pane=$1
    local timeout=30
    local elapsed=0

    while [ $elapsed -lt $timeout ]; do
        OUTPUT=$(tmux capture-pane -t .$pane -p -S -10 | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')

        if echo "$OUTPUT" | grep -qE '(^>|^❯|codex>)'; then
            return 0  # 起動完了
        fi

        sleep 2
        elapsed=$((elapsed + 2))
    done

    return 1  # タイムアウト
}
```

## エラーハンドリング

### クラッシュ検出

```bash
detect_codex_crash() {
    local pane=$1
    local pane_pid=$(tmux list-panes -F '#{pane_index}|#{pane_pid}' | grep "^${pane}|" | cut -d'|' -f2)

    # codex プロセスが生存しているか確認
    if ! pgrep -P "$pane_pid" -f "codex" > /dev/null 2>&1; then
        return 0  # クラッシュ（プロセスなし）
    fi

    return 1  # 正常
}
```

### エラーパターン

capture-pane の出力から検出するエラーパターン:

```bash
ERROR_PATTERNS='(Error:|error:|FATAL|panic:|Traceback|npm ERR!)'
```

### リカバリー手順

1. codex プロセスの生存確認
2. クラッシュしている場合:
   - pane を kill
   - 新しい pane を作成
   - codex を再起動
3. エラー出力がある場合:
   - エラー内容をキャプチャ
   - ユーザーに報告

```bash
recover_codex() {
    local pane=$1

    # 既存 pane を終了
    tmux kill-pane -t .$pane 2>/dev/null

    # 新しい pane を作成
    tmux split-window -h -c "#{pane_current_path}"
    NEW_PANE=$(tmux list-panes -F '#{pane_index}' | tail -1)

    # codex を再起動（シェルコマンドなので send-keys 直接でOK）
    tmux send-keys -t .$NEW_PANE "codex --no-alt-screen --full-auto" Enter

    # 起動待機
    sleep 3

    echo "$NEW_PANE"
}
```

## 推奨 tmux レイアウト

```
┌────────────────────┬──────────────────┐
│                    │                  │
│   Claude Code      │   Codex CLI      │
│   (メイン pane)    │   (サブ pane)    │
│                    │                  │
│   pane 0           │   pane 1         │
│                    │                  │
└────────────────────┴──────────────────┘
```

```bash
# 推奨セットアップ
tmux split-window -h -p 40 -c "#{pane_current_path}"
# → 左60%: Claude Code, 右40%: Codex CLI
```

## 注意事項

- codex の `--no-alt-screen` は capture-pane の動作に必須
- `--full-auto` なしでは承認プロンプトで対話が止まる
- exec モードの `-o` オプションはファイルが既存の場合上書きされる
- 長いプロンプトは改行で分割せず、1行で送信する
- プロンプト内のシングルクォートは `'\''` でエスケープする
- **TUI への送信は必ずラッパースクリプト経由で、別々の Bash ツール呼び出しで2ステップに分ける**:
  ```bash
  # Bash 呼び出し1: テキスト入力
  bash ~/.claude/skills/tmux-agent/bin/tmux-send-text.sh "プロンプト"

  # Bash 呼び出し2: Enter で送信確定（必ず別の Bash 呼び出し！）
  bash ~/.claude/skills/tmux-agent/bin/tmux-send-enter.sh
  ```
  `tmux send-keys` を直接呼ばないこと（`$()` コマンド置換による承認プロンプトが発生する）。
  同一 Bash 呼び出し内でまとめると Enter が反映されないことがある。
- 初回プロンプトは引数付き起動でも渡せる:
  ```bash
  codex --no-alt-screen --full-auto "初回プロンプト"
  ```
