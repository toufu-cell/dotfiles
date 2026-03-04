require('toggleterm').setup({
  direction = 'horizontal',
  size = 15,
  open_mapping = false,
  start_in_insert = true,
  persist_size = true,
  close_on_exit = true,
  shell = vim.o.shell,
  shade_terminals = true,
  shading_factor = 2,
  float_opts = {
    border = 'curved',
    winblend = 3,
  },
})

local Terminal = require('toggleterm.terminal').Terminal

local claudeCode = Terminal:new({
  cmd = 'claude',
  direction = 'horizontal',
  size = 20,
  hidden = true,
  display_name = 'Claude Code',
  on_open = function(term)
    vim.cmd('startinsert!')
  end,
})

local codexCli = Terminal:new({
  cmd = 'codex',
  direction = 'horizontal',
  size = 20,
  hidden = true,
  display_name = 'Codex CLI',
  on_open = function(term)
    vim.cmd('startinsert!')
  end,
})

-- <C-\> で表示中の全 toggleterm を閉じる（hidden 含む）/ なければデフォルトを開く
local function toggleAll()
  -- include_hidden = true で hidden ターミナル（Claude Code, Codex CLI）も取得
  local terms = require('toggleterm.terminal').get_all(true)
  local closed = false
  for _, term in ipairs(terms) do
    if term:is_open() then
      term:close()
      closed = true
    end
  end
  if not closed then
    vim.cmd('ToggleTerm')
  end
end

_G._toggleterm_toggle_all = toggleAll

vim.keymap.set('n', '<C-\\>', toggleAll,
  { desc = 'Terminal: Toggle All', noremap = true })
-- t モードでは <C-\> が特殊プレフィックスのため、<Cmd> で直接実行
vim.keymap.set('t', '<C-\\>', '<Cmd>lua _toggleterm_toggle_all()<CR>',
  { desc = 'Terminal: Toggle All', noremap = true })

vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTerm<CR>',
  { desc = 'Terminal: Toggle' })
vim.keymap.set('n', '<leader>tf', '<cmd>ToggleTerm direction=float<CR>',
  { desc = 'Terminal: Float' })
vim.keymap.set('n', '<leader>tc', function() claudeCode:toggle() end,
  { desc = 'Terminal: Claude Code' })
vim.keymap.set('n', '<leader>tx', function() codexCli:toggle() end,
  { desc = 'Terminal: Codex CLI' })

-- ターミナル内でのキーマッピング
local termgrp = vim.api.nvim_create_augroup('ToggleTermMaps', { clear = true })
vim.api.nvim_create_autocmd('TermOpen', {
  group = termgrp,
  pattern = 'term://*',
  callback = function()
    local opts = { buffer = 0, noremap = true }
    vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', 'jj', [[<C-\><C-n>]], opts)
    -- C-h/j/k/l は vim-tmux-navigator に委譲（init.lua で t モード含めマッピング済み）
  end,
})
