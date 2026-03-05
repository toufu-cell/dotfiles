#!/bin/bash
# Claude Code statusline script
# Displays: model | context bar | +/-lines | git branch
#           cost | duration | API time | tokens

input=$(cat)

# Extract all fields in one jq call
eval "$(echo "$input" | jq -r '
    @sh "MODEL=\(.model.display_name // "?")",
    @sh "PCT=\(.context_window.used_percentage // 0 | floor)",
    @sh "LINES_ADD=\(.cost.total_lines_added // 0)",
    @sh "LINES_DEL=\(.cost.total_lines_removed // 0)",
    @sh "COST=\(.cost.total_cost_usd // 0)",
    @sh "DURATION_MS=\(.cost.total_duration_ms // 0)",
    @sh "API_MS=\(.cost.total_api_duration_ms // 0)",
    @sh "IN_TOK=\(.context_window.current_usage.input_tokens // 0)",
    @sh "OUT_TOK=\(.context_window.current_usage.output_tokens // 0)",
    @sh "CACHE_READ=\(.context_window.current_usage.cache_read_input_tokens // 0)",
    @sh "CACHE_CREATE=\(.context_window.current_usage.cache_creation_input_tokens // 0)",
    @sh "CWD=\(.cwd // "")",
    @sh "WT_BRANCH=\(.worktree.branch // "")"
' 2>/dev/null)"

# Colors (ANSI truecolor)
GREEN='\033[38;2;151;201;195m'   # #97C9C3
YELLOW='\033[38;2;229;192;123m'  # #E5C07B
RED='\033[38;2;224;108;117m'     # #E06C75
GRAY='\033[38;2;74;88;92m'       # #4A585C
RESET='\033[0m'

# Color based on context usage
if [ "$PCT" -ge 80 ]; then
    BAR_COLOR="$RED"
elif [ "$PCT" -ge 50 ]; then
    BAR_COLOR="$YELLOW"
else
    BAR_COLOR="$GREEN"
fi

# Progress bar (10 segments)
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && BAR=$(printf "%${FILLED}s" | tr ' ' '▰')
[ "$EMPTY" -gt 0 ] && BAR="${BAR}$(printf "%${EMPTY}s" | tr ' ' '▱')"

# Git branch (use worktree.branch if available, otherwise run git)
BRANCH="$WT_BRANCH"
if [ -z "$BRANCH" ] && [ -n "$CWD" ]; then
    BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null)
fi

# Format tokens (compact: 1234 -> 1.2k, 12345 -> 12k)
fmt_tok() {
    local n=$1
    if [ "$n" -ge 1000000 ]; then
        printf "%.1fM" "$(echo "$n / 1000000" | bc -l)"
    elif [ "$n" -ge 1000 ]; then
        printf "%.1fk" "$(echo "$n / 1000" | bc -l)"
    else
        echo "$n"
    fi
}

# Format duration
fmt_dur() {
    local ms=$1
    local sec=$((ms / 1000))
    local min=$((sec / 60))
    local s=$((sec % 60))
    if [ "$min" -gt 0 ]; then
        printf "%dm%ds" "$min" "$s"
    else
        printf "%ds" "$s"
    fi
}

SEP="${GRAY} │ ${RESET}"

# Line 1: model | context bar % | +/-lines | branch
LINE1="${BAR_COLOR}${MODEL}${RESET}"
LINE1="${LINE1}${SEP}${BAR_COLOR}${BAR} ${PCT}%${RESET}"
LINE1="${LINE1}${SEP}${GREEN}+${LINES_ADD}${RESET}${GRAY}/${RESET}${RED}-${LINES_DEL}${RESET}"
if [ -n "$BRANCH" ]; then
    LINE1="${LINE1}${SEP}${GRAY}${BRANCH}${RESET}"
fi

# Line 2: cost | duration | API time | tokens
COST_FMT=$(printf '$%.2f' "$COST")
CACHE_TOK=$((CACHE_READ + CACHE_CREATE))
LINE2="${GRAY}${COST_FMT}${RESET}"
LINE2="${LINE2}${SEP}${GRAY}$(fmt_dur "$DURATION_MS")${RESET}"
LINE2="${LINE2}${SEP}${GRAY}API $(fmt_dur "$API_MS")${RESET}"
LINE2="${LINE2}${SEP}${GRAY}In:$(fmt_tok "$IN_TOK") Out:$(fmt_tok "$OUT_TOK") Cache:$(fmt_tok "$CACHE_TOK")${RESET}"

echo -e "$LINE1"
echo -e "$LINE2"
