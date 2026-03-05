-- extensions/bufferline.lua
-- バッファタブライン（上部にバッファ一覧を表示）

require('bufferline').setup {
    options = {
        mode = 'buffers',
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count, level)
            local icon = level:match('error') and ' ' or ' '
            return ' ' .. icon .. count
        end,
        -- nvim-tree との連携: ツリー幅分オフセット
        offsets = {
            {
                filetype = 'NvimTree',
                text = 'File Explorer',
                highlight = 'Directory',
                separator = true,
            },
        },
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = 'thin',
    },
}
