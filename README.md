# Dotfiles

個人的な設定ファイルの管理リポジトリ

## 構成

```
dotfiles/
├── .config/
│   ├── .claude/        # Claude Code（CLAUDE.md, settings, commands, skills）
│   ├── .codex/         # Codex CLI（AGENTS.md）
│   ├── gh/             # GitHub CLI
│   ├── git/            # Git グローバル設定
│   ├── nvim/           # Neovim
│   ├── opencode/       # OpenCode（AGENTS.md, opencode.json）
│   ├── starship.toml   # Starship プロンプト
│   ├── tmux/           # tmux
│   ├── wezterm/        # Wezterm ターミナル
│   └── zsh/            # ZSH（.zshrc, .zshenv）
├── .zshenv             # ZDOTDIR 設定（エントリポイント）
├── .gitignore
└── README.md
```

## セットアップ

```bash
# 1. クローン
git clone <your-repo-url> ~/dotfiles

# 2. 既存の設定をバックアップ
mkdir -p ~/dotfiles_backup
for d in nvim wezterm zsh tmux gh git starship.toml; do
    mv ~/.config/$d ~/dotfiles_backup/ 2>/dev/null || true
done
mv ~/.zshenv ~/dotfiles_backup/ 2>/dev/null || true

# 3. シンボリックリンクを作成
ln -sf ~/dotfiles/.config/nvim ~/.config/nvim
ln -sf ~/dotfiles/.config/wezterm ~/.config/wezterm
ln -sf ~/dotfiles/.config/zsh ~/.config/zsh
ln -sf ~/dotfiles/.config/tmux ~/.config/tmux
ln -sf ~/dotfiles/.config/gh ~/.config/gh
ln -sf ~/dotfiles/.config/git ~/.config/git
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml
ln -sf ~/dotfiles/.config/.claude ~/.config/.claude
ln -sf ~/dotfiles/.config/.codex ~/.config/.codex
ln -sf ~/dotfiles/.config/opencode ~/.config/opencode
ln -sf ~/dotfiles/.zshenv ~/.zshenv

# 4. シェルを再起動
exec zsh
```

## 含まれる設定

### シェル / ターミナル
- **ZSH** - antigen, zsh-autosuggestions, シンタックスハイライト, XDG Base Directory 準拠
- **Starship** - カスタムプロンプト（Nord テーマベース）
- **tmux** - ターミナルマルチプレクサ
- **Wezterm** - カスタムキーバインド, editprompt

### エディタ
- **Neovim** - LSP, nvim-cmp, Telescope, nvim-tree, onenord テーマ

### Git
- **GitHub CLI** - エイリアス (`co` = `pr checkout`)
- **git/ignore** - グローバル gitignore

### AI コーディングツール
- **Claude Code** - グローバル指示 (CLAUDE.md), 権限設定, カスタムコマンド (31個), スキル (8種)
- **Codex CLI** - グローバル指示 (AGENTS.md)
- **OpenCode** - モデル設定, グローバル指示 (AGENTS.md)
