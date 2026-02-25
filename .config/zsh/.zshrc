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
