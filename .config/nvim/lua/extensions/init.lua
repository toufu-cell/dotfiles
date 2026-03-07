-- extensions/init.lua
-- プラグインマネージャー lazy.nvim の設定

local plugins = {
  -- シンタックスハイライト
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufNewFile', 'BufReadPre' },
    build = ':TSUpdate',
  },
  -- カラースキーム
  {
    'rmehri01/onenord.nvim',
    event = { 'VimEnter' },
    priority = 1000,
    config = function() require 'extensions.onenord' end,
  },
  -- ステータスライン
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'auto',
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
        }
      }
    end,
  },
  -- 検索結果ハイライト
  {
    'kevinhwang91/nvim-hlslens',
    event = { 'SearchWrapped' },
    config = function()
      require('hlslens').setup()
      -- hlslens ロード時に scrollbar の検索ハンドラーを初期化
      local ok, search = pcall(require, 'scrollbar.handlers.search')
      if ok then
        search.setup()
      end
    end,
  },
  -- Git変更表示
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre' },
    config = function()
      require('gitsigns').setup()
    end,
  },
  -- スクロールバー
  {
    'petertriho/nvim-scrollbar',
    event = { 'BufNewFile', 'BufReadPre' },
    dependencies = {
      'lewis6991/gitsigns.nvim',
    },
    config = function()
      require('scrollbar').setup()
      require('scrollbar.handlers.gitsigns').setup()
      -- search ハンドラーは hlslens 側の config で初期化する
    end,
  },
  -- ファジーファインダー（ファイル・テキスト検索）
  {
    'nvim-telescope/telescope.nvim',
    keys = {
      { '<leader>ff', desc = 'Find: Files' },
      { '<leader>fg', desc = 'Find: Grep' },
      { '<leader>fb', desc = 'Find: Buffers' },
      { '<leader>fh', desc = 'Find: Help' },
    },
    tag = '0.1.4',
    config = function() require 'extensions.telescope' end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
  },
  -- ファイルエクスプローラー
  {
    'nvim-tree/nvim-tree.lua',
    keys = {
      { '<leader>ex', '<cmd>NvimTreeToggle<CR>', desc = 'Toggle file explorer' }
    },
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function() require 'extensions.nvim-tree' end,
  },
  -- LSP: 言語サーバーインストーラー
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    build = ':MasonUpdate',
    config = function()
      require('mason').setup()
    end,
  },
  -- LSP: masonとlspconfigの橋渡し
  {
    'williamboman/mason-lspconfig.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
    },
  },
  -- LSP: 言語サーバー設定
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function() require 'extensions.lsp' end,
  },
  -- 補完エンジン
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',     -- LSPソース
      'hrsh7th/cmp-buffer',        -- バッファソース
      'hrsh7th/cmp-path',          -- パスソース
      'L3MON4D3/LuaSnip',          -- スニペットエンジン
      'saadparwaiz1/cmp_luasnip',  -- スニペットソース
    },
    config = function() require 'extensions.cmp' end,
  },
  -- tmux-Neovim シームレスナビゲーション（C-h/j/k/l）
  {
    'christoomey/vim-tmux-navigator',
    event = 'VeryLazy',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
    },
    keys = {
      { '<C-h>', '<cmd>TmuxNavigateLeft<CR>', mode = { 'n', 't' }, desc = 'Navigate Left' },
      { '<C-j>', '<cmd>TmuxNavigateDown<CR>', mode = { 'n', 't' }, desc = 'Navigate Down' },
      { '<C-k>', '<cmd>TmuxNavigateUp<CR>', mode = { 'n', 't' }, desc = 'Navigate Up' },
      { '<C-l>', '<cmd>TmuxNavigateRight<CR>', mode = { 'n', 't' }, desc = 'Navigate Right' },
    },
  },
  -- Git差分ビューア（サイドバイサイド diff / ファイル履歴）
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = 'Diffview: Open' },
      { '<leader>gD', '<cmd>DiffviewClose<CR>', desc = 'Diffview: Close' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = 'Diffview: File History' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<CR>', desc = 'Diffview: Repo History' },
    },
    config = function() require 'extensions.diffview' end,
  },
  -- Flash: 高速ナビゲーション
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      -- 検索モードの設定
      modes = {
        -- 検索時にラベルを表示
        search = {
          enabled = true,
        },
        -- f/t/F/Tを強化
        char = {
          enabled = true,
          keys = { "f", "F", "t", "T" },
        },
      },
    },
    keys = {
      -- s: 任意の位置にジャンプ
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      -- S: Treesitterノードにジャンプ
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      -- r: リモート操作（operator-pending モードで使用）
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      -- R: Treesitter検索（ビジュアルモードで使用）
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- <c-s>: 検索中にFlashトグル
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  -- デバッグ: DAP クライアント + UI
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    keys = {
      { '<leader>Du', desc = 'DAP UI: Toggle' },
      { '<leader>Dc', desc = 'DAP: Continue' },
      { '<leader>Db', desc = 'DAP: Toggle Breakpoint' },
      { '<leader>DB', desc = 'DAP: Conditional Breakpoint' },
      { '<leader>Dn', desc = 'DAP: Step Over' },
      { '<leader>Di', desc = 'DAP: Step Into' },
      { '<leader>Do', desc = 'DAP: Step Out' },
      { '<leader>Dr', desc = 'DAP: Open REPL' },
      { '<leader>Dl', desc = 'DAP: Run Last' },
      { '<leader>Dx', desc = 'DAP: Terminate' },
      { '<leader>De', mode = { 'n', 'v' }, desc = 'DAP UI: Eval' },
      { '<F5>', desc = 'DAP: Continue' },
      { '<F10>', desc = 'DAP: Step Over' },
      { '<F11>', desc = 'DAP: Step Into' },
    },
    config = function() require 'extensions.dap' end,
  },
  -- Vimモーション練習（悪い習慣の矯正）
  {
    'm4xshen/hardtime.nvim',
    event = 'VeryLazy',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      max_count = 5,        -- 5回連打まで許可
      restriction_mode = 'hint',  -- ブロックせずヒントのみ表示
      disable_mouse = false,      -- マウス操作を許可
    },
  },
  -- 統合ターミナル（Claude Code / Codex CLI 専用ターミナル付き）
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    keys = {
      { '<C-\\>', desc = 'Terminal: Toggle' },
      { '<leader>tt', desc = 'Terminal: Toggle' },
      { '<leader>tf', desc = 'Terminal: Float' },
      { '<leader>tc', desc = 'Terminal: Claude Code' },
      { '<leader>tx', desc = 'Terminal: Codex CLI' },
    },
    config = function() require 'extensions.toggleterm' end,
  },
  -- snacks.nvim: ユーティリティ集（bigfile / notifier / words）
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      notifier = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      { ']]', function() Snacks.words.jump(vim.v.count1) end, desc = 'Next Reference', mode = { 'n' } },
      { '[[', function() Snacks.words.jump(-vim.v.count1) end, desc = 'Prev Reference', mode = { 'n' } },
    },
  },
  -- インデントガイド + スコープハイライト
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require 'extensions.indent-blankline' end,
  },
  -- バッファタブライン（上部にバッファ一覧）
  {
    'akinsho/bufferline.nvim',
    version = '*',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function() require 'extensions.bufferline' end,
  },
  -- コードアウトライン（関数・クラス一覧のサイドパネル）
  {
    'stevearc/aerial.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '<leader>ao', '<cmd>AerialToggle!<CR>', desc = 'Aerial: Toggle outline' },
      { '<leader>as', '<cmd>Telescope aerial<CR>', desc = 'Aerial: Symbol search' },
    },
    config = function() require 'extensions.aerial' end,
  },
  -- パンくずナビ（ウィンドウ上部に現在位置を表示）
  {
    'Bekaboo/dropbar.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
  },
  -- キーバインドチートシート（Leader 押下でポップアップ表示）
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      spec = {
        { '<leader>b', group = 'Buffer' },
        { '<leader>f', group = 'Find' },
        { '<leader>l', group = 'LSP' },
        { '<leader>t', group = 'Terminal' },
        { '<leader>D', group = 'DAP' },
        { '<leader>g', group = 'Git' },
        { '<leader>n', group = 'Noice' },
        { '<leader>a', group = 'Aerial' },
        { '<leader>e', group = 'Explorer' },
        { '<leader>c', group = 'Copy' },
      },
    },
  },
  -- コマンドラインポップアップ化 + LSP UI 改善
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    config = function() require 'extensions.noice' end,
  },
}

local opts = {
  checker = {
    enabled = true,
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      paths = {},
      disabled_plugins = {
        "gzip",
        "matchit",
        -- "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}

-- lazy.nvimの自動インストール
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop  -- Neovim 0.10以降との互換性
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(plugins, opts)
