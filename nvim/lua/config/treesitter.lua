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
  "nim",
}

local ts = require("nvim-treesitter")

ts.setup({})

vim.api.nvim_create_user_command("TSInstallConfigured", function()
	ts.install(ensure_installed)
end, {
	desc = "Install configured Tree-sitter parsers",
})

local function register_crystal_parser()
	require("nvim-treesitter.parsers").crystal = {
		install_info = {
			url = "https://github.com/crystal-lang-tools/tree-sitter-crystal",
			generate = false,
			generate_from_json = false,
			queries = "queries/nvim",
		},
	}
end

register_crystal_parser()

vim.api.nvim_create_autocmd("User", {
	pattern = "TSUpdate",
	callback = register_crystal_parser,
})

vim.treesitter.language.register("crystal", { "cr" })
