local null_ls = require "null-ls"
local b = null_ls.builtins

local sources = {

    b.formatting.prettierd.with { filetypes = { "html", "markdown", "css" } },
  b.formatting.deno_fmt,

  -- Lua
  b.formatting.stylua,
  b.diagnostics.luacheck.with { extra_args = { "--global vim" } },

  -- Shell
  b.formatting.shfmt,
  b.diagnostics.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
}

local M = {}

M.setup = function()
  null_ls.setup {
    debug = true,
    sources = sources,

    -- format on save
    on_attach = function(client, bufnr)
      if client.resolved_capabilities.document_formatting then
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>fm", "<cmd>lua vim.lsp.buf.formatting()<CR>", {})
        vim.api.nvim_buf_set_keymap(bufnr, "v", "<space>fM", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", {})
      end
    end,
  }
end

return M
