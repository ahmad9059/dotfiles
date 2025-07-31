-- Define configuration options for formatting with conform.nvim
local options = {
  -- Set formatters for each filetype
  formatters_by_ft = {
    lua = { "stylua" }, -- Use stylua for Lua formatting
    javascript = { "prettierd" }, -- Use prettierd for JS
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    html = { "prettierd" },
    css = { "prettierd" },
    json = { "prettierd" },
    markdown = { "prettierd" },
    yaml = { "prettierd" },
  },

  -- Format on save settings
  format_on_save = {
    timeout_ms = 500, -- Timeout for formatting (in milliseconds)
    lsp_fallback = true, -- Use LSP formatter if no formatter is configured above
  },
}

-- Return the options table to be used by conform.nvim
return options
