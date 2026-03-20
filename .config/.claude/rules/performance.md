# Execution Efficiency

## Context Management

- 大規模な multi-file 変更、広範囲 refactor、複雑なデバッグでは、早めに plan を作り、文脈が肥大化する前に要約して区切り直す
- 単一ファイルの小変更や独立した utility 作成では、不要なファイルを読まずに最小コンテキストで進める

## Reasoning Budget

- 軽量で反復的な作業では過剰に重い推論を避ける
- 設計判断、曖昧性の高い不具合調査、影響範囲の広い変更では深い推論を優先する

## Failure Handling

- build / lint / test が失敗したら、最初の具体的なエラーを起点に1種類ずつ直す
- 各修正後に再検証し、複数の問題を同時に触りすぎない
