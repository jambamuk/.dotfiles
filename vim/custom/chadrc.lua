local M = {}
local override = require "custom.override"

M.plugins = {

  override = {
    ["hrsh7th/nvim-cmp"] = override.cmp,
    ["williamboman/mason.nvim"] = override.mason,
  },

  user = require "custom.plugins",
}


M.ui = {
  theme = "onedark",
}

M.mappings = require "custom.mappings"

return M
