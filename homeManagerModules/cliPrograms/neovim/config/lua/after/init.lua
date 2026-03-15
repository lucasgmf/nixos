require("after.plugin.color")
require("after.plugin.gitsigns")
require("after.plugin.harpoon")
require("after.plugin.lualine")
require("after.plugin.mini") -- TODO: see this later
require("after.plugin.startify")
require("after.plugin.telescope")
require("after.plugin.todo-comments")
require("after.plugin.undotree")
require("after.plugin.color-override")

-- TODO: UNDOTREE
-- TODO: zellij or tmux navigation

require("nvim-treesitter").setup {
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

require("after.lang.lsp")
require("after.lang.cmp")
-- TODO: rustaceanvim
