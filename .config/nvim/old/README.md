# Installing NvChad Version 2.5
## Backup and remove old nvim config.
Backup old nvim config.
```
mv ~/.config/nvim ~/.config/nvim-old
```
Or remove old nvim config.
```
rm -rf ~/.config/nvim
```
Remove local/state and local/share
```
rm -rf ~/.local/state/nvim
rm -rf ~/.local/share/nvim
```
## Install NvChad.
Install required packages.
```
sudo pacman -S --needed neovim unzip luarocks xclip wl-clipboard
```
Install NvChad config from https://nvchad.com/docs/quickstart/install
```
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
```
Or this already configured version
```
git clone https://github.com/ProgrammingRainbow/NvChad-2.5 ~/.config/nvim && nvim
```
You can safely remove the `.git` and image files.
```
rm-rf ~/.config/nvim/.git
rm ~/.config/nvim/*.png
```
Edit the file `~/.config/nvim/lua/options.lua` to change tabs from 2 to 4 spaces. \
Original config is here https://github.com/NvChad/NvChad/blob/v2.5/lua/nvchad/options.lua
```
-- local o = vim.o
```
To this.
```
local o = vim.o

-- Indenting
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4

```
Edit `~/.config/nvim/.stylua.toml` to change indent width to 4 and to use parentheses.
```
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 4
quote_style = "AutoPreferDouble"
# call_parentheses = "None"
```
## Setup Format and Style with Conform.
Edit `~/.config/nvim/lua/plugins/init.lua` to load module on save.
```
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        config = function()
            require("configs.conform")
        end,
    },
```
Edit `~/.config/nvim/lua/configs/conform.lua` to enable format_on_save.
```
local options = {
    formatters_by_ft = {
        lua = { "stylua" },
    },

    format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        lsp_fallback = true,
    },
}

require("conform").setup(options)
```
## Setup Treesitter
https://github.com/nvim-treesitter/nvim-treesitter \
Added to the Top of `~/.config/nvim/lua/plugins/init.lua`. 
```
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("configs.treesitter")
        end,
    },
```
Create file `~/.config/nvim/lua/configs/treesitter.lua`. \
Copy from the internal one.
https://github.com/NvChad/NvChad/blob/v2.5/lua/nvchad/configs/treesitter.lua
```
local options = {
    ensure_installed = {
        "bash",
        "fish",
        "lua",
        "luadoc",
        "markdown",
        "printf",
        "toml",
        "vim",
        "vimdoc",
        "yaml",
    },

    highlight = {
        enable = true,
        use_languagetree = true,
    },

    indent = { enable = true },
}

require("nvim-treesitter.configs").setup(options)
```

## Basic Treesitter commands.
List Treesitter installed languages.
```
:TSInstallInfo
```
Install fish for treesitter.
```
:TSInstall fish
```
Update fish.
```
:TSUpdate fish
```
Update all.
```
:TSUpdate
```
Disable treesitter highlighting.
```
:TSDisable highlight
```
Enable treesitter highlighting.
```
:TSEnable highlight
```
## Treesitter language for filetype.
Check loaded treesitter language.
```
:lua print(require"nvim-treesitter.parsers".get_buf_lang())
```
or
```
:Inspect
```
Check filetype of buffer.
```
:echo &filetype
```
or
```
:set filetype?
```
Set filetype.
```
:set filetype=fish
```
## Setup LSPConfig.
https://github.com/neovim/nvim-lspconfig \
Edit file `~/.config/nvim/lua/plugins/init.lua`. \
Under Treesitter add an lspconfig entry.
```
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("nvchad.configs.lspconfig").defaults()
            require("configs.lspconfig")
        end,
    },
```
Edit file `~/.config/nvim/lua/configs/lspconfig.lua`. \
We will be adding a table that has a list of all servers configured. \
This will be used later in the mason-lspconfig to automate there installation. \
Then we will have a simple default_servers table for looping and setting up default configs. \
Using the NvChad default lua_ls found \
here https://github.com/NvChad/NvChad/blob/v2.5/lua/nvchad/configs/lspconfig.lua \
we will add love2d support `"${3rd}/love2d/library",` but also disable linting diagnostics.
```
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

-- list of all servers configured.
lspconfig.servers = {
    "lua_ls",
}

-- list of servers configured with default config.
local default_servers = {}

-- lsps with default config
for _, lsp in ipairs(default_servers) do
    lspconfig[lsp].setup({
        on_attach = on_attach,
        on_init = on_init,
        capabilities = capabilities,
    })
end

lspconfig.lua_ls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,

    settings = {
        Lua = {
            diagnostics = {
                enable = false, -- Disable all diagnostics from lua_ls
                -- globals = { "vim" },
            },
            workspace = {
                library = {
                    vim.fn.expand("$VIMRUNTIME/lua"),
                    vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                    vim.fn.stdpath("data") .. "/lazy/ui/nvchad_types",
                    vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
                    "${3rd}/love2d/library",
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
            },
        },
    },
})
```
## Setting up Linting.
https://github.com/mfussenegger/nvim-lint \
Edit file `~/.config/nvim/lua/plugins/init.lua`. \
Between LSPConfig and Confom add an entry for Linting.
```
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("configs.lint")
        end,
    },
```
Create file `~/.config/nvim/lua/configs/lint.lua`. \
`lint.linters_by_ft` is a key, value table for all linters to be configured. \
`lint.linters.laucheck.args = {` Will over write the arguments table for luacheck. \
To get the default args before editing use this command \
`:lua print(vim.inspect(require('lint').linters.luacheck.args))`. \
or unpack the original args into the table and add your new args below it.
Create an auto command to run the linter when opeing a buffer, saving or leaving insert mode.
```
local lint = require("lint")

lint.linters_by_ft = {
    lua = { "luacheck" },
}

lint.linters.luacheck.args = {
    unpack(lint.linters.luacheck.args),
    "--globals",
    "love",
    "vim",
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    callback = function()
        lint.try_lint()
    end,
})
```
## Setting up mason-conform.
https://github.com/zapling/mason-conform.nvim \
Edit the file `~/.config/nvim/lua/plugins/init.lua`. \
Below the conform entry add mason-conform.
```
    {
        "zapling/mason-conform.nvim",
        event = "VeryLazy",
        dependencies = { "conform.nvim" },
        config = function()
            require("configs.mason-conform")
        end,
    },
```
Create the file `~/.config/nvim/lua/configs/mason-conform.lua`. \
Any formatters you don't wish to auto install add to ignore_install table.
```
require("mason-conform").setup({
    -- List of formatters to ignore during install
    ignore_install = {},
})
```
## Setting up mason-lspconfig.
https://github.com/williamboman/mason-lspconfig.nvim \
Edit the file `~/.config/nvim/lua/plugins/init.lua`. \
Below the lspconfig entry add mason-lspconfig.
```
    {
        "williamboman/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-lspconfig" },
        config = function()
            require("configs.mason-lspconfig")
        end,
    },
```
Create the file `~/.config/nvim/lua/configs/mason-lspconfig.lua`. \
This entire file is simply creating a table of servers to pass into ensure_installed. \
There is also a table at the top to add any server that should not be installed.
```
local lspconfig = package.loaded["lspconfig"]

-- List of servers to ignore during install
local ignore_install = {}

-- Helper function to find if value is in table.
local function table_contains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- Build a list of lsp servers to install minus the ignored list.
local all_servers = {}
for _, s in ipairs(lspconfig.servers) do
    if not table_contains(ignore_install, s) then
        table.insert(all_servers, s)
    end
end

require("mason-lspconfig").setup({
    ensure_installed = all_servers,
    automatic_installation = false,
})
```
## Setting up mason-lint.
https://github.com/rshkarin/mason-nvim-lint \
Edit the file `~/.config/nvim/lua/plugins/init.lua`. \
Below the lint entry add mason-lint.
```
    {
        "rshkarin/mason-nvim-lint",
        event = "VeryLazy",
        dependencies = { "nvim-lint" },
        config = function()
            require("configs.mason-lint")
        end,
    },
```
Create the file `~/.config/nvim/lua/configs/mason-lint.lua`. \
This entire file is simply creating a table of linters to pass into ensure_installed. \
There is also a table at the top to add any linter that should not be installed.
```
local lint = package.loaded["lint"]

-- List of linters to ignore during install
local ignore_install = {}

-- Helper function to find if value is in table.
local function table_contains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- Build a list of linters to install minus the ignored list.
local all_linters = {}
for _, v in pairs(lint.linters_by_ft) do
    for _, linter in ipairs(v) do
        if not table_contains(ignore_install, linter) then
            table.insert(all_linters, linter)
        end
    end
end

require("mason-nvim-lint").setup({
    ensure_installed = all_linters,
    automatic_installation = false,
})
```
# C and C++
## UPDATE
I have changed the hack that was in place for clang_format since the video. \
Change file `~/.config/nvim/lua/configs/conform.lua`.
```
        c_cpp = { "clang-format" }, -- Hack to force download.
        c = { "clang_format" },
        cpp = { "clang_format" },
```
and
```
        clang_format = {
```
The a simpler way.
```
        c = { "clang-format" },
        cpp = { "clang-format" },
```
and
```
        ["clang-format"] = {
```
In `~/.config/nvim/lua/configs/lspconfig.lua`. The on_attach function takes client and bufnr parameters. It has almost no documentations and i have no idea if leaving it off affects anything. But it appears it should be provided.
```
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr)
```
## lspconfig
Edit file `~/.config/nvim/lua/configs/lspconfig.lua`. \
Add `"clangd",` to lspconfig.servers.
```
lspconfig.servers = {
    "lua_ls",
    "clangd",
}
```
Add a setup for clangd. This disables formatting.
```
lspconfig.clangd.setup({
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr)
    end,
    on_init = on_init,
    capabilities = capabilities,
})
```
## conform
Edit file `~/.config/nvim/lua/configs/conform.lua`. \
Add a C and C++ entry to formatters_by_ft.
```
        c = { "clang-format" },
        cpp = { "clang-format" },
```
Between formatters_by_ft and format_on_save tables add. This sets tab spacing to 4. The default is 2.
```
    formatters = {
        ["clang-format"] = {
            prepend_args = {
                "-style={ \
                IndentWidth: 4, \
                TabWidth: 4, \
                UseTab: Never, \
                AccessModifierOffset: 0, \
                IndentAccessModifiers: true, \
                PackConstructorInitializers: Never}",
            },
        },
    },
```
## treesitter
Edit file `~/.config/nvim/lua/configs/treesitter.lua`. \
Add syntax highlighting for c, c++, make and cmake.
```
        "c",
        "cmake",
        "cpp",
        "make",
```
# Golang
## UPDATE
I think all the formatters for Go only apply to actual .go files. So all non Go filetypes have been removed from `conform.lua`.
In `treesitter.lua` gotmpl has been added.
## lspconfig
Edit file `~/.config/nvim/lua/configs/lspconfig.lua`. \
Add `"gopls",` to lspconfig.servers.
```
lspconfig.servers = {
    "lua_ls",
    "gopls",
}
```
Add a setup for gopls. This disables formatting and adds some linting options.
```
lspconfig.gopls.setup({
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr)
    end,
    on_init = on_init,
    capabilities = capabilities,
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gotmpl", "gowork" },
    root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            completeUnimported = true,
            usePlaceholders = true,
            staticcheck = true,
        },
    },
})
```
## conform
Edit file `~/.config/nvim/lua/configs/conform.lua`. \
Add Golang entry to formatters_by_ft.
```
        go = { "gofumpt", "goimports-reviser", "golines" },
```
Between `formatters_by_ft` and `format_on_save` add entries to table `formatters`.
```
    formatters = {
        ["goimports-reviser"] = {
            prepend_args = { "-rm-unused" },
        },
        golines = {
            prepend_args = { "--max-len=80" },
        },
    },
```
## treesitter
Edit file `~/.config/nvim/lua/configs/treesitter.lua`. \
Add syntax highlighting for Go related filetypes.
```
        "go",
        "gomod",
        "gosum",
        "gotmpl",
        "gowork",
```
# Python
## lspconfig
Edit file `~/.config/nvim/lua/configs/lspconfig.lua`. \
Add `"pyright",` to `lspconfig.servers`.
```
    "pyright",
```
Add `"pyright"` to `default_servers`.
```
    "pyright",
```
## conform
Edit file `~/.config/nvim/lua/configs/conform.lua`. \
Add `python` `entries to formatters_by_ft` for isort and black.
```
        python = { "isort", "black" },
```
Between `formatters_by_ft` and `format_on_save` add entries to table `formatters`. \
Try to speed up black and to to make isort play better wtih black.
```
    formatters = {
        -- Python
        black = {
            prepend_args = {
                "--fast",
                "--line-length",
                "80",
            },
        },
        isort = {
            prepend_args = {
                "--profile",
                "black",
            },
        },
    },
```
## linting
Edit file `~/.config/nvim/lua/configs/lint.lua`. \
Add a python flake8 entry to `linters_by_ft` table.
```
    python = { "flake8" },
```
## treesitter
Edit file `~/.config/nvim/lua/configs/treesitter.lua`. \
Add syntax highlighting for Python.
```
        "python",
```
# Python (Dreams of Code)
## lspconfig
Edit file `~/.config/nvim/lua/configs/lspconfig.lua`. \
Add `"pyright",` to `lspconfig.servers`.
```
    "pyright",
```
Choose default or choose to disable type checks for pyright. \
(Choice 1) For default add `"pyright"` to `default_servers`.
```
    "pyright",
```
(Choice 2) Or to prevent duplicate linting from pyright and mypy add the following. This will not stop pyright unused variable hits. I was unable to turn this off.
```
lspconfig.pyright.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,

    settings = {
        python = {
            analysis = {
                typeCheckingMode = "off", -- Disable type checking diagnostics
            },
        },
    },
})
```
## conform
Edit file `~/.config/nvim/lua/configs/conform.lua`. \
Add a `python` entry to `formatters_by_ft` for isort and black.
```
        python = { "black" },
```
(Optional) Between `formatters_by_ft` and `format_on_save` add entries to table `formatters`. \
Try to speed up black and to to make isort play better wtih black.
```
    formatters = {
        -- Python
        black = {
            prepend_args = {
                "--fast",
                "--line-length",
                "80",
            },
        },
    },
```
## linting
Edit file `~/.config/nvim/lua/configs/lint.lua`. \
Add a python mypy and ruff entries to `linters_by_ft` table.
```
    python = { "mypy", "ruff" },
```
## treesitter
Edit file `~/.config/nvim/lua/configs/treesitter.lua`. \
Add syntax highlighting for Python.
```
        "python",
```
## dap
Edit file `~/.config/nvim/lua/plugins/init.lua`. \
We will add the entry for nvim-dap and also load it's config from `configs/dap.lua`
```
    {
        "mfussenegger/nvim-dap",
        config = function()
            require("configs.dap")
        end,
    },
```

Create `~/.config/nvim/lua/configs/dap.lua`. \
We are adding a leader + d + b key mapping to set a breakpoint. This key mapping is only set when dap is loaded that's why it's not in mappings.lua
```
local map = vim.keymap.set

map(
    "n",
    "<leader>db",
    "<cmd> DapToggleBreakpoint <CR>",
    { desc = "Toggle DAP Breakpoint" }
)

map(
    "n",
    "<leader>dr",
    "<cmd> DapContinue <CR>",
    { desc = "Start or continue DAP" }
)
```
## dap-ui
Edit file `~/.config/nvim/lua/plugins/init.lua`. \
we need an entry for both nvim-nio and nvim-dap-ui. Dap UI depends on both nvim-dap and nvim-nio. We will load it's configuration from `configs/dap-ui.lua`
```
    {
        "nvim-neotest/nvim-nio",
    },

    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            require("configs.dap-ui")
        end,
    },
```
Create `~/.config/nvim/lua/configs/dap-ui.lua`.
```
local dap = require("dap")
local dapui = require("dapui")
dapui.setup()

local map = vim.keymap.set
map(
    "n",
    "<leader>du",
    "<cmd>lua require('dapui').toggle()<CR>",
    { desc = "Toggle DAP UI" }
)

dap.listeners.after.attach.dapui_config = function()
    dapui.open()
end
dap.listeners.after.launch.dapui_config = function()
    dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
end
```
## dap-python
Edit file `~/.config/nvim/lua/plugins/init.lua`. \
We will have this load when `python` files are loaded. We will load it's configurations from `configs/dap-python.lua`.
```
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        dependencies = {
            "mfussenegger/nvim-dap",
            "rcarriga/nvim-dap-ui",
        },
        config = function()
            require("configs.dap-python")
        end,
    },
```
Create `~/.config/nvim/lua/configs/dap-python.lua`. \
We are setting the path to debugpy and passing that to the dap-python setup. We are also setting up key mappings that will only be loaded when `nvim-dap-python` is loaded.
```
local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
require("dap-python").setup(path)

local map = vim.keymap.set

map("n", "<leader>dpr", function()
    require("dap-python").test_method()
end, { desc = "Run DAP Python test method" })
```
## mason-nvim-dap
Edit file `~/.config/nvim/lua/plugins/init.lua`. \
We will used `mason-nvim-dap` to automagicly install debugpy. We will set it's loading to verylazy so it doesn't slowdown nvim startup time. It will also load its config from `configs/mason-dap.lua`
```
    {
        "jay-babu/mason-nvim-dap.nvim",
        event = "VeryLazy",
        config = function()
            require("configs.mason-dap")
        end,
    },
```
Create `~/.config/nvim/lua/configs/mason-dap.lua`. \
This mason-nvim-dap like other similar packages doesn't actually load it's packages on demand so we will just put the package into the ensured installed. Debugpy is actually refered to as `python`. Any package that is being installed automatically that you don't want to, can be added into the exclude table.
```
require("mason-nvim-dap").setup({
    ensure_installed = { "python" },
    automatic_installation = { exclude = {} },
})
```

# Odin
## lspconfig
Edit file `~/.config/nvim/lua/configs/lspconfig.lua`. \
Add `"ols",` to `lspconfig.servers`.
```
    "ols",
```
Add `"ols"` to `default_servers`.
```
    "ols",
```
## treesitter
Edit file `~/.config/nvim/lua/configs/treesitter.lua`. \
Add syntax highlighting for Odin.
```
        "odin",
```
# Haskell
## lspconfig
Edit file `~/.config/nvim/lua/configs/lspconfig.lua`. \
Add the haskell-language-server `"hls",` to `lspconfig.servers`. Unless it's installed on your system.
```
    "hls",
```
Add a setup for hls. This disables formatting.
```
lspconfig.hls.setup({
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr)
    end,
    on_init = on_init,
    capabilities = capabilities,
})
```
## linting
Edit file `~/.config/nvim/lua/configs/lint.lua`. \
Add a hlint entry to `linters_by_ft` table.
```
    haskell = { "hlint" },
```
## conform
Edit file `~/.config/nvim/lua/configs/conform.lua`. \
Add an entry to `formatters_by_ft` for ormolu or fourmolu. Also add stylish-haskell.\
Four spaces the right choice.
```
        haskell = { "fourmolu", "stylish-haskell" },
```
Two spaces the wrong choice.
```
        haskell = { "ormolu", "stylish-haskell" },
```
## treesitter
Edit file `~/.config/nvim/lua/configs/treesitter.lua`. \
Add syntax highlighting for Haskell.
```
        "haskell",
```
