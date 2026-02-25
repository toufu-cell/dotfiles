# SKILL.md テンプレート: 常時ルール型

サイズ目安: ~290B

```markdown
---
name: {skill-name}
description: {スキルの目的 + 最重要ルール1行}
---

詳細な手順は `INSTRUCTIONS.md` を参照（このスキルのディレクトリ内）。
```

## 置換ルール

| プレースホルダ | 説明 |
|-------------|------|
| `{skill-name}` | スキル名（kebab-case） |
| `{スキルの目的 + 最重要ルール1行}` | description 内に最も重要なルールを含める（70文字以内） |

## 注意

- description が唯一の「常時読み込まれる」情報なので、最重要ルールを必ず含める
- コマンドファイルは不要
- INSTRUCTIONS.md にルールの全体を記述
