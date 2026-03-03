---
description: Codex CLI への質問（セットアップ→送信→待機→回収の統合コマンド）
allowed-tools: Bash
---

# tmux Codex Ask

Codex CLI にプロンプトを送信し、応答を回収する統合コマンド。
**tmux 優先、exec フォールバックのデュアルモード対応。**

## 引数

- `$ARGUMENTS` — Codex に送信するプロンプト

## 手順

### 0. モード検出

```bash
bash ~/.claude/skills/tmux-agent/bin/codex-review-init.sh
```

出力が `tmux` → tmux モード（手順 1〜3）、`exec` → exec モード（手順 4）へ進む。

### tmux モード

#### 1. セットアップ + スナップショット

pane index は `/tmp/tmux-codex-pane.txt` に自動保存される。以降のスクリプトはこのファイルから自動読み取りする。

```bash
bash ~/.claude/skills/tmux-agent/bin/tmux-pane-setup.sh
```

```bash
bash ~/.claude/skills/tmux-agent/bin/tmux-snapshot.sh
```

#### 2. プロンプト送信（2つの Bash 呼び出しに分ける）

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

#### 3. 待機 + 出力回収

```bash
bash ~/.claude/skills/tmux-agent/bin/tmux-poll.sh
```

### exec モード

#### 4. 1コマンドで実行（tmux 不可時）

```bash
bash ~/.claude/skills/tmux-agent/bin/codex-exec-review.sh "$ARGUMENTS"
```

stdout に Codex の応答が出力される。

## 使用例

```
/tmux-codex-ask このコードの設計方針をレビューしてください

# 追加ラウンド（tmux モード時）は /tmux-pane-send + /tmux-pane-read を使う
# exec モード時は再度 /tmux-codex-ask を使う（ステートレス）
```
