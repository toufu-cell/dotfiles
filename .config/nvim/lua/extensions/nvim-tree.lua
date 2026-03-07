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

    -- nvim-treeから開いたバッファを追跡するテーブル（set形式）
    _G.nvim_tree_opened_bufs = _G.nvim_tree_opened_bufs or {}

    -- ファイルを開く操作をラップし、開いたバッファを追跡する
    local function track_open(open_fn)
      return function()
        local node = api.tree.get_node_under_cursor()
        if not node or (node.type ~= 'file' and node.type ~= 'link') then
          open_fn()
          return
        end
        -- open前のウィンドウ数を記録（picker キャンセル検出用）
        local wins_before = vim.api.nvim_list_wins()
        local cur_win = vim.api.nvim_get_current_win()
        local cur_buf = vim.api.nvim_win_get_buf(cur_win)
        open_fn()
        -- open後にウィンドウやバッファが変わっていなければpickerキャンセルと判断
        local new_win = vim.api.nvim_get_current_win()
        local new_buf = vim.api.nvim_win_get_buf(new_win)
        local wins_after = vim.api.nvim_list_wins()
        if new_win == cur_win and new_buf == cur_buf and #wins_after == #wins_before then
          return
        end
        -- pathを解決（symlinkの場合はlink_toを使用）
        local path = node.link_to or node.absolute_path
        local opened_bufnr = vim.fn.bufnr(path)
        if opened_bufnr ~= -1 and vim.api.nvim_buf_is_loaded(opened_bufnr) then
          _G.nvim_tree_opened_bufs[opened_bufnr] = true
        end
      end
    end

    -- デフォルトのキーマップを設定
    local function opts(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- ファイル/フォルダを開く・展開/折りたたむ（追跡付き）
    vim.keymap.set('n', '<CR>', track_open(api.node.open.edit), opts('Open'))
    vim.keymap.set('n', 'o', track_open(api.node.open.edit), opts('Open'))
    vim.keymap.set('n', '<2-LeftMouse>', track_open(api.node.open.edit), opts('Open'))

    -- 分割して開く（追跡付き）
    vim.keymap.set('n', '<C-v>', track_open(api.node.open.vertical), opts('Open: Vertical Split'))
    vim.keymap.set('n', '<C-x>', track_open(api.node.open.horizontal), opts('Open: Horizontal Split'))
    vim.keymap.set('n', '<C-t>', track_open(api.node.open.tab), opts('Open: New Tab'))

    -- プレビュー（追跡対象外: フォーカスがtreeに戻るため）
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
    custom = { '^%.git$', 'node_modules', '.cache' }, -- これらのディレクトリを非表示
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
