-- extensions/aerial.lua
-- コードアウトライン（関数・クラス一覧のサイドパネル）

require('aerial').setup {
    backends = { 'lsp', 'treesitter', 'markdown', 'man' },
    layout = {
        max_width = { 40, 0.2 },
        min_width = 20,
        default_direction = 'right',
    },
    show_guides = true,
    filter_kind = false,
    -- aerial バッファ内でのキーマップ
    keymaps = {
        ['{'] = 'actions.prev',
        ['}'] = 'actions.next',
    },
}

-- Telescope 統合
local ok, telescope = pcall(require, 'telescope')
if ok then
    telescope.load_extension('aerial')
end
