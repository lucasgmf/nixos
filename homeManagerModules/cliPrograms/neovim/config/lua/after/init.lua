require("after.plugin.color")
require("after.plugin.telescope")
require("after.plugin.mini")

require("nvim-treesitter.configs").setup{
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

