# setting
# 新規ファイル作成時のパーミッション
umask 022
# コアダンプを残さない
limit coredumpsize 0
# キーバインドをemacsに
bindkey -d
bindkey -e

# homebrew
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# antigen
if [ -f $HOME/.local/bin/antigen.zsh ]; then
  # antigenのキャッシュディレクトリをZDOTDIR配下に設定
  export ADOTDIR=$HOME/.config/zsh/.antigen
  # antigenがチェックするファイルをZDOTDIR配下の.zshrcに設定
  export ANTIGEN_CHECK_FILES=($HOME/.config/zsh/.zshrc)

  source $HOME/.local/bin/antigen.zsh

  # Load the oh-my-zsh's library
  antigen use oh-my-zsh

  antigen bundles <<EOBUNDLES
    # Bundles from the default repo (robbyrussell's oh-my-zsh)
    git
    # Syntax highlighting bundle.
    zsh-users/zsh-syntax-highlighting
    # Fish-like auto suggestions
    zsh-users/zsh-autosuggestions
    # Extra zsh completions
    zsh-users/zsh-completions
    # z
    rupa/z z.sh
    # abbr
    olets/zsh-abbr@main
EOBUNDLES

  # Load the theme
  antigen theme robbyrussell

  # Tell antigen that you're done
  antigen apply
fi

# history (antigen apply 後に配置して oh-my-zsh の設定を上書き)
# 履歴ファイルの保存先
export HISTFILE=${HOME}/.config/zsh/.zsh_history
# メモリに保存される履歴の件数
export HISTSIZE=1000
# 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000
export HISTFILESIZE=100000
# 重複を記録しない
setopt hist_ignore_dups
# 開始と終了を記録
setopt EXTENDED_HISTORY
# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups
# スペースで始まるコマンド行はヒストリリストから削除
setopt hist_ignore_space
# ヒストリを呼び出してから実行する間に一旦編集可能
setopt hist_verify
# 余分な空白は詰めて記録
setopt hist_reduce_blanks
# 古いコマンドと同じものは無視
setopt hist_save_no_dups
# historyコマンドは履歴に登録しない
setopt hist_no_store
# 保管時にヒストリを自動的に展開
setopt hist_expand
# history共有
setopt share_history

# shell options
# zshの補完候補が画面から溢れ出る時、それでも表示するか確認
LISTMAX=50
# バックグラウンドジョブの優先度(ionice)をbashと同じ挙動に
unsetopt bg_nice
# 補完候補を詰めて表示
setopt list_packed
# ビープ音を鳴らさない
setopt no_beep
# ファイル種別表示を補完候補の末尾に表示しない
unsetopt list_types

# mise
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# starship
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# alias
alias ls='ls -F -G'
alias vim='nvim'

# abbr (zsh-abbrがインストールされている場合のみ)
if command -v abbr &> /dev/null; then
  abbr -S ll='ls -l' >>/dev/null 2>&1
  abbr -S la='ls -A' >>/dev/null 2>&1
  abbr -S lla='ls -l -A' >>/dev/null 2>&1
  abbr -S v='vim' >>/dev/null 2>&1
  abbr -S g='git' >>/dev/null 2>&1
  abbr -S gst='git status' >>/dev/null 2>&1
  abbr -S gsw='git switch' >>/dev/null 2>&1
  abbr -S gbr='git branch' >>/dev/null 2>&1
  abbr -S gfe='git fetch' >>/dev/null 2>&1
  abbr -S gpl='git pull' >>/dev/null 2>&1
  abbr -S gad='git add' >>/dev/null 2>&1
  abbr -S gcm='git commit' >>/dev/null 2>&1
  abbr -S gmg='git merge' >>/dev/null 2>&1
  abbr -S gpsh='git push' >>/dev/null 2>&1
  abbr -S lg='lazygit' >>/dev/null 2>&1
fi

# Additional PATH settings
# Rust/Cargo
export PATH="$HOME/.cargo/bin:$PATH"
# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
export PATH="$PATH:$HOME/flutter/bin"
export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="/opt/homebrew/opt/node@20/bin:$PATH"

# Claude MCP shortcuts
alias mcp-blender-on="claude mcp add --scope local blender -- uvx blender-mcp && echo 'Blender MCP enabled for this project'"
alias mcp-blender-off="claude mcp remove --scope local blender && echo 'Blender MCP disabled for this project'"
alias mcp-blender-status="claude mcp list | grep blender"


# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
