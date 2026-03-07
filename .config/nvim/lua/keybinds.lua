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
vim.keymap.set('n', '<Leader>w', function()
    if vim.bo.buftype == '' then
        vim.cmd('write')
    else
        vim.notify('Cannot save: special buffer', vim.log.levels.WARN)
    end
end, { desc = 'Save' })
vim.keymap.set('n', '<Leader>q', ':q<CR>', { desc = 'Quit' })

-- バッファ移動（bufferline.nvim 連携）
vim.keymap.set('n', '<Leader>bn', '<cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<Leader>bp', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<Leader>bd', function()
    local buf = vim.api.nvim_get_current_buf()
    vim.cmd('BufferLineCyclePrev')
    vim.cmd('bdelete ' .. buf)
end, { desc = 'Close buffer' })

-- nvim-treeから開いたバッファを一括で閉じる
vim.keymap.set('n', '<Leader>ba', function()
    local bufs = _G.nvim_tree_opened_bufs or {}
    local closed = 0
    for bufnr, _ in pairs(bufs) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            local ok = pcall(vim.api.nvim_buf_delete, bufnr, {})
            if ok then
                bufs[bufnr] = nil
                closed = closed + 1
            end
        else
            bufs[bufnr] = nil
        end
    end
    vim.notify('Closed ' .. closed .. ' nvim-tree buffer(s)', vim.log.levels.INFO)
end, { desc = 'Close all nvim-tree opened buffers' })

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
