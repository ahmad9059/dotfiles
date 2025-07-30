-- VS Code Config
if vim.g.vscode then
  -- Minimal config for VSCode-Neovim

  -- Use system clipboard (so yank/copy in VSCode copies to system)
  vim.opt.clipboard:prepend { "unnamed", "unnamedplus" }

  -- Optional key mappings for consistency
  vim.keymap.set("n", "Y", '"+y', { noremap = true, silent = true })
  vim.keymap.set("v", "Y", '"+y', { noremap = true, silent = true })
  vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true, silent = true })
  vim.keymap.set("i", "<C-a>", "<Esc>ggVG", { noremap = true, silent = true })

  return
end

-- Neovim
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- force for global virtual_text
vim.diagnostic.config {
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
}

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
