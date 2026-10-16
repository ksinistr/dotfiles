return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{
			"MeanderingProgrammer/render-markdown.nvim",
			ft = { "markdown", "codecompanion" },
			-- don't duplicate heading/code icons in the sign column
			opts = { sign = { enabled = false } },
		},
	},
	opts = {
		strategies = {
			-- Change the default chat adapter
			chat = {
				adapter = "copilot",
			},
		},
		inline = {
			adapter = "copilot",
		},
		opts = {
			-- Set debug logging
			log_level = "DEBUG",
		},
	},
	-- keys = {
	-- 	{ "<leader>cl", "<cmd>CodeCompanion<CR>", desc = "Inline" },
	-- 	{ "<leader>cc", "<cmd>CodeCompanionChat<CR>", desc = "Chat" },
	-- },
	config = function()
		require("config.codecompanion")
	end,
}
