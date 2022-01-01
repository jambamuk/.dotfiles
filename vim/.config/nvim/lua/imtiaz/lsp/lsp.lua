-- hrsh7th/cmp-nvim-lsp compatibility with lsp-installer
-- https://github.com/williamboman/nvim-lsp-installer#user-content-setup
local lsp_installer = require("nvim-lsp-installer")
-- require("nvim-lsp-installer").settings({ log_level = vim.log.levels.DEBUG })

-- NOTE: JAVA REQUIRES JAVA 11
-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
    local opts = {
        on_attach = require("imtiaz.lsp.handlers").on_attach,
        capabilities = require("imtiaz.lsp.handlers").capabilities
    }

    if server.name == "sumneko_lua" then
        local sumneko_opts = require("imtiaz.lsp.settings.sumneko_lua")
        opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
    end

    if server.name == "jsonls" then
        local jsonls_opts = require("imtiaz.lsp.settings.jsonls")
        opts = vim.tbl_deep_extend("force", jsonls_opts, opts)
    end

    -- (optional) Customize the options passed to the server
    -- if server.name == "tsserver" then
    --     opts.root_dir = function() ... end
    -- end

    -- This setup() function is exactly the same as lspconfig's setup function.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    server:setup(opts)
end)

