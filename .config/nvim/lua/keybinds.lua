-- keybinds.lua
-- Neovimキーバインド設定

-- Normalモードで ; を : として使う（コマンド入力を簡単に）
vim.keymap.set('n', ';', ':')

-- Leaderキーをスペースに設定
vim.g.mapleader = ' '

-- ウィンドウ/ペイン間の移動は vim-tmux-navigator に委譲（extensions/init.lua）

-- ESCの代わりにjjで挿入モードを抜ける
vim.keymap.set('i', 'jj', '<ESC>')


-- 保存と終了のショートカット
vim.keymap.set('n', '<Leader>w', ':w<CR>')   -- スペース+wで保存
vim.keymap.set('n', '<Leader>q', ':q<CR>')   -- スペース+qで終了

-- バッファ移動（bufferline.nvim 連携）
vim.keymap.set('n', '<Leader>bn', '<cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<Leader>bp', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<Leader>bd', function()
    local buf = vim.api.nvim_get_current_buf()
    vim.cmd('BufferLineCyclePrev')
    vim.cmd('bdelete ' .. buf)
end, { desc = 'Close buffer' })

-- noice.nvim キーマップ
vim.keymap.set('n', '<Leader>nd', '<cmd>Noice dismiss<CR>', { desc = 'Noice: Dismiss messages' })
vim.keymap.set('n', '<Leader>nl', '<cmd>Noice last<CR>', { desc = 'Noice: Last message' })
vim.keymap.set('n', '<Leader>nh', '<cmd>Noice history<CR>', { desc = 'Noice: Message history' })

-- :messages の内容をクリップボードにコピー（noice.nvim 対応）
vim.keymap.set('n', '<Leader>cm', function()
    local has_noice, manager = pcall(require, 'noice.message.manager')
    if has_noice then
        local config = require('noice.config')
        local filter = config.options.commands.history.filter
        local messages = manager.get(filter, { history = true, sort = true })
        local lines = {}
        for _, msg in ipairs(messages) do
            table.insert(lines, msg:content())
        end
        vim.fn.setreg('+', table.concat(lines, '\n'))
        vim.notify('Noice history copied to clipboard', vim.log.levels.INFO)
        return
    end
    local ok, result = pcall(vim.api.nvim_exec2, 'messages', { output = true })
    if ok then
        vim.fn.setreg('+', result.output)
        vim.notify('Messages copied to clipboard', vim.log.levels.INFO)
    else
        vim.notify('Failed to copy messages', vim.log.levels.ERROR)
    end
end, { desc = 'Copy messages to clipboard', silent = true })
