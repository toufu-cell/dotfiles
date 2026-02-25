---
description: 指定トピックを調査してObsidian vaultにノートとして保存する
allowed-tools: Bash, WebSearch, WebFetch, Read, Write
---

指定されたトピックについて調査し、Obsidian vault にノートとして保存してください。

## 手順

以下のスキルファイルを参照してワークフローを実行すること:
- `~/.claude/skills/obsidian-research/SKILL.md` - メインワークフロー
- `~/.claude/skills/obsidian-research/templates.md` - ノートテンプレート
- `~/.claude/skills/obsidian-research/category-rules.md` - カテゴリ判定ルール

## 実行する5フェーズ

### Phase 1: 除外条件チェック

トピック `$ARGUMENTS` に機密情報（個人情報・APIキー・社外秘情報）が含まれていないか確認する。
含まれる場合は即座に中断してユーザーに警告する。

### Phase 2: カテゴリ判定 + 重複確認

1. `category-rules.md` の first-match rule に従いカテゴリ（IT用語集/Clippings/調査メモ）と信頼度を決定する
2. topic 正規化ルールを適用してファイル名を決定する
3. Vault の対応ディレクトリで既存ファイルを確認する:

```bash
VAULT="${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian_Vault"
ls "$VAULT/{保存先ディレクトリ}/" 2>/dev/null | grep -i "{正規化トピック名}"
```

### Phase 3: WebSearch で調査

以下の2クエリで検索する:
- 「{トピック} とは 仕組み」
- 「{トピック} 使い方 具体例」

必要に応じて WebFetch で詳細ページを取得する。
**status の決定は SKILL.md の「status 決定ルール（一元定義）」に従う。**
- 出典2件以上 + カテゴリ判定 HIGH → `verified`
- 出典1件以下、または MEDIUM/LOW → `draft`
- Clippings（URL直指定）: WebFetch 成功 → `verified`、失敗 → `draft`

### Phase 4: ノート整形

1. `templates.md` の対応テンプレートを適用する
2. 既存 IT用語集ノートとの関連リンクを `[[リンク]]` 形式で追加する
3. frontmatter の `retrieved_at` を ISO8601+TZ 形式で記入する

### Phase 5: ファイル保存

Write ツールでファイルを保存する（Bash の echo/cat リダイレクト禁止）。

**保存前にディレクトリ存在を確認・作成する（Bash で実行）:**
```bash
VAULT="${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian_Vault"
mkdir -p "$VAULT/IT用語集"
mkdir -p "$VAULT/Clippings"
mkdir -p "$VAULT/調査メモ"
```

保存パス:
- IT用語集: `$VAULT/IT用語集/{用語名}.md`
- Clippings: `$VAULT/Clippings/{タイトル}.md`
- 調査メモ: `$VAULT/調査メモ/{YYYY-MM-DD}-{トピック}.md`

完了後は以下の形式で報告する:
```
✅ 保存完了
- パス: {保存パス}
- status: {verified|draft}
- 出典数: {N}件
- 関連リンク: [[リンク1]], [[リンク2]]
```

## 調査トピック

$ARGUMENTS
