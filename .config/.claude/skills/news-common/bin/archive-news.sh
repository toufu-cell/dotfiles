#!/usr/bin/env bash
# archive-news.sh — 7日超前のニュースファイルをアーカイブに移動
#
# 使い方: bash ~/.claude/skills/news-common/bin/archive-news.sh
#
# 対象: $VAULT/ニュース/ 直下の以下パターン
#   - YYYY-MM-DD-*-tech-trends.md
#   - YYYY-MM-DD-*-stock-news.md
#   - YYYY-MM-DD-*-stock-analysis.md
# 移動先: $VAULT/ニュース/archive/YYYY/MM/

set -euo pipefail

VAULT="${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian_Vault"
NEWS_DIR="${VAULT}/ニュース"
ARCHIVE_DIR="${NEWS_DIR}/archive"
RETENTION_DAYS=7

# JST基準の現在日付から保持期限を算出
CUTOFF_DATE=$(TZ=Asia/Tokyo date -j -v-${RETENTION_DAYS}d +%Y-%m-%d)
CUTOFF_EPOCH=$(date -j -f '%Y-%m-%d' "${CUTOFF_DATE}" +%s)

archived=0

for f in "${NEWS_DIR}"/*.md; do
    [ -f "$f" ] || continue

    basename=$(basename "$f")

    # ファイル名先頭の日付 (YYYY-MM-DD) を抽出
    if [[ ! "$basename" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})- ]]; then
        continue
    fi
    file_date="${BASH_REMATCH[1]}"

    # 対象パターンのみ処理
    case "$basename" in
        *-tech-trends.md|*-stock-news.md|*-stock-analysis.md) ;;
        *) continue ;;
    esac

    # 日付パース失敗時はスキップ
    file_epoch=$(date -j -f '%Y-%m-%d' "${file_date}" +%s 2>/dev/null) || continue

    # fileDate < cutoffDate ならアーカイブ対象
    if [ "$file_epoch" -lt "$CUTOFF_EPOCH" ]; then
        year="${file_date:0:4}"
        month="${file_date:5:2}"
        dest_dir="${ARCHIVE_DIR}/${year}/${month}"
        mkdir -p "$dest_dir"
        mv "$f" "$dest_dir/"
        archived=$((archived + 1))
    fi
done

if [ "$archived" -gt 0 ]; then
    echo "archived ${archived} file(s) to ${ARCHIVE_DIR}/"
else
    echo "no files to archive"
fi
