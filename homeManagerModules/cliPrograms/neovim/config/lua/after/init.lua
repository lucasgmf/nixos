require("after.plugin.color")
require("after.plugin.gitsigns")
require("after.plugin.harpoon")
require("after.plugin.lualine")
require("after.plugin.mini") -- TODO: see this later 
require("after.plugin.startify")
require("after.plugin.telescope")
require("after.plugin.todo-comments")
-- TODO: UNDOTREE
-- TODO: zellij or tmux navigation
require("nvim-treesitter").setup{
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

-- TODO: Language models!
require("after.lang.lsp")
