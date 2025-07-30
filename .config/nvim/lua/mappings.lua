require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Move cursor in insert mode with Alt + h/j/k/l
map("i", "<A-h>", "<Left>", { desc = "Move left in insert mode" })
map("i", "<A-j>", "<Down>", { desc = "Move down in insert mode" })
map("i", "<A-k>", "<Up>", { desc = "Move up in insert mode" })
map("i", "<A-l>", "<Right>", { desc = "Move right in insert mode" })

-- Select all with Ctrl + A
map("n", "<C-a>", "ggVG", { desc = "Select all" })
map("i", "<C-a>", "<ESC>ggVG", { desc = "Select all in insert mode" })
map("v", "<C-a>", "<ESC>ggVG", { desc = "Select all in visual mode" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Visual mode block selections
map("v", "<leader>i{", "vi{", { desc = "Select inside {}" })
map("v", "<leader>a{", "va{", { desc = "Select around {}" })

map("v", "<leader>i(", "vi(", { desc = "Select inside ()" })
map("v", "<leader>a(", "va(", { desc = "Select around ()" })

map("v", "<leader>i[", "vi[", { desc = "Select inside []" })
map("v", "<leader>a[", "va[", { desc = "Select around []" })

map("v", '<leader>i"', 'vi"', { desc = 'Select inside ""' })
map("v", '<leader>a"', 'va"', { desc = 'Select around ""' })

map("v", "<leader>i'", "vi'", { desc = "Select inside ''" })
map("v", "<leader>a'", "va'", { desc = "Select around ''" })

map("v", "<leader>i`", "vi`", { desc = "Select inside ``" })
map("v", "<leader>a`", "va`", { desc = "Select around ``" })

for i = 1, 9 do
  map("n", "<A-" .. i .. ">", function()
    local bufs = vim.fn.getbufinfo { buflisted = 1 }
    if bufs[i] then
      vim.api.nvim_set_current_buf(bufs[i].bufnr)
    end
  end, { desc = "Switch to listed buffer " .. i })
end

map({ "n", "t" }, "<A-i>", function()
  require("nvchad.term").toggle {
    pos = "float",
    id = "floatTerm",
    float_opts = {
      row = 0.1,
      col = 0.08,
      width = 0.8,
      height = 0.7,
      border = "rounded",
    },
  }
end, { desc = "Toggle floating terminal" })
