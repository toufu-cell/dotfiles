-- extensions/indent-blankline.lua
-- インデントガイド + 現在スコープハイライト

local ibl = require('ibl')

ibl.setup {
    indent = {
        char = '│',
    },
    scope = {
        enabled = true,
        show_start = true,
        show_end = false,
    },
    exclude = {
        filetypes = {
            'NvimTree',
            'help',
            'lazy',
            'Trouble',
            'toggleterm',
            'DressingInput',
            'aerial',
        },
        buftypes = {
            'terminal',
            'nofile',
        },
    },
}

-- bigfile 対策: snacks.nvim が filetype を 'bigfile' に設定した場合は無効化
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'bigfile',
    callback = function(args)
        ibl.setup_buffer(args.buf, { enabled = false })
    end,
})
