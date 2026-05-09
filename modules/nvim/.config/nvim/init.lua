require("config.lazy")

local ts_builtin = require("telescope.builtin")

vim.opt.nu = true
vim.opt.termguicolors = true
vim.opt.tabstop = 8
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
-- au FileType html setlocal tabstop=8 expandtab shiftwidth=2 softtabstop=2
-- au FileType htmldjango setlocal tabstop=8 expandtab shiftwidth=2 softtabstop=2
-- nmap <F7> :NvimTreeToggle<CR>
vim.opt.smartindent = true

-- need a map method to handle the different kinds of key maps
local function map(mode, combo, mapping, opts)
  local options = {noremap = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, combo, mapping, options)
end
map('', '<F7>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>tt', ts_builtin.builtin, { desc = 'Open Telescope window' })
vim.keymap.set('n', '<leader>ff', ts_builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', ts_builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fm', ts_builtin.git_files, { desc = 'Telescope git files' })
vim.keymap.set('n', '<leader>fb', ts_builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', ts_builtin.help_tags, { desc = 'Telescope help tags' })
--local ts_extensions = require('telescope.extensions')
vim.keymap.set('n', '<leader>f]', ts_builtin.lsp_implementations, { desc = 'Telescope go to implementation' })
vim.keymap.set('n', '<leader>fd', ts_builtin.lsp_definitions, { desc = 'Telescope go to definition' })
vim.keymap.set('n', '<leader>f[', ts_builtin.lsp_references, { desc = 'Telescope go to usages' })
vim.keymap.set('n', '<leader>fs', ts_builtin.lsp_dynamic_workspace_symbols, { desc = 'Telescope find symbols' })
vim.keymap.set('n', '<leader>pm', '<cmd>Mason<CR>', { desc = 'Open Mason' })
vim.keymap.set('n', '<leader>pM', '<cmd>MasonToolsInstallSync<CR>', { desc = 'Install Mason tools' })
-- <C-w>d for showing LSP diagnostics in a window
vim.keymap.set('n', '<C-w>d', vim.diagnostic.open_float, { desc = 'Show LSP diagnostics' })
-- <c-space> for LSP omnifunc
vim.keymap.set('i', '<c-space>', function()
  vim.lsp.omnifunc(0, 'v:lua.vim.lsp.omnifunc')
end)
vim.api.nvim_set_keymap("i", "<S-TAB>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
-- vim.keymap.set('i', '<S-TAB>', require('CopilotChat.completion').complete, { desc = 'Copilot Chat complete' })
vim.cmd('colorscheme noctis_uva')
