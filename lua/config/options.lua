require("config.remote_clipboard").setup()
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false

-- Python: basedpyright вместо pyright, ruff как линтер/форматтер.
-- Читается спекой lazyvim.plugins.extras.lang.python на этапе разбора спеков,
-- поэтому должно стоять здесь, а не в plugins/.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"
