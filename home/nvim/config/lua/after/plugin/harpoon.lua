local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", mark.add_file, {desc = "harpoon: mark file"})
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, {desc = "harpoon: toggle ui"})

vim.keymap.set("n", "<C-1>", function() ui.nav_file(1) end, {desc = "harpoon: navigate to file index 1"})
vim.keymap.set("n", "<C-2>", function() ui.nav_file(2) end, {desc = "harpoon: navigate to file index 2"})
vim.keymap.set("n", "<C-3>", function() ui.nav_file(3) end, {desc = "harpoon: navigate to file index 3"})
vim.keymap.set("n", "<C-4>", function() ui.nav_file(4) end, {desc = "harpoon: navigate to file index 4"})
