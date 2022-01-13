-- Setup nvim-cmp.
local cmp = require('cmp')

vim.opt.completeopt = {"menu", "menuone", "noselect"}

-- lspkind
local lspkind = require("lspkind")
-- local kind_icons = {
--     Class = "",
--     Color = "",
--     Constant = "",
--     Constructor = "",
--     Enum = "",
--     EnumMember = "",
--     Event = "",
--     Field = "",
--     File = "",
--     Folder = "",
--     Function = "",
--     Interface = "",
--     Keyword = "",
--     Method = "m",
--     Module = "",
--     Operator = "",
--     Property = "",
--     Reference = "",
--     Snippet = "",
--     Struct = "",
--     Text = "",
--     TypeParameter = "",
--     Unit = "",
--     Value = "",
--     Variable = ""
-- }

local kind_icons = {
    Class = "",
    Color = "",
    Constant = "",
    Constructor = "",
    Enum = "了",
    EnumMember = "",
    Event = "",
    Field = "",
    File = "",
    Folder = "",
    Function = "ﬦ",
    Operator = "",
    Interface = "ﰮ",
    Keyword = "",
    Method = "ƒ",
    Module = "",
    Property = "",
    Snippet = "﬌",
    Struct = "",
    Text = "",
    TypeParameter = "",
    Unit = "",
    Value = "",
    Variable = ""
}

-- Only needed if using the native lsp - if I don't do this need to use other stuff as well
lspkind.init({with_text = true, symbol_map = kind_icons})

cmp.setup({
    snippet = {
        expand = function(args) require("luasnip").lsp_expand(args.body) end
    },
    experimental = {
        -- I like the new menu better! Nice work hrsh7th
        native_menu = false,
        -- Let's play with this for a day or two
        ghost_text = false
    },
    mapping = {
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping {i = cmp.mapping.confirm {select = true}},
        ["<Right>"] = cmp.mapping {i = cmp.mapping.confirm {select = true}},
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), {"i", "s"}),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), {"i", "s"}),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item {
            behavior = cmp.SelectBehavior.Insert
        }, {"i"}),
        ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item {
            behavior = cmp.SelectBehavior.Insert
        }, {"i"})
    },
    sources = {
        {name = 'nvim_lsp'}, {name = 'buffer'}, {name = "path"},
        {name = "treesitter"}, {name = "cmdline"}
    },
    formatting = {
        format = lspkind.cmp_format {
            with_text = true,
            menu = {
                buffer = "[buf]",
                nvim_lsp = "[LSP]",
                nvim_lua = "[api]",
                path = "[path]",
                luasnip = "[snip]",
                gh_issues = "[issues]",
                tn = "[TabNine]"
            }
        }
    },
    documentation = {
        border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}
    },
    map_cr = true, --  map <CR> on insert mode
    map_complete = true, -- it will auto insert `(` (map_char) after select function or method item
    auto_select = true, -- automatically select the first item
    insert = false, -- use insert confirm behavior instead of replace
    map_char = { -- modifies the function or method delimiter by filetypes
        all = '(',
        tex = '{'
    }
})

-- require'cmp'.setup.cmdline(':', {sources = {{name = 'cmdline'}}})
cmp.setup.cmdline(":", {
    completion = {autocomplete = true},

    sources = cmp.config.sources({{name = "path"}}, {
        {name = "cmdline", max_item_count = 20, keyword_length = 1}
    })
})

-- require'cmp'.setup.cmdline('/', {sources = {{name = 'buffer'}}})
cmp.setup.cmdline("/", {
    completion = {autocomplete = true},
    sources = cmp.config.sources({{name = "nvim_lsp_document_symbol"}},
                                 {{name = "buffer"}})
})
