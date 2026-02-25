-- extensions/lsp.lua
-- LSP（Language Server Protocol）設定
-- Neovim 0.11の新しいvim.lsp.config方式を使用

local mason_lspconfig = require('mason-lspconfig')

-- 補完機能を有効化
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- LSPがアタッチされた時の設定
local on_attach = function(client, bufnr)
  -- キーバインド設定
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- 定義ジャンプ
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  -- 型定義ジャンプ
  vim.keymap.set('n', 'gD', vim.lsp.buf.type_definition, opts)
  -- ホバー情報表示
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  -- 実装ジャンプ
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  -- 参照箇所を表示
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  -- シンボルをリネーム
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  -- コードアクション
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  -- フォーマット
  vim.keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format { async = true }
  end, opts)
  -- 診断（エラー・警告）を表示
  vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
  -- 前の診断へ移動
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  -- 次の診断へ移動
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
end

-- mason-lspconfigの設定
mason_lspconfig.setup({
  -- 自動的にインストールする言語サーバー
  ensure_installed = {
    'lua_ls',        -- Lua
    'ts_ls',         -- TypeScript/JavaScript
    'pyright',       -- Python
    'rust_analyzer', -- Rust
    'gopls',         -- Go
    'bashls',        -- Bash
    'jsonls',        -- JSON
    'yamlls',        -- YAML
    'omnisharp',     -- C#
  },
  -- 自動インストールを有効化
  automatic_installation = true,
})

-- 各言語サーバーの設定を定義（新方式）
-- Lua Language Server
vim.lsp.config['lua_ls'] = {
  cmd = { 'lua-language-server' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', '.git' },
  filetypes = { 'lua' },
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- TypeScript/JavaScript Language Server
vim.lsp.config['ts_ls'] = {
  cmd = { 'typescript-language-server', '--stdio' },
  root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Python (Pyright)
vim.lsp.config['pyright'] = {
  cmd = { 'pyright-langserver', '--stdio' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
  filetypes = { 'python' },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Rust Analyzer
vim.lsp.config['rust_analyzer'] = {
  cmd = { 'rust-analyzer' },
  root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
  filetypes = { 'rust' },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Go (gopls)
vim.lsp.config['gopls'] = {
  cmd = { 'gopls' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Bash Language Server
vim.lsp.config['bashls'] = {
  cmd = { 'bash-language-server', 'start' },
  root_markers = { '.git' },
  filetypes = { 'sh', 'bash' },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- JSON Language Server
vim.lsp.config['jsonls'] = {
  cmd = { 'vscode-json-language-server', '--stdio' },
  root_markers = { '.git' },
  filetypes = { 'json', 'jsonc' },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- YAML Language Server
vim.lsp.config['yamlls'] = {
  cmd = { 'yaml-language-server', '--stdio' },
  root_markers = { '.git' },
  filetypes = { 'yaml', 'yaml.docker-compose' },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- OmniSharp (C#)
vim.lsp.config['omnisharp'] = {
  cmd = { 'omnisharp' },
  root_markers = { '*.sln', '*.csproj', 'omnisharp.json', 'function.json', '.git' },
  filetypes = { 'cs', 'vb' },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- 各言語サーバーを有効化（新方式）
vim.lsp.enable('lua_ls')
vim.lsp.enable('ts_ls')
vim.lsp.enable('pyright')
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('gopls')
vim.lsp.enable('bashls')
vim.lsp.enable('jsonls')
vim.lsp.enable('yamlls')
vim.lsp.enable('omnisharp')

-- 診断表示の設定
vim.diagnostic.config({
  virtual_text = {
    prefix = '●',
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- 診断記号の設定
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
