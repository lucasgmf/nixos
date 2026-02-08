require("after.plugin.color")
require("after.plugin.telescope")
require("after.plugin.mini")
require("after.plugin.harpoon")
require("nvim-treesitter").setup{
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

