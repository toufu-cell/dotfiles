# Obsidian Research テンプレート集

このファイルは3種類の保存先に対応するノートテンプレートを定義する。
全テンプレートに `source_urls`, `source_titles`, `retrieved_at`（ISO8601+TZ）, `status` を必須フィールドとして含める。

---

## IT用語集テンプレート

```markdown
---
tags: 用語
kana: {よみがな}
status: verified
source_urls:
  - "{URL1}"
  - "{URL2}"
source_titles:
  - "{ページタイトル1}"
  - "{ページタイトル2}"
retrieved_at: "{YYYY-MM-DDTHH:MM:SS+09:00}"
---

=={1行サマリー（30字以内で要点を凝縮）}==

## 定義

{用語の正式な定義・概念説明}

## 特徴・仕組み

{技術的な特徴や動作原理の箇条書き}
- {特徴1}
- {特徴2}
- {特徴3}

## 使用例・ユースケース

{具体的な活用シーン・コード例}

```{言語}
{コード例（あれば）}
```

## 関連用語

- [[{関連用語1}]]
- [[{関連用語2}]]

## 参考リンク

- [{ページタイトル1}]({URL1})
- [{ページタイトル2}]({URL2})
```

**使用条件**:
- カテゴリ: IT技術用語
- 信頼度: 高（出典2件以上）→ `status: verified`
- 信頼度: 中（出典1件）→ `status: draft` に変更して使用

---

## 調査メモテンプレート

```markdown
---
tags:
  - research
  - {トピック関連タグ}
topic: "{トピック名}"
created: {YYYY-MM-DD}
status: verified
source_urls:
  - "{URL1}"
  - "{URL2}"
source_titles:
  - "{タイトル1}"
  - "{タイトル2}"
retrieved_at: "{YYYY-MM-DDTHH:MM:SS+09:00}"
---

## 概要

{トピックの要約・調査の背景}

## 詳細

### {サブトピック1}

{内容}

### {サブトピック2}

{内容}

## まとめ・考察

{調査結果のまとめ・気づき}

## 参照リンク

- [{タイトル1}]({URL1})
- [{タイトル2}]({URL2})

## 関連ノート

- [[{関連ノート1}]]
- [[{関連ノート2}]]
```

**使用条件**:
- カテゴリ: その他・汎用調査（IT用語集・Clippings に当てはまらない場合）
- 信頼度: 低（カテゴリ曖昧）→ `status: draft`
- ファイル名: `{YYYY-MM-DD}-{トピック}.md`

---

## Clippings テンプレート

```markdown
---
title: "{記事タイトル}"
source: "{URL}"
author:
  - "[[{著者名}]]"
published: {YYYY-MM-DD}
created: {今日の日付 YYYY-MM-DD}
description: "{記事の一行説明}"
tags:
  - clippings
status: verified
source_urls:
  - "{URL}"
source_titles:
  - "{記事タイトル}"
retrieved_at: "{YYYY-MM-DDTHH:MM:SS+09:00}"
---

{記事の要約・メモ・引用}

---

> [!NOTE] 元記事
> [{記事タイトル}]({URL})

## メモ・コメント

{読んだ感想・追加メモ}

## 関連ノート

- [[{関連ノート1}]]
```

**使用条件**:
- カテゴリ: URL が明示指定された場合
- 信頼度: URL直指定 + WebFetch 成功 → `status: verified`、WebFetch 失敗 → `status: draft`
- ファイル名: 記事タイトルそのまま（特殊文字は `_` に変換）

---

## status フィールドの値と意味

**status の決定ロジックは SKILL.md の「status 決定ルール（一元定義）」が唯一の基準。**
テンプレートのデフォルト値は仮置きなので、保存時に必ず上書きすること。

| 値 | 意味 | 付与条件 |
|----|-----|---------|
| `verified` | 十分な出典あり・信頼性高 | 出典2件以上 + カテゴリ判定 HIGH（または Clippings で WebFetch 成功） |
| `draft` | 出典不足または判定が曖昧 | 出典1件以下 / カテゴリ判定 MEDIUM/LOW / Clippings で WebFetch 失敗 |

**`draft` 付与時はノート冒頭に以下を追加する**:

```markdown
> [!WARNING] Draft
> このノートは出典が不足しているか、カテゴリ判定が曖昧です。
> 情報の正確性を確認してから活用してください。
```
