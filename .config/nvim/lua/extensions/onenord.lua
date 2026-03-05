-- extensions/onenord.lua
-- onenord カラースキーム設定

local colors = require('onenord.colors').load()

require('onenord').setup {
  theme = 'dark',
  styles = {
    comments = 'NONE',
    strings = 'NONE',
    keywords = 'bold',
    functions = 'bold',
    variables = 'NONE',
    diagnostics = 'underline',
  },

  disable = {
    background = true,
  },

  custom_highlights = {
    MatchParen = { fg = colors.none, bg = colors.none, style = 'bold,underline' },
    GitSignsAddLnInline = { fg = colors.none, bg = colors.none, style = 'underline' },
    GitSignsChangeLnInline = { fg = colors.none, bg = colors.none, style = 'underline' },
    GitSignsDeleteLnInline = { fg = colors.none, bg = colors.none, style = 'bold,underline' },
    -- dropbar.nvim 背景透過対策
    WinBar = { fg = colors.light_gray, bg = colors.none },
    WinBarNC = { fg = colors.gray, bg = colors.none },
  },

  custom_colors = {
    mypink = '#FFB2CC',
  },
}
