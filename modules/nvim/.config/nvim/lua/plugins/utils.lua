return {
    {
        'nvim-telescope/telescope.nvim',
        tag = 'v0.2.1',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local telescope = require("telescope")
            local find_command

            if vim.fn.executable("fd") == 1 then
                find_command = {
                    "fd",
                    "--type", "f",
                    "--strip-cwd-prefix",
                    "--hidden",
                    "--follow",
                    "--no-ignore-vcs",
                    "--exclude", ".git",
                    "--exclude", "node_modules",
                    "--exclude", "__pycache__",
                    "--exclude", ".mypy_cache",
                    "--exclude", ".pytest_cache",
                    "--exclude", ".venv",
                    "--exclude", ".terraform",
                    "--exclude", "dist",
                    "--exclude", "build",
                    "--exclude", "target",
                }
            else
                find_command = {
                    "rg",
                    "--files",
                    "--hidden",
                    "--follow",
                    "--no-ignore-vcs",
                    "--glob", "!.git/*",
                    "--glob", "!node_modules/*",
                    "--glob", "!__pycache__/*",
                    "--glob", "!.mypy_cache/*",
                    "--glob", "!.pytest_cache/*",
                    "--glob", "!.venv/*",
                    "--glob", "!.terraform/*",
                    "--glob", "!dist/*",
                    "--glob", "!build/*",
                    "--glob", "!target/*",
                }
            end

            telescope.setup({
                defaults = {
                    file_ignore_patterns = {
                        "^%.git/",
                        "node_modules/",
                        "__pycache__/",
                        "^%.mypy_cache/",
                        "^%.pytest_cache/",
                        "%.venv/",
                        "^%.terraform/",
                        "^dist/",
                        "^build/",
                        "^target/",
                    },
                },
                pickers = {
                    find_files = {
                        hidden = true,
                        no_ignore = true,
                        no_ignore_parent = true,
                        find_command = find_command,
                    },
                    live_grep = {
                        additional_args = function()
                            return {
                                "--hidden",
                                "--no-ignore-vcs",
                                "--glob", "!.git/*",
                                "--glob", "!**/node_modules/*",
                                "--glob", "!**/__pycache__/*",
                                "--glob", "!**/.mypy_cache/*",
                                "--glob", "!**/.pytest_cache/*",
                                "--glob", "!**/.venv/*",
                                "--glob", "!**/.terraform/*",
                                "--glob", "!**/dist/*",
                                "--glob", "!**/build/*",
                                "--glob", "!**/target/*",
                            }
                        end,
                    },
                },
            })
        end,
    },
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup {}
        end,
    },
    {
        "mason-org/mason.nvim",
        opts = {},
    },
    {
        "lewis6991/gitsigns.nvim",
        {},
    },
}
