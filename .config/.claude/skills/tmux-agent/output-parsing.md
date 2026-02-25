# 出力パース・ポーリング戦略

## 概要

tmux capture-pane で取得した出力から、コマンドの完了を検出し、
必要な部分を抽出する手法を定義する。

## 完了検出: 3層ポーリング戦略

### 第1層: プロンプトパターン検出 + Working 除外（最も確実）

codex は処理中に `Working (Ns • esc to interrupt)` を表示する。
このパターンが含まれていたら**まだ処理中**なので待機を継続する。

```bash
# Codex CLI のプロンプトパターン
PROMPT_PATTERNS='(context left)'

# 処理中パターン（これが表示されていたらまだ完了していない）
WORKING_PATTERN='Working'

poll_for_prompt() {
    local pane=$1
    local timeout=${2:-120}
    local elapsed=0

    while [ $elapsed -lt $timeout ]; do
        OUTPUT=$(tmux capture-pane -t .$pane -p -S -10 | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')

        # "Working" が含まれていたら処理中 → 待機継続
        if echo "$OUTPUT" | grep -q "$WORKING_PATTERN"; then
            sleep 3
            elapsed=$((elapsed + 3))
            continue
        fi

        # "Working" がなく "context left" があれば完了
        if echo "$OUTPUT" | grep -qE "$PROMPT_PATTERNS"; then
            return 0  # 完了
        fi

        sleep 3
        elapsed=$((elapsed + 3))
    done

    return 1  # タイムアウト
}
```

### 第2層: 出力安定化（汎用）

3回連続で同一出力が得られたら完了と判定する。

```bash
poll_for_stable() {
    local pane=$1
    local timeout=${2:-120}
    local prev=""
    local same_count=0
    local elapsed=0

    while [ $elapsed -lt $timeout ]; do
        CURRENT=$(tmux capture-pane -t .$pane -p -S -200 | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')

        if [ "$CURRENT" = "$prev" ]; then
            same_count=$((same_count + 1))
            if [ $same_count -ge 3 ]; then
                return 0  # 安定化 = 完了
            fi
        else
            same_count=0
        fi

        prev="$CURRENT"
        sleep 3
        elapsed=$((elapsed + 3))
    done

    return 1  # タイムアウト
}
```

### 第3層: タイムアウト（フォールバック）

上記の検出が失敗した場合、120秒で強制的に出力を回収する。

```bash
MAX_TIMEOUT=120
```

## 推奨ポーリング手順

```
1. send-keys -l でテキスト送信（Bash 呼び出し1）
2. send-keys Enter で送信確定（Bash 呼び出し2 — 必ず別の呼び出し！）
3. 初回は少し長めに待機（5秒）— codex が処理を開始するまでの猶予
4. 3秒間隔でポーリング開始
5. 第1層: "Working" が含まれていたら処理中 → 待機継続
6. 第1層: "Working" がなく "context left" があれば完了
7. 検出できない場合 → 第2層: 出力安定化に切り替え
8. 120秒経過で強制回収（第3層）
9. capture-pane → クリーニング → 行番号ベースで差分抽出
```

## 出力クリーニング

### ANSI エスケープ除去

```bash
clean_output() {
    local raw="$1"
    echo "$raw" \
        | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
        | sed 's/\x1b\][^\x07]*\x07//g' \
        | sed 's/\r//g' \
        | sed '/^[[:space:]]*$/d'
}
```

### パイプライン

```bash
tmux capture-pane -t .$PANE -p -S -200 \
    | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
    | sed 's/\x1b\][^\x07]*\x07//g' \
    | sed 's/\r//g' \
    | sed '/^[[:space:]]*$/d'
```

## 差分抽出

### 推奨方法: 送信プロンプトをキーにして応答を抽出

capture-pane の全出力から、送信したプロンプト文字列以降の `•` 行を抽出する。
これが最も確実で、pane のスクロールバック制限にも影響されない。

```bash
extract_new_output() {
    local pane=$1
    local prompt="$2"

    # capture-pane の全出力を取得
    tmux capture-pane -t .$pane -p -S -200 \
        | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g'
}
```

**実用的には**: capture-pane の出力全体を Claude Code に返し、
Claude Code 側で送信したプロンプトと `•` で始まる応答行を識別するのが最も確実。

### 代替方法: 行番号ベース

スナップショット行数の差分で新しい部分を取得する方法。
ただし `--no-alt-screen` モードでは capture-pane のスクロールバックが
pane の表示行数に制限されるため、行数が一致しないケースがある。

```bash
extract_by_line_number() {
    local before_file=$1
    local after_file=$2

    BEFORE_COUNT=$(wc -l < "$before_file" | tr -d ' ')
    tail -n +"$((BEFORE_COUNT + 1))" "$after_file"
}
```

### 使わないこと: マーカー文字列ベース

codex のフッター行（`context left` 等）が before/after の両方に存在するため、
マーカー一致で抽出すると空になる。この方式は使用禁止。

## exec モードの出力取得

exec モードでは出力パースの複雑さを回避できる。

```bash
# ファイル出力（最も確実）
codex exec -o /tmp/codex-out.md "prompt"
cat /tmp/codex-out.md

# JSONL 出力（構造化データ向け）
codex exec --json "prompt" | while IFS= read -r line; do
    TYPE=$(echo "$line" | jq -r '.type // empty')
    case "$TYPE" in
        message)
            echo "$line" | jq -r '.content'
            ;;
    esac
done
```

## トラブルシューティング

| 問題 | 原因 | 対処 |
|------|------|------|
| 出力が空 | alt-screen モード | `--no-alt-screen` を確認 |
| エスケープ文字が残る | sed パターン不足 | 包括的クリーニングを使用 |
| 完了検出できない | プロンプトパターン不一致 | 安定化検出にフォールバック |
| 差分が正しくない | before スナップショットが不完全 | 送信直前に取得する |
