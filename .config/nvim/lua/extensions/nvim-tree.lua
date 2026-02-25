-- extensions/nvim-tree.lua
-- nvim-tree（ファイルエクスプローラー）設定

require('nvim-tree').setup {
  -- ファイルシステムのウォッチャーを無効化（パフォーマンス向上）
  disable_netrw = true,
  hijack_netrw = true,

  -- ビュー設定
  view = {
    width = 30,
    side = 'left',
  },

  -- nvim-treeバッファのオプション設定
  on_attach = function(bufnr)
    local api = require('nvim-tree.api')

    -- nvim-treeバッファではスワップファイルを無効化
    vim.bo[bufnr].swapfile = false
    vim.bo[bufnr].bufhidden = 'wipe'

    -- デフォルトのキーマップを設定
    local function opts(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- ファイル/フォルダを開く・展開/折りたたむ
    vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))

    -- 分割して開く
    vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
    vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts('Open: Horizontal Split'))
    vim.keymap.set('n', '<C-t>', api.node.open.tab, opts('Open: New Tab'))

    -- プレビュー
    vim.keymap.set('n', '<Tab>', api.node.open.preview, opts('Open Preview'))

    -- ファイル操作
    vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
    vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
    vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
    vim.keymap.set('n', 'x', api.fs.cut, opts('Cut'))
    vim.keymap.set('n', 'c', api.fs.copy.node, opts('Copy'))
    vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))

    -- その他
    vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
    vim.keymap.set('n', 'q', api.tree.close, opts('Close'))
    vim.keymap.set('n', 'g?', api.tree.toggle_help, opts('Help'))
  end,

  -- レンダラー設定
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
      glyphs = {
        default = '',
        symlink = '',
        folder = {
          arrow_closed = '',
          arrow_open = '',
          default = '',
          open = '',
          empty = '',
          empty_open = '',
          symlink = '',
          symlink_open = '',
        },
        git = {
          unstaged = '✗',
          staged = '✓',
          unmerged = '',
          renamed = '➜',
          untracked = '★',
          deleted = '',
          ignored = '◌',
        },
      },
    },
  },

  -- フィルター設定
  filters = {
    dotfiles = false, -- 隠しファイルを表示
    custom = { '.git', 'node_modules', '.cache' }, -- これらのディレクトリを非表示
  },

  -- Git統合
  git = {
    enable = true,
    ignore = false,
  },

  -- アクション設定
  actions = {
    open_file = {
      quit_on_open = false, -- ファイルを開いてもツリーを閉じない
      window_picker = {
        enable = true,
      },
    },
  },
}
