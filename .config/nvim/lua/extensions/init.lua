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
    event = { 'VimEnter' },
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
      'kevinhwang91/nvim-hlslens',
    },
    config = function()
      require('scrollbar').setup()
      require('scrollbar.handlers.gitsigns').setup()
      require('scrollbar.handlers.search').setup()
    end,
  },
  -- ファジーファインダー（ファイル・テキスト検索）
  {
    'nvim-telescope/telescope.nvim',
    keys = {
      '<leader>ff', '<leader>fg', '<leader>fb', '<leader>fh'
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
  -- Vimモーション練習（悪い習慣の矯正）
  {
    'm4xshen/hardtime.nvim',
    lazy = false,
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      max_count = 5,        -- 5回連打まで許可
      restriction_mode = 'hint',  -- ブロックせずヒントのみ表示
      disable_mouse = false,      -- マウス操作を許可
    },
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
