#!/bin/zsh
# trend-news: 直近7日分のダイジェストから既出URLを抽出して出力する
# Usage: bash ~/.claude/skills/trend-news/bin/collect-known-urls.sh
# Output: 1行1URL（sort -u済み）

set -euo pipefail

VAULT="${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian_Vault"
CUTOFF=$(TZ=Asia/Tokyo date -v-7d +%Y-%m-%d)

# ファイル名先頭の YYYY-MM-DD（10文字）が CUTOFF 以降のもののみ対象
for f in "$VAULT/ニュース/"*-tech-trends.md; do
    [ -f "$f" ] || continue
    fname=$(basename "$f")
    fdate=${fname:0:10}
    if [ "$fdate" ">" "$CUTOFF" ] || [ "$fdate" = "$CUTOFF" ]; then
        grep -hro 'https\?://[^ )]*' "$f" 2>/dev/null || true
    fi
done | sort -u
