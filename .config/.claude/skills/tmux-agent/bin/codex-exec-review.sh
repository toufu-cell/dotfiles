#!/usr/bin/env bash
# codex-exec-review.sh — exec モードでの Codex レビュー実行ラッパー
# 使い方:
#   bash codex-exec-review.sh "プロンプト"     # 引数からプロンプト
#   echo "長文" | bash codex-exec-review.sh -  # stdin からプロンプト
# Exit codes: 0=成功, 1=引数なし, 2=実行失敗, 3=タイムアウト

set -euo pipefail

TIMEOUT_SEC=120
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE_FILE="/tmp/codex-review-mode-${PPID}.txt"

# --- 遅延初期化: モードファイルがなければ codex-review-init.sh を実行 ---
if [ ! -f "$MODE_FILE" ]; then
    bash "${SCRIPT_DIR}/codex-review-init.sh" >/dev/null 2>&1 || true
fi

# --- 引数チェック ---
if [ $# -eq 0 ]; then
    echo "ERROR: プロンプトを引数に指定してください" >&2
    echo "使い方: bash codex-exec-review.sh \"プロンプト\"" >&2
    echo "        echo \"長文\" | bash codex-exec-review.sh -" >&2
    exit 1
fi

# --- 出力ファイル（mktemp で一意なパスを生成） ---
OUTPUT_FILE=$(mktemp /tmp/codex-exec-XXXXXX.md)

# --- クリーンアップ（trap で保証） ---
cleanup() {
    rm -f "$OUTPUT_FILE"
}
trap cleanup EXIT

# --- タイムアウト付き実行関数 ---
run_with_timeout() {
    if command -v timeout >/dev/null 2>&1; then
        # GNU timeout が利用可能
        timeout "$TIMEOUT_SEC" "$@"
        local rc=$?
        if [ $rc -eq 124 ]; then
            return 124
        fi
        return $rc
    else
        # macOS フォールバック: perl alarm
        perl -e "alarm($TIMEOUT_SEC); exec @ARGV" -- "$@"
        local rc=$?
        if [ $rc -eq 142 ]; then
            # 128 + SIGALRM(14) = 142
            return 142
        fi
        return $rc
    fi
}

# --- codex exec 実行 ---
EXEC_RC=0
if [ "$1" = "-" ]; then
    # stdin モード: パイプで直接渡す（ARG_MAX 回避）
    run_with_timeout codex exec --ephemeral -o "$OUTPUT_FILE" - <&0 || EXEC_RC=$?
else
    # 引数モード
    run_with_timeout codex exec --ephemeral -o "$OUTPUT_FILE" "$1" || EXEC_RC=$?
fi

# --- exit code の判定 ---
if [ $EXEC_RC -eq 124 ] || [ $EXEC_RC -eq 142 ]; then
    echo "ERROR: codex exec がタイムアウトしました（${TIMEOUT_SEC}秒）" >&2
    exit 3
elif [ $EXEC_RC -ne 0 ]; then
    echo "ERROR: codex exec が失敗しました（exit code: $EXEC_RC）" >&2
    exit 2
fi

# --- 出力ファイルの内容を stdout に出力 ---
if [ -s "$OUTPUT_FILE" ]; then
    cat "$OUTPUT_FILE"
else
    echo "(codex exec の出力が空でした)" >&2
fi
