#!/bin/zsh
# trend-news: JST基準の日付・時間帯・収集範囲を算出して出力する
# Usage: bash ~/.claude/skills/trend-news/bin/compute-period.sh
# Output: KEY=VALUE 形式（1行1エントリ）

set -euo pipefail

DATE=$(TZ=Asia/Tokyo date +%Y-%m-%d)
HOUR=$(TZ=Asia/Tokyo date +%H)

if [ "$HOUR" -lt 12 ]; then
    PERIOD="AM"
    PREV_DATE=$(TZ=Asia/Tokyo date -v-1d +%Y-%m-%d)
    # AM: 前日 18:00 JST <= time < 当日 12:00 JST
    RANGE_FROM=$(TZ=Asia/Tokyo date -j -f "%Y-%m-%d %H:%M:%S" "${PREV_DATE} 18:00:00" +%s)
    RANGE_TO=$(TZ=Asia/Tokyo date -j -f "%Y-%m-%d %H:%M:%S" "${DATE} 12:00:00" +%s)
else
    PERIOD="PM"
    PREV_DATE=""
    # PM: 当日 06:00 JST <= time < 現在時刻
    RANGE_FROM=$(TZ=Asia/Tokyo date -j -f "%Y-%m-%d %H:%M:%S" "${DATE} 06:00:00" +%s)
    RANGE_TO=$(TZ=Asia/Tokyo date +%s)
fi

echo "DATE=${DATE}"
echo "HOUR=${HOUR}"
echo "PERIOD=${PERIOD}"
echo "PREV_DATE=${PREV_DATE}"
echo "RANGE_FROM=${RANGE_FROM}"
echo "RANGE_TO=${RANGE_TO}"
