-- extensions/diffview.lua
-- Git差分のサイドバイサイド表示・ファイル履歴閲覧

require('diffview').setup({
    use_icons = true,
    view = {
        default = {
            layout = 'diff2_horizontal',
        },
        file_history = {
            layout = 'diff2_horizontal',
        },
    },
})
