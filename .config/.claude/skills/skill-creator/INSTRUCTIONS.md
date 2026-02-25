# skill-creator - 詳細手順

## 概要

自然言語の要件から Claude Code スキルを自動生成する。
5 フェーズ（ヒアリング → 設計 → 生成 → 品質チェック → 完了報告）で処理する。

テンプレートは `templates/` ディレクトリ内を参照。品質基準は `quality-checklist.md` を参照。

---

## Phase 1: 要件ヒアリング

### 1a. 基本情報の収集

`$ARGUMENTS` から以下を抽出する:

| 情報 | 例 |
|-----|-----|
| スキル名（kebab-case） | `docker-manager` |
| 目的（1文） | Dockerコンテナの管理を支援する |
| 主な機能 | コンテナ一覧、起動、停止、ログ確認 |
| 発動タイミング | コマンドで明示起動 / 自動 / 文脈 / 常時 |

### 1b. 発動パターン仮判定

要件のキーワードから仮判定する:

| キーワード | パターン |
|-----------|---------|
| 「/xxx で起動」「コマンドで」 | コマンド起動型 |
| 「自動で」「〇〇という言葉で」「〇〇したら」 | 自動発動型 |
| 「常に」「必ず」「全セッションで」 | 常時ルール型 |
| 「〇〇のときに」「〇〇の作業中」 | 文脈判断型 |
| 判定不能 | → 1c で選択肢を提示 |

### 1c. ユーザー確認（必須）

**必ず AskUserQuestion を使ってパターンをユーザーに確認する。**

```
質問: 「このスキルの発動パターンはどれが適切ですか？」
選択肢:
  1. コマンド起動型（/xxx で明示起動）← 仮判定結果なら「(推奨)」を付ける
  2. 自動発動型（キーワードで自動発動）
  3. 文脈判断型（特定の作業時に適用）
  4. 常時ルール型（常にルールとして適用）
```

ユーザーが選択しない場合は仮判定結果をデフォルト採用。

### 1d. コマンドファイル要否判定

| パターン | コマンドファイル |
|---------|----------------|
| コマンド起動型 | 必須 |
| 自動発動型 | 推奨（ユーザーに確認） |
| 文脈判断型 | 任意（ユーザーに確認） |
| 常時ルール型 | 不要 |

### 1e. INSTRUCTIONS.md 構造パターン判定

| ケース | パターン |
|-------|---------|
| 順序のあるワークフロー | フェーズ分割型 |
| 複数コマンド/機能を横断 | クイックスタート+詳細型 |
| ルール・規約の参照 | ガイドライン型 |

---

## Phase 2: 設計

### 2a. 既存スキルとの競合チェック

```bash
# 既存スキル一覧
ls ~/.claude/skills/

# 既存コマンド一覧
ls ~/.config/.claude/commands/
```

同名スキルまたはコマンドが存在する場合:
- ユーザーに警告して別名を提案
- 上書きはユーザーの明示的な承認が必要

### 2b. ファイル構成の決定

以下を決定する:
1. SKILL.md テンプレート（4種から選択）
2. INSTRUCTIONS.md テンプレート（3種から選択）
3. コマンドファイルの有無と名前
4. 補助ファイルの有無（templates, rules 等）

### 2c. 設計書をユーザーに提示

以下の形式でユーザーに提示し、承認を待つ:

```
## スキル設計書

- スキル名: {name}
- 発動パターン: {pattern}
- INSTRUCTIONS 構造: {structure}

### 生成ファイル
- ~/.claude/skills/{name}/SKILL.md
- ~/.claude/skills/{name}/INSTRUCTIONS.md
- ~/.config/.claude/commands/{cmd}.md（該当する場合）
- {補助ファイル}（該当する場合）

### SKILL.md 概要
{テンプレートに基づく内容の要約}

### INSTRUCTIONS.md 概要
{フェーズ構成やセクション構成の要約}
```

**承認を得るまで Phase 3 に進まない。**

---

## Phase 3: 生成

### 3a. SKILL.md の生成

1. `templates/` から該当テンプレートを読み込む
   - コマンド起動型: `templates/skill-command.md`
   - 自動発動型: `templates/skill-auto-trigger.md`
   - 文脈判断型: `templates/skill-context.md`
   - 常時ルール型: `templates/skill-always-on.md`
2. プレースホルダを要件に基づいて置換
3. `Write` ツールで `~/.claude/skills/{name}/SKILL.md` に書き出し

### 3b. INSTRUCTIONS.md の生成

1. `templates/` から該当テンプレートを読み込む
   - フェーズ分割型: `templates/instructions-phased.md`
   - クイックスタート+詳細型: `templates/instructions-quickstart.md`
   - ガイドライン型: `templates/instructions-guideline.md`
2. テンプレートの構造に沿って、要件に基づく具体的な内容を埋める
3. `Write` ツールで `~/.claude/skills/{name}/INSTRUCTIONS.md` に書き出し

### 3c. コマンドファイルの生成（該当する場合）

1. `templates/command.md` を参照
2. 適切なバリエーションを選択（引数あり/なし）
3. `Write` ツールで `~/.config/.claude/commands/{cmd}.md` に書き出し

### 3d. 補助ファイルの生成（該当する場合）

スキルに必要な追加ファイル（テンプレート、ルール集等）を生成する。

---

## Phase 4: 品質チェック

`quality-checklist.md` に基づいて検証する。

### 4a. 構造検証（CRITICAL）

```bash
# ファイル存在チェック
ls ~/.claude/skills/{name}/SKILL.md
ls ~/.claude/skills/{name}/INSTRUCTIONS.md
```

```bash
# frontmatter チェック
head -5 ~/.claude/skills/{name}/SKILL.md
```

- `---` で囲まれた YAML frontmatter があること
- `name` と `description` が含まれること

### 4b. パターン整合性（HIGH）

発動パターンに応じた必須セクションを確認:
- 自動発動型: 「発動条件」「誤発動抑止」セクションが存在
- 文脈判断型: 「使用タイミング」セクションが存在
- 常時ルール型: `description` に最重要ルールが含まれる
- コマンド起動型: コマンドファイルが存在

### 4c. サイズ検証（HIGH）

```bash
wc -c ~/.claude/skills/{name}/SKILL.md
```

- 通常: ≤ 700B
- 自動発動型: ≤ 1200B

### 4d. 問題修正

問題が見つかった場合:
1. CRITICAL → 即座に修正して再チェック
2. HIGH → 修正して再チェック
3. MEDIUM → ユーザーに報告（修正は任意）

---

## Phase 5: 完了報告

以下の形式でユーザーに報告:

```
## スキル生成完了

### 生成ファイル
- ✅ ~/.claude/skills/{name}/SKILL.md ({size}B)
- ✅ ~/.claude/skills/{name}/INSTRUCTIONS.md
- ✅ ~/.config/.claude/commands/{cmd}.md（該当する場合）

### 品質チェック結果
- CRITICAL: {N}/{N} Pass
- HIGH: {N}/{N} Pass
- MEDIUM: {N}/{N} Pass

### 使い方
{パターンに応じた使用方法の説明}
```

---

## エラーハンドリング

| エラー | 対処 |
|-------|------|
| `$ARGUMENTS` が空 | AskUserQuestion で要件をヒアリング |
| 既存スキルと名前が重複 | ユーザーに警告し別名を提案 |
| SKILL.md がサイズ超過 | description を短縮、セクションを INSTRUCTIONS.md に移動 |
| frontmatter が不正 | 自動修正して再検証 |
| ユーザーが設計を拒否 | フィードバックに基づいて Phase 2 に戻る |
