local ensure_installed = {
	"c",
	"lua",
	"vim",
	"query",
	"go",
	"gomod",
	"gowork",
	"rust",
	"bash",
	"json",
	"latex",
	"make",
	"python",
	"tsx",
	"javascript",
	"typescript",
	"html",
	"css",
	"markdown",
	"yaml",
	"toml",
	"jq",
	"sql",
	"dockerfile",
	"regex",
	"nix",
	"zig",
}

local ts = require("nvim-treesitter")

ts.setup({})

-- Launch TSInstallConfigured to install the configured parsers
vim.api.nvim_create_user_command("TSInstallConfigured", function()
	ts.install(ensure_installed)
end, {
	desc = "Install configured Tree-sitter parsers",
})
