return {
  -- User
  ["tpope/vim-fugitive"] = {},
  -- ["github/copilot.vim"] = {},
  ["tpope/vim-surround"] = {},
  ["mfussenegger/nvim-jdtls"] = {},
  ["nvim-telescope/telescope-fzf-native.nvim"] = {run = 'make'},
  ["wesleimp/stylua.nvim"] = {},
  ["eslint/eslint"] = {},
  ["nvim-telescope/telescope.nvim"] = {
    config = function ()
      require "plugins.configs.telescope"
      require("telescope").load_extension('fzf')
    end
  },
  ["neovim/nvim-lspconfig"] = {
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.plugins.lspconfig"
    end,
  },
  ["nvim-treesitter/nvim-treesitter-context"] = { },
}

