local harpoon = require('harpoon')

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set('n', '<leader>dj', function() harpoon:list():add() end)
vim.keymap.set('n', '<leader>dk', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
vim.keymap.set('n', '<leader>dl', function() harpoon:list():clear() end)

vim.keymap.set('n', '<leader>d1', function() harpoon:list():select(1) end)
vim.keymap.set('n', '<leader>d2', function() harpoon:list():select(2) end)
vim.keymap.set('n', '<leader>d3', function() harpoon:list():select(3) end)
vim.keymap.set('n', '<leader>d4', function() harpoon:list():select(4) end)
vim.keymap.set('n', '<leader>d5', function() harpoon:list():select(5) end)
vim.keymap.set('n', '<leader>d6', function() harpoon:list():select(6) end)
vim.keymap.set('n', '<leader>d7', function() harpoon:list():select(7) end)
vim.keymap.set('n', '<leader>d8', function() harpoon:list():select(8) end)
vim.keymap.set('n', '<leader>d9', function() harpoon:list():select(9) end)
vim.keymap.set('n', '<leader>d0', function() harpoon:list():select(0) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set('n', '<leader>dp', function() harpoon:list():prev() end)
vim.keymap.set('n', '<leader>dn', function() harpoon:list():next() end)
