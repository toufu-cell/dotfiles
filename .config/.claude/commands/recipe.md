---
description: 材料リストからレシピを考案してObsidian vaultに保存する
allowed-tools: Bash, Read, Write, WebSearch, WebFetch
---

# recipe スキル

材料リストを受け取り、レシピを考案して Obsidian vault の `レシピ/` フォルダに保存します。

## 引数

`$ARGUMENTS` に材料リストをスペース・読点・カンマ区切りで渡します。

例:
- `/recipe 鶏肉、玉ねぎ、卵`
- `/recipe chicken, onion, egg`
- `/recipe 豚バラ 白菜 豆腐 ごま油`

## 実行

`~/.claude/skills/recipe/SKILL.md` を参照してワークフローを実行してください。

入力された材料: $ARGUMENTS
