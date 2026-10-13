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
	"crystal",
	"ocaml",
	"koka",
}

local ts = require("nvim-treesitter")

ts.setup({})

vim.api.nvim_create_user_command("TSInstallConfigured", function()
	ts.install(ensure_installed)
end, {
	desc = "Install configured Tree-sitter parsers",
})

local custom_parsers = {
	crystal = {
		url = "https://github.com/crystal-lang-tools/tree-sitter-crystal",
		generate = false,
		generate_from_json = false,
		queries = "queries/nvim",
	},
	koka = {
		url = "https://github.com/koka-community/tree-sitter-koka",
		queries = "queries",
	},
}

local function register_custom_parsers()
	local parsers = require("nvim-treesitter.parsers")
	for lang, install_info in pairs(custom_parsers) do
		parsers[lang] = { install_info = install_info }
	end
end

register_custom_parsers()

vim.api.nvim_create_autocmd("User", {
	pattern = "TSUpdate",
	callback = register_custom_parsers,
})

vim.treesitter.language.register("crystal", { "cr" })
