return {
    {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
    },
    {
     "zbirenbaum/copilot.lua",
     opts = {}
    },
    {
    "nvim-treesitter/nvim-treesitter",
    opts = {
            ensure_installed = { "lua", "python", "javascript", "typescript", "html", "css", "json", "yaml", "markdown", "bash", "rust" },
            highlight = {
                enable = true,
        },
        },
    lazy = false,
    build = ':TSUpdate',
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local servers = {
                clangd = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim" },
                            },
                        },
                    },
                },
                pyright = {},
                rust_analyzer = {},
                tailwindcss = {},
                ts_ls = {},
            }

            if vim.lsp.config and vim.lsp.enable then
                local enabled_servers = {}

                for server, config in pairs(servers) do
                    vim.lsp.config(server, config)
                    table.insert(enabled_servers, server)
                end

                vim.lsp.enable(enabled_servers)
            else
                local lspconfig = require("lspconfig")

                for server, config in pairs(servers) do
                    lspconfig[server].setup(config)
                end
            end
        end,
    },
    {
    "mason-org/mason-lspconfig.nvim",
    opts = {
        ensure_installed = {
            "clangd",
            "lua_ls",
            "pyright",
            "rust_analyzer",
            "tailwindcss",
            "ts_ls",
        },
        automatic_installation = true,
    },
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
            ensure_installed = {
                "clangd",
                "lua-language-server",
                "pyright",
                "rust-analyzer",
                "tailwindcss-language-server",
                "typescript-language-server",
            },
            run_on_start = true,
            start_delay = 3000,
        },
        dependencies = {
            "mason-org/mason.nvim",
        },
    },
    {
        "jglasovic/venv-lsp.nvim",
    config = function()
        require("venv-lsp").setup()
    end,

    },
}
