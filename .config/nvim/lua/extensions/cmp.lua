-- extensions/cmp.lua
-- nvim-cmp（補完エンジン）設定

local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  -- スニペットエンジンの設定
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  -- 補完ウィンドウの設定
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },

  -- キーマッピング
  mapping = cmp.mapping.preset.insert({
    -- 補完メニューをスクロール
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),

    -- 補完を表示
    ['<C-Space>'] = cmp.mapping.complete(),

    -- 補完を中止
    ['<C-e>'] = cmp.mapping.abort(),

    -- 補完を確定（Enterキー）
    ['<CR>'] = cmp.mapping.confirm({ select = true }),

    -- 次の候補へ移動（Tab）
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),

    -- 前の候補へ移動（Shift+Tab）
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),

  -- 補完ソースの設定（優先順位順）
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },  -- LSPからの補完
    { name = 'luasnip' },   -- スニペット補完
  }, {
    { name = 'buffer' },    -- バッファ内の単語
    { name = 'path' },      -- ファイルパス
  }),

  -- 補完候補の表示形式
  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    format = function(entry, vim_item)
      -- アイコン表示
      local kind_icons = {
        Text = "",
        Method = "󰆧",
        Function = "󰊕",
        Constructor = "",
        Field = "󰇽",
        Variable = "󰂡",
        Class = "󰠱",
        Interface = "",
        Module = "",
        Property = "󰜢",
        Unit = "",
        Value = "󰎠",
        Enum = "",
        Keyword = "󰌋",
        Snippet = "",
        Color = "󰏆",
        File = "󰈙",
        Reference = "",
        Folder = "󰉋",
        EnumMember = "",
        Constant = "󰏿",
        Struct = "",
        Event = "",
        Operator = "󰆕",
        TypeParameter = "󰅲",
      }

      vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
      vim_item.menu = ({
        nvim_lsp = '[LSP]',
        luasnip = '[Snippet]',
        buffer = '[Buffer]',
        path = '[Path]',
      })[entry.source.name]

      return vim_item
    end,
  },
})
