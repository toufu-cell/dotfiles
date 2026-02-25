-- extensions/telescope.lua
-- Telescope（ファジーファインダー）設定

local telescope = require 'telescope'
local themes = require 'telescope.themes'

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ['<C-h>'] = 'which_key',
        ['<esc>'] = require('telescope.actions').close,
        ['<C-[>'] = require('telescope.actions').close,
      },
      n = {
        ['<C-h>'] = 'which_key',
      }
    },
    winblend = 20,
  },
  extensions = {
    fzf = {
      fuzzy = true,                   -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,    -- override the file sorter
      case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
    },
  },
}

telescope.load_extension 'fzf'

local builtin = require 'telescope.builtin'

-- キーマッピング
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
