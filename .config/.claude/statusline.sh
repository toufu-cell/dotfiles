#!/bin/bash
# Claude Code statusline script
# Displays: model | context bar | +/-lines | git branch
#           cost | duration | API time | tokens | rate limit

input=$(cat)

# --- Rate limit usage (cached, macOS only) ---
USAGE_CACHE="/tmp/claude-statusline-usage-${UID}.json"
USAGE_CACHE_TTL=60

fetch_usage() {
    local creds token tmpfile
    creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null) || return 1
    token=$(echo "$creds" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null) || return 1
    [ -z "$token" ] && return 1
    tmpfile=$(mktemp "${USAGE_CACHE}.XXXXXX") || return 1
    if curl -s --max-time 3 "https://api.anthropic.com/api/oauth/usage" \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        -H "Content-Type: application/json" \
        -o "$tmpfile" 2>/dev/null \
        && jq -e '.five_hour' "$tmpfile" >/dev/null 2>&1; then
        mv -f "$tmpfile" "$USAGE_CACHE"
    else
        rm -f "$tmpfile"
        return 1
    fi
}

# Only fetch on macOS, and only if cache is stale or missing
if [ "$(uname)" = "Darwin" ]; then
    if [ ! -f "$USAGE_CACHE" ]; then
        fetch_usage 2>/dev/null
    else
        cache_mod=$(stat -f%m "$USAGE_CACHE" 2>/dev/null || echo 0)
        now=$(date +%s)
        if [ $((now - cache_mod)) -gt $USAGE_CACHE_TTL ]; then
            fetch_usage 2>/dev/null
        fi
    fi
fi

# Read cached usage data
if [ -f "$USAGE_CACHE" ]; then
    RL_5H=$(jq -r '.five_hour.utilization // empty' "$USAGE_CACHE" 2>/dev/null)
    RL_7D=$(jq -r '.seven_day.utilization // empty' "$USAGE_CACHE" 2>/dev/null)
fi
RL_5H="${RL_5H:-?}"
RL_7D="${RL_7D:-?}"

# Format utilization (round to integer if numeric)
fmt_rl() {
    local v=$1
    if [ "$v" = "?" ]; then echo "?"; return; fi
    printf '%.0f' "$v" 2>/dev/null || echo "?"
}
RL_5H=$(fmt_rl "$RL_5H")
RL_7D=$(fmt_rl "$RL_7D")

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

# Braille Dots progress bar
# Each block is ⣿ (filled) or ⠶ (empty), with color based on usage
braille_bar() {
    local pct=$1 width=$2 color=$3 dim=$4
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    local bar=""
    local i
    for ((i=0; i<filled; i++)); do
        bar="${bar}${color}⣿${RESET}"
    done
    for ((i=0; i<empty; i++)); do
        bar="${bar}${dim}⣿${RESET}"
    done
    echo "$bar"
}

DIM='\033[38;2;55;65;68m'   # dim dots for empty segments
BAR_WIDTH=10
BAR=$(braille_bar "$PCT" "$BAR_WIDTH" "$BAR_COLOR" "$DIM")

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
LINE1="${LINE1}${SEP}${GRAY}ctx${RESET} ${BAR} ${BAR_COLOR}${PCT}%${RESET}"
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

# Rate limit color (red if >=80%, yellow if >=50%)
rl_color() {
    local v=$1
    if [ "$v" = "?" ]; then echo "$GRAY"; return; fi
    if [ "$v" -ge 80 ] 2>/dev/null; then echo "$RED"
    elif [ "$v" -ge 50 ] 2>/dev/null; then echo "$YELLOW"
    else echo "$GREEN"; fi
}
RL5_COLOR=$(rl_color "$RL_5H")
RL7_COLOR=$(rl_color "$RL_7D")

# Braille Dots rate limit bars
RL_BAR_WIDTH=5
if [ "$RL_5H" = "?" ]; then
    RL5_BAR="${GRAY}?${RESET}"
    RL5_PCT="?"
else
    RL5_BAR=$(braille_bar "$RL_5H" "$RL_BAR_WIDTH" "$RL5_COLOR" "$DIM")
    RL5_PCT="${RL_5H}%"
fi
if [ "$RL_7D" = "?" ]; then
    RL7_BAR="${GRAY}?${RESET}"
    RL7_PCT="?"
else
    RL7_BAR=$(braille_bar "$RL_7D" "$RL_BAR_WIDTH" "$RL7_COLOR" "$DIM")
    RL7_PCT="${RL_7D}%"
fi

LINE2="${LINE2}${SEP}${RL5_COLOR}5h${RESET} ${RL5_BAR} ${RL5_COLOR}${RL5_PCT}${RESET} ${RL7_COLOR}7d${RESET} ${RL7_BAR} ${RL7_COLOR}${RL7_PCT}${RESET}"

echo -e "$LINE1"
echo -e "$LINE2"
