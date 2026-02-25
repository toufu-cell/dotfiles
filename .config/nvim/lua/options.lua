-- options.lua
-- Neovim基本オプション設定

-- global
-- 24ビットRGBカラー有効化
vim.api.nvim_set_option('termguicolors', true)
-- ファイル末尾に移動した際に4行分の余白設定
vim.api.nvim_set_option('scrolloff', 4)
-- 検索時に大文字小文字無視
vim.api.nvim_set_option('ignorecase', true)
-- 検索時に大文字が含まれていたらignorecaseを無効化
vim.api.nvim_set_option('smartcase', true)
-- 置換時に画面下部に検索結果を表示
vim.api.nvim_set_option('inccommand', 'split')
-- クリップボードの有効化
vim.api.nvim_set_option('clipboard', 'unnamedplus')

-- window
-- 行番号表示
vim.api.nvim_win_set_option(0, 'number', true)
-- 相対行番号表示
-- vim.api.nvim_win_set_option(0, 'relativenumber', true)
-- カーソル行を強調
vim.api.nvim_win_set_option(0, 'cursorline', true)
-- 標識のためのスペースを最左列に設ける
vim.api.nvim_win_set_option(0, 'signcolumn', 'yes:1')
-- テキストの折り返しを無効化
vim.api.nvim_win_set_option(0, 'wrap', false)
-- 非表示文字の可視化
vim.api.nvim_win_set_option(0, 'list', true)
-- 指定したカラム列を強調
-- vim.api.nvim_win_set_option(0, 'colorcolumn', '100')

-- buffer
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  pattern = '*',
  group = vim.api.nvim_create_augroup('buffer_set_options', {}),
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local filetype = vim.bo.filetype

    -- NvimTreeバッファではスワップファイルを無効化
    if filetype == 'NvimTree' or bufname:match('NvimTree') then
      vim.bo.swapfile = false
      vim.bo.bufhidden = 'wipe'
      return
    end

    -- 通常のバッファではswapfile作成を有効化
    vim.bo.swapfile = true
    -- tab幅
    vim.bo.tabstop = 4
    -- tabをスペースに変換
    vim.bo.expandtab = true
    -- オートインデントをtabstopの値に
    vim.bo.shiftwidth = 0
  end
})
