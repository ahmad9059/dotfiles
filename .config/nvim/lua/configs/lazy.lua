return {
  -- Enable lazy loading by default for all plugins
  defaults = { lazy = true },

  -- Set default colorscheme to load at startup
  install = { colorscheme = { "nvchad" } },

  ui = {
    icons = {
      ft = "", -- Icon for file type
      lazy = "󰂠 ", -- Icon for lazy-loaded plugins
      loaded = "", -- Icon for loaded plugins
      not_loaded = "", -- Icon for not-loaded plugins
    },
  },

  performance = {
    rtp = {
      -- Disable unused or rarely used built-in Vim plugins for better startup time
      disabled_plugins = {
        "2html_plugin", -- HTML conversion plugin
        "tohtml", -- Alias for above
        "getscript", -- Legacy plugin script downloader
        "getscriptPlugin",
        "gzip", -- Handles .gz files
        "logipat", -- Legacy log pattern plugin
        "netrw", -- File explorer, replaced by better alternatives
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit", -- Extends % matching
        "tar", -- Handles .tar files
        "tarPlugin",
        "rrhelper", -- Remote runtime helper
        "spellfile_plugin", -- Handles additional spell files
        "vimball", -- Plugin archive format
        "vimballPlugin",
        "zip", -- Handles .zip files
        "zipPlugin",
        "tutor", -- Built-in Vim tutor
        "rplugin", -- Remote plugin interface
        "syntax", -- Disabling if using treesitter
        "synmenu", -- Syntax menu (GUI related)
        "optwin", -- Option window
        "compiler", -- Compiler plugin
        "bugreport", -- Generates bug reports
        "ftplugin", -- Filetype plugins (safe to disable if replaced manually)
      },
    },
  },
}
