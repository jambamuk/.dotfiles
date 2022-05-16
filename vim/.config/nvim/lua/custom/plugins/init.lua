return {
  -- User
  ["tpope/vim-fugitive"] = {},
  ["github/copilot.vim"] = {},
  ["tpope/vim-surround"] = {},
  ["mfussenegger/nvim-jdtls"] = {},
  ["nvim-telescope/telescope-fzf-native.nvim"] = {run = 'make'},
  ["wesleimp/stylua.nvim"] = {},
  ["jose-elias-alvarez/null-ls.nvim"] = {
    after = "nvim-lspconfig",
    config = function()
      require("custom.plugins.null-ls").setup()
    end,
  },
  ["nvim-telescope/telescope.nvim"] = {
    config = function ()
      require "plugins.configs.telescope"
      require("telescope").load_extension('fzf')
    end
  }
}
