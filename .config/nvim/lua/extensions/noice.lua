-- extensions/noice.lua
-- コマンドラインポップアップ化 + LSP UI 改善
--
-- 責務分離:
--   noice = cmdline UI + messages 整形 + LSP UI（表示の整形・ルーティング担当）
--   snacks notifier = vim.notify() の最終レンダラー（通知の見た目担当）
--   noice は vim.notify を上書きしない（notify.enabled = false）

require('noice').setup {
    cmdline = {
        view = 'cmdline_popup',
    },
    -- snacks notifier と共存: noice は vim.notify を上書きしない
    notify = {
        enabled = false,
    },
    messages = {
        view = 'notify',  -- メッセージは snacks notifier 経由で表示
    },
    lsp = {
        override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
        },
        hover = {
            enabled = true,
        },
        signature = {
            enabled = true,
        },
        progress = {
            enabled = true,
        },
    },
    presets = {
        lsp_doc_border = true,
    },
}
