vim.lsp.set_log_level('error')

-- ============================================================
-- Line lengths
-- ============================================================
local LINE_LENGTHS = {
    python = 88,
    lua    = 120,
    go     = 100,
    c      = 100,
    cpp    = 100,
}

-- vim.opt.colorcolumn = tostring(LINE_LENGTHS.python)

-- Format on save
vim.api.nvim_create_autocmd('BufWritePre', {
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false, -- errors while typing
    severity_sort = true,
})

-- Keymaps set up on every LSP attach
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local bufnr = event.buf
        local function opts(desc)
            return { desc = "LSP: " .. desc, buffer = bufnr, nowait = true, remap = false }
        end
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("Code action"))
        vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, opts("Format buffer"))
        vim.keymap.set("n", "<leader>cs", builtin.lsp_document_symbols, opts("Find symbols"))
        vim.keymap.set("n", "gd", function() builtin.lsp_definitions({ reuse_win = true }) end, opts("Goto definition"))
        vim.keymap.set("n", "gr", function() builtin.lsp_references({ reuse_win = true }) end, opts("Goto references"))
        vim.keymap.set("n", "gi", function() builtin.lsp_implementations({ reuse_win = true }) end,
            opts("Goto Implementation"))
        vim.keymap.set("n", "gt", function() builtin.lsp_type_definitions({ reuse_win = true }) end,
            opts("Goto Type Definition"))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover docs"))
    end
})

-- Define LSP server configurations
local servers = {
    marksman = { -- markdown
        cmd = { 'marksman', 'server' },
        filetypes = { 'markdown', 'markdown.mdx' },
        root_dir = vim.fs.root(0, { '.marksman.toml', '.git' }),
    },
    clangd = { -- c / cpp
        cmd = { 'clangd' },
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
        root_dir = vim.fs.root(0, { '.clangd', 'compile_commands.json', 'compile_flags.txt', '.git' }),
    },
    pylsp = { -- python
        cmd = { 'pylsp' },
        filetypes = { 'python' },
        root_dir = vim.fs.root(0, { 'pyproject.toml', 'setup.py', '.git' }),
        settings = {
            pylsp = {
                plugins = {
                    black = { enabled = true, line_length = LINE_LENGTHS.python },
                    mypy = { enabled = true, live_mode = true },
                    pyflakes = { enabled = false },
                    pycodestyle = { enabled = false },
                    mccabe = { enabled = false },
                }
            }
        }
    },
    lua_ls = { -- lua
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_dir = vim.fs.root(0, { '.luarc.json', '.luarc.jsonc', '.stylua.toml', '.git' }),
        settings = {
            Lua = {
                format = {
                    defaultConfig = {
                        max_line_length = tostring(LINE_LENGTHS.lua),
                    }
                }
            }
        }
    },
    gopls = { -- go
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_dir = vim.fs.root(0, { 'go.work', 'go.mod', '.git' }),
    },
    nil_ls = { -- nix
        cmd = { 'nil' },
        filetypes = { 'nix' },
        root_dir = vim.fs.root(0, { 'flake.nix', '.git' }),
    },
}

-- Register and enable all servers
for name, config in pairs(servers) do
    vim.lsp.config(name, config)
    vim.lsp.enable(name)
end
