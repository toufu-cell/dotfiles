-- extensions/lint.lua
-- nvim-lint 設定

local lint = require('lint')

lint.linters_by_ft = {
  python = { 'ruff' },
  javascript = { 'eslint_d' },
  javascriptreact = { 'eslint_d' },
  typescript = { 'eslint_d' },
  typescriptreact = { 'eslint_d' },
  sh = { 'shellcheck' },
  bash = { 'shellcheck' },
}

local lintGroup = vim.api.nvim_create_augroup('nvim_lint', { clear = true })

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = lintGroup,
  callback = function()
    lint.try_lint()
  end,
})
