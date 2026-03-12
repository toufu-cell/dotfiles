---
name: trend-news
description: Hacker News・はてなブックマーク・Reddit・Zenn・Qiita からその日のテクノロジートレンドを収集し、Obsidian vault に日次ニュースとして保存する。
---

コマンド `/trend-news` で起動。詳細な手順は `INSTRUCTIONS.md` を参照（このスキルのディレクトリ内）。

## 取得方法

3グループ並列実行:
- **Group A (WebFetch)**: HN Firebase API, はてブ hotentry HTML, Zenn JSON API, Qiita RSS
- **Group B (Script)**: Reddit (`bin/fetch_reddit.py` — 標準ライブラリのみ)
- **Group C (WebSearch)**: 一般ニュース補助検索
