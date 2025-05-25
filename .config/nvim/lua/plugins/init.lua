return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    lazy = false, -- force immediate loading
    -- Still restrict commands if needed by filetype:
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      -- You can use either mini.nvim or nvim-web-devicons:
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("render-markdown").setup {
        file_types = { "markdown" }, -- ensure this matches your buffers
        log_level = "debug", -- for more detailed logs
      }
    end,
  },
  {
    "github/copilot.vim",
    lazy = false,
    config = function()
      -- Mapping tab is already used by NvChad
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ""
      -- The mapping is set to other key, see custom/lua/mappings
      -- or run <leader>ch to see copilot mapping section
    end,
  },
  {
    "mattn/emmet-vim",
    lazy = false, -- Ensures Emmet loads on start
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "javascript",
      },
    },
  },
}
