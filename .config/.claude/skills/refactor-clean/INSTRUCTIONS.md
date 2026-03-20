# refactor-clean - 詳細手順

## 概要

プロジェクト全体のデッドコード（未使用の関数・ファイル・依存）を静的解析ツールで検出し、テスト駆動で安全に削除するワークフロー。

---

## Phase 0: 事前チェック

1. **git clean 状態確認** — `git status` で未コミット変更を確認
   - 未コミット変更あり → **hard fail（続行禁止）**。先にコミットまたは stash してから再実行
2. **テストスイート存在確認** — テストファイル・テストコマンドの有無を確認
   - テストなし → ユーザーに警告し、続行可否を確認。続行する場合は **no-test モード** に移行
3. **プロジェクト言語の自動検出**
   - `package.json` → JavaScript/TypeScript
   - `pyproject.toml` / `setup.py` / `requirements.txt` → Python
   - 両方 or その他 → 検出結果をユーザーに提示して確認

**中断条件**: git dirty worktree

---

## Phase 1: ベースライン確立

1. **repo 定義済みコマンドを優先検出**:
   - `package.json` の `scripts`（build, lint, test, typecheck 等）
   - `pyproject.toml` の `[tool.pytest]`, `[tool.mypy]`, `[tool.ruff]` 等
   - `Makefile` のターゲット（build, lint, test, check 等）
2. repo 定義が見つからない場合のみ `tool-matrix.md` のフォールバックコマンドを使用
3. 検出した全検証コマンド（build / typecheck / lint / test）を実行して green を確認
4. **いずれかが失敗すればデッドコード削除を開始しない**

---

## Phase 2: デッドコード検出

1. **言語別ツール選定**（`tool-matrix.md` 参照）
2. ツールがインストール済みか確認
   - 未インストール時: Grep フォールバック（**候補ヒント生成のみ、SAFE 判定不可**）
3. 検出結果を安全度で分類: **SAFE / CAUTION / DANGER**

### 分類基準

| 分類 | 条件 | 例 |
|------|------|-----|
| **SAFE** | 静的ツールが unused 判定 + repo 内参照なし + baseline 通過 | 未使用 internal 関数、未使用 test helper |
| **CAUTION** | public API/export/config/reflection/dynamic import 経由の可能性 | コンポーネント、API route、middleware |
| **DANGER** | entrypoint/generated/plugin/CLI/subprocess/文字列参照依存 | config ファイル、entry point、型定義 |

### 特殊ルール

- **Grep フォールバック時**: 全ての検出結果は CAUTION 以上として扱う（SAFE 判定しない）
- **no-test モード時**: 全ての検出結果を CAUTION 以上として扱う（SAFE 自動削除不可。build/lint のみで検証し、削除には毎回ユーザー承認が必要）

---

## Phase 3: Codex レビュー（削除前ゲート）

CLAUDE.md の必須ルール（編集前レビュー）に準拠。既存の tmux/exec Codex 連携手順に従って送信する。

### 送信フォーマット

```
[レビュー依頼]
## 背景
プロジェクトのデッドコード検出結果をレビューしてほしい。

## 削除候補一覧
### SAFE（{N}件）
- {ファイルパス}: {関数名/export名} — {検出ツール}の判定理由
- ...

### CAUTION（{N}件）
- {ファイルパス}: {関数名/export名} — 要確認: {動的参照の可能性等}
- ...

### DANGER（スキップ対象, {N}件）
- {ファイルパス}: {理由}

## 判断ポイント
- SAFE 候補の削除に問題ないか
- CAUTION 候補のうち削除可能なものはあるか
- 見落としているリスクはないか
```

- Codex の指摘に基づき候補を調整
- **Codex 接続不可時: hard fail**。ユーザーが明示的に「Codex レビューなしで続行」を承認した場合のみ停止解除（CLAUDE.md の必須ルール準拠）

---

## Phase 4: 安全削除ループ

1. **SAFE アイテムから開始**
2. **1ファイルにつき1つの変更のみ**実施 → Phase 1 と同じ検証コマンドを全て実行
3. pass なら次へ
4. **fail なら該当ファイルのみ** `git checkout -- <対象ファイル>` でリバートし、スキップ
5. 同一ファイル内に複数の削除候補がある場合は、1つ削除 → 検証 → 成功ならコミット → 次の候補、の順で処理（コミット済みの成功結果を巻き戻さない）
6. **CAUTION アイテム**は動的インポート・外部消費者を追加検証してから削除
7. **DANGER アイテム**はスキップ（手動対応推奨）

---

## Phase 5: サマリ報告

削除結果をレポートし、全検証コマンドの最終実行結果を確認する。

```
Dead Code Cleanup
──────────────────────────────
Deleted:   {N} unused functions
           {N} unused files
           {N} unused dependencies
Skipped:   {N} items (verification failed)
           {N} items (DANGER/manual)
Saved:     ~{N} lines removed
──────────────────────────────
All verifications passing: build / typecheck / lint / test
```

---

## エラーハンドリング

| エラー | 対処 |
|-------|------|
| git dirty worktree | **hard fail**: 先にコミットまたは stash してから再実行 |
| テストスイートなし | no-test モード: SAFE 自動削除不可、全候補 CAUTION 以上（build/lint のみで検証 + 毎回ユーザー承認） |
| 検出ツール未インストール | Grep フォールバック（候補ヒントのみ、SAFE 判定不可） |
| 検証失敗（削除後） | 該当ファイルのみ `git checkout -- <file>` でリバート |
| Codex 接続不可 | **hard fail**: ユーザーが明示的に bypass 承認した場合のみ続行 |
