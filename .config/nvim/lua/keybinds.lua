-- keybinds.lua
-- Neovimキーバインド設定

-- Normalモードで ; と : をスワップ（コマンド入力を楽にしつつ、元の ; も使えるようにする）
vim.keymap.set('n', ';', ':')
vim.keymap.set('n', ':', ';')

-- Leaderキーをスペースに設定
vim.g.mapleader = ' '

-- ウィンドウ/ペイン間の移動は vim-tmux-navigator に委譲（extensions/init.lua）

-- ESCの代わりにjjで挿入モードを抜ける
vim.keymap.set('i', 'jj', '<ESC>')

-- j/k を表示行移動にし、カウント付きの場合はジャンプリストに保存
-- @see https://eiji.page/blog/neovim-remeber-jump-jk/
vim.keymap.set({ 'n', 'x' }, 'j', function()
    if vim.v.count > 0 or #vim.fn.reg_recording() > 0 or #vim.fn.reg_executing() > 0 then
        return "m'" .. vim.v.count .. 'j'
    end
    return 'gj'
end, { expr = true })
vim.keymap.set({ 'n', 'x' }, 'k', function()
    if vim.v.count > 0 or #vim.fn.reg_recording() > 0 or #vim.fn.reg_executing() > 0 then
        return "m'" .. vim.v.count .. 'k'
    end
    return 'gk'
end, { expr = true })

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

-- :messages の内容をクリップボードにコピー（snacks notifier + noice.nvim + :messages）
local CM_SELF_MSGS = { 'Messages copied to clipboard', 'No messages to copy' }
vim.keymap.set('n', '<Leader>cm', function()
    local lines = {}
    local seen = {}
    local function add(text)
        if text and text ~= '' and not seen[text] then
            for _, self_msg in ipairs(CM_SELF_MSGS) do
                if text == self_msg then return end
            end
            seen[text] = true
            table.insert(lines, text)
        end
    end
    -- 1. snacks notifier の通知履歴
    pcall(function()
        for _, notif in ipairs(Snacks.notifier.get_history()) do
            add(notif.msg)
        end
    end)
    -- 2. noice.nvim の msg_show 履歴（active + history）
    pcall(function()
        local config = require('noice.config')
        if not config.is_running() then return end
        local manager = require('noice.message.manager')
        local filter = { event = 'msg_show' }
        for _, msg in ipairs(manager.get(filter, { sort = true })) do
            add(msg:content())
        end
        for _, msg in ipairs(manager.get(filter, { history = true, sort = true })) do
            add(msg:content())
        end
    end)
    -- 3. フォールバック: :messages
    if #lines == 0 then
        pcall(function()
            local result = vim.api.nvim_exec2('messages', { output = true })
            if result.output and result.output ~= '' then
                add(result.output)
            end
        end)
    end
    if #lines > 0 then
        vim.fn.setreg('+', table.concat(lines, '\n'))
        vim.notify('Messages copied to clipboard', vim.log.levels.INFO)
    else
        vim.notify('No messages to copy', vim.log.levels.WARN)
    end
end, { desc = 'Copy messages to clipboard', silent = true })

-- kensaku-search: / と ? のときだけローマ字→日本語変換を適用
vim.keymap.set('c', '<CR>', function()
    local cmdtype = vim.fn.getcmdtype()
    if cmdtype == '/' or cmdtype == '?' then
        return '<Plug>(kensaku-search-replace)<CR>'
    end
    return '<CR>'
end, { expr = true })
