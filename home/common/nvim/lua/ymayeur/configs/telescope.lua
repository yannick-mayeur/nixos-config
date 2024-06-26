local actions = require "telescope.actions"

require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,                   -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,    -- override the file sorter
      case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
    mappings = {
      i = {
        ["<C-S-Q>"] = actions.send_selected_to_qflist + actions.open_qflist,
      },
    }
  }
}

require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>fj', builtin.find_files, {})
vim.keymap.set('n', '<leader>fk', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fws', function()
  local word = vim.fn.expand("<cword>")
  builtin.grep_string({ search = word })
end)
vim.keymap.set('n', '<leader>fWs', function()
  local word = vim.fn.expand("<cWORD>")
  builtin.grep_string({ search = word })
end)
vim.keymap.set('n', '<leader>fs', function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

vim.keymap.set('n', '<leader>fts', function()
  builtin.grep_string({ search = "TODO-YM" })
end)
