# trend-news スキル — 実行手順

## 概要

Reddit・はてなブックマーク・Hacker News からその日のテクノロジートレンドを収集し、Obsidian vault に日次ニュースとしてまとめて保存する。

## 定数

- **Vault パス**: `${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian_Vault`
- **保存先**: `$VAULT/ニュース/{YYYY-MM-DD}-{PERIOD}-tech-trends.md`
  - `PERIOD` は `AM` または `PM`（実行時の JST 時刻で自動判定）
- **タイムゾーン**: JST（Asia/Tokyo）基準で日付を決定
- **デフォルトジャンル**: テクノロジー全般

---

## Phase 1: トレンド収集

### 1.1 日付・時間帯の確定

JST 基準で当日の日付と時間帯を確定する。

```bash
DATE=$(TZ=Asia/Tokyo date +%Y-%m-%d)
HOUR=$(TZ=Asia/Tokyo date +%H)
# HOUR < 12 → PERIOD=AM, HOUR >= 12 → PERIOD=PM
```

AM 時は前日日付も算出:
```bash
PREV_DATE=$(TZ=Asia/Tokyo date -v-1d +%Y-%m-%d)  # macOS
```

#### 収集範囲の定義

| PERIOD | 収集範囲 (JST) | 説明 |
|--------|---------------|------|
| AM | 前日 18:00 JST <= time < 当日 12:00 JST | 前日夜~当日朝のニュース |
| PM | 当日 06:00 JST <= time < 現在時刻 | 当日朝~午後のニュース |

- AM/PM で 06:00-12:00 が意図的にオーバーラップ（朝のニュースの取りこぼし防止）
- 時刻比較は半開区間 `[start, end)` で統一

### 1.2 ソース別トレンド収集

各ソースに最適な方法で記事を収集する。**ソース間で並列実行**する。

#### Hacker News（HN API 経由 — プライマリソース）

WebSearch ではなく **Hacker News 公式 Firebase API** を使用する。WebSearch は HN の外部記事 URL を正確に返せないため。

**手順:**

1. **トップストーリー ID 取得**: WebFetch で `https://hacker-news.firebaseio.com/v0/topstories.json` を取得（最大 50 件の ID 配列）
2. **個別記事取得**: 上位 50 件（`MAX_HN_ITEM_FETCH`）の ID について WebFetch で `https://hacker-news.firebaseio.com/v0/item/{id}.json` を取得（並列、最大同時 5 件）。日付フィルタで絞り込まれるため、多めに取得する
3. **取得フィールド**: 各 item から `id`, `title`, `url`, `score`, `descendants`（コメント数）, `time`（Unix timestamp）を抽出
4. **時間帯フィルタ**: `item.time` を JST 変換し、PERIOD に応じた収集範囲でフィルタ:
   - **AM**: `前日 18:00 JST <= item.time < 当日 12:00 JST`
   - **PM**: `当日 06:00 JST <= item.time < 現在時刻`
   - 時刻比較は半開区間 `[start, end)` で統一（Unix timestamp を JST 変換後に比較）
5. **URL 決定**:
   - `item.url` が存在する → そのまま採用
   - `item.url` が無い（Ask HN, Show HN 等） → `https://news.ycombinator.com/item?id={id}` を採用

**制約:**
- `MAX_HN_ITEM_FETCH`: 最大 50 件まで（topstories の上位）
- 429/timeout 発生時: 指数バックオフ（2 秒 → 4 秒、最大 2 回リトライ）
- 日付フィルタ後の記事が 3 件未満の場合: `newstories.json` からも追加取得を試みる
- API 全体が失敗した場合: WebSearch フォールバック（従来の HN クエリ）を使用し、`status: partial` を設定

#### Reddit（WebSearch 経由）

| クエリ1（一覧取得用） | クエリ2（補完検索用） |
|---------------------|---------------------|
| `(site:reddit.com/r/programming OR site:reddit.com/r/technology) {YYYY-MM-DD}` | `reddit programming trending {YYYY-MM-DD}` |

#### はてなブックマーク（WebSearch 経由）

| クエリ1（一覧取得用） | クエリ2（補完検索用） |
|---------------------|---------------------|
| `site:b.hatena.ne.jp テクノロジー 人気エントリー {YYYY-MM-DD}` | `はてなブックマーク テクノロジー ホットエントリー {YYYY-MM-DD}` |

**AM 時の日付処理**: PERIOD が AM の場合、各クエリの `{YYYY-MM-DD}` 部分を `{PREV_DATE} OR {TODAY_DATE}` に変更する。PM 時は現行のまま（`{TODAY_DATE}` のみ）。

**ジャンル絞り込み**: 引数（`$ARGUMENTS`）でジャンルが指定された場合、各クエリにそのジャンルキーワードを追加する。

### 1.2a URL 検証ルール

全ソースの収集完了後、**全記事の URL を以下のルールで検証する**。

**ルートURL検出（要検証）:**
- URL のパスが `/` のみ、またはパスが空の場合（例: `https://example.com/`, `https://example.com`）は**要検証**フラグを立てる
- ただし、ルート URL が正しい場合もある（製品告知ページ等）ため、一律除外はしない

**要検証 URL の解決手順（優先順位）:**
1. **HN API 由来の URL**: `item.url` をそのまま信頼する（API から取得したルート URL は正しい可能性が高い）
2. **HN ディスカッションページ**: API 由来の URL が無い場合 → `https://news.ycombinator.com/item?id={id}` を使用
3. **記事タイトルで再 WebSearch**: 上記で解決しない場合のみ、記事タイトルの完全一致で再検索。**タイトルが完全一致する結果のみ採用**（部分一致や類似タイトルは不採用）
4. **除外**: いずれでも解決しない場合、その記事は最終出力から除外する

**URL 品質ルール（全フェーズ共通・厳守）:**
- **URL 推測の禁止**: ドメイン名やサイト名から URL を推測・生成してはならない。WebSearch / WebFetch / API から取得した実際の URL のみ使用可
- **URL 捏造の禁止**: 検索結果に含まれない URL を作り出してはならない。正確な URL が不明な記事は、URL なし（HN ディスカッションページ等の代替 URL）で掲載するか、除外する
- **ルート URL の許容条件**: API から直接取得した URL がルート URL である場合のみ許容。WebSearch 結果からルート URL しか得られなかった場合は要検証手順を実行すること

### 1.3 WebFetch による詳細補足

WebSearch の結果から特に重要そうな記事については、WebFetch で詳細ページの内容を補足取得する。HN API で取得済みの記事は WebFetch 不要。

### 1.4 取得失敗時のフォールバック

| 条件 | 対応 |
|------|------|
| 1サイト取得失敗 | 残り2サイトで継続。frontmatter に `status: partial` を設定 |
| 2サイト以上失敗 | ユーザーに報告し、取得できたサイトのみで保存するか確認（AskUserQuestion） |
| 全サイト失敗 | 保存せずエラー報告して終了 |

### 1.5 記事数上限

| 段階 | 上限 |
|------|------|
| 候補収集 | 30-50件 |
| 重複除去後 | 自動削減 |
| 最終掲載数 | 12-18件 |

---

## Phase 2: 要約・整形

### 2.1 ランキング基準

以下の指標を総合してランキングを決定する:

1. **Engagement**: いいね数 / ブクマ数 / ポイント数
2. **Recency**: 投稿時刻の新しさ
3. **Cross-source overlap**: 複数サイトで同一ニュースが話題になっている

**engagement 取得不可時の代替指標:**
- WebSearch 結果の表示順位（上位ほど高評価）
- 投稿時刻の新しさ
- コメント数（取得可能な場合）

### 2.2 重複判定

同一ニュースの別URL検出:
- タイトルの類似度を比較
- ドメインが異なるが同一内容の記事はマージ
- マージした場合は出典を複数表記（例: `> 出典: Reddit, Hacker News`）

### 2.3 要約・タグ付け

- 各記事に **2-3行の日本語要約** を付与
- カテゴリタグを付与: `AI`, `Web開発`, `インフラ`, `セキュリティ`, `プログラミング言語`, `DevOps`, `データベース`, `モバイル`, `OSS`, `その他`

### 2.4 構成

- **Top Stories**: サイト横断で最も注目度の高い記事を5件選出
- **サイト別セクション**: 各サイトから3-5件（Top Stories と重複してよい）
- 最終的なユニーク記事数は 12-18件

---

## Phase 3: 重複確認 + Obsidian 保存

### 3.1 同日ファイルの確認

保存先パスに同日のファイルが存在するか確認する:

```
$VAULT/ニュース/{YYYY-MM-DD}-{PERIOD}-tech-trends.md
```

- **存在しない場合**: そのまま保存
- **存在する場合**: AskUserQuestion でユーザーに確認
  - 上書き
  - スキップ（保存しない）
  - 追記（既存ファイルの末尾に追加）

### 3.2 ノートの生成・保存

以下のテンプレートに従って Markdown ファイルを生成し、Write ツールで保存する。

```markdown
---
date: {YYYY-MM-DD}
type: daily-news
generated_at: "{YYYY-MM-DD}T{HH:MM:SS}+09:00"
coverage_period: "{PERIOD}"
coverage_range:
  from: "{開始時刻 ISO8601 e.g. 2026-03-04T18:00:00+09:00}"
  to: "{終了時刻 ISO8601 e.g. 2026-03-05T12:00:00+09:00}"
coverage_window: "{YYYY-MM-DD} {PERIOD} JST"
time_precision: "best-effort"
item_count: {記事数}
sources:
  - reddit
  - hatena-bookmark
  - hackernews
tags:
  - tech-trends
  - daily-digest
status: draft
---

# Tech Trends - {YYYY-MM-DD} {PERIOD}

> 収集期間: {YYYY-MM-DD} {PERIOD} (JST) | 記事数: {N}件 | ランキング基準: engagement + recency + cross-source overlap

## Top Stories

### 1. [記事タイトル](URL)
**[カテゴリタグ]** - 要約テキスト（2-3行）
> 出典: Reddit r/programming, Hacker News

### 2. ...
（Top 5 まで）

## Reddit

### [記事タイトル](URL)
要約...
（3-5件）

## はてなブックマーク

### [記事タイトル](URL)
要約...
（3-5件）

## Hacker News

### [記事タイトル](URL)
要約...
（3-5件）

---
*Generated by trend-news skill*
```

**frontmatter の status 値:**
- `draft`: 全サイト正常取得
- `partial`: 一部サイト取得失敗

**sources リスト**: 実際に取得できたサイトのみ列挙する。

**URL の記載ルール（テンプレート内 `[記事タイトル](URL)` の URL）:**
- API / WebSearch / WebFetch から取得した**実在する URL のみ**記載する
- URL が不明・取得失敗の記事は `[記事タイトル](https://news.ycombinator.com/item?id={id})` のように HN ディスカッションページ等の代替 URL を使用する
- **ドメインルートだけの URL（例: `https://github.com`）を記事リンクとして使用してはならない**（1.2a の検証手順を通過した場合を除く）

---

## Phase 4: 完了報告

保存完了後、ユーザーに以下を報告する:

- 保存パス（フルパス）
- 収集した記事数
- 収集期間（日付・時間帯 AM/PM）
- 主要トピック（Top 3 のタイトルを列挙）
- 取得失敗したサイトがあればその旨
