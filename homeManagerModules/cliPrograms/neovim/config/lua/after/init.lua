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
require("nvim-treesitter").setup {
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

-- TODO: Language models!

-- Set LSP log level (default is 'warn')
-- Options: 'trace', 'debug', 'info', 'warn', 'error', 'off'
vim.lsp.set_log_level('error') -- Only log errors, not warnings/info/debug

require("after.lang.lsp")
-- TODO: Completions
