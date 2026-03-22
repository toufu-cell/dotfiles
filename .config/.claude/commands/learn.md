---
description: セッション中の気づきをパターンとして保存する
---

セッション中に発見したパターン・ルール・気づきを `~/.claude/skills/learned/` に永続化する。

## 品質ゲート（3点必須）

以下の3点が揃わない限り保存しない:

1. **situation**: どのような状況で適用するか
2. **rule**: 具体的なルール・パターン
3. **evidence**: なぜそのルールが正しいと言えるか（今回の経験）

$ARGUMENTS に上記3点が含まれない場合は、不足情報をユーザーに質問する。

## 保存フォーマット

`~/.claude/skills/learned/<pattern-name>.md` に以下の形式で保存:

```
---
name: <pattern-name>
description: <1行の要約>
learned_at: YYYY-MM-DD
---

## Situation
<状況>

## Rule
<ルール>

## Evidence
<根拠>
```

## 手順

1. $ARGUMENTS の内容から situation / rule / evidence を抽出（不足なら質問）
2. 保存前に `~/.claude/skills/learned/` 内の既存パターンを Glob で重複チェック
3. パターン名は kebab-case で、内容から推定
4. `mkdir -p ~/.claude/skills/learned/` でディレクトリ確保
5. Write ツールでファイルを保存
6. 保存完了を報告

$ARGUMENTS
