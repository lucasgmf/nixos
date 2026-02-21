-- testing!
local builtin = require('telescope.builtin')require('telescope').setup = function()
    local actions = require "telescope.actions"
    return {
        mappings = {
            i = {
                ["<C-Down>"] = actions.cycle_history_next,
                ["<C-Up>"] = actions.cycle_history_prev,
                ["<C-f>"] = actions.preview_scrolling_down,
                ["<C-b>"] = actions.preview_scrolling_up,
            },
            n = {
                ["q"] = actions.close,
            },
        }
    }
end

local function opts(desc)
    return { desc = "Telescope: " .. desc }
end

local builtin = require "telescope.builtin"
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'telescope find "project files"' })
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'telescope find "git files"' })
vim.keymap.set('n', '<leader>pr', builtin.resume, opts("Resume last picker"))
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ")})
end,

{ desc = 'telescope find "project string"'})

-- testing these 2
require('telescope').load_extension('fzf')
require('dressing').setup{}

