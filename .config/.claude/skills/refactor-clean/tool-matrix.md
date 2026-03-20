# tool-matrix - 言語別ツール一覧

## 検出ツール

| 言語 | 推奨ツール | コマンド | 検出対象 |
|------|-----------|---------|----------|
| JS/TS | knip | `npx knip` | 未使用 files, exports, dependencies |
| JS/TS | depcheck | `npx depcheck` | 未使用 npm dependencies |
| JS/TS | ts-prune | `npx ts-prune` | 未使用 TypeScript exports |
| Python | vulture | `vulture src/` | 未使用 Python コード |
| Go | deadcode | `deadcode ./...` | 未使用 Go コード（将来対応） |
| Rust | cargo-udeps | `cargo +nightly udeps` | 未使用 Rust 依存（将来対応） |

## 検証コマンド（フォールバック用）

**優先**: repo 定義済みコマンドを使用（package.json scripts, pyproject.toml, Makefile）

**フォールバック**: repo 定義が見つからない場合のみ以下を使用:

| 言語 | build | typecheck | lint | test |
|------|-------|-----------|------|------|
| JS/TS | `npm run build` | `npx tsc --noEmit` | `npx eslint .` | `npm test` |
| Python | - | `mypy .` | `ruff check .` | `pytest` |

## Grep フォールバック手順

検出ツールが利用できない場合の手動検出手順:

1. Grep で `export` / `def` / `class` を検索し、`import` / 呼び出し元がないものを候補として列挙
2. **Grep 結果は全て CAUTION 扱い**（SAFE 判定は不可）
3. 必ず手動確認またはユーザー承認を経てから削除
