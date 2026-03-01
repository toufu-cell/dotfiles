-- extensions/dap.lua
-- DAP（Debug Adapter Protocol）設定
-- nvim-dap + nvim-dap-ui の設定

local dap = require('dap')
local dapui = require('dapui')

-- ============================================================
-- UI セットアップ
-- ============================================================
dapui.setup()

-- デバッグ開始時に自動で UI を開く
dap.listeners.before.attach.dapui_config = function()
    dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
    dapui.open()
end

-- デバッグ終了時に自動で UI を閉じる
dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
end

-- ============================================================
-- ブレークポイントの視覚カスタマイズ
-- ============================================================
vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticOk', linehl = 'DiffAdd', numhl = '' })

-- ============================================================
-- キーバインド
-- ============================================================
-- デバッグ操作（Fキー）
vim.keymap.set('n', '<F5>', dap.continue, { desc = 'DAP: Continue' })
vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'DAP: Step Over' })
vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'DAP: Step Into' })

-- デバッグ操作（<leader>D プレフィックス）
-- ※ <leader>d は LSP 診断表示に使用中のため、DAP は大文字 D で分離
vim.keymap.set('n', '<leader>Dc', dap.continue, { desc = 'DAP: Continue' })
vim.keymap.set('n', '<leader>Dn', dap.step_over, { desc = 'DAP: Step Over' })
vim.keymap.set('n', '<leader>Di', dap.step_into, { desc = 'DAP: Step Into' })
vim.keymap.set('n', '<leader>Do', dap.step_out, { desc = 'DAP: Step Out' })
vim.keymap.set('n', '<leader>Db', dap.toggle_breakpoint, { desc = 'DAP: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>DB', function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'DAP: Conditional Breakpoint' })
vim.keymap.set('n', '<leader>Dr', dap.repl.open, { desc = 'DAP: Open REPL' })
vim.keymap.set('n', '<leader>Dl', dap.run_last, { desc = 'DAP: Run Last' })
vim.keymap.set('n', '<leader>Dx', dap.terminate, { desc = 'DAP: Terminate' })

-- UI 操作
vim.keymap.set('n', '<leader>Du', dapui.toggle, { desc = 'DAP UI: Toggle' })
vim.keymap.set({ 'n', 'v' }, '<leader>De', dapui.eval, { desc = 'DAP UI: Eval' })

-- ============================================================
-- アダプター設定: Python (debugpy)
-- ============================================================
-- Mason でインストール: :MasonInstall debugpy
dap.adapters.python = {
    type = 'executable',
    command = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python',
    args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
    {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        pythonPath = function()
            -- venv があればそちらを使用
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
                return cwd .. '/venv/bin/python'
            elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
                return cwd .. '/.venv/bin/python'
            else
                return 'python3'
            end
        end,
    },
}

-- ============================================================
-- アダプター設定: JavaScript / TypeScript (js-debug-adapter)
-- ============================================================
-- Mason でインストール: :MasonInstall js-debug-adapter
dap.adapters['pwa-node'] = {
    type = 'server',
    host = 'localhost',
    port = '${port}',
    executable = {
        command = vim.fn.stdpath('data') .. '/mason/bin/js-debug-adapter',
        args = { '${port}' },
    },
}

-- JavaScript
dap.configurations.javascript = {
    {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        cwd = '${workspaceFolder}',
    },
}

-- TypeScript（ts-node 経由）
dap.configurations.typescript = {
    {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch file (ts-node)',
        program = '${file}',
        cwd = '${workspaceFolder}',
        runtimeExecutable = 'npx',
        runtimeArgs = { 'ts-node' },
    },
    {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch file (compiled JS)',
        program = '${file}',
        cwd = '${workspaceFolder}',
    },
}

-- TypeScriptReact / JavaScriptReact は同じアダプターを再利用
dap.configurations.typescriptreact = dap.configurations.typescript
dap.configurations.javascriptreact = dap.configurations.javascript
