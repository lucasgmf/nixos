vim.lsp.set_log_level('error')

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
    lsp_zero.default_keymaps({ buffer = bufnr })

    local function opts(desc)
        return { desc = "LSP: " .. desc, buffer = bufnr, nowait = true, remap = false }
    end

    local builtin = require "telescope.builtin"
    vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts("Code action"))
    -- vim.keymap.set("n", "<leader>R", function() vim.lsp.buf.rename() end, opts("Rename"))
    vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format() end, opts("Format buffer"))
    vim.keymap.set('n', '<leader>cs', builtin.lsp_document_symbols, opts("Find symbols"))
    vim.keymap.set("n", "gd", function() builtin.lsp_definitions({ reuse_win = true }) end, opts("Goto definition"))
    vim.keymap.set("n", "gr", function() builtin.lsp_references({ reuse_win = true }) end, opts("Goto references"))
    vim.keymap.set("n", "gi", function() builtin.lsp_implementations({ reuse_win = true }) end,
        opts("Goto Implementation"))
    vim.keymap.set("n", "gt", function() builtin.lsp_type_definitions({ reuse_win = true }) end,
        opts("Goto Type Definition"))
end)

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
    },
    lua_ls = { -- lua
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_dir = vim.fs.root(0, { '.luarc.json', '.luarc.jsonc', '.stylua.toml', '.git' }),
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
