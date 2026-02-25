# 品質チェックリスト

生成したスキルの品質を検証する。全 CRITICAL が Pass するまでリリースしない。

---

## CRITICAL（必須）

- [ ] `SKILL.md` が存在する
- [ ] `INSTRUCTIONS.md` が存在する
- [ ] frontmatter に `name` がある
- [ ] frontmatter に `description` がある
- [ ] frontmatter が正しい YAML（`---` で囲まれている）

## HIGH（強く推奨）

- [ ] SKILL.md のサイズ ≤ 700B（自動発動型は ≤ 1200B）
- [ ] 発動パターンに応じた必須セクションがある
  - 自動発動型: 「発動条件」「誤発動抑止」セクション
  - 文脈判断型: 「使用タイミング」セクション
  - 常時ルール型: description に最重要ルールが含まれる
- [ ] スキル名が既存スキルと重複しない
- [ ] コマンド名が既存コマンドと重複しない
- [ ] コマンド起動型にはコマンドファイルが生成されている

## MEDIUM（推奨）

- [ ] SKILL.md に `INSTRUCTIONS.md` への参照文がある
- [ ] INSTRUCTIONS.md にエラーハンドリングの記述がある
- [ ] コマンドファイルに `$ARGUMENTS` の参照がある（引数を取る場合）

---

## 検証コマンド例

```bash
# ファイル存在チェック
ls ~/.claude/skills/{skill-name}/SKILL.md
ls ~/.claude/skills/{skill-name}/INSTRUCTIONS.md

# frontmatter チェック
head -5 ~/.claude/skills/{skill-name}/SKILL.md

# サイズチェック
wc -c ~/.claude/skills/{skill-name}/SKILL.md

# 既存スキルとの重複チェック
ls ~/.claude/skills/

# 既存コマンドとの重複チェック
ls ~/.config/.claude/commands/
```
