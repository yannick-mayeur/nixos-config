local harpoon = require('harpoon')

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set('n', '<leader>di', function() harpoon:list():add() end)
vim.keymap.set('n', '<leader>do', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
vim.keymap.set('n', '<leader>du', function() harpoon:list():clear() end)

vim.keymap.set('n', '<leader>dy', function() harpoon:list():select(1) end)
vim.keymap.set('n', '<leader>du', function() harpoon:list():select(2) end)
vim.keymap.set('n', '<leader>di', function() harpoon:list():select(3) end)
vim.keymap.set('n', '<leader>do', function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set('n', '<C-S-P>', function() harpoon:list():prev() end)
vim.keymap.set('n', '<C-S-N>', function() harpoon:list():next() end)
