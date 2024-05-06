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
require('lspconfig').solargraph.setup({
  cmd = { 'bundle', 'exec', 'solargraph', 'stdio' }
})
require('lspconfig').rubocop.setup({
  cmd = { 'bundle', 'exec', 'rubocop', '--lsp' }
})

local cmp = require('cmp')
local _ = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({ select = false }),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  }),
})
