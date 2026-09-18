return {
	"nvimdev/lspsaga.nvim",
	opts = {
		lightbulb = {
			virtual_text = false,
			enable_in_insert = false,
			debounce = 300,
			ignore = {
				clients = { "ocamllsp" },
			},
		},
	},
	config = function(_, opts)
		require("lspsaga").setup(opts)
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- optional
		"nvim-tree/nvim-web-devicons", -- optional
	},
}
