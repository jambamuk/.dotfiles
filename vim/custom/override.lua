local M = {}
M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "emmet-ls",
    "json-lsp",

    "rust-analyzer",
  },
}
M.cmp = function()
  local cmp = require "cmp"
  return {
    mapping = {
      ["<Tab>"] = cmp.config.disable,
      ["<S-Tab>"] = cmp.config.disable
    }
  }
end

return M
