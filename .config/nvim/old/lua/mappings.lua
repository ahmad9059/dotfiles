require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Insert mode navigation
map("i", "<A-j>", "<Left>", { desc = "Move left" })
map("i", "<A-l>", "<Right>", { desc = "Move right" })
map("i", "<A-k>", "<Down>", { desc = "Move down" })
map("i", "<A-i>", "<Up>", { desc = "Move up" })