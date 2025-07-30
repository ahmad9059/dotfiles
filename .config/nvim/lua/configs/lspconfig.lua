local default_config = require "nvchad.configs.lspconfig"
local on_attach = default_config.on_attach
local capabilities = default_config.capabilities
local lspconfig = require "lspconfig"

-- ESLint
lspconfig.eslint.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = true

    -- Enable virtual text for ESLint diagnostics
    vim.diagnostic.config({
      virtual_text = true,
    }, bufnr)

    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
}

-- TypeScript and JavaScript (ts_ls)
lspconfig.ts_ls.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    vim.diagnostic.config({ virtual_text = true }, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  -- Auto Import
  settings = {
    typescript = {
      preferences = {
        includeCompletionsForModuleExports = true,
        includeCompletionsWithInsertText = true,
        importModuleSpecifierPreference = "non-relative", -- optional, you can use "relative" instead
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

-- Use telescope-ui-select for vim.ui.select()
vim.ui.select = require("telescope.themes").get_dropdown {}
require("telescope").load_extension "ui-select"

-- HTML
lspconfig.html.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- CSS
lspconfig.cssls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- TailwindCSS
lspconfig.tailwindcss.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- JSON
lspconfig.jsonls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- emmet_ls
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
        ["bem.enabled"] = true,
      },
    },
  },
}

-- Lua (with 'vim' global fix)
lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      runtime = {
        version = "LuaJIT",
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
