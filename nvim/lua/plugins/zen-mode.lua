-- Distraction-free reading/writing, toggled per buffer
return {
	"folke/zen-mode.nvim",
	cmd = "ZenMode",
	keys = {
		{ "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle zen mode" },
	},
	opts = {
		window = {
			width = 80,
			options = {
				number = false,
				relativenumber = false,
				signcolumn = "no",
				colorcolumn = "",
			},
		},
		plugins = {
			gitsigns = { enabled = true }, -- hide git signs
		},
	},
}
