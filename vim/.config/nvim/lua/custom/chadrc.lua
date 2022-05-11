local M = {}

local userPlugins = require "custom.plugins"

M.plugins = {

   options = {
      lspconfig = {
         setup_lspconf = "custom.plugins.lspconfig",
      },

      statusline = {
         separator_style = "round",
      },
   },

   user = userPlugins,
}

M.ui = {
   theme = "onedark",
}

return M
