-- extensions/conform.lua
-- conform.nvim formatter 設定

require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff_format' },
    javascript = { 'prettierd' },
    javascriptreact = { 'prettierd' },
    typescript = { 'prettierd' },
    typescriptreact = { 'prettierd' },
    json = { 'prettierd' },
    jsonc = { 'prettierd' },
    markdown = { 'prettierd' },
    sh = { 'shfmt' },
    bash = { 'shfmt' },
    go = { 'gofmt' },
    rust = { 'rustfmt' },
  },
  format_on_save = {
    lsp_fallback = true,
    timeout_ms = 2000,
  },
})
