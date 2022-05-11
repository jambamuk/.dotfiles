local map = nvchad.map

map("n", "<leader>cc", ":Telescope <CR>")
map("n", "<leader>q", ":q <CR>")
map("n", "<leader>fg", "<cmd> :Telescope live_grep <CR>")

vim.g.copilot_assume_mapped = true
map("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })


