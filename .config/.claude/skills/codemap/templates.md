# Codemap テンプレート仕様

## メタデータヘッダー

全ての codemap ファイルの先頭に以下のメタデータを挿入する。

```markdown
<!--
  codemap: {type}
  generated_at: {ISO 8601 タイムスタンプ}
  git_commit: {短縮コミットハッシュ}
  tool_version: 1.0.0
  scan_scope: {repo | package}
  included_paths: {スキャン対象パスのカンマ区切り}
  excluded_paths: {除外パスのカンマ区切り}
  confidence: {high | medium | low}
  DO NOT EDIT - このファイルは /update-codemaps で自動生成されます
-->
```

### フィールド定義

| フィールド | 必須 | 説明 |
|---|---|---|
| `codemap` | Yes | codemap タイプ（v1 では `architecture` 固定） |
| `generated_at` | Yes | 生成日時（ISO 8601、タイムゾーン付き） |
| `git_commit` | Yes | 生成時の HEAD コミット短縮ハッシュ（`git rev-parse --short HEAD`） |
| `tool_version` | Yes | codemap スキルのバージョン（`1.0.0`） |
| `scan_scope` | Yes | `repo`（リポジトリ全体）または `package`（monorepo のパッケージ単位） |
| `included_paths` | Yes | スキャン対象ディレクトリ |
| `excluded_paths` | Yes | 除外ディレクトリ |
| `confidence` | Yes | 推論の信頼度。`high`: 明確な構造、`medium`: 一部推定あり、`low`: 大部分が推定 |

## architecture.md テンプレート

```markdown
<!--
  codemap: architecture
  generated_at: ...
  git_commit: ...
  tool_version: 1.0.0
  scan_scope: repo
  included_paths: ...
  excluded_paths: ...
  confidence: high
  DO NOT EDIT - このファイルは /update-codemaps で自動生成されます
-->

# Architecture: {プロジェクト名}

## Overview

- **Type**: {monorepo | app | library | cli | config}
- **Language**: {主要言語}
- **Framework**: {主要フレームワーク（あれば）}

## Directory Structure

```
{主要ディレクトリのみの ASCII tree}
```

## Entry Surfaces

| Surface | Path | Description |
|---|---|---|
| {type} | {path} | {説明} |

## Architecture Diagram

```
{データフロー / コンポーネント関係の ASCII 図}
```

## Key Dependencies

| Dependency | Purpose |
|---|---|
| {名前} | {用途} |

## Notes

- {低信頼の推論がある場合は「推定」と明記}
```

## Token Budget

- デフォルト: **1000 トークン**
- `.codemap.yml` の `token_budget` で上書き可能
- budget を超える場合は、以下の優先順位で情報を削減:
  1. Notes セクションを簡潔にする
  2. Key Dependencies を主要なもののみに絞る
  3. Directory Structure を浅くする（depth 2 まで）
  4. Entry Surfaces を主要なもののみに絞る

## セクション定義（差分比較用）

差分検知は以下のセクション単位で行う:

| セクション | 差分判定基準 |
|---|---|
| Overview | Type, Language, Framework の変更 |
| Directory Structure | ディレクトリの追加・削除・リネーム |
| Entry Surfaces | surface の追加・削除・パス変更 |
| Architecture Diagram | 図の構造的変更 |
| Key Dependencies | 依存関係の追加・削除 |

**大きな構造変更**: Overview の Type 変更、Entry Surfaces の 50% 以上変更、新規セクション追加 → ユーザー承認が必要

**軽微な更新**: 依存関係の追加のみ、ディレクトリ名の変更のみ、Notes の更新のみ → 自動更新

## .codemap.yml スキーマ

```yaml
# .codemap.yml (全フィールドオプション)
output_dir: docs/CODEMAPS        # 出力先ディレクトリ (デフォルト: docs/CODEMAPS)
token_budget: 1000               # トークン上限 (デフォルト: 1000)
extra_ignore:                    # built-in ignore に追加するパターン
  - generated/
  - proto/
include_generated:               # ignore を除外するパス（設計理解に必要な生成コード）
  - src/generated/client.ts
scan_scope: repo                 # repo | package (デフォルト: repo)
```
