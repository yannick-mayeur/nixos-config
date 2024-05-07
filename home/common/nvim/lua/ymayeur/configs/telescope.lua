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
vim.keymap.set('n', '<leader>fh', builtin.buffers, {})
vim.keymap.set('n', '<leader>fl', builtin.help_tags, {})
