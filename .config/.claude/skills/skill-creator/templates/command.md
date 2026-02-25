# コマンドファイルテンプレート

配置先: `~/.config/.claude/commands/{command-name}.md`

```markdown
{スキルの目的を1文で説明}

`~/.claude/skills/{skill-name}/SKILL.md` を読み込み、指示に従って実行してください。

{引数がある場合}
要件: $ARGUMENTS
```

## 置換ルール

| プレースホルダ | 説明 |
|-------------|------|
| `{スキルの目的を1文で説明}` | コマンドの概要 |
| `{skill-name}` | スキルディレクトリ名 |
| `{引数がある場合}` | 引数がなければこの行を削除 |

## バリエーション

### 引数なし（固定動作）
```markdown
{スキルの目的を1文で説明}

`~/.claude/skills/{skill-name}/SKILL.md` を読み込み、指示に従って実行してください。
```

### 引数あり（自然言語入力）
```markdown
{スキルの目的を1文で説明}

`~/.claude/skills/{skill-name}/SKILL.md` を読み込み、指示に従って実行してください。

入力: $ARGUMENTS
```

### 引数あり（ファイルパス指定）
```markdown
{スキルの目的を1文で説明}

`~/.claude/skills/{skill-name}/SKILL.md` を読み込み、指示に従って実行してください。

対象: $ARGUMENTS
```
