# Codemap 生成手順

## 概要

プロジェクトのコードベースをスキャンし、AIがトークン効率的に理解するための `architecture.md` を自動生成・更新する。

---

## Phase 1: プロジェクト構造スキャン

### 1.1 リポジトリルートの特定

```bash
git rev-parse --show-toplevel
```

- git リポジトリでなければエラーメッセージを表示して終了
- cwd ではなく、常にリポジトリルートをベースにする

### 1.2 repo-local config の読み取り

リポジトリルートに `.codemap.yml` があれば Read で読み取る。

**デフォルト値**（`.codemap.yml` がない場合）:
- `output_dir`: `docs/CODEMAPS`
- `token_budget`: `1000`
- `extra_ignore`: `[]`
- `include_generated`: `[]`
- `scan_scope`: `repo`

### 1.3 除外パターンの構築

以下の順序で除外リストを構築する:

1. **built-in ignore**（常に除外）:
   - `node_modules`, `dist`, `build`, `.venv`, `vendor`
   - `__pycache__`, `.next`, `.nuxt`, `target`, `coverage`
   - `.git`, `.svn`, `.hg`
   - `*.min.js`, `*.min.css`, `*.map`
   - `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - `go.sum`, `Cargo.lock`, `Gemfile.lock`, `poetry.lock`

2. **`.gitignore`** のパターンを追加

3. **`.codemap.yml` の `extra_ignore`** を追加

4. **`.codemap.yml` の `include_generated`** で指定されたパスを除外リストから除く

### 1.4 プロジェクトタイプの判定

Glob で以下のマーカーファイルを探索し、プロジェクトタイプを判定する:

| マーカー | タイプ |
|---|---|
| `packages/` or `apps/` or `workspaces` in package.json | `monorepo` |
| `go.mod` + `cmd/` | `cli` (Go) |
| `go.mod` (cmd/ なし) | `app` or `library` (Go) |
| `setup.py` or `pyproject.toml` | `app` or `library` (Python) |
| `Cargo.toml` | `app` or `library` (Rust) |
| `src/` + フレームワーク設定ファイル | `app` |
| `lib/` + `index.*` | `library` |
| 上記に該当しない | `config` or `unknown` |

**confidence の決定**:
- マーカーが明確に1つのタイプを示す → `high`
- 複数のタイプに該当する可能性がある → `medium`
- マーカーが見つからない → `low`

### 1.5 entry surfaces の特定

単一のエントリーポイントを前提にせず、以下の **entry surfaces** を探索する:

| Surface タイプ | 探索パターン |
|---|---|
| app server | `main.ts`, `main.go`, `app.py`, `server.*`, `index.ts` (Express/Fastify 等) |
| CLI | `cli.*`, `cmd/`, `bin/`, `__main__.py` |
| worker | `worker.*`, `consumer.*`, `processor.*` |
| route handlers | `routes/`, `api/`, `pages/` (Next.js 等) |
| public exports | `index.ts`, `mod.rs`, `__init__.py` (library の場合) |
| config entry | `Makefile`, `Dockerfile`, `docker-compose.yml` |

各 surface について、パスと簡潔な説明を記録する。

---

## Phase 2: Codemap 生成

### 2.1 出力ディレクトリの準備

- `{repo_root}/{output_dir}/` が存在しなければ作成
- 既存ファイルがあれば Phase 4（差分検知）に進む

### 2.2 architecture.md の生成

`templates.md` のテンプレートに従い、以下の情報を収集・構造化する:

1. **Overview**: プロジェクトタイプ、主要言語、フレームワーク
2. **Directory Structure**: Glob で主要ディレクトリを取得し、ASCII tree で表現（depth 3 まで）
3. **Entry Surfaces**: Phase 1.5 で特定した surface を表形式で記述
4. **Architecture Diagram**: コンポーネント間の関係を ASCII 図で表現
   - データの流れ（入力 → 処理 → 出力）
   - レイヤー構造（API → Service → Repository 等）
   - 外部サービスとの接続
5. **Key Dependencies**: package.json, go.mod, requirements.txt 等から主要な依存関係を抽出
6. **Notes**: confidence が `medium` 以下の場合、推定箇所を明記

### 2.3 メタデータヘッダーの付与

```bash
git rev-parse --short HEAD
```

で現在のコミットハッシュを取得し、`templates.md` のメタデータヘッダーフォーマットに従ってヘッダーを付与。

### 2.4 token budget チェック

生成後の内容が token budget を超えていないか推定する。
超えている場合は `templates.md` の削減優先順位に従って情報を絞る。

### 2.5 ファイル書き込み

Write ツールで `{output_dir}/architecture.md` に書き込む。

---

## Phase 3: 差分検知と更新

既存の `architecture.md` がある場合のみ実行。

### 3.1 既存ファイルの読み取り

Read ツールで既存の `architecture.md` を読み取る。

### 3.2 セクション単位の差分比較

`templates.md` のセクション定義に従い、各セクションを比較する:

- **Overview**: Type, Language, Framework が変わったか
- **Directory Structure**: ディレクトリの追加・削除があったか
- **Entry Surfaces**: surface の追加・削除・パス変更があったか
- **Architecture Diagram**: 構造的な変更があったか
- **Key Dependencies**: 依存関係の追加・削除があったか

### 3.3 更新判定

**大きな構造変更**（ユーザー承認が必要）:
- Overview の Type が変更された
- Entry Surfaces の 50% 以上が変更された
- Architecture Diagram の構造が大幅に変わった

→ 変更内容をユーザーに表示し、承認を求める

**軽微な更新**（自動更新）:
- 依存関係の追加のみ
- ディレクトリ名の変更のみ
- Notes の更新のみ
- Directory Structure の軽微な変更

→ 自動で上書き更新

### 3.4 変更レポートの保存

`{repo_root}/.reports/codemap-diff.txt` に以下を記録:

```
Codemap Diff Report
Generated: {timestamp}
Commit: {old_commit} → {new_commit}

Changes:
- [section] {変更内容の要約}
- [section] {変更内容の要約}

Action: {auto-updated | awaiting-approval | no-change}
```

---

## Phase 4: 陳腐化チェック

既存の `architecture.md` がある場合に実行。

### 4.1 git commit ベースの乖離判定

メタデータの `git_commit` と現在の HEAD を比較:

```bash
git rev-list --count {old_commit}..HEAD
```

差分コミット数と、変更されたファイルの確認:

```bash
git diff --stat {old_commit}..HEAD
```

### 4.2 主要ディレクトリの変更確認

以下を確認:
- `src/`, `lib/`, `app/`, `packages/` 等のディレクトリに変更があるか
- 新しいディレクトリが追加されたか
- エントリーポイントファイルに変更があるか

### 4.3 警告の表示

**再生成推奨**（以下のいずれかに該当）:
- 差分コミット数が 50 以上
- 主要ディレクトリに構造的変更がある
- エントリーポイントファイルが変更されている

**補助警告**:
- メタデータの `generated_at` から 90日 以上経過

警告メッセージ例:
```
⚠ codemap が陳腐化している可能性があります
  - 前回生成: {generated_at} (commit: {git_commit})
  - 現在の HEAD: {current_commit}
  - 差分コミット数: {count}
  - 主要ディレクトリの変更: {yes/no}
  → /update-codemaps で再生成を推奨します
```

---

## Phase 5: 実行フロー（まとめ）

```
/update-codemaps 実行
    │
    ├─ Phase 1: プロジェクト構造スキャン
    │   ├─ リポジトリルート特定
    │   ├─ .codemap.yml 読み取り（あれば）
    │   ├─ 除外パターン構築
    │   ├─ プロジェクトタイプ判定
    │   └─ entry surfaces 特定
    │
    ├─ 既存 architecture.md あり？
    │   │
    │   ├─ Yes → Phase 4: 陳腐化チェック
    │   │        → Phase 3: 差分検知
    │   │        → 更新 or 承認待ち
    │   │
    │   └─ No  → Phase 2: 新規生成
    │            → ファイル書き込み
    │
    └─ 完了報告
        ├─ 生成/更新されたファイルパス
        ├─ confidence レベル
        └─ 変更サマリー（更新時）
```

---

## エラーハンドリング

| 状況 | 対応 |
|---|---|
| git リポジトリでない | エラーメッセージを表示して終了 |
| `.codemap.yml` のフォーマット不正 | 警告を出してデフォルト値で続行 |
| 出力先に書き込み権限がない | エラーメッセージを表示して終了 |
| token budget 超過 | 削減優先順位に従って自動削減 |
| confidence が `low` | 警告を表示して生成は実行（推定箇所を明記） |
