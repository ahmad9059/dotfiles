-- Load NvChad's default LSP config (includes `on_attach` and `capabilities`)
local default_config = require "nvchad.configs.lspconfig"
local on_attach = default_config.on_attach
local capabilities = default_config.capabilities

-- Load lspconfig plugin
local lspconfig = require "lspconfig"

-- HTML LSP
lspconfig.html.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- CSS LSP
lspconfig.cssls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- TailwindCSS LSP
lspconfig.tailwindcss.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- TypeScript and JavaScript (custom setup for tsserver)
lspconfig.ts_ls.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false -- disable formatting to avoid conflict with prettier

    vim.diagnostic.config({ virtual_text = true }, bufnr)

    -- Keymap for triggering code actions
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

    on_attach(client, bufnr)
  end,
  capabilities = capabilities,

  -- Command to start the TypeScript language server
  cmd = { "typescript-language-server", "--stdio" },

  -- Filetypes handled by this server
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },

  -- Language server preferences for better auto-import suggestions
  settings = {
    typescript = {
      preferences = {
        includeCompletionsForModuleExports = true,
        includeCompletionsWithInsertText = true,
        importModuleSpecifierPreference = "non-relative", -- use absolute paths
      },
    },
    javascript = {
      preferences = {
        includeCompletionsForModuleExports = true,
        includeCompletionsWithInsertText = true,
        importModuleSpecifierPreference = "non-relative",
      },
    },
  },
}

-- JSON LSP
lspconfig.jsonls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Emmet LSP (supports fast HTML/CSS abbreviation expansions)
lspconfig.emmet_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {
    "html",
    "css",
    "scss",
    "javascript",
    "javascriptreact",
    "typescriptreact",
  },
  init_options = {
    html = {
      options = {
        ["bem.enabled"] = true, -- Enable BEM-style abbreviations
      },
    },
  },
}

-- Use Telescope UI dropdown for vim.ui.select prompts (e.g. code actions)
vim.ui.select = require("telescope.themes").get_dropdown {}
require("telescope").load_extension "ui-select"

-- ESLint configuration
lspconfig.eslint.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = true -- enable formatting support

    -- Show linting errors inline as virtual text
    vim.diagnostic.config({
      virtual_text = true,
    }, bufnr)

    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
}

-- Lua LSP (custom settings to recognize 'vim' as global and disable telemetry)
lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" }, -- Avoid undefined global warning for 'vim'
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true), -- Make Neovim runtime files visible to LSP
        checkThirdParty = false, -- Disable third-party checks
      },
      runtime = {
        version = "LuaJIT", -- Lua runtime version used by Neovim
      },
      telemetry = {
        enable = false, -- Disable telemetry to respect privacy
      },
    },
  },
}
