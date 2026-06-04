vim.opt.rtp:append(vim.fn.stdpath("config") .. "/nvim-lspconfig")
vim.opt.rtp:append(vim.fn.stdpath("config") .. "/mason.nvim")
vim.opt.rtp:append(vim.fn.stdpath("config") .. "/mason-lspconfig.nvim")

-- Add the same capabilities to ALL server configurations.
-- Refer to :h vim.lsp.config() for more information.
vim.lsp.config("*", {
	capabilities = vim.lsp.protocol.make_client_capabilities(),
})

require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"eslint",
		"lua_ls",
		"pylsp",
		"rust_analyzer",
		-- npm install -g typescript typescript-language-server
		-- npm install -g vscode-langservers-extracted
		"ts_ls",
		-- npm install -g bash-language-server
		"bashls",
		-- npm install -g dockerfile-language-server-nodejs
		"dockerls",
		-- npm install -g eslint_d eslint prettier
		"graphql",
		"html",
		-- "htmx",
		"jqls",
		"jsonls",
		"ltex",
		"markdown_oxide",
		"phpactor",
		-- npm install -g yaml-language-server
		"yamlls",
		"ruff",
	},
})

-- custom LSP configurations
vim.lsp.config("golangci_lint_ls", require("config.lsp.golangci"))
vim.lsp.config("pylsp", require("config.lsp.python"))
vim.lsp.config("rust_analyzer", require("config.lsp.rust"))
vim.lsp.config("ts_ls", require("config.lsp.typescript"))
vim.lsp.config("yamlls", require("config.lsp.yamlls"))

-- enable manually installed LSP servers
vim.lsp.enable("gopls")
vim.lsp.enable("golangci_lint_ls")
vim.lsp.enable("nil_ls")
vim.lsp.enable("zls")
