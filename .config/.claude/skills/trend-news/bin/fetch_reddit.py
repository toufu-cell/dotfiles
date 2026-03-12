#!/usr/bin/env python3
"""Reddit JSON API から指定 subreddit のホット投稿を取得する。

標準ライブラリのみ使用（pip install 不要）。

Usage:
    python3 fetch_reddit.py <subreddit> [limit]

Examples:
    python3 fetch_reddit.py programming 15
    python3 fetch_reddit.py technology 10
"""

import json
import sys
import urllib.request


def fetch_reddit(subreddit: str, limit: int = 15) -> None:
    url = f"https://www.reddit.com/r/{subreddit}/hot.json?limit={limit}"
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "trend-news-skill/1.0"},
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read().decode())
    except Exception as e:
        print(f"ERROR: Failed to fetch r/{subreddit}: {e}", file=sys.stderr)
        sys.exit(1)

    for post in data.get("data", {}).get("children", []):
        d = post["data"]
        title = d.get("title", "")
        permalink = f"https://www.reddit.com{d.get('permalink', '')}"
        score = d.get("score", 0)
        num_comments = d.get("num_comments", 0)
        created_utc = d.get("created_utc", 0)
        url_link = d.get("url", "")
        print(json.dumps({
            "title": title,
            "permalink": permalink,
            "url": url_link,
            "score": score,
            "num_comments": num_comments,
            "created_utc": created_utc,
            "subreddit": subreddit,
        }, ensure_ascii=False))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <subreddit> [limit]", file=sys.stderr)
        sys.exit(1)
    sub = sys.argv[1]
    lim = int(sys.argv[2]) if len(sys.argv) > 2 else 15
    fetch_reddit(sub, lim)
