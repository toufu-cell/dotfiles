# SKILL.md テンプレート: コマンド起動型

サイズ目安: ~300B

```markdown
---
name: {skill-name}
description: {スキルの目的を1文で}
---

詳細な手順は `INSTRUCTIONS.md` を参照（このスキルのディレクトリ内）。
```

## 置換ルール

| プレースホルダ | 説明 |
|-------------|------|
| `{skill-name}` | スキル名（kebab-case） |
| `{スキルの目的を1文で}` | 50文字以内で簡潔に |

## 注意

- コマンドファイル（`~/.config/.claude/commands/{skill-name}.md`）が必須
- SKILL.md 自体は最小限。ロジックは INSTRUCTIONS.md に書く
