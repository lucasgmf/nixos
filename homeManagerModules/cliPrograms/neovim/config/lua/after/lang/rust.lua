vim.g.rustaceanvim = {
    tools = {},
    server = {
        default_settings = {
            ['rust-analyzer'] = {
                cargo = {
                    allTargets = false,
                    allFeatures = true,
                    loadOutDirsFromCheck = true,
                    buildScripts = {
                        enable = true,
                    },
                },
                -- Add clippy lints for Rust.
                checkOnSave = true,
                procMacro = {
                    enable = true,
                    ignored = {
                        ["async-trait"] = { "async_trait" },
                        ["napi-derive"] = { "napi" },
                        ["async-recursion"] = { "async_recursion" },
                    },
                },
            },
        },
    },
    dap = {},
}

require("crates").setup {
    completion = {
        cmp = {
            enabled = true,
        },

        crates = {
            enabled = true,
            max_results = 8, -- The maximum number of search results to display
            min_chars = 3,   -- The minimum number of charaters to type before completions begin appearing
        },
    },
}
