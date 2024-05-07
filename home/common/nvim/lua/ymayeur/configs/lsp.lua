local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(_, bufnr)
  lsp_zero.default_keymaps({ buffer = bufnr })
end)

lsp_zero.format_on_save({
  format_opts = {
    async = false,
    timeout_ms = 500,
  },
  servers = {
    ['rubocop'] = { 'ruby' },
    ['eslint'] = { 'javascript', 'typescript', 'typescriptreact' },
  }
})

require('lspconfig').tsserver.setup({})
require('lspconfig').eslint.setup({
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})
require('lspconfig').lua_ls.setup({})

-- Configure solargraph with lspconfig
-- we say
require('lspconfig').solargraph.setup({
  cmd = { 'bundle', 'exec', 'solargraph', 'stdio' }
})
-- Configure rubocop with lspconfig
-- we say we want to use the rubocop provided by bundle
require('lspconfig').rubocop.setup({
  cmd = { 'bundle', 'exec', 'rubocop', '--lsp' }
})

require('copilot').setup({
  suggestion = {
    enabled = false,
    auto_trigger = false
  },
  panel = { enabled = false },
  filetypes = {
    nix = true,
    lua = true,
    ruby = true,
    javascript = true,
    typescript = true,
    typescriptreact = true,
  }
})


local cmp = require('cmp')
-- local _ = require('lsp-zero').cmp_action()

require('copilot_cmp').setup()

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

cmp.setup({
  sources = {
    { name = 'copilot',  group_index = 2 },
    { name = 'nvim_lsp', group_index = 2 },
    { name = 'buffer',   group_index = 2 },
    { name = 'luasnip',  group_index = 2 },
    { name = 'path',     group_index = 2 },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    format = require("lspkind").cmp_format({
      mode = "symbol",
      symbol_map = { Copilot = '' }
    })
  },
  mapping = cmp.mapping.preset.insert({
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({ select = false }),

    ["<Tab>"] = vim.schedule_wrap(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  }),
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  }
})
