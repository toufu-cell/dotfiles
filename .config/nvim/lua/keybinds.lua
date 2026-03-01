-- keybinds.lua
-- Neovimキーバインド設定

-- Normalモードで ; を : として使う（コマンド入力を簡単に）
vim.keymap.set('n', ';', ':')

-- Leaderキーをスペースに設定
vim.g.mapleader = ' '

-- ウィンドウ間の移動を簡単に
vim.keymap.set('n', '<C-h>', '<C-w>h')  -- 左のウィンドウへ
vim.keymap.set('n', '<C-j>', '<C-w>j')  -- 下のウィンドウへ
vim.keymap.set('n', '<C-k>', '<C-w>k')  -- 上のウィンドウへ
vim.keymap.set('n', '<C-l>', '<C-w>l')  -- 右のウィンドウへ

-- ESCの代わりにjjで挿入モードを抜ける
vim.keymap.set('i', 'jj', '<ESC>')


-- 保存と終了のショートカット
vim.keymap.set('n', '<Leader>w', ':w<CR>')   -- スペース+wで保存
vim.keymap.set('n', '<Leader>q', ':q<CR>')   -- スペース+qで終了

-- バッファ移動
vim.keymap.set('n', '<Leader>n', ':bnext<CR>')      -- 次のバッファ
vim.keymap.set('n', '<Leader>p', ':bprevious<CR>')  -- 前のバッファ

-- :messages の内容をクリップボードにコピー
vim.keymap.set('n', '<Leader>cm', function()
    local ok, result = pcall(vim.api.nvim_exec2, 'messages', { output = true })
    if ok then
        vim.fn.setreg('+', result.output)
        vim.notify('Messages copied to clipboard', vim.log.levels.INFO)
    else
        vim.notify('Failed to copy messages', vim.log.levels.ERROR)
    end
end, { desc = 'Copy :messages to clipboard', silent = true })
