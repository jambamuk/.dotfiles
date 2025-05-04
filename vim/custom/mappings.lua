local M = {}

M.telescope = {
  n = {
    ["<leader>fg"] = { "<cmd> Telescope live_grep <CR>", "   live grep" },
  }
}

M.misc = {
  i = {
    ["jk"] = {"<ESC>", "Escape"},
  },
  v = {
    ["J"] = {":m '>+1<CR>gv=gv", "move line up"},
    ["K"] = {":m '<-2<CR>gv=gv", "move line down"},
  }
}

return M
