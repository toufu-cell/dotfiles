#!/bin/zsh
# trend-news 自動実行スクリプト
# launchd から毎朝実行される想定
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

LOGDIR="$HOME/.claude/skills/trend-news/logs"
mkdir -p "${LOGDIR}"

PROMPT=$(cat <<'PROMPT_END'
/trend-news

テクノロジー全般。保存先は既定。失敗時は partial で保存し、プレビューは行わないこと。ファイル保存のみ行う。
PROMPT_END
)

echo "[$(date)] Starting trend-news" >> "${LOGDIR}/trend-news.log"

claude \
  -p "$PROMPT" \
  --allowedTools "WebFetch,WebSearch,Write,Read,Glob,Grep,Bash(python3 $HOME/.claude/skills/trend-news/bin/fetch_reddit.py *),Bash(grep *),Bash(TZ=* date *),Bash(date *),Bash(basename *),Bash(sort *),Bash(mkdir *),Bash(bash $HOME/.claude/skills/news-common/bin/archive-news.sh)" \
  >> "${LOGDIR}/trend-news.log" 2>&1

CLAUDE_EXIT=$?
echo "[$(date)] Exit code: $CLAUDE_EXIT" >> "${LOGDIR}/trend-news.log"
exit "$CLAUDE_EXIT"
